private ["_allObjectives", "_group", "_leaderPos", "_minDist", "_minObjective"];
params ["_group", "_allObjectives"];

_leaderPos = getPos (leader _group);
_minDist = -1;
_minObjective = objNull;

{
  _totalDist = (_x select 1) + (_leaderPos distanceSqr (getPos (_x select 0)));
  if ((_totalDist < _minDist) or (_minDist == -1)) then {
    _minDist = _totalDist;
    _minObjective = _x select 0;
  };
} forEach _allObjectives;

_currentOrder = _group getVariable "order";
if (isNil "_currentOrder") then {
  _group setVariable ["order", _minObjective];
  [_group, _minObjective] call WF_setWaypoint;
} else {
    if  (_currentOrder != _minObjective) then {
      _group setVariable ["order", _minObjective];
      [_group, _minObjective] call WF_setWaypoint;
    };
};
