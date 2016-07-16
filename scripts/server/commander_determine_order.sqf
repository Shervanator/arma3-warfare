private ["_preferredElement", "_sideStr"];
params ["_hqMarker", "_towns", "_side", "_teamGroups"];

_sideStr = str _side;
_undecidedGroups = +_teamGroups;
_teamAIGroups = [];
_allObjectives = [];
_enemyTowns = [];
_hqPos = getMarkerPos _hqMarker;
_grpTypeNumbers = [];
_roundedGrpCount = 0;
_enemySides = [_side] call WF_getEnemySides;
_spcSqdTypes = ["armor", "air"]; // MUST be in the same order as WFG_squadTypes in init.sqf! (except no first element, in this case "infantry")
_typesAndPortions = [["inf", 0]];
_allAllyTowns = missionNameSpace getVariable (_sideStr + "locations");

{
  if (!(isPlayer (leader _x))) then {
    _teamAIGroups pushBack _x;
  };
} forEach _undecidedGroups;

//------------------------------------------------------------------------------
// Handels Unit Money

{
  _wallet = _x getVariable "wallet";
  _x setVariable ["wallet", (_wallet + WFG_baseIncome + ((count _allAllyTowns) * WFG_townIncome))];
} forEach _undecidedGroups;

// End Unit Money
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Unit Purchase AI
_income = WFG_baseIncome + ((count _allAllyTowns) * WFG_townIncome);
_incomePerMinut =(_income * 60) / WFG_commanderCycleTime;
_countTeamAIGroups = count _teamAIGroups;
if ((missionNamespace getVariable (_sideStr + "income") != _income) or (_countTeamAIGroups != missionNamespace getVariable ("count" + _sideStr + "grps"))) then {

  missionNamespace setVariable ["count" + _sideStr + "grps", _countTeamAIGroups];
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
    };
  } forEach _spcSqdTypes;
  _typesAndPortions set [0, ["inf", _remainingPortion]];

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

  {
    private ["_n0GrpsNeeded", "_grps", "_grp"];
    _n0GrpsNeeded = _x select 1;
    _grps = missionNameSpace getVariable (_sideStr + (_x select 0) + "Sqds");
    while {_n0GrpsNeeded > 0} do {
      _grp = _extraGrps select 0;
      _grps pushBack _grp;
      _grp setVariable ["grpType", (_x select 0)];
      _grp setVariable ["unitInQue", false];
      _extraGrps deleteAt 0;
      _n0GrpsNeeded = _n0GrpsNeeded - 1;
    };
  } forEach _needMore;
};

{
  private ["_wallet", "_grpType", "_grpComposition", "_template", "_countUnits", "_index", "_highestPercentGap", "_percentGap", "_buildUnit", "_unitInQue", "_notEnoughChips"];
  _notEnoughChips = false;

  while {(!_notEnoughChips and ((count (units _x)) <= WG_grpLimit))} do {
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
    private ["_objective", "_thershold", "_forceStrength", "_grp"];
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

      if ((_grp getVariable "currentObjective") != _objective) then {
        _grp setVariable ["currentObjective", _objective];
        [_grp, _objective, 50] call WF_setWaypoint;
      };

      _forceStrength = _forceStrength + ([units _grp] call WF_estimateForceStrength);
      _allPreferredgroups = _allPreferredgroups - [_grp];
    };
  } forEach _preferredObjectives;
};
