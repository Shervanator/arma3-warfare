params ["_hqMarker", "_towns", "_side", "_teamGroups"];
_allObjectives = [];
_enemyTowns = [];
_hqPos = getMarkerPos _hqMarker;

{
  if ((_x getVariable "WF_townState") == "alert") then {
    _allObjectives pushBack [_x, (getPos _x) distanceSqr _hqPos];
  };
} forEach (missionNameSpace getVariable ((str _side) + "locations"));

_enemySides = [resistance, east, west] - [_side];
_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 0)) + "locations"));
_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 1)) + "locations"));
{
  _allObjectives pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3];
} forEach _enemyTowns;

{
  [_x, _allObjectives] call WF_findBestObjective;

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
    _units = missionNamespace getVariable ("WF_arrayTypes_" + (str _side) + "infantry");
    _unit = _units select (floor (random (count _units)));
    [_x, configName (_unit select 0), _unit select 1] call WF_buildUnit;
  };
} forEach _teamGroups;
