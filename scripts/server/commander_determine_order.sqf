private ["_preferredElement", "_sideStr"];
params ["_hqMarker", "_towns", "_side", "_undecidedGroups"];

_sideStr = str _side;
_allObjectives = [];
_enemyTowns = [];
_hqPos = getMarkerPos _hqMarker;
_enemySides = [_side] call WF_getEnemySides;

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
      _allObjectives pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3, (_enemyStrength - _friendlyStrength) * 2];
    };
  };
} forEach (missionNameSpace getVariable (_sideStr + "locations"));

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

//------------------------------------------------------------------------------
// Handels Unit Purchase

{
  _wallet = _x getVariable "wallet";
  // count towns
  _numberOfTowns = 0;
  {
    if (_x getVariable "townOwner" == _side) then {
      _numberOfTowns = _numberOfTowns + 1;
    };
  } forEach _towns;
  _x setVariable ["wallet", (_wallet + 20 + (_numberOfTowns * 20))];

  if (!(isPlayer (leader _x)) && (count (units _x)) <= 10) then {
    [_x] call WF_purchaseAI;
  };
} forEach _undecidedGroups;

// End Unit Purchase
//------------------------------------------------------------------------------

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
        [_grp, _objective, 50] call WF_setWaypoint;
        _grp setVariable ["currentObjective", _objective];
      };

      _forceStrength = _forceStrength + ([units _grp] call WF_estimateForceStrength);
      _allPreferredgroups = _allPreferredgroups - [_grp];
    };
  } forEach _preferredObjectives;
};
