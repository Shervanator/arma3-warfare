/* Function for saving the very large zone division paths to a database. It is necessary as inidbi2 (the addon currently used for saving data) has a limit of 8k elements 
per array.

Parameters:
  _inidbi: The database to save data to
  
Returns:
  None
  
Author: kyfohatl */

private ["_inidbi"];
params ["_inidbi"];


// Save all path information:
// Loop through each zone and save its paths
for [{private _i = 0}, {_i < (count kyf_WG_zoneDivisionPaths)}, {_i = _i + 1}] do {
  private _currentZone = kyf_WG_zoneDivisionPaths select _i;

  // Now loop through each division of a zone to save its paths
  for [{private _j = 0}, {_j < (count _currentZone)}, {_j = _j + 1}] do {
    private _currentDiv = _currentZone select _j;

    // Now loop through the paths from this division to each target zone (each other zone on the map)
    for [{private _k = 0}, {_k < (count _currentDiv)}, {_k = _k + 1}] do {
      private _currentTargetZone = _currentDiv select _k;

      // Now loop through the paths to each division of the target zone
      for [{private _l = 0}, {_l < (count _currentTargetZone)}, {_l = _l + 1}] do {
        private _currentTargetDiv = _currentTargetZone select _l;

        /* The key uniquely identifies this path. _i is the zone this path belongs to, _j is the division, _k is the target zone of this path and _l is the target 
        division of this path. Example: path0123 is a path from zone 0, division 1 to zone 2, division 3 */
        ["write", ["AllZonePaths", "path" + str _i + str _j + str _k + str _l, _currentTargetDiv]] call _inidbi;
      };
    };
  };
};