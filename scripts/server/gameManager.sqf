_townMarkers = [];
_towns = [];
_blueForMarker = "";
_opForMarker = "";

west setFriend [resistance, 0];
east setFriend [resistance, 0];
resistance setFriend [west, 0];
resistance setFriend [east, 0];

{
  switch (getMarkerType _x) do {
    case "mil_flag": { _townMarkers pushback _x };
    case "b_hq": { _blueForMarker = _x };
    case "o_hq": { _opForMarker = _x };
  };
} foreach allMapMarkers;

{
  _town = "FlagPole_F" createVehicle (getMarkerPos _x);
  _town setVariable ["marker", _x];
  _towns pushBack _town;
  switch (getMarkerColor _x) do {
    case "ColorYellow": { _town setVariable ["type", "village"] };
    case "ColorBlack": { _town setVariable ["type", "town"] };
    case "ColorRed": { _town setVariable ["type", "airport"] };
  };
} forEach _townMarkers;

{
  [_x] execVM "scripts\server\town\townManager.sqf";
} forEach _towns;



_opForGroups = [];
_blueForGroups = [];

{
  switch (side _x) do {
    case west: { _blueForGroups pushBack _x; };
    case east: { _opForGroups pushBack _x; };
  };

  if (isPlayer (leader _x)) then {
    _x setVariable ["wallet", 10000];
  } else {
    _x setVariable ["wallet", 1000];
  };
} forEach allGroups;

sleep 10;
[_blueForMarker, _towns, west, _blueForGroups] execFSM "scripts\server\fsm\commander.fsm";
[_opForMarker, _towns, east, _opForGroups] execFSM "scripts\server\fsm\commander.fsm";
