params ["_hqMarker", "_towns", "_side"];

_minTown = "";
_minDist = -1;
{
  _dist = (getMarkerPos _hqMarker) distanceSqr (getPos _x);
  if ((_minDist == -1) or (_dist < _minDist)) then {
    _minDist = _dist;
    _minTown = _x;
  };
} forEach _towns;

{
  if (side _x == _side) then {
    _x addWaypoint [(getPos _mintown), 50];
  };
} forEach allGroups;
