params ["_hqMarker", "_towns", "_side"];

_teamGroups = [];

{
  if (side _x == _side) then {
    _teamGroups pushBack _x;
  };
} forEach allGroups;

[_hqMarker, _towns, _side, _teamGroups] execFSM "scripts\server\fsm\commander.fsm";
