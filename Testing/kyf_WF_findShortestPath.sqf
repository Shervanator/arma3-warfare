private [];
params ["_startPos", "_endPos", "_startZoneInfo", "_endZoneInfo"];

//------------------------------------------------------------------------------
// find zone info if not provided

// *** is this necessary???
_startZone = -1;
_endZone = -1;

if (isNil "_startZoneInfo") then {
  _startZone = [_startPos] call kyf_WF_findZone;
} else {
  if ("_startZoneInfo" == -1) then {
    _startZone = [_startPos] call kyf_WF_findZone;
  } else {
    _startZone = _startZoneInfo;
  };
};

if (isNil "_endZoneInfo") then {
  _endZone = [_endPos] call kyf_WF_findZone;
} else {
  if ("_endZoneInfo" == -1) then {
    _endZone = [_endPos] call kyf_WF_findZone;
  } else {
    _endZone = _endZoneInfo;
  };
};

//------------------------------------------------------------------------------
//
