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

_opForGroups = [];
_blueForGroups = [];

{
  switch (side _x) do {
    case west: {
      _blueForGroups pushBack _x;
      _x setVariable ["currentObjective", objNull];
    };

    case east: {
      _opForGroups pushBack _x;
      _x setVariable ["currentObjective", objNull];
    };
  };
  missionNameSpace setVariable ["EASTgrps", _opForGroups];
  missionNameSpace setVariable ["WESTgrps", _blueForGroups];

  if (isPlayer (leader _x)) then {
    _x setVariable ["wallet", 500];
  } else {
    _x setVariable ["wallet", 500];
  };
} forEach allGroups;

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

sleep 20; // this sleep time needs to be increased as town scripts now take longer than 10 seconds to execute (running in background). Alternatively come up with a better way
missionNamespace setVariable ["EASTincome", 0];
missionNamespace setVariable ["WESTincome", 0];
missionNamespace setVariable ["countEASTAIgrps", 0];
missionNamespace setVariable ["countWESTAIgrps", 0];
missionNamespace setVariable ["EASTai_vehicle_transport_checklist" , []];
missionNamespace setVariable ["WESTai_vehicle_transport_checklist" , []];
[_blueForMarker, _towns, west, _blueForGroups] execFSM "scripts\server\fsm\commander.fsm";
[_opForMarker, _towns, east, _opForGroups] execFSM "scripts\server\fsm\commander.fsm";
