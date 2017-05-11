private ["_allObjectives", "_group", "_leaderPos", "_minPoints", "_totalPoints", "_preferredObjective", "_side", "_preferredElement"];
params ["_group", "_allObjectives", "_side"];

_leaderPos = getPos (leader _group);
_minPoints = -1;
_preferredObjective = objNull;

{
  _totalPoints = (_x select 1) + (_leaderPos distanceSqr (getPos (_x select 0))); // atm the importance of the objective (e.g. airport vs village) is not taken into account when calculating poitns.
  if ((_totalPoints < _minPoints) or (_minPoints == -1)) then {
    _minPoints = _totalPoints;
    _preferredObjective = _x select 0;
    _preferredElement = _x;
  };
} forEach _allObjectives;

(_preferredObjective getVariable ((str _side) + "preferredGroups")) pushBack [_group, _minPoints];

_preferredElement
