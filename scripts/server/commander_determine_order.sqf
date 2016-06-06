params ["_hqMarker", "_towns", "_side", "_teamGroups"];

setWaypoint ={
  params ["_group", "_towns", "_side"];
  private ["_group", "_towns", "_side"];

  _leader = leader _group;
  _position = getMarkerPos _hqMarker;

  if (alive _leader) then {
    _position = getPos _leader;
  };
  _minTown = [_position, _towns, _side] call WF_findClosestObjective;
  _group setVariable ["order", _minTown];

  while {(count (waypoints _group)) > 0} do {
    deleteWaypoint [_group, 0];
  };

  _group addWaypoint [(getPos _minTown), 50]
};

{
  _currentOrder = _x getVariable "order";
  if ((isNil "_currentOrder")) then {
    [_x, _towns, _side] call setWaypoint;
  } else {
    if ((_currentOrder getVariable "townOwner") == _side) then {
      [_x, _towns, _side] call setWaypoint;
    };
  };
  _wallet = _x getVariable "wallet";
  _x setVariable ["wallet", (_wallet + 20)];

  if (!(isPlayer (leader _x)) && (count (units _x)) <= 10) then {
    if (random 1 <= 0.5) then {
      [_x, "B_soldier_LAT_F"] call WF_buildUnit;
    } else {
      [_x, "O_G_Soldier_F"] call WF_buildUnit;
    };
  };
} forEach _teamGroups;
