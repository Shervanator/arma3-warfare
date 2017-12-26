/* This file contains all resources (not including addons) necessary for creating a new
scenario with the kyfohatl warfare mod. Place the required information in the relevant
section.
*/

private ["_exitPointPairs"];

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Zone creation and setup

//------------------------------------------------------------------------------
/* Exit point setup
 Each element within _exitPointPairs array is an array of two exit points which are connected
to each other. The order of elements is not important.*/

// PLACE YOUR INFORMATION HERE
_exitPointPairs = [];

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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
