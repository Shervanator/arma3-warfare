/* Function reads all mission setup information generated during the mission setup phase from an external database,
and store the data in the relevant variables

Parameters:
	- NONE

Returns:
	- NONE

Author: kyfohatl */

#include "..\missionSetup\setup_settings\zone_settings.sqf"

// DEBUG
#include "..\debug\error_handling.sqf"
// END DEBUG

// Zones -----------------------------------------------------------------

// Open database file
private _inidbi = ["new", EXTERNAL_DATABASE_NAME] call OO_INIDBI;

// Make sure that database file exists, throw exception otherwise
try {!(assert ("exists" call _inidbi))} catch {
  ERROR_LOG_START(__FILE__);
  diag_log "ERROR: Database file does not exist";
  ERROR_LOG_END(__FILE__);
};

// Read basic zone info
kyf_WG_allZones = [];
private _countZones = ["read", ["Zones General Info", "countZones"]] call _inidbi;

for [{private _i = 0}, {_i < _countZones}, {_i = _i + 1}] do {
  private _zoneInfo = ["read", ["Zone Basic Info", "zone" + str _i]] call _inidbi;
  kyf_WG_allZones pushBack _zoneInfo;
};

// Read zone divisions
kyf_WG_zoneDivisions = [];

for [{private _i = 0}, {_i < _countZones}, {_i = _i + 1}] do {
  private _zoneDivs = ["read", ["Zones Divisions", "zone" + str _i + "_divisions"]] call _inidbi;
  kyf_WG_zoneDivisions pushBack _zoneDivs;
};

// Read zone paths
[_inidbi] call kyf_WF_readPredPaths;

// DEBUG
// Will cycle through all paths and display them as markers on the screen. Make sure DEBUG_RUN_ZONE_PATH_TEST is defined to use
#include "..\debug\zones\test_zone_paths.sqf"
// END DEBUG