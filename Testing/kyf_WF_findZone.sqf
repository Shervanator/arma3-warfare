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

private ["_pos", "_returnFullZone", "_zone", "_return"];
params ["_pos", "_returnFullZone"];

_zone = [];
_return = -1;

{
  private ["_zoneBasicInfo", "_zoneCentre"];

  _zoneBasicInfo = _x select 1;
  _zoneCentre = _zoneBasicInfo select 0;

  if ([_zoneCentre select 0, _zoneCentre select 1, _zoneBasicInfo select 3, _zoneBasicInfo select 1, _zoneBasicInfo select 2, _pos] call kyf_WF_isPointInEllipse) exitWith {
    if (_returnFullZone) then {
      _return = _x;
    } else {
      _return = _x select 0;
    };
  };
} forEach kyf_WG_allZones;

_return
