private ["_hqMarker", "_towns", "_side", "_allSideGrps", "_allSidePlayerGrps", "_allSideAIGrps", "_preferredElement", "_sideStr"];
params ["_hqMarker", "_towns", "_side", "_allSideGrps", "_allSidePlayerGrps", "_allSideAIGrps"];

_sideStr = str _side;
_undecidedGroups = +_allSideGrps;
_allObjectives = [];
_enemyTowns = [];
_hqPos = getMarkerPos _hqMarker;
_grpTypeNumbers = [];
_enemySides = [_side] call WF_getEnemySides;
_spcSqdTypes = ["armor", "air"]; // MUST be in the same order as WFG_squadTypes in init.sqf! (except no first element, in this case "infantry")
_typesAndPortions = [["inf", 0]];
_allAllyTowns = missionNameSpace getVariable (_sideStr + "locations");

//------------------------------------------------------------------------------
// Commander income & money
_countVillage = {(_x getVariable "type") == "village"} count _allAllyTowns;
_countTown = {(_x getVariable "type") == "town"} count _allAllyTowns;
_countAirport = {(_x getVariable "type") == "airport"} count _allAllyTowns;
_income = WFG_baseIncome + (_countVillage * WFG_villageIncome) + (_countTown * WFG_townIncome) + (_countAirport * WFG_AirportIncome);
_money = (missionNamespace getVariable (_sideStr + "money")) + _income;
missionNamespace setVariable [_sideStr + "money", _money];
_incomePerMinute = (_income * 60) / WFG_commanderCycleTime;

// Has income changed? Used later on in unit purchase and construction decision making
_incomeChanged = false;
_prevIncome = missionNamespace getVariable (_sideStr + "income");
if (isNil "_prevIncome") then {
  missionNamespace setVariable [_sideStr + "income", _income];
  _incomeChanged = true;
} else {
  if (_income != _prevIncome) then {
    missionNamespace setVariable [_sideStr + "income", _income];
    _incomeChanged = true;
  };
};

// TEMP PLAYER MONEY!!!!!!!!
{
  _wallet = _x getVariable "wallet";
  _x setVariable ["wallet", (_wallet + _income / 5)];
} forEach _allSidePlayerGrps;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Calculate unit cap (UC)
_UC_countUnits = 0;
{
  _UC_countUnits = _UC_countUnits + (count (units _x));
} forEach _allSideGrps;

_unitCapPortion = _UC_countUnits / WFG_unitCap; //****???????
//------------------------------------------------------------------------------
// PURCHASE AI

_stopPurchaseLoop = false;
while {!_stopPurchaseLoop} do {
  // Build from que or select a new type?
  _runPurchaseAI = true;
  _buildQue = missionNameSpace getVariable (_sideStr + "buildQue");
  if (!(_incomeChanged) and !(isNil "_buildQue")) then {
    if ((count _buildQue) > 0) then {
      _runPurchaseAI = false;
      missionNamespace setVariable [_sideStr + "buildQue", nil];
    };
  } else {
    // Not sure this is necessary but the purpose is to ensure _buildQue is defined outside of the "if (_runPurchaseAI)" code bracket should it return as nil in the code above.
    _buildQue = [];
  };
  //

  if (_runPurchaseAI) then {
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    // Unit Purchase AI
    _buildUnitArray = [];
    if (_UC_countUnits < WFG_unitCap) then {
      private _excess = 0;
      // select best group type
      _strTemplate = +(missionNamespace getVariable (_sideStr + "allGrpTypes"));
      _numbTemplate = +(missionNamespace getVariable (_sideStr + "portionTemplate"));

      for [{private _i = 0; private _reference = -1; private ["_type", "_avgCost", "_size", "_minutes", "_portion", "_timeGap"]}, {_i < (count _strTemplate)}, {_i = _i + 1}] do {
        _type = _strTemplate select _i;
        _avgCost = missionNamespace getVariable (_type + _sideStr + "avgCost");
        _size = missionNamespace getVariable (_type + "AIGrpLowerLimit");

        if (!(isNil "_avgCost") and !(isNil "_size")) then { // Accounting for types like "other" that have undef avg cost and size
          _minutes = ((_avgCost * _size) - _money) / _incomePerMinute;
          if (_minutes < 0) then {
            _minutes = 0;
          };

          if (_reference == -1) then {
            _reference = _minutes; // Since _strTemplate is already in order of lowest avg cost to highest (done in server init), the first element will be the cheapest on avg and hence the reference.
          } else {
            _portion = _numbTemplate select _i;
            _timeGap = _minutes - _reference;
            if (_timeGap > 30) then {
              _excess = _excess + _portion;
              _numbTemplate set [_i, 0];
            } else {
              if (_timeGap > 15) then {
                _excess = _excess + (_portion / 2);
                _numbTemplate set [_i, _portion / 2];
              };
            };
          };
        };
      };

      // Redistribute any excess portions from above ---------------------------
      if (_excess > 0) then {
        private _sum = 1 - _excess;
        for [{private _i = 0; private ["_element"]}, {_i < (count _numbTemplate)}, {_i = _i + 1}] do {
          _element = _numbTemplate select _i;
          _numbTemplate set [_i, _element + ((_element / _sum) * _excess)];
        };
      };
      //------------------------------------------------------------------------

      _grpTypePortions = [];
      {
        _grpTypePortions pushBack 0;
      } forEach _numbTemplate;

      {
        private ["_type", "_index"];

        _type = _x getVariable "grpType";
        if (isNil "_type") then {
          _x setVariable ["grpType", "other"];
          _type = "other";
        };

        _index = _strTemplate find _type;
        _grpTypePortions set [_index, (_grpTypePortions select _index) + 1];
      } forEach _allSideAIGrps;

      _grpTypeToBuild = _strTemplate select ([_grpTypePortions, _numbTemplate] call WF_findHighestPercentGap);

      // Plan out selected group type
      _buildUnitArray = [_grpTypeToBuild, _sideStr, _money, _incomePerMinute, _UC_countUnits] call WF_AIunitSelection;
    };

    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Other options (such as construction) go here

    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Spend money on the best option
    _decisionPool = [];

    // Unit formula
    if ((count _buildUnitArray) > 0) then {
      _buildUnitArray pushBack "units";
      _buildUnitArray pushBack (((_buildUnitArray select 1) + 1) * _unitCapPortion * WFG_AIunitFactor); // The +1 is to avoid a zero minut build time skewing the formula (as x 0 = 0). WFG_AIunitFactor should be relatively high to enhance the effect of _unitCapPortion.
      _decisionPool pushBack _buildUnitArray;
    };

    // Other fomulae go here (e.g. construction formula)

    // Find the lowest points (i.e. "best" option)
    _bestPoints = -1;
    _buildQue = [];
    {
      if (((_x select ((count _x) - 1)) < _bestPoints) or (_bestPoints == -1)) then {
        _buildQue = _x;
      };
    } forEach _decisionPool;
  };

  // Build / purchase the best option
  switch (_buildQue select ((count _buildQue) - 2)) do {
    case "units": {
      _stopPurchaseLoop = [_buildQue select 0, _side, _buildQue select 2, _buildQue select 3, [_allSideGrps, _allSideAIGrps]] call WF_AIBuildUnit;
    };

    case "contruction": {
      //construct
    };

    default {
      _stopPurchaseLoop = true;
    };
  };

  if (_stopPurchaseLoop) then {
    missionNamespace setVariable [_sideStr + "buildQue", _buildQue];
  };
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// SEPERATE AI GROUPS
_teamAIGroups = [];
{
  if !(isPlayer (leader _x)) then {
    _teamAIGroups pushBack _x;
  };
} forEach _undecidedGroups;

//------------------------------------------------------------------------------
// RUN ANY PROCESSES RELATING TO NEW AI GROUPS (FROM PLAYER CONTROL)
{
  _wasPlayer = _x getVariable "wasPlayer";
  if !(isNil "_wasPlayer") then {
    if (_wasPlayer) then {
      // Necessary for vehicleLocki func
      {
        unassignVehicle _x;
      } forEach (units _x);

      _x setVariable ["wasPlayer", nil];
    };
  };
} forEach _teamAIGroups;

//------------------------------------------------------------------------------
// RUN MONITOR FUNCTIONS
_monitorFuncList = missionNamespace getVariable ("monitorFunctions" + _sideStr);
if !(isNil "_monitorFuncList") then {
  for [{private _i = 0; private ["_element"]}, {_i < (count _monitorFuncList)}, {_i = _i + 1}] do {
    _element = _monitorFuncList select _i;
    _i = [(_element select 2), _monitorFuncList, _i] call (_element select 1);
  };
};

//------------------------------------------------------------------------------
// RUN VEHICLE LOCK AND GET IN VEHICLE SCRIPTS
{
  private ["_grp"];
  _grp = _x;
  {
    if (canMove _x) then {
      if (isNil {_x getVariable "monitoredUnits"}) then {
        _x setVariable ["monitoredUnits", [leader _grp]];
      };

      [_x, _grp, _side] call WF_determineVehicleLock;
    };
  } forEach ([_grp, true] call WF_getGrpVehicles);
} forEach _teamAIGroups;

//------------------------------------------------------------------------------
// Handels Unit Money

// End Unit Money
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Unit Purchase AI
_incomePerMinute = (_income * 60) / WFG_commanderCycleTime;
_countTeamAIGroups = count _teamAIGroups;
if ((missionNamespace getVariable (_sideStr + "income") != _income) or (_countTeamAIGroups != missionNamespace getVariable ("count" + _sideStr + "AIgrps"))) then {

  missionNamespace setVariable ["count" + _sideStr + "AIgrps", _countTeamAIGroups];
  _remainingPortion = 1;
  {
    private ["_ideal", "_minutes"];
    _ideal = missionNameSpace getVariable (_x + "Portion");
    _minutes = (missionNamespace getVariable (_x + _sideStr + "avgCost")) / _incomePerMinute;
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
  private ["_wallet", "_grpType", "_grpComposition", "_template", "_countUnits", "_index", "_highestPercentGap", "_percentGap", "_buildUnit", "_unitInQue", "_notEnoughChips", "_buildUnitArray"];
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
        _minutes = ((missionNameSpace getVariable ("WF_cost_" + (configName (_buildUnitArray select _i)))) - _wallet) / _incomePerMinute;
        if ((_minutes > 50) and ((count _buildUnitArray) > 1)) then {
          _buildUnitArray deleteAt _i;
          _i = _i - 1;
        };
      };

      _buildUnit = _buildUnitArray select (floor (random (count _buildUnitArray)));
    } else {
      _buildUnit = _unitInQue;
    };

    _notEnoughChips = [_buildUnit, _x, _side] call WF_AIBuildUnit;
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
