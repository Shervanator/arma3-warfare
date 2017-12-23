private ["_pos", "_radius", "_safePos", "_closeRoads"];
params ["_pos", "_radius"];

_safePos = [];
// preferably find a pos on a road if possible
_closeRoads = _pos nearRoads _radius;
if (_closeRoads isEqualTo []) then { // If no roads are nearby
  _safePos = [_pos, 0, _radius, 15, 0, 0.35, 0, [], [false]] call BIS_fnc_findSafePos; // ** objDist may be too large here check later
} else { // If there are nearby roads (within rad)
  _safePos = _closeRoads select 0; // No need to find the closest segment as that is resource intensive
};

_safePos // If no pos is found the bool "false" is returned
