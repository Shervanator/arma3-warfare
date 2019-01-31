/* Function will read the predefined zone paths from an external database.

Parameters:
  - _inidbi: The database to read from

Returns:
  - Nothing directly, but stores all zone division paths in the global variable kyf_WG_zoneDivisionPaths

Author: kyfohatl */

private ["_inidbi"];
params ["_inidbi"];

// Read the total number of zones
private _countZones = ["read", ["Zones General Info", "countZones"]] call _inidbi;

// Declare the global variable that will store all paths
kyf_WG_zoneDivisionPaths = [];

for [{private _zone = 0}, {_zone < _countZones}, {_zone = _zone + 1}] do {
  // Add array element representing the paths of this zone
  kyf_WG_zoneDivisionPaths pushBack [];

  // Read division count of this zone
  private _divCount = ["read", ["Zones General Info", "countDivs_Z" + str _zone]] call _inidbi;

  // Read paths for each division of this zone
  for [{private _div = 0}, {_div < _divCount}, {_div = _div + 1}] do {
    // Add element representing all paths of this division
    (kyf_WG_zoneDivisionPaths select _zone) pushBack [];

    // Now cycle through all target zones and read paths for this division
    for [{private _targetZone = 0}, {_targetZone < _countZones}, {_targetZone = _targetZone + 1}] do {
      // Add array element representing this zone
      ((kyf_WG_zoneDivisionPaths select _zone) select _div) pushBack [];

      // Check if paths to this zone exist
      private _path = ["read", ["AllZonePaths", "path" + str _zone + str _div + str _targetZone + "0"]] call _inidbi;

      if (_path isEqualTo false) then {
        // Cannot path to this zone, hence no further action is needed

      } else {
        // Can path to this zone. Add this path that was read
        (((kyf_WG_zoneDivisionPaths select _zone) select _div) select _targetZone) pushBack _path;

        // Read the division count of this target zone
        private _tgtDivCount = ["read", ["Zones General Info", "countDivs_Z" + str _targetZone]] call _inidbi;

        // Cycle through the remaining divisions of this target zone and read paths to it
        for [{private _targetDiv = 1}, {_targetDiv < _tgtDivCount}, {_targetDiv = _targetDiv + 1}] do {

          // Read path
          _path = ["read", ["AllZonePaths", "path" + str _zone + str _div + str _targetZone + str _targetDiv]] call _inidbi;

          // Add path
          (((kyf_WG_zoneDivisionPaths select _zone) select _div) select _targetZone) pushBack _path;
        };
      };
    };
  };
};