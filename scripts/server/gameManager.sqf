_towns = [];
_blueForMarker = "";
_opForMarker = "";

{
  switch (getMarkerType _x) do {
    case "mil_flag": { _towns pushback _x };
    case "b_hq": { _blueForMarker = _x };
    case "o_hq": { _opForMarker = _x };
  };
} foreach allMapMarkers;

// Create triggers on towns
{
  [_x] execVM "scripts\server\townManager.sqf";
} forEach _towns;

[_blueForMarker, _towns, west] execVM "scripts\server\commander.sqf";
[_opForMarker, _towns, east] execVM "scripts\server\commander.sqf";
