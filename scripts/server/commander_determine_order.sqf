params ["_hqMarker", "_towns", "_side", "_teamGroups"];

{
  _currentOrder = _x getVariable "order";
  if ((isNil "_currentOrder")) then {
    [_x, _towns, _side, _hqMarker] call WF_setWaypoint;
  } else {
    if ((_currentOrder getVariable "townOwner") == _side) then {
      [_x, _towns, _side, _hqMarker] call WF_setWaypoint;
    };
  };
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
