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
for [{private _i = 0}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  ["write", ["Zone Basic Info", "zone" + str _i, kyf_WG_allZones select _i]] call _inidbi;
};

// Zone divisions
for [{private _i = 0}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  ["write", ["Zones Divisions", "zone" + str _i + "_divisions", kyf_WG_zoneDivisions select _i]] call _inidbi;
};

// Number of zones
["write", ["Zones General Info", "countZones", count kyf_WG_allZones]] call _inidbi;

// Number of divisions of each zone
for [{private _i = 0}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  ["write", ["Zones General Info", "countDivs_Z" + str _i, count (kyf_WG_zoneDivisions select _i)]] call _inidbi;
};

// Zone predefined paths
[_inidbi] call kyf_WF_saveZonePaths;

//-----------------------------------------------------------