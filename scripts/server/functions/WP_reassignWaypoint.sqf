private ["_group", "_radius", "_enemyForces", "_knowAny", "_side", "_objective", "_trg", "_pos"];
params ["_group"];

_side = side _group;
_objective = _group getVariable "currentObjective";

//------------------------------------------------------------------------------
//DEBUG

if (isNil "_objective") then {
  _side = side _group;
  "SCRIPT ERROR! A GROUP HAS NO DEFINED OBJECTIVE! (reassignWaypoint.sqf)" remoteExec ["hint", 0];
  diag_log "ATTENTION: SCRIPT ERROR! LOOK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
  diag_log "A GROUP HAS NO DEFINED OBJECTIVE! (reassignWaypoint.sqf)";
  diag_log ["Time ellapsed since mission start is:", serverTime];
  diag_log ["Position of the grp leader is:", getPos (leader _group)];
  diag_log ["The group is:", _group];
  diag_log ["Side of the group is:", _side];
  diag_log ["Is the leader of the group a player?", isPlayer (leader _group)];
  diag_log ["how many alive members in the group?", {alive _x} count (units _group)];
  diag_log ["is this group in teamGroups?", _group in (missionNameSpace getVariable ((str _side) + "grps"))];
  diag_log ["The group type is", _group getVariable "grpType"];
  diag_log ["The number of teamGroups at this time is:", count (missionNameSpace getVariable ((str _side) + "grps"))];
  diag_log ["The number of AI teamGroups at this time is:", missionNameSpace getVariable ("count" + (str _side) + "AIgrps")];
  diag_log ["List of allied towns:", missionNameSpace getVariable ((str _side) + "locations")];
};

//END DEBUG
//------------------------------------------------------------------------------

_trg = _objective getVariable "alertZone";
_enemyForces = [list _trg, [_side] call WF_getEnemySides] call WF_unitSideFilter;
_radius = (triggerArea _trg) select 0;
_pos = getPos _objective;

if ((count _enemyForces) > 0) then {
  _knowAny = false;
  {
    if (((_side knowsAbout _x) > 0) and !(surfaceIsWater (getPos _x))) exitWith {
      _pos = getPos _x;
      _pos set [2, 0];
      [_group, _pos, 5] call WF_setWaypoint;
      _knowAny = true;
    };
  } forEach _enemyForces;

  if (!_knowAny) then {
    [_group, _pos, _radius] call WF_setWaypoint;
  };
} else {
  [_group, _pos, _radius] call WF_setWaypoint;
};
