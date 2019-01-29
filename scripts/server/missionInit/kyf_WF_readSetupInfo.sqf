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
#include "..\debug\zones\test_zone_paths.sqf"
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

// Read general zone info
kyf_WG_allZones = ["read", ["Zones", "kyf_WG_allZones"]] call _inidbi;

// Read zone divisions
kyf_WG_zoneDivisions = ["read", ["Zones", "kyf_WG_zoneDivisions"]] call _inidbi;

// Read zone paths
[_inidbi] call kyf_WF_readPredPaths;

// DEBUG
// Will cycle through all paths and display them as markers on the screen. Make sure DEBUG_RUN_ZONE_PATH_TEST is defined to use
DEBUG_RUN_ZONE_PATH_TEST
// END DEBUG