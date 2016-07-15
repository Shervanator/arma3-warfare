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



_opForGroups = [];
_blueForGroups = [];
missionNameSpace setVariable ["EASTinfSqds", []];
missionNameSpace setVariable ["WESTinfSqds", []];
missionNameSpace setVariable ["EASTarmorSqds", []];
missionNameSpace setVariable ["WESTarmorSqds", []];
missionNameSpace setVariable ["EASTairSqds", []];
missionNameSpace setVariable ["WESTairSqds", []];

{
  switch (side _x) do {
    case west: {
      _blueForGroups pushBack _x;
      _x setVariable ["currentObjective", objNull];
      (missionNamespace getVariable "WESTinfSqds") pushBack _x;
      _x setVariable ["grpType", "inf"];
    };

    case east: {
      _opForGroups pushBack _x;
      _x setVariable ["currentObjective", objNull];
      (missionNamespace getVariable "EASTinfSqds") pushBack _x;
      _x setVariable ["grpType", "inf"];
    };
  };

  if (isPlayer (leader _x)) then {
    _x setVariable ["wallet", 500];
  } else {
    _x setVariable ["wallet", 500];
  };
} forEach allGroups;

sleep 20; // this sleep time needs to be increased as town scripts now take longer than 10 seconds to execute (running in background). Alternatively come up with a better way
missionNamespace setVariable ["EASTincome", 0];
missionNamespace setVariable ["WESTincome", 0];
missionNamespace setVariable ["countEASTgrps", count _opForGroups];
missionNamespace setVariable ["countWESTgrps", count _blueForGroups];
[_blueForMarker, _towns, west, _blueForGroups] execFSM "scripts\server\fsm\commander.fsm";
[_opForMarker, _towns, east, _opForGroups] execFSM "scripts\server\fsm\commander.fsm";
