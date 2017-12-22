private [];
params ["_currentPos", "_targetPos"];

//------------------------------------------------------------------------------
// Get current zone
_currentZone = [_currentPos, false] call kyf_WF_getZones;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Get the zone of the ultimate objective
_targetZone = [_targetPos, false] call kyf_WF_getZone;
//------------------------------------------------------------------------------
_minPath = [_targetPos];

if ((_currentZone != -1) and (_targetZone != -1)) then { // i.e. Are we and our objective in a defined zone?

  _func = {
    private ["_path", "_zones", "_distance", "_nextZone", "_allZones"];
    params ["_path", "_zones", "_distance"];

    _nextZone = _zones select 0;
    if (_currentZone == _nextZone) then {
      _distance = _distance + (_currentPos distanceSqr (_path select 0));
      if ((_distance < _minDist) or (_minDist == -1)) then {
        _minDist = _distance;
        _minPath = _path;
      };
    } else {

      // If a zone has no access points (i.e. isolated island), then (_allZones select _nextZone) select 2 will return an empty array and hence the function will not call itself again
      {
        private _parentZone = _x select 1;

        if !(_parentZone in _zones) then { // i.e. We are not returning to a zone we have already been to, preventing going back and forth on the same path
          private _nextPos = _x select 0;
          [[_nextPos] append _path, [_parentZone] append _zones, _distance + ((_path select 0) distanceSqr _nextPos)] call _func;
        };
      } forEach ((_allZones select _nextZone) select 2); // zones are arranged in order, so that a zones' number corresponds to it's index in the zones' array. So _allZones select zoneNumber returns the the zone's varset
    };
  };

  _allZones = +kyf_WG_zones;
  _minDist = -1;
  [[_targetPos], [_targetZone], 0] call _func;
};

_minPath


[1, [[xRANGE], [yRANGE]], [acessPoints]] // each access point also has the zone it's located in along with it in the array
[access point pos, parent zone]
