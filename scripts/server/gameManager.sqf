_townMarkers = [];
_towns = [];
_blueForMarker = "";
_opForMarker = "";

{
  switch (getMarkerType _x) do {
    case "mil_flag": { _townMarkers pushback _x };
    case "b_hq": { _blueForMarker = _x };
    case "o_hq": { _opForMarker = _x };
  };
} foreach allMapMarkers;

{
  _town = "FlagPole_F" createVehicle (getMarkerPos _x);
  _towns pushBack _town;
  switch (getMarkerColor _x) do {
    case "ColorYellow": { _town setVariable ["type", "village"] };
    case "ColorBlack": { _town setVariable ["type", "town"] };
    case "ColorRed": { _town setVariable ["type", "airport"] };
  };
} forEach _townMarkers;

{
  [_x] execVM "scripts\server\townManager.sqf";
} forEach _towns;

sleep 3;  // Come back to this sleep command later!
[_blueForMarker, _towns, west] execVM "scripts\server\commander.sqf";
[_opForMarker, _towns, east] execVM "scripts\server\commander.sqf";
