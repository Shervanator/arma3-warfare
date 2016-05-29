params ["_hqMarker", "_towns", "_side"];

_minTown = "";
_minDist = -1;
{
  _dist = (getMarkerPos _hqMarker) distanceSqr (getMarkerPos _x);
  if ((_minDist == -1) or (_dist < _minDist)) then {
    _minDist = _dist;
    _minTown = _x;
  };
} forEach _towns;

//_minTown remoteExec ["hint", 0, true];
{
  if (side _x == _side) then {
    _x addWaypoint [(getMarkerPos _mintown), 50];
  };
} forEach allGroups;
