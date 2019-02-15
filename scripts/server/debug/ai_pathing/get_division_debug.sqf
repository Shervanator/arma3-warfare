/* Debug procedure will allow visualization of the process of finding the division of a given point within a zone. 
Note that this is a procedure (due to usage of waitUntil requires suspension) and hence must be executed via execVM 
and NOT call.

Parameters:
	-
  
RETURNS:
  - NONE
  
Author: kyfohatl */

#define MARKER_SHAPE "ICON"
#define MARKER_TYPE "hd_dot"
#define MAIN_COLOR "ColorRed"
#define SECOND_COLOR "ColorBlue"

private ["_pos", "_zone", "_l1p1", "_l2p1", "_angle1", "_angle2", "_ax1Coordinate", "_ax2Coordinate"];
params ["_pos", "_zone", "_l1p1", "_l2p1", "_angle1", "_angle2", "_ax1Coordinate", "_ax2Coordinate"];

private _cornerPoints = (_zone select 1) select 4;

// Wait for player to signal the next stage to begin
hint format ["Finding the division of position in zone %1. Press J while in map to go from one stage to the next", _zone];
waitUntil {kyf_WG_DEBUG_getPath_nextStep};

// Reset var
kyf_WG_DEBUG_getPath_nextStep = false;

// Create markers to visualize the axis line
private _m1 = ["l1p1" + str _l1p1, _l1p1, MARKER_SHAPE, MARKER_TYPE, MAIN_COLOR] call kyf_WF_make_marker;
private _m2 = ["l1p2" + str (_cornerPoints select 1), (_cornerPoints select 1), MARKER_SHAPE, MARKER_TYPE, SECOND_COLOR] call kyf_WF_make_marker;

hint format ["The %1 marker is the main ref point. The angle between the lines is %2. The hyp is %3. This results in axis coordinate %4", MAIN_COLOR, _angle1, _pos distance2D _l1p1, _ax1Coordinate];

// Wait for next stage
waitUntil {kyf_WG_DEBUG_getPath_nextStep};

// Reset var
kyf_WG_DEBUG_getPath_nextStep = false;

// Remove old markers
{
  deleteMarker _x;
} forEach [_m1, _m2];

// Create markers for the second axis
private _m3 = ["l2p1" + str _l2p1, _l2p1, MARKER_SHAPE, MARKER_TYPE, MAIN_COLOR] call kyf_WF_make_marker;
private _m4 = ["l2p2" + str (_cornerPoints select 3), (_cornerPoints select 3), MARKER_SHAPE, MARKER_TYPE, SECOND_COLOR] call kyf_WF_make_marker;

hint format ["The %1 marker is the main ref point. The angle between the lines is %2. The hyp is %3. This results in axis coordinate %4", MAIN_COLOR, _angle2, _pos distance2D _l2p1, _ax2Coordinate];

// Wait for next stage
waitUntil {kyf_WG_DEBUG_getPath_nextStep};

// Reset var
kyf_WG_DEBUG_getPath_nextStep = false;

// Remove markers
{
  deleteMarker _x;
} forEach [_m3, _m4];

hint "Debug stage complete";