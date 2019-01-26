/*function for taking a position and returning its parent zone.

Parameters:
_pos: position - The position to check
_returnFullZone: boolean - If true the full zone array will be reutrned, otherwise only the zone index
is returned.

Return:
Either of (depending on _returnFullZone):
number: The index of the zone
array: The full zone Array

If the position is not inside any zone, -1 is returned.

Author: kyfohatl*/

// DEBUG
//#include "scripts\server\debug\debug_settings.sqf"
// END DEBUG

private ["_pos", "_returnFullZone", "_zone", "_return"];
params ["_pos", "_returnFullZone"];

_zone = [];
_return = -1;

// DEBUG
  #ifdef EXTREME_DEBUG
    DEBUG_LOG_START(__FILE__);
    diag_log "Finding the zone of a given position";
    diag_log format ["Checking zone %1", _x select 0];
  #endif
// END DEBUG

{
  private ["_zoneBasicInfo", "_zoneCentre"];

  _zoneBasicInfo = _x select 1;
  _zoneCentre = _zoneBasicInfo select 0;

  // DEBUG
    #ifdef EXTREME_DEBUG
      diag_log format ["Checking zone %1", _x select 0];
    #endif
  // END DEBUG



  if ([_zoneCentre select 0, _zoneCentre select 1, _zoneBasicInfo select 3, _zoneBasicInfo select 1, _zoneBasicInfo select 2, _pos] call kyf_WF_isPointInEllipse) exitWith {

    // DEBUG
    #ifdef EXTREME_DEBUG
      diag_log format ["Point is in zone %1", _x select 0];
    #endif
    // END DEBUG

    if (_returnFullZone) then {
      _return = _x;
    } else {
      _return = _x select 0;
    };
  };
} forEach kyf_WG_allZones;

// DEBUG
#ifdef EXTREME_DEBUG
  DEBUG_LOG_END(__FILE__);
#endif
// END DEBUG

_return
