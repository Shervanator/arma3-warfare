/* Resources related to zone setup. Place all relavant information in the appropriate sections.

Author: kyfohatl */

/* Exit point setup:
Each element within _exitPointPairs array is an array of two exit points which are connected
to each other. The order of elements is not important.

Example: If zone0 connects to zone1 via exit point "kyf_zep0_z0" to exit point "kyf_zep0_z1", and also connects to zone3 via "kyf_zep1_z0" to 
"kyf_zep0_z3", then we would have: _exitPointPairs = [["kyf_zep0_z0", "kyf_zep0_z1"], ["kyf_zep1_z0", "kyf_zep0_z3"]] */

// PLACE EXIT POINT PAIRS IN THIS ARRAY
private _exitPointPairs = [["kyf_zep0_z0", "kyf_zep0_z1"], ["kyf_zep1_z1", "kyf_zep0_z2"], ["kyf_zep1_z2", "kyf_zep1_z3"], ["kyf_zep1_z0", "kyf_zep0_z3"]];

// Associated code
{
  private ["_element0", "_element1", "_element0Pos", "_element1Pos", "_distance", "_distanceSqr"];

  _element0 = _x select 0;
  _element1 = _x select 1;

  _element0Pos = getMarkerPos _element0;
  _element1Pos = getMarkerPos _element1;

  _distance = _element0Pos distance _element1Pos;
  _distanceSqr = _element0Pos distanceSqr _element1Pos;

  missionNamespace setVariable [_element0 + "_Link", _element1];
  missionNamespace setVariable [_element0 + "_LinkD2", _distanceSqr];
  missionNamespace setVariable [_element0 + "_LinkD", _distance];

  missionNamespace setVariable [_element1 + "_Link", _element0];
  missionNamespace setVariable [_element1 + "_LinkD2", _distanceSqr];
  missionNamespace setVariable [_element1 + "_LinkD", _distance];
} forEach _exitPointPairs;