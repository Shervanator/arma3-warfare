/* Enables testing of AI pathing. By selecting a start and end point on the map, the AI path built between the 
two points will be shown.

Parameters:
  - NONE
  
Returns:
  - NONE
  
Author: kyfohatl */

// Import necessary key codes
#include "..\..\..\settings\script_settings\button_codes.sqf"

// Include error handling
#include "..\error_handling.sqf"

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


  private _handler = (findDisplay 12) displayAddEventHandler ["MouseButtonDown", {
    private _mButton = _this select 1;

    if (_mButton == MOUSE_LCLICK_DIK) then {
      private _pos = [_this select 2, _this select 3];

      if (kyf_WG_debug_aiPath_waiting) then {
        // Both start and end points provided. Show end point on map
        kyf_WG_debug_aiPath_endPoint = [MARKER_NAME_END + str _pos, _pos, "ICON", "mil_triangle", MARKER_COLOUR] call kyf_WF_make_marker;

        // Now show full path (path will include the nearest division centre if in a zone)
        private _path = [kyf_WG_debug_aiPath_startPoint, kyf_WG_debug_aiPath_endPoint] call kyf_WF_getPath;
        kyf_WG_debug_aiPath_fullPathMarkers = [_path] call kyf_DF_showPath;

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
        hint "Pathing debug: Please also choose the end point of the path";
      };
    };

    // Return false to prevent overriding of normal mouse button function on the map
    false
  }];
} else {
  // Not running script in correct environment. Give error
  ERROR_LOG_START(__FILE__);
  diag_log "ERROR: Function should be run in client server environment";
  ERROR_LOG_END(__FILE__);
};