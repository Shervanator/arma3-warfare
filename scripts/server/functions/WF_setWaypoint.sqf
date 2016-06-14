params ["_group", "_towns", "_side", "_hqMarker"];

_leader = leader _group;
_position = getMarkerPos _hqMarker;

if (alive _leader) then {
  _position = getPos _leader;
};
_minTown = [_position, _towns, _side] call WF_findClosestObjective;
_group setVariable ["order", _minTown];

while {(count (waypoints _group) > 1)} do {
  deleteWaypoint ((waypoints _group) select 1);
};

_group addWaypoint [(getPos _minTown), 50];

if (isPlayer _leader) then {hint str (count (waypoints _group));};
