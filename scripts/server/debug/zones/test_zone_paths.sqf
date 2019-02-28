/* Function will test zone and pathing data imported from external database file if the relevant debug setting is enabled 

Parameters:
  - NONE
  
RETURNS:
  - NONE
  
Author: kyfohatl */

// Other zone debug settings
#include "zone_debug_settings.sqf"

// Slow mode, to allow markers to be displayed for custom amounts of time before moving on to the next set of merkers
// Ensure DEBUG_SETUP_ZONES_SLOW_MODE is defined to use
#include "slow_mode.sqf"

// Definitions
#define MARKER_SHAPE "ICON"
#define MARKER_TYPE_ENDPOINT "mil_triangle"
#define MARKER_TYPE_NORMAL "hd_dot"
#define MARKER_COLOR "ColorPink"

#ifdef DEBUG_ZONE_PATHS
  // Cycle through all zones and illustrate their paths
  private _zIndex = 0;
  {
    private _zone = _x;

    // Cycle through the divisions of the zone
    private _dIndex = 0;
    {
      private _div = _x;

      // Cycle through paths to each targte zone
      private _tzIndex = 0;
      {
        private _tgtZone = _x;

        // Cycle through each target division of the target zone
        private _tdIndex = 0;
        {
          private _tgtDiv = _x;
          private _path = (_tgtDiv select 0) select 0;
          private _debugMarkers = [];

          // Create start and end markers for the starting and target divisions (as division paths do not include the start and end division)
          private _startPos = ((kyf_WG_zoneDivisions select _zIndex) select _dIndex) select 2;
          private _endPos = ((kyf_WG_zoneDivisions select _tzIndex) select _tdIndex) select 2;

          private _startM = ["DEBUG_START" + str _startPos, _startPos, MARKER_SHAPE, MARKER_TYPE_ENDPOINT, MARKER_COLOR] call kyf_WF_make_marker;
          private _endM = ["DEBUG_START" + str _endPos, _endPos, MARKER_SHAPE, MARKER_TYPE_ENDPOINT, MARKER_COLOR] call kyf_WF_make_marker;

          _debugMarkers pushBack _startM;
          _debugMarkers pushBack _endM;

          // Now create a marker for each position on the path, wait some time depending on slow mode, and then delete the markers
          {
            private _marker = ["DEBUG" + str _x, _x, MARKER_SHAPE, MARKER_TYPE_NORMAL, MARKER_COLOR] call kyf_WF_make_marker;
            _debugMarkers pushBack _marker;
          } forEach _path;

          // Wait for appropriate amount of time based on slow mode settings
          sleep kyf_WG_DEBUG_SETUP_smVal;

          // Now delete pathfinding debug markers
          {
            deleteMarker _x;
          } forEach _debugMarkers;

          _tdIndex = _tdIndex + 1;
        } forEach _tgtZone;

        _tzIndex = _tzIndex + 1;
      } forEach _div;

      _dIndex = _dIndex + 1;
    } forEach _zone;

    _zIndex = _zIndex + 1;
  } forEach kyf_WG_zoneDivisionPaths;
#endif