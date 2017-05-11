private ["_group", "_objectivePos", "_radius", "_wp", "_objective", "_side"];
params ["_group", "_objectivePos", "_radius"];

while {(count (waypoints _group) > 1)} do {
  deleteWaypoint ((waypoints _group) select 1);
};

_wp = _group addWaypoint [_objectivePos, _radius];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 20;
/*_wp setWayPointStateMents ["true", "[group this] execVM 'scripts\server\functions\WP_reassignWaypoint.sqf'"];*/
_wp setWayPointStateMents ["true", "deleteWaypoint [group this, currentWaypoint (group this)]"];
