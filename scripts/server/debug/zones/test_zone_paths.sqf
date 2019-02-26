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

#ifdef DEBUG_ZONE_PATHS
  // Cycle through all zones and illustrate their paths
  {
    private _zone = _x;

    // Cycle through the divisions of the zone
    {
      private _div = _x;

      // Cycle through paths to each targte zone
      {
        private _tgtZone = _x;

        // Cycle through each target division of the target zone
        {
          private _tgtDiv = _x;
          private _path = (_tgtDiv select 0) select 0;
          private _debugMarkers = [];

          // Now create a marker for each position on the path, wait some time depending on slow mode, and then delete the markers
          for [{private _i = 0}, {_i < (count _path)}, {_i = _i + 1}] do {
            // Create appropriate marker for the path
            private _marker = createMarker ["DEBUG" + str _i + str (_path select _i), _path select _i];
            _marker setMarkerShape "ICON";

            // Set the start and end markers as triangles while all others are dots
            if ((_i == 0) or (_i == ((count _path) - 1))) then {
              _marker setMarkerType "mil_triangle";
            } else {
              _marker setMarkerType "hd_dot";
            };

            _marker setMarkerColor "ColorPink";
            _debugMarkers pushBack _marker;
          };

          // Wait for appropriate amount of time based on slow mode settings
          sleep kyf_WG_DEBUG_SETUP_smVal;

          // Now delete pathfinding debug markers
          {
            deleteMarker _x;
          } forEach _debugMarkers;
        } forEach _tgtZone;
      } forEach _div;
    } forEach _zone;
  } forEach kyf_WG_zoneDivisionPaths;
#endif