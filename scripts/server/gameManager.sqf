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
  _fPole = "FlagPole_F" createVehicle (getMarkerPos _x);
  _towns pushBack _fPole;
} forEach _townMarkers;

{
  [_x] execVM "scripts\server\townManager.sqf";
} forEach _towns;

sleep 2;  // Come back to this sleep command later!
[_blueForMarker, _towns, west] execVM "scripts\server\commander.sqf";
[_opForMarker, _towns, east] execVM "scripts\server\commander.sqf";
