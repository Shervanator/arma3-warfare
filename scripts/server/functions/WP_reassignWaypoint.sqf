private ["_group", "_radius", "_enemyForces", "_knowAny", "_side", "_objective", "_trg"];
params ["_group"];

_side = side _group;
_objective = _group getVariable "currentObjective";
if (isNil "_objective") then {hint str _side;} else {
  _trg = _objective getVariable "alertZone";
  _enemyForces = [list _trg, [_side] call WF_getEnemySides] call WF_unitSideFilter;
  _radius = (triggerArea _trg) select 0;

  if ((count _enemyForces) > 0) then {
    _knowAny = false;
    {
      if ((_side knowsAbout _x) > 0) exitWith {
        [_group, _x, 10] call WF_setWaypoint;
        _knowAny = true;
      };
    } forEach _enemyForces;

    if (!_knowAny) then {
      [_group, _objective, _radius] call WF_setWaypoint;
    };
  } else {
    [_group, _objective, _radius] call WF_setWaypoint;
  };
};
