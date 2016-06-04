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
} forEach _teamGroups;
