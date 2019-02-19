/* Sets up water zones and their related paths 

Parameters:
  - NONE 
  
Returns:
  - NONE 

Author: kyfohatl */

#define WATER_ZONE_TAG "kyf_wZone"

private _wZonesUnsorted = [];
private _wZoneCount = 0;

// Place all water zone markers in one array
{
  if ((_x select [0, 9]) isEqualTo WATER_ZONE_TAG) then {
    _wZonesUnsorted pushBack _x;
    _wZoneCount = _wZoneCount + 1;
  };
} forEach allMapMarkers;

// Initialize global var which will contain all water zones in order
kyf_WG_waterZones = [];

// Now sort them in order
for [{private _i = 0}, {_i < _wZoneCount}, {_i = _i + 1}] do {
  for [{private _n = 0}, {_n < (count _wZonesUnsorted)}, {_n = _n + 1}] do {
    private _wZone = _wZonesUnsorted select _n;

    if ([str _i, _wZone, 9] call kyf_WF_compareStrToNestedStr) exitWith {

      // Each water zone will have the following format: [zone index identifier, [EMPTY ARRAY], Zone marker name]
      /* Water Zones are on purpose made in the same structure as normal zones, to make interactions with already existing scripts easier, despite the fact this means there 
      will be some redundant elements (such as the empty array, as water zones do not need to store their geometrical information) */
      kyf_WG_allZones pushBack [_i, [], _wZone];

      _wZonesUnsorted deleteAt _n;
    };
  };
};

// Now add exit point information
