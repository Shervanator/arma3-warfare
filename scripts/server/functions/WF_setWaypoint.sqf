private ["_group", "_minObjective"];
params ["_group", "_minObjective"];

while {(count (waypoints _group) > 1)} do {
  deleteWaypoint ((waypoints _group) select 1);
};

_group addWaypoint [(getPos _minObjective), 50];
