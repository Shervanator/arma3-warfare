/* Function will test zone and pathing data imported from external database file if the relevant debug setting is enabled 

Parameters:
  - NONE
  
RETURNS:
  - NONE
  
Author: kyfohatl */

// Slow mode, to allow markers to be displayed for custom amounts of time before moving on to the next set of merkers
// Ensure DEBUG_SETUP_ZONES_SLOW_MODE is defined to use
#include "slow_mode.sqf"

#ifdef DEBUG_ZONE_PATHS
  #define DEBUG_RUN_ZONE_PATH_TEST\
    \// Cycle through all zones and illustrate their paths
    {\
      \// Cycle through the divisions of each zone
      {\
        \// Cycle through paths to each targte zone
        {\
          \// Cycle through each target division
          {\
            \
            private _debugMarkers = [];\
            private _path = _x select 0;\
            \
            for [{private _i = 0}, {_i < (count _path)}, {_i = _i + 1}] do {\
              \// Create appropriate marker for the path
              private _marker = createMarker [str _i + str (_path select _i), _path select _i];\
              _marker setMarkerShape "ICON";\
              \
              \// Set the start and end markers ar triangles while all others are dots
              if ((_i == 0) or (_i == ((count _path) - 1))) then {\
                _marker setMarkerType "mil_triangle";\
              } else {\
                _marker setMarkerType "hd_dot";\
              };\
              \
              _marker setMarkerColor "ColourPink";\
              _debugMarkers pushBack _marker;\
            };\

            \// Wait for appropriate amount of time based on slow mode settings
            sleep kyf_WG_DEBUG_SETUP_smVal;\

            \// Now delete pathfinding debug markers
            {\
              deleteMarker _x;\
            } forEach _debugMarkers;\
          } forEach _x;\
        } forEach _x;\
      } forEach _x;\
    } forEach kyf_WG_zoneDivisionPaths;
#else
  #define DEBUG_RUN_ZONE_PATH_TEST
#endif