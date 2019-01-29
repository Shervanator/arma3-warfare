/* Saves all important setup information to an external database file.

REQUIRED ADDON: inidbi2

Parameters: None

Returns: None

Author: kyfohatl
*/

#include "setup_settings\zone_settings.sqf"

// Create new database
private _inidbi = ["new", EXTERNAL_DATABASE_NAME] call OO_INIDBI;

// Check for existing database, and delete if it exists (to avoid duplication of data)
if ("exists" call _inidbi) then {
  "delete" call _inidbi;
};

// Now save relevant data
//-----------------------------------------------------------
// Zones

// General zone information: Zone geometrical data and exit point information
["write", ["Zones", "kyf_WG_allZones", kyf_WG_allZones]] call _inidbi;

// Zone divisions
["write", ["Zones", "kyf_WG_zoneDivisions", kyf_WG_zoneDivisions]] call _inidbi;

// Number of zones
["write", ["Zones", "countZones", count kyf_WG_allZones]] call _inidbi;

// Number of divisions of each zone
for [{private _i = 0}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  ["write", ["Zones", "countDivs_Z" + str _i, count (kyf_WG_zoneDivisions select _i)]] call _inidbi;
};

// Zone predefined paths
[_inidbi] call kyf_WF_saveZonePaths;

//-----------------------------------------------------------