private ["_group", "_minObjective", "_radius", "_wp"];
params ["_group", "_minObjective", "_radius"];

while {(count (waypoints _group) > 1)} do {
  deleteWaypoint ((waypoints _group) select 1);
};

_wp = _group addWaypoint [(getPos _minObjective), _radius];
_wp setWaypointType "SAD";
_wp setWayPointStateMents ["true", "this execVM 'scripts\server\WP_reassignWaypoint.sqf'"];
