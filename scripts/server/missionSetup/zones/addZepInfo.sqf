/* Function for adding basic exit point information to a zone

Parameters:
  - _zepIndex: Integer, representing the current index of the exit points we are up to
  - _exitPointsUnsorted: Array containing all exit point markers
  - _zoneInfo: The full zone array
  - _letterCount: Integer, representing the number of letters in an exit point marker tag

Returns:
  - _zepIndex: Integer. The exit point index we are up to. Each exit point has a unique zepIndex by adding +1 to _zepIndex when it is stored

Author: kyfohatl */

#include "..\setup_settings\zone_settings.sqf"
#include "..\..\debug\debug_settings.sqf"

private ["_zepIndex", "_exitPointsUnsorted", "_zoneInfo", "_letterCount"];
params ["_zepIndex", "_exitPointsUnsorted", "_zoneInfo", "_letterCount"];

private _zoneName = _zoneInfo select 2;

// DEBUG
#ifdef SETUP_ZONE_DEBUG_MAJOR
  DEBUG_LOG_START("_add_zep_info");
  diag_log "Checking zone exit point information - _add_zep_info";
  diag_log format ["Parent Zone: %1", _zoneName];
#endif
//END DEBUG

private _exitPointInfo = [];

for [{private _i = 0; private _zoneNumberStr = _zoneName select [_letterCount, (count _zoneName) - _letterCount]; private ["_linkPos", "_zep", "_start"]}, {_i < (count _exitPointsUnsorted)}, {_i = _i + 1}] do {
  _zep = _exitPointsUnsorted select _i;

  // Isolate the name of the owning zone from the name of the zep. In format kyf_zep12_z2, the second instance of "z" is our start point
  _start = ([_zep, "z", 2] call kyf_WF_findSymbolInStr) + 1;

  // See if the exit point belongs this zone (i.e. has the same zone number). The zone number in format kyf_zone12 can be aquired by selecting between _letterCount and (count _zoneName) - _letterCount
  if ([_zoneNumberStr, _zep, _start] call kyf_WF_compareStrToNestedStr) then {
    // Assign exit point a unique number _zepIndex which corresponds to the index it occupies in the hash table array.
    _zepIndex = _zepIndex + 1;

    /* Hash table where zep's are organized based on _zepIndex. Table select _zepIndex will now provide us with an array unique to this exit point, where we can store paths in our A* algorithm,
    although the array is empty at this point. Used in kyf_WF_findShortestPath */
    (missionNamespace getVariable HASH_TABLE_NAME) pushBack [];

    // DEBUG
    // Debug exit point linkage
    #ifdef SETUP_ZONE_DEBUG_EXTREME
      diag_log "Exit point link debug:";
      diag_log format ["Exit marker: %1", _zep];
      diag_log format ["Link marker: %1", missionNamespace getVariable (_zep + "_Link")];
    #endif
    // END DEBUG

    _linkPos = getMarkerPos (missionNamespace getVariable (_zep + "_Link"));

    // exit point format [index identifier, pos, [link zone index, link pos], distance from pos to linkPos squared, distance from pos to linkPos, exit point marker name]
    _exitPointInfo pushBack [_zepIndex, getMarkerPos _zep, [[_linkPos, false] call kyf_WF_findZone, _linkPos], missionNamespace getVariable (_zep + "_LinkD2"), missionNamespace getVariable (_zep + "_LinkD"), _zep];

    // DEBUG
    #ifdef SETUP_ZONE_DEBUG_MAJOR
      diag_log "zep format: [index identifier, pos, [link zone index, link pos], distance from pos to linkPos squared, distance from pos to linkPos, exit point marker name]";
      diag_log _exitPointInfo;
    #endif
    // END DEBUG
  };
};

// DEBUG
#ifdef SETUP_ZONE_DEBUG_MAJOR
  DEBUG_LOG_END("_add_zep_info");
#endif
// END DEBUG

_zoneInfo pushBack _exitPointInfo;
_zepIndex