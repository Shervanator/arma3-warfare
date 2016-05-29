_base = _this select 0;
_townArray = _this - [_base];
_minDist = (getMarkerPos _base) distance (getMarkerPos (_this select 1));
_minTown = _this select 1;
{
  _dist = (getMarkerPos _base) distance (getMarkerPos _x);
  if (_dist < _minDist) then {
    _minDist = _dist;
    _minTown = _x;
  };
} foreach _townArray;
hint format ["%1, %2", _minDist, _minTown];
