params ["_currentPosition", "_towns", "_side"];

_minTown = objNull;
_minDist = -1;
{
  if ((_x getVariable "townOwner") != _side) then {
    _dist = _currentPosition distanceSqr (getPos _x);
    if ((_minDist == -1) or (_dist < _minDist)) then {
      _minDist = _dist;
      _minTown = _x;
    };
  };
} forEach _towns;

_minTown
