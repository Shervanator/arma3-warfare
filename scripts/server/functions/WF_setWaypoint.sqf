private ["_group", "_objectivePos", "_radius", "_wp", "_objective", "_side"];
params ["_group", "_objectivePos", "_radius"];

while {(count (waypoints _group) > 1)} do {
  deleteWaypoint ((waypoints _group) select 1);
};

_wp = _group addWaypoint [_objectivePos, _radius];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 20;

//------------------------------------------------------------------------------
//DEBUG

if (isNil "_group") then {
  "SCRIPT ERROR! A GROUP HAS BECOME UNDEFINED!" remoteExec ["hint", 0];
  diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
  diag_log "A GROUP HAS BECOME UNDEFINED!";
  diag_log ["Time ellapsed since mission start is:", serverTime];
  diag_log ["Position of objective is:", _objectivePos];
};

_objective = _group getVariable "currentObjective";
if (isNil "_objective") then {
  _side = side _group;
  "SCRIPT ERROR! A GROUP HAS NO DEFINED OBJECTIVE!" remoteExec ["hint", 0];
  diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
  diag_log "A GROUP HAS NO DEFINED OBJECTIVE!";
  diag_log ["Time ellapsed since mission start is:", serverTime];
  diag_log ["Position of objective is:", _objectivePos];
  diag_log ["Position of the grp leader is:", getPos (leader _group)];
  diag_log ["The group is:", _group];
  diag_log ["Side of the group is:", _side];
  diag_log ["Is the leader of the group a player?", isPlayer (leader _group)];
  diag_log ["how many alive members in the group?", {alive _x} count (units _group)];
  diag_log ["is this group in teamGroups?", _group in (missionNameSpace getVariable ((str _side) + "grps"))];
  diag_log ["The group type is", _group getVariable "grpType"];
  diag_log ["The number of teamGroups at this time is:", count (missionNameSpace getVariable ((str _side) + "grps"))];
  diag_log ["The number of AI teamGroups at this time is:", missionNameSpace getVariable ("count" + (str _side) + "AIgrps")];
};

//END DEBUG
//------------------------------------------------------------------------------

_wp setWayPointStateMents ["true", "[group this] execVM 'scripts\server\functions\WP_reassignWaypoint.sqf'"];
