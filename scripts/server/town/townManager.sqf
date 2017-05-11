params ["_town"];

(missionNameSpace getVariable "GUERlocations") pushBack _town;
_townPos = getPos _town;

switch (_town getVariable "type") do {
  case "village": {
    _town setVariable ["capZone", ([_townPos, 65] call WF_createTrigger)];
    _town setVariable ["alertZone", ([_townPos, 1000] call WF_createTrigger)];
  };
  case "town": {
    _town setVariable ["capZone", ([_townPos, 130] call WF_createTrigger)];
    _town setVariable ["alertZone", ([_townPos, 1200] call WF_createTrigger)];
  };
  case "airport": {
    _town setVariable ["capZone", ([_townPos, 270] call WF_createTrigger)];
    _town setVariable ["alertZone", ([_townPos, 1500] call WF_createTrigger)];
  };
};

sleep 2; // TODO: come back to this
_town execFSM "scripts\server\fsm\townController.fsm";
