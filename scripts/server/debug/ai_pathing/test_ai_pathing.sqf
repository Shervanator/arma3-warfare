/* Enables testing of AI pathing. By selecting a start and end point on the map, the AI path built between the 
two points will be shown.

Parameters:
  - NONE
  
Returns:
  - NONE
  
Author: kyfohatl */

// Import necessary key codes
#include "..\..\..\..\settings\script_settings\button_codes.sqf"

// Include error handling
#include "..\error_handling.sqf"

// DEBUG
// Necessary setup for get_division_debug which runs in getZoneDiv
#include "ai_pathing_settings.sqf"

#ifdef DEBUG_VISUAL_AI_PATHING_GET_ZONE_DIV
  // Pressing a button will set this var to true, and allow progression of debug to the next stage
  kyf_WG_DEBUG_getPath_nextStep = false;

  private _debugHandler = (findDisplay 12) displayAddEventHandler ["KeyDown", {
    private _key = _this select 1;

    if (_key == KEY_J) then {
      kyf_WG_DEBUG_getPath_nextStep = true;
    };
  }];
#endif
// END DEBUG

#define MARKER_COLOUR "ColorYellow"
#define MARKER_NAME_START "DEBUG_pathing_start"
#define MARKER_NAME_END "DEBUG_pathing_end"

// Make sure this is running on a client server as it is intended to work in that environment only at the moment
if (assert (isServer and !isDedicated)) then {
  // Initialize some global vars to allow communication with event handler function
  kyf_WG_debug_aiPath_waiting = false;
  kyf_WG_debug_aiPath_startPoint = "";
  kyf_WG_debug_aiPath_endPoint = "";
  kyf_WG_debug_aiPath_fullPathMarkers = [];


  private _handler = addMissionEventHandler ["MapSingleClick", {
    private _pos = _this select 1;
    private _shift = _this select 3;

    if (kyf_WG_debug_aiPath_waiting) then {
      // Both start and end points provided. Show end point on map

      if (_shift) then {
        hint "Land-only paht requested. Please note that if a land only path does not exist, a water path will be shown instead. Displaying path...";
      } else {
        hint "Path chosen. Path MAY require crossing water. Displaying predefined path of best fit...";
      };

      // Show the chosen end point on the map
      kyf_WG_debug_aiPath_endPoint = [MARKER_NAME_END + str _pos, _pos, "ICON", "mil_triangle", MARKER_COLOUR] call kyf_WF_make_marker;

      // Now show full path (path will include the nearest division centre if in a zone)
      private _path = [getMarkerPos kyf_WG_debug_aiPath_startPoint, getMarkerPos kyf_WG_debug_aiPath_endPoint, _shift] call kyf_WF_getPath;
      kyf_WG_debug_aiPath_fullPathMarkers = [_path] call kyf_DF_showPath;

      // Reset control var
      kyf_WG_debug_aiPath_waiting = false;

    } else {
      // New path started. Delete old path if present
      if !(kyf_WG_debug_aiPath_startPoint isEqualTo "") then {
        deleteMarker kyf_WG_debug_aiPath_startPoint;
        deleteMarker kyf_WG_debug_aiPath_endPoint;
      };

      {
        deleteMarker _x;
      } forEach kyf_WG_debug_aiPath_fullPathMarkers;

      kyf_WG_debug_aiPath_fullPathMarkers = [];

      // Now show the new start point on the map
      kyf_WG_debug_aiPath_startPoint = [MARKER_NAME_START + str _pos, _pos, "ICON", "mil_triangle", MARKER_COLOUR] call kyf_WF_make_marker;

      //wait till the end point is provided
      kyf_WG_debug_aiPath_waiting = true;
      hint "Pathing debug: Please also choose the end point of the path. Hold SHIFT while clicking for land-only paths";
    };
  }];
} else {
  // Not running script in correct environment. Give error
  ERROR_LOG_START(__FILE__);
  diag_log "ERROR: Function should be run in client server environment";
  ERROR_LOG_END(__FILE__);
};