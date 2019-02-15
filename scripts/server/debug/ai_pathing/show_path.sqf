/* Function will illustrate given series of positions (aka a path) on the map as a set of markers

Parameters:
  - _path: Array of positions
  - (optional) _color: String (cfg_colors color), color of the path markers
  
Returns:
  - _allMarkers: Array of markers (strings) created

Author: kyfohatl
*/

#define MARKER_NAME_BASE "DEBUG_path"
#define MARKER_NAME_START "_start"
#define MARKER_NAME_END "_end"
#define MARKER_SHAPE "ICON"
#define MARKER_TYPE_DEFAULT "hd_dot"
#define MARKER_TYPE_SPECIAL "mil_triangle"
#define MARKER_COLOUR_DEFAULT "ColorPink"

private ["_pathData", "_color"];
params ["_pathData", "_color"];

// Take only the position data of the path and discard the distance data
private _path = _pathData select 0;

private _markerColor = MARKER_COLOUR_DEFAULT;

// Initialize return value
private _allMarkers = [];

// Check if color is provided
if !(isNil "_color") then {
  _markerColor = _color;
};

for [{private _i = 0}, {_i < (count _path)}, {_i = _i + 1}] do {
  private _pos = _path select _i;
  private _markerName = MARKER_NAME_BASE;
  private _markerType = MARKER_TYPE_DEFAULT;

  // Make start and end markers different for better illustration of the path
  if (_i == 0) then {
    _markerName = _markerName + MARKER_NAME_START;
    _markerType = MARKER_TYPE_SPECIAL;
  };

  if (_i == ((count _path) - 1)) then {
    _markerName = _markerName + MARKER_NAME_END;
    _markerType = MARKER_TYPE_SPECIAL;
  };

  // Now create the marker
  _markerName = _markerName + str _pos;
  private _marker = [_markerName, _pos, MARKER_SHAPE, _markerType, _markerColor] call kyf_WF_make_marker;
  _allMarkers pushBack _marker;
};

_allMarkers