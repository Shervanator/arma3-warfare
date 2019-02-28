/* Returns the best path between two points. If both points are within zones, the best predefined path is chosen and otherwise a straight path 
between them is returned.

Parameters:
	- _start and _end: Position 2D or 3D of the starting and ending position
  - _noWater: Boolean. If true water paths can be returned, while if false only land paths will be returned. In the case that a land-only path does not exits, 
  then the water path will be returned
  
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

private ["_start", "_end", "_noWater"];
params ["_start", "_end", "_noWater"];

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

// Initialize necessary vars
private _pathArray = [];
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
    _pathArray = (((kyf_WG_zoneDivisionPaths select _startZone) select _startDiv) select _tgtZone) select _tgtDiv;

    // By default, the first element in the _pathArray will be the shortest path. However it may require crossing water zones
    _path = _pathArray select 0;

    // Check water pathing
    if (_noWater and ((_pathArray select 0) select 2)) then {
      // Path contains water, but water paths are not desired. See if a land-only path exists
      // If an alternative land-only path exists, it would be the second element in the _pathArray. If not, then the water path is returned
      if ((count _pathArray) > 1) then {
        // Alternative land-only path does exist
        _path = _pathArray select 1;
      };
    };
  };
};

// If either at least one of the positions is not in a zone, or a path between the zones that contain the positions do not exist, then create a simple path
if (_simplePath) then {
  // Make a straight path from start to end
  _path = [[_start, _end], _start distanceSqr _end, false];
};

// DEBUG
#ifdef DEBUG_AI_PATHING_GETPATH
  diag_log format ["Final chosen path: %1", _path];
  DEBUG_LOG_END(__FILE__);
#endif
// END DEBUG

// Format: [path: [start, pos1, pos2, ..., end], total path cost in distance sqr, is water]
_path