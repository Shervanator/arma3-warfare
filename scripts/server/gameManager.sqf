_townMarkers = [];
_towns = [];
_blueForMarker = "";
_opForMarker = "";
missionNameSpace setVariable ["EASTlocations", []];
missionNameSpace setVariable ["WESTlocations", []];
missionNameSpace setVariable ["GUERlocations", []];

west setFriend [resistance, 0];
east setFriend [resistance, 0];
resistance setFriend [west, 0];
resistance setFriend [east, 0];

// TO BE DELETED LATER
_allPlayableUnits = [];
missionNameSpace setVariable ["allPlayableUnits", _allPlayableUnits];
//

{
  switch (getMarkerType _x) do {
    case "mil_flag": { _townMarkers pushback _x };
    case "b_hq": { _blueForMarker = _x };
    case "o_hq": { _opForMarker = _x };
  };
} foreach allMapMarkers;
missionNameSpace setVariable ["EASTHQPos", getMarkerPos _opForMarker];
missionNameSpace setVariable ["WESTHQPos", getMarkerPos _blueForMarker];

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

//------------------------------------------------------------------------------
// Defining variables
{
  _str = str _x;

  missionNamespace setVariable [_str + "caution_TPQue", []]; // used for vehicle tp in commander_determine_orders
  missionNamespace setVariable [_str + "caution_transportVehicles", []]; // same as above
} forEach [east, west];
//------------------------------------------------------------------------------

sleep 20; // this sleep time needs to be increased as town scripts now take longer than 10 seconds to execute (running in background). Alternatively come up with a better way
[[_blueForMarker, _towns, west], [_opForMarker, _towns, east]] execFSM "scripts\server\fsm\commander.fsm";
