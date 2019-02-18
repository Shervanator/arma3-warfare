/* Returns the best path between two points. If both points are within zones, the best predefined path is chosen and otherwise a straight path 
between them is returned.

Parameters:
	- _start and _end: Position 2D or 3D of the starting and ending position
  
Returns:
  - _path: Array of positions, indicating the path that must be travelled
  
Author: kyfohatl */

// DEBUG
#include "..\debug\ai_pathing\ai_pathing_settings.sqf"
#include "..\debug\debug_settings.sqf"

#ifdef DEBUG_VISUAL_AI_PATHING_GET_ZONE_DIV
  /* Get a process manager going to order the execution of parallel processes, if one is not already running.
  Author's Note: You may notice that this is absolutely terrible "parallel programming". Since this is only a minor debug function I could not be bothered writing this 
  properly, since this basic form should do the job */

  if (isNil "kyf_DG_aiPathing_VisPathManager_handle") then { // The procedure does not exist
    // Initiate parameter array
    kyf_DG_aiPathing_VisPathManager_params = [];

    // Run procedure
    kyf_DG_aiPathing_VisPathManager_handle = [] execVM "scripts\server\debug\ai_pathing\ai_pathing_debug_manager.sqf";
  } else {
    if (isNull kyf_DG_aiPathing_VisPathManager_handle) then { // The procedure exists, but has finished running
      // Reset the params array
      kyf_DG_aiPathing_VisPathManager_params = [];

      // Run procedure
      kyf_DG_aiPathing_VisPathManager_handle = [] execVM "scripts\server\debug\ai_pathing\ai_pathing_debug_manager.sqf";
    };
  };
#endif
// END DEBUG

private ["_start", "_end"];
params ["_start", "_end"];

private _data = [];
private _simplePath = false;

{
  // Get the zone of the point
  private _zone = [_x, true] call kyf_WF_findZone;

  // Check if point is inside a zone
  if (_zone isEqualTo -1) exitWith {
    // Point not inside a zone, complicated pathing is not required
    _simplePath = true;
  };

  // Get the division of the point within the zone
  private _div = [_x, _zone] call kyf_WF_getZoneDiv;

  // DEBUG
  #ifdef DEBUG_AI_PATHING_GETPATH
    DEBUG_LOG_START(__FILE__);
    diag_log format ["Acquired division: %1", _div];
  #endif
  // END DEBUG

  // Now we must keep the zone and division index of the point to find the correct path
  _data pushBack (_zone select 0);
  _data pushBack (_div select 0);
} forEach [_start, _end];

// Initialize return value
private _path = [];

// Get proper path if possible
if !(_simplePath) then {
  // DEBUG
  #ifdef DEBUG_AI_PATHING_GETPATH
    diag_log format ["Full data is: %1", _data];
  #endif
  // END DEBUG

  private _startZone = _data select 0;
  private _startDiv = _data select 1;
  private _tgtZone = _data select 2;
  private _tgtDiv = _data select 3;

  // Make sure that a path between these zones exists
  if ((((kyf_WG_zoneDivisionPaths select _startZone) select _startDiv) select _tgtZone) isEqualTo []) then {
    // Path between zones does not exist. Make a straight path
    _simplePath = true;
  } else {
    // Path exists. Find the right path
    _path = (((kyf_WG_zoneDivisionPaths select _startZone) select _startDiv) select _tgtZone) select _tgtDiv;
  };
};

// Either at least one of the positions is not in a zone, or a path between the zones that contain the positions do not exist
if (_simplePath) then {
  // Make a straight path from start to end
  _path = [[_start, _end], _start distanceSqr _end];
};

// DEBUG
#ifdef DEBUG_AI_PATHING_GETPATH
  diag_log format ["Final chosen path: %1", _path];
  DEBUG_LOG_END(__FILE__);
#endif
// END DEBUG

// Format: [start, pos1, pos2, ..., end]
_path