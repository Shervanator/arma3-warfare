// Function for identifying which of the predefined zones a position ([x,y]) is in. Depending on the the param "_returnFull", it returns the complete
// zone var set (if == true) or just the zone numerical identifyer (if == false), which is an integer identifying the zone. If no zone is found, either -1 or
// and empty array [] are returned, again depending on what _returnFull is.

private ["_pos", "_returnFull", "_return", "_currentZone", "_zoneNumber", "_allZones", "_xVar", "_yVar", "_zoneRange", "_xRangeMin", "_xRangeMax", "_yRangeMin", "_yRangeMax"];
params ["_pos", "_returnFull"];

_return = -1;
_currentZone = []; // Returning [] means that the unit/pos is not in a defined zone
_zoneNumber = -1; // Returning -1 means that the unit/pos is not in a defined zone
_allZones = +kyf_WG_zones;
_xVar = _pos select 0;
_yVar = _pos select 1;

{
  _zoneRange = _x select 1;
  _xRangeMin = (_zoneRange select 0) select 0;
  _xRangeMax = (_zoneRange select 0) select 1;
  _yRangeMin = (_zoneRange select 1) select 0;
  _yRangeMax = (_zoneRange select 1) select 1;

  if (((_xVar >= _xRangeMin) and (_xVar <= _xRangeMax)) and ((_yVar >= _yRangeMin) and (_yVar <= _yRangeMax))) exitWith {
    _currentZone = _x;
    _zoneNumber = _currentZone select 0;
  };

} forEach _allZones;

if (_returnFull) then {
  _return = _currentZone;
} else {
  _return = _zoneNumber;
};

_return
