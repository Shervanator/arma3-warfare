private ["_preferredElement", "_sideStr"];
params ["_hqMarker", "_towns", "_side", "_teamGroups"];

_sideStr = str _side;
_undecidedGroups = +_teamGroups;
_allObjectives = [];
_enemyTowns = [];
_hqPos = getMarkerPos _hqMarker;
_grpTypeNumbers = [];
_enemySides = [_side] call WF_getEnemySides;
_spcSqdTypes = ["armor", "air"]; // MUST be in the same order as WFG_squadTypes in init.sqf! (except no first element, in this case "infantry")
_typesAndPortions = [["inf", 0]];
_allAllyTowns = missionNameSpace getVariable (_sideStr + "locations");

//------------------------------------------------------------------------------
//DEBUG

if ((count _teamGroups) != 10) then {
  _debug_aliveGrps = [];
  _debug_playerGrps = [];
  "SCRIPT ERROR! THE NUMBER OF TEAM GRPS HAS CHANGED!" remoteExec ["hint", 0];
  diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
  diag_log "THE NUMBER OF TEAM GRPS HAS CHANGED!";
  diag_log ["time since mission started:", serverTime];
  diag_log ["side of the groups", _side];
  diag_log ["Number of groups that are supposed to be", 10];
  diag_log ["Number of groups that actually are", count _teamGroups];
  diag_log ["list of all the groups", _teamGroups];
  diag_log ["Number of Grps with dead leaders", {alive (leader _x)} count _teamGroups];
  {
    if (({alive _x} count (units _x)) == 0) then {
      _debug_aliveGrps pushBack _x;
    };

    if (isPlayer (leader _x)) then {
      _debug_playerGrps pushBack _x;
    };
  } forEach _teamGroups;
  diag_log ["List of Groups with no members", _debug_aliveGrps];
  diag_log ["List of player groups that are still in teamGroups:", _debug_playerGrps];
};

//END DEBUG
//------------------------------------------------------------------------------

_teamAIGroups = [];
_grpControlAI = [];
_grpControlPlayer = [];
{
  private ["_grpControlChange"];
  _prevStatus = _x getVariable "isLeaderPlayer";
  if (isNil "_prevStatus") then {
    _x setVariable ["isLeaderPlayer", true];
    _prevStatus = true;
  };

  _grpControlChange = _x getVariable "grpControlChange";
  if (isNil "_grpControlChange") then {
    _x setVariable ["grpControlChange", false];
  };

  if (!(isPlayer (leader _x))) then {
    _teamAIGroups pushBack _x;
    if (_prevStatus == true) then {
      _x setVariable ["isLeaderPlayer", false];
      _x setVariable ["grpControlChange", true];
      _grpControlAI pushBack _x;
    };
  } else {
    if (_prevStatus == false) then {
      _x setVariable ["isLeaderPlayer", true];
      _grpControlPlayer pushBack _x;
    };
  };
} forEach _undecidedGroups;

//------------------------------------------------------------------------------
// Handles AI group transport
{
  private ["_grp"];
  _grp = _x;
  {
    private ["_vehicle", "_assignedVehicle", "_element"];
    _element = [];
    _vehicle = vehicle _x;
    if (_vehicle != _x) then {
      if (canMove _vehicle) then {
        _element pushBack _vehicle;
        _element pushBack [leader _grp];
        _element pushBack _grp;
      };
    } else {
      _assignedVehicle = assignedVehicle _x;
      if !(isNull _assignedVehicle) then {
        if (canMove _assignedVehicle) then {
          _element pushBack _assignedVehicle;
          _element pushBack [leader _grp];
          _element pushBack _grp;
        };
      };
    };

    if ((count _element) > 2) then {
      (missionNamespace getVariable (_sideStr +  "ai_vehicle_transport_checklist")) pushBackUnique _element;
    };
  } forEach (units _x);
} forEach _grpControlAI;

{
  {
    private ["_vehicle", "_checklist"];
    _vehicle = objNull;

    if (vehicle _x != _x) then {
      _vehicle = vehicle _x;
    } else {
      if !(isNull (assignedVehicle _x)) then {
        _vehicle = assignedVehicle _x;
      };
    };

    if !(isNull _vehicle) then {
      _checklist = missionNamespace getVariable (_sideStr +  "ai_vehicle_transport_checklist");
      {
        if ((_x select 0) isEqualTo _vehicle) exitWith {

        };
      } forEach _checklist;
    };
  } forEach (units _x);
} forEach _grpControlPlayer;

{
  private ["_grp"];
  _grp = _x select 2;
  [_x select 0, _x select 1, _grp, (_grp getVariable "grpControlChange")] call WF_determineVehicleLock;
  if ((_grp getVariable "grpControlChange") == true) then {
    _grp setVariable ["grpControlChange", false];
  };
} forEach (missionNamespace getVariable (_sideStr +  "ai_vehicle_transport_checklist"));

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Handels Unit Money
_countVillage = {(_x getVariable "type") == "village"} count _allAllyTowns;
_countTown = {(_x getVariable "type") == "town"} count _allAllyTowns;
_countAirport = {(_x getVariable "type") == "airport"} count _allAllyTowns;
_income = WFG_baseIncome + (_countVillage * WFG_villageIncome) + (_countTown * WFG_townIncome) + (_countAirport * WFG_AirportIncome);
{
  _wallet = _x getVariable "wallet";
  _x setVariable ["wallet", (_wallet + _income)];
} forEach _undecidedGroups;

// End Unit Money
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Unit Purchase AI
_incomePerMinut = (_income * 60) / WFG_commanderCycleTime;
_countTeamAIGroups = count _teamAIGroups;
if ((missionNamespace getVariable (_sideStr + "income") != _income) or (_countTeamAIGroups != missionNamespace getVariable ("count" + _sideStr + "AIgrps"))) then {

  missionNamespace setVariable ["count" + _sideStr + "AIgrps", _countTeamAIGroups];
  _remainingPortion = 1;
  {
    private ["_ideal", "_minutes"];
    _ideal = missionNameSpace getVariable (_x + "Portion");
    _minutes = (missionNamespace getVariable (_x + _sideStr + "avgCost")) / _incomePerMinut;
    if (_minutes < 50) then {
      if (_minutes > 35) then {
        _typesAndPortions pushBack [_x, _ideal * 0.5];
        _remainingPortion = _remainingPortion - (_ideal * 0.5);
      } else {
        _typesAndPortions pushBack [_x, _ideal];
        _remainingPortion = _remainingPortion - _ideal;
      };
    } else {
      _typesAndPortions pushBack [_x, 0];
    };
  } forEach _spcSqdTypes;
  _typesAndPortions set [0, ["inf", _remainingPortion]];

  _roundedGrpCount = 0;
  {
    private ["_n"];
    _n = round (_countTeamAIGroups * (_x select 1));
    _grpTypeNumbers pushBack [_x select 0, _n];
    _roundedGrpCount = _roundedGrpCount + _n;
  } forEach _typesAndPortions;

  while {_roundedGrpCount != _countTeamAIGroups} do {
    private ["_n", "_element", "_index", "_remainingGroups"];
    _remainingGroups = _roundedGrpCount - _countTeamAIGroups;

    if ((round (_remainingGroups * ((_typesAndPortions select 0) select 1)) == 0) or ((abs _remainingGroups) == 1)) then {

      if (_remainingGroups > 0) then {
        _index = (count _grpTypeNumbers) - 1;
        while {_remainingGroups != 0} do {
          _element = (_grpTypeNumbers select _index) select 1;
          if (_element > 0) then {
            _grpTypeNumbers set [_index, [(_grpTypeNumbers select _index) select 0, _element - 1]];
          };
          if (_index == 0) then {
            _index = (count _grpTypeNumbers) - 1;
          } else {
            _index = _index - 1;
          };

          _remainingGroups = _remainingGroups - 1;
        };
      } else {
        _index = 0;
        while {_remainingGroups != 0} do {
          _element = (_grpTypeNumbers select _index) select 1;
          _grpTypeNumbers set [_index, [(_grpTypeNumbers select _index) select 0, _element + 1]];

          if (_index == (count _grpTypeNumbers) - 1) then {
            _index = 0;
          } else {
            _index = _index + 1;
          };

          _remainingGroups = _remainingGroups + 1;
        };
      };
      _roundedGrpCount = _countTeamAIGroups;
    } else {
      _index = 0;
      {
        _element = (_grpTypeNumbers select _index) select 1;
        _n = round (_remainingGroups * (_x select 1));
        _grpTypeNumbers set [_index, [(_grpTypeNumbers select _index) select 0, _element - _n]];
        _roundedGrpCount = _roundedGrpCount - _n;
        _index = _index + 1;
      } forEach _typesAndPortions;
    };
  };

  missionNameSpace setVariable [_sideStr + "infSqds", []];
  missionNameSpace setVariable [_sideStr + "armorSqds", []];
  missionNameSpace setVariable [_sideStr + "airSqds", []];
  {
    private ["_grpType"];
    _grpType = _x getVariable "grpType";
    if (isNil "_grpType") then {
      _grpType = "inf";
      _x setVariable ["grpType", "inf"];
    };
    (missionNameSpace getVariable (_sideStr + _grpType + "Sqds")) pushBack _x;
  } forEach _teamAIGroups;

  _needMore = [];
  _extraGrps = [];
  {
    private ["_grps"];
    _grps = missionNamespace getVariable (_sideStr + (_x select 0) + "Sqds");
    _grpDifference = (_x select 1) - (count _grps);
    if (_grpDifference != 0) then {
      if (_grpDifference > 0) then {
        _needMore pushBack [(_x select 0), _grpDifference];
      } else {
        while {_grpDifference < 0} do {
          _randomN0 = floor (random (count _grps));
          _extraGrps pushBack (_grps select _randomN0);
          _grps deleteAt _randomN0;  // I think since this modifies the original array i don't need to use setVar again to save the new array (?)
          _grpDifference = _grpDifference + 1;
        };
      };
    };
  } forEach _grpTypeNumbers;

  //------------------------------------------------------------------------------
  //DEBUG
  _debug_countNeedMore = 0;
  {
    _debug_countNeedMore = _debug_countNeedMore + (_x select 1);
  } forEach _needMore;
  if (_debug_countNeedMore != (count _extraGrps)) then {
    _debug_aliveGrps = [];
    "SCRIPT ERROR! needMore != extraGrps" remoteExec ["hint", 0];
    diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
    diag_log "needMore != extraGrps!";
    diag_log ["time since mission started:", serverTime];
    diag_log ["side of the groups", _side];
    diag_log ["Number of needed groups", _debug_countNeedMore];
    diag_log ["Number of extra groups available", count _extraGrps];
    diag_log ["list of the extra groups", _extraGrps];
    diag_log ["list of types we need more groups for", _needMore];
    diag_log ["Number of extra grps with dead leaders", {alive (leader _x)} count _extraGrps];
    diag_log ["Ideal grp proportions or typesAndPortions:", _typesAndPortions];
    diag_log ["Ideal grp comp numbers or grpTypeNumbers:", _grpTypeNumbers];
    diag_log ["List of inf sqds:", missionNameSpace getVariable (_sideStr + "infSqds")];
    diag_log ["List of armor sqds:", missionNameSpace getVariable (_sideStr + "armorSqds")];
    diag_log ["List of air sqds:", missionNameSpace getVariable (_sideStr + "airSqds")];
    diag_log ["Income:", _income];
    diag_log ["List of allied towns:", _allAllyTowns];
    {
      if (({alive _x} count (units _x)) == 0) then {
        _debug_aliveGrps pushBack _x;
      };
    } forEach _extraGrps;
    diag_log ["List of extra groups with no members", _debug_aliveGrps];
  };

  //END DEBUG
  //------------------------------------------------------------------------------

  if ((count _needMore) > 0) then {
    {
      private ["_n0GrpsNeeded", "_grps", "_grp"];
      _n0GrpsNeeded = _x select 1;
      _grps = missionNameSpace getVariable (_sideStr + (_x select 0) + "Sqds");
      while {_n0GrpsNeeded > 0} do {
        _grp = _extraGrps select 0;

        //------------------------------------------------------------------------------
        //DEBUG

        if (isNil "_grp") then {
          _debug_aliveGrps = [];
          "SCRIPT ERROR! extraGrps select 0 is undefined!" remoteExec ["hint", 0];
          diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
          diag_log "extraGrps select 0 is undefined!";
          diag_log ["time since mission started:", serverTime];
          diag_log ["side of the groups", _side];
          diag_log ["Number of extra groups available", count _extraGrps];
          diag_log ["list of the extra groups", _extraGrps];
          diag_log ["list of types we need more groups for", _needMore];
          diag_log ["Number of extra grps with dead leaders", {alive (leader _x)} count _extraGrps];
          diag_log ["Ideal grp proportions or typesAndPortions:", _typesAndPortions];
          diag_log ["Ideal grp comp numbers or grpTypeNumbers:", _grpTypeNumbers];
          diag_log ["List of inf sqds:", missionNameSpace getVariable (_sideStr + "infSqds")];
          diag_log ["List of armor sqds:", missionNameSpace getVariable (_sideStr + "armorSqds")];
          diag_log ["List of air sqds:", missionNameSpace getVariable (_sideStr + "airSqds")];
          diag_log ["Income:", _income];
          diag_log ["List of allied towns:", _allAllyTowns];
          {
            if (({alive _x} count (units _x)) == 0) then {
              _debug_aliveGrps pushBack _x;
            };
          } forEach _extraGrps;
          diag_log ["List of extra groups with no members", _debug_aliveGrps];
        };

        //END DEBUG
        //------------------------------------------------------------------------------

        _grps pushBack _grp;
        _grp setVariable ["grpType", (_x select 0)];
        _grp setVariable ["unitInQue", false];
        _extraGrps deleteAt 0;
        _n0GrpsNeeded = _n0GrpsNeeded - 1;
      };
    } forEach _needMore;
  };
};

{
  private ["_wallet", "_grpType", "_grpComposition", "_template", "_countUnits", "_index", "_highestPercentGap", "_percentGap", "_buildUnit", "_unitInQue", "_notEnoughChips"];
  _notEnoughChips = false;

  while {(!_notEnoughChips and ((count (units _x)) < WG_grpLimit))} do {
    _unitInQue = _x getVariable "unitInQue";
    if (isNil "_unitInQue") then {
      _unitInQue = false;
      _x setVariable ["unitInQue", false];
    };

    if (_unitInQue isEqualTo false) then {
      _wallet = _x getVariable "wallet";
      _grpType = _x getVariable "grpType";
      _grpComposition = [units _x] call WF_getGrpCompNumbers;
      _countUnits = count (units _x);
      _template = missionNameSpace getVariable (_sideStr + _grpType + "Template");
      _buildUnitArray = +((_template select 0) select 2);
      _highestPercentGap = 0;
      _index = 0;
      {
        _portion = (_x select 1) / _countUnits;
        _percentGap = ((_template select _index) select 1) - _portion;
        if (_percentGap > _highestPercentGap) then {
          _highestPercentGap = _percentGap;
          _buildUnitArray = +((_template select _index) select 2);
        };

        _index = _index + 1;
      } forEach _grpComposition;

      for [{private _i = 0; private "_minutes"},{_i <= (count _buildUnitArray - 1)}, {_i = _i + 1}] do {
        _minutes = ((missionNameSpace getVariable ("WF_cost_" + (configName (_buildUnitArray select _i)))) - _wallet) / _incomePerMinut;
        if ((_minutes > 50) and ((count _buildUnitArray) > 1)) then {
          _buildUnitArray deleteAt _i;
          _i = _i - 1;
        };
      };

      _buildUnit = _buildUnitArray select (floor (random (count _buildUnitArray)));
    } else {
      _buildUnit = _unitInQue;
    };

    _notEnoughChips = [_buildUnit, _x] call WF_AIBuildUnit;
  };
} forEach _teamAIGroups;
//------------------------------------------------------------------------------

{
  if ((_x getVariable "WF_townState") == "alert") then {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;

    _friendlyForces = [];
    {
      _friendlyForces append (units _x);
    } forEach (_x getVariable "patrolForces");

    _enemyStrength = [_enemyForces] call WF_estimateForceStrength;
    _friendlyStrength = [_friendlyForces] call WF_estimateForceStrength;
    if (_enemyStrength > _friendlyStrength) then {
      _allObjectives pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3, (_enemyStrength - _friendlyStrength) * 1.2];
    };
  };
} forEach _allAllyTowns;

_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 0)) + "locations"));
_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 1)) + "locations"));
{
  _enemyStrength = 0;
  if ((_x getVariable "WF_townState") == "alert") then {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;
    _enemyStrength = [_enemyForces] call WF_estimateForceStrength;
  } else {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;
    _enemyStrength = ([_enemyForces] call WF_estimateForceStrength) + (_x getVariable "patrolForceStrength");
  };

  _allObjectives pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3, (_enemyStrength) * 2];
} forEach _enemyTowns;

{
  (_x select 0) setVariable [(_sideStr + "preferredGroups"), []];
} forEach _allObjectives;

while {(count _undecidedGroups) > 0} do {

_preferredObjectives = [];

  {
    _preferredObjectives pushBackUnique ([_x, _allObjectives, _side] call WF_findBestObjective);
  } forEach _undecidedGroups;

  _undecidedGroups = [];

  {
    private ["_objective", "_thershold", "_forceStrength", "_grp", "_objectivePos"];
    _objective = _x select 0;
    _thershold = _x select 2;
    _forceStrength = 0;
    _allPreferredgroups = _objective getVariable (_sideStr + "preferredGroups");
    //if thershold has not been reached???

    while {(count _allPreferredgroups) > 0} do {
      if ((count _allObjectives > 1) and (_forceStrength > _thershold)) exitWith {
        _allObjectives = _allObjectives - [_x];
        _undecidedGroups append _allPreferredgroups;
      };

      _minPoints = -1;
      {
        if (((_x getVariable "objectivePoints") < _minPoints) or (_minPoints == -1)) then {
          _minPoints = _x getVariable "objectivePoints";
          _grp = _x;
        };
      } forEach _allPreferredgroups;

      if ((_grp getVariable "currentObjective") == _objective) then {
        if (count (waypoints _grp) <= 1) then {
          [_grp, _objective] call WF_reassignWaypoint;
        };
      } else {
        _grp setVariable ["currentObjective", _objective];
        _objectivePos = getPos _objective;
        [_grp, _objectivePos, 10] call WF_setWaypoint;
      };

      _forceStrength = _forceStrength + ([units _grp] call WF_estimateForceStrength);
      _allPreferredgroups = _allPreferredgroups - [_grp];
    };
  } forEach _preferredObjectives;
};
