/* Returns the division that given point in a given zone is in.

Parameters:
  - _pos: Position 2D or 3D. The position of the given point
  - _zone: The zone (full zone, not just the index) that the given point is in
  
Returns:
  - _div: The division of the zone in which the point is located
  
Author: kyfohatl */

// DEBUG
#include "..\debug\ai_pathing\ai_pathing_settings.sqf"
#include "..\debug\debug_settings.sqf"
// END DEBUG

private ["_pos", "_zone"];
params ["_pos", "_zone"];

// Get necessary geometrical information of the zone
private _geoInfo = _zone select 1;

private _point1 = (_geoInfo select 4) select 0;
private _point2 = (_geoInfo select 4) select 2;

private _axis1Eqn = _geoInfo select 5;
private _axis2Eqn = _geoInfo select 6;

// Use geometry to find where the pos is located relative to the zone (centre of the zone is [0,0], and the two axis form the x and y axis)

// Find the euqations of the lines between the pos and the first point (corner point) on each axis
private _line1Eqn = [_point1, _pos] call kyf_WF_getSLEqn;
private _line2Eqn = [_point2, _pos] call kyf_WF_getSLEqn;

// Find the ACUTE angle between each line formed by the pos and each of the axis
private _angle1 = [_line1Eqn select 0, _axis1Eqn select 0, 1] call kyf_WF_getAngBetLines;
private _angle2 = [_line2Eqn select 0, _axis2Eqn select 0, 1] call kyf_WF_getAngBetLines;

// Now use cosine to find the (x,y) coordinates (relative to the zone) of the pos (adj = cos(a) / hyp)
_ax1Coordinate = (_point1 distance2D _pos) * (cos _angle1);
_ax2Coordinate = (_point2 distance2D _pos) * (cos _angle2);

// DEBUG
// Log debug information
#ifdef DEBUG_LOG_AI_PATHING_GET_ZONE_DIV
  DEBUG_LOG_START(__FILE__);
  diag_log format ["Finding the division of pos %1 in zone %2", _pos, _zone select 0];
  diag_log format ["Angle1: %1, Angle2: %2", _angle1, _angle2];
  diag_log format ["Axis 1 coordinate: %1, Axis 2 coordinate: %2", _ax1Coordinate, _ax2Coordinate];
  diag_log format ["Line1 length: %1, Line2 Length: %2", _point1 distance2D _pos, _point2 distance2D _pos];
#endif

// Visualize debug information
#ifdef DEBUG_VISUAL_AI_PATHING_GET_ZONE_DIV
  // Hand over parameters to the debug manager currently running and it will organize a time for them to be shown
  kyf_DG_aiPathing_VisPathManager_params pushBack [_pos, _zone, _point1, _point2, _angle1, _angle2, _ax1Coordinate, _ax2Coordinate];
#endif
// END DEBUG

// Now find the division using aquired axis coordinates
// In order to do so, we must go up each axis and find the first instance where our axis coordinates are less than the segment value
private _zoneDivs = kyf_WG_zoneDivisions select (_zone select 0); // The zone's index corresponds to which element in the kyf_WG_zoneDivisions contains the divisions for this zone

// Initiate the division variable
private _div = [];

// DEBUG
// Show debug information
#ifdef DEBUG_LOG_AI_PATHING_GET_ZONE_DIV
  diag_log format ["Divisions to be tested: %1", _zoneDivs];
#endif
// END DEBUG

/* Line segements start from the smallest value and increase on both axis. Hence the first instance the pos aixs coordinates is <= to both axis segemtns is 
the correct division for the pos */
for [{private _i = 0}, {_i < (count _zoneDivs)}, {_i = _i + 1}] do {
  private _currentDiv = _zoneDivs select _i;
  private _axis1Segment = _currentDiv select 0;
  private _axis2Segment = _currentDiv select 1;

  // DEBUG
  // Log debug information
  #ifdef DEBUG_LOG_AI_PATHING_GET_ZONE_DIV
    diag_log format ["Testing division: %1", _currentDiv];
  #endif
  // END DEBUG

  if ((_ax1Coordinate <= _axis1Segment) and (_ax2Coordinate <= _axis2Segment)) exitWith {
    _div = [_i, +_currentDiv];
  };
};

// DEBUG
#ifdef DEBUG_LOG_AI_PATHING_GET_ZONE_DIV
  diag_log format ["Chosen division: %1", _div];
  DEBUG_LOG_END(__FILE__);
#endif
// END DEBUG

// Return value format: [division index, [_line1Seg, _line2Seg, centre point of the division]]
_div