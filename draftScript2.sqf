private ["_handleKilled", "_killedEHList", "_getInWaitingList", "_getInVarSet", "_driver", "_handleGetIn", "_funcExists", "_reverseFunc", "_monitorScriptHandle"];

_handleKilled = _x addEventHandler ["Killed", {
  private ["_unit", "_killedEHList", "_vehicle"];
  _unit = _this select 0;
  _killedEHList = _unit getVariable "killedEHList";
  {
    if ((_x select 1) == _thisEventHandler) exitWith {
      _vehicle = _x select 0;
      [_vehicle, "GetIn", [_vehicle, false, [_unit], 1]] call WF_runReverseFuncType;
    };
  } forEach _killedEHList;
}];

_killedEHList = _x getVariable "killedEHList";
if (isNil "killedEHList") then {
  _x setVariable ["killedEHList", [[_vehicle, _handleKilled]]];
} else {
  _killedEHList pushBack [_vehicle, _handleKilled];
};

_getInWaitingList = _vehicle getVariable "getInWaitingList";
_getInVarSet = _vehicle getVariable "getInVarSet";
if (isNil "_getInWaitingList") then {
  _driver = driver _vehicle;
  if !(isNull _driver) then {
    if !(isPlayer _driver) then {
      _driver disableAI "MOVE";
    };
  };

  _handleGetIn = _vehicle addEventHandler ["GetIn", {
    [_this select 0, "GetIn", [_this select 0, false, [_this select 2]]] call WF_runReverseFuncType;
  }];

  _vehicle setVariable ["getInWaitingList", [_x]];
  if (isNil "_getInVarSet") then {
    _vehicle setVariable ["getInVarSet", [_handleGetIn, 5, [_unitAndSeat]]];
    _funcExists = [_vehicle, "GetIn", false] call WF_reverseFuncCheck;

    if !(_funcExists) then {
      _reverseFunc = {
        private ["_vehicle", "_completeReverse", "_units", "_unassign", "_getInWaitingList", "_getInVarSet", "_monitoredUnits", "_driver", "_unitAndSeatList", "_killedEHList", "_deleteFunc"];
        params ["_vehicle", "_completeReverse", "_units", "_unassign"];

        _getInWaitingList = _vehicle getVariable "getInWaitingList";
        _getInVarSet = _vehicle getVariable "getInVarSet";
        _monitoredUnits = _vehicle getVariable "monitoredUnits";
        _driver = assignedDriver _vehicle;

        if (_completeReverse) then {
          // Complete Reverse
          if !(isNil "_getInWaitingList") then {
            if !(isNull _driver) then {
              if !(isPlayer _driver) then {
                _driver enableAI "MOVE";
              };
            };

            _vehicle setVariable ["getInWaitingList", nil];
            _vehicle removeEventHandler ["GetIn", _getInVarSet select 0];
            terminate (_getInVarSet select 3);
          };

          if !(isNil "_getInVarSet") then {
            {
              private ["_unit", "_killedEHList"];

              _unit = _x select 0;
              _killedEHList = _unit getVariable "killedEHList";
              if !(isNil "_killedEHList") then {
                for [{private _i = 0; private ["_element"]}, {_i < (count _killedEHList)}, {_i = _i + 1}] do {
                  _element = _killedEHList select _i;
                  if ((_element select 0) isEqualTo _vehicle) then {
                    _unit removeEventHandler ["Killed", _element select 1];
                    _killedEHList deleteAt _i;
                    _i = _i - 1;
                  };
                };

                if ((count _killedEHList) == 0) then {
                  _unit setVariable ["killedEHList", nil];
                };
              };

              if ((count _x) > 2) then {
                if ((_x select 2) == "turret") then {
                  _vehicle lockTurret [_x select 1, false];
                } else {
                  _vehicle lockCargo [_x select 1, false];
                };
              };
            } forEach (_getInVarSet select 2);

            _vehicle setVariable ["getInVarSet", nil];
          };

          if !(isNil "_monitoredUnits") then {
            _vehicle setVariable ["monitoredUnits", nil];
          };
        } else {
          // PARTIAL REVERSE
          if !(isNil "_getInWaitingList") then {
            if (canMove _vehicle) then {
              {
                for [{private _i = 0}, {_i < (count _getInWaitingList)}, {_i = _i + 1}] do {
                  if ((_getInWaitingList select _i) == _x) then {
                    _getInWaitingList deleteAt _i;
                    _i = _i - 1;
                  };
                };
              } forEach _units;

              if ((count _getInWaitingList) == 0) then {
                _vehicle setVariable ["getInWaitingList", nil];
                _vehicle removeEventHandler ["GetIn", _getInVarSet select 0];
                terminate (_getInVarSet select 3);
                if !(isNull _driver) then { // potential issue here if the driver whose AI was disabled is NOT the same as the driver who is currently assigned to the vehicle (however that may occur).
                  if !(isPlayer _driver) then {
                    _driver enableAI "MOVE";
                  };
                };
              };
            } else {
              _vehicle setVariable ["getInWaitingList", nil];
              _vehicle removeEventHandler ["GetIn", _getInVarSet select 0];
              terminate (_getInVarSet select 3);
              if !(isNull _driver) then {
                if !(isPlayer _driver) then {
                  _driver enableAI "MOVE";
                };
              };
            };
          };

          if !(isNil "_unassign") then {
            _unitAndSeatList = _getInVarSet select 2;
            {
              for [{private _i = 0; private ["_unitAndSeat"]}, {_i < (count _unitAndSeatList)}, {_i = _i + 1}] do {
                _unitAndSeat = _unitAndSeatList select _i;
                if ((_unitAndSeat select 0) == _x) then {
                  if ((count _unitAndSeat) > 2) then {
                    if ((_unitAndSeat select 2) == "turret") then {
                      _vehicle lockTurret [_unitAndSeat select 1, true];
                    } else {
                      _vehicle lockCargo [_unitAndSeat select 1, true];
                    };
                  };

                  _unitAndSeatList deleteAt _i;
                  _i = _i - 1;
                };
              };

              _killedEHList = _x getVariable "killedEHList";
              if !(isNil "_killedEHList") then {
                for [{private _i = 0; private ["_element"]}, {_i < (count _killedEHList)}, {_i = _i + 1}] do {
                  _element = _killedEHList select _i;
                  if ((_element select 0) isEqualTo _vehicle) then {
                    _x removeEventHandler ["Killed", _element select 1];
                    _killedEHList deleteAt _i;
                    _i = _i - 1;
                  };
                };

                if ((count _killedEHList) == 0) then {
                  _x setVariable ["killedEHList", nil];
                };
              };

              if (alive _x) then {
                unassignVehicle _x;
              };
            } forEach _units;

            if ((count _unitAndSeatList) == 0) then {
              _vehicle setVariable ["getInVarSet", nil];
            };

            if (_unassign > 0) then {
              _deleteFunc = {
                private ["_unit", "_monitoredUnits"];
                params ["_unit", "_monitoredUnits"];

                for [{private _i = 0}, {_i < (count _monitoredUnits)}, {_i = _i + 1}] do {
                  if ((_monitoredUnits select _i) == _unit) then {
                    _monitoredUnits deleteAt _i;
                    _i = _i - 1;
                  };
                };
              };

              {
                if ((_unassign > 1) or !(_x in (missionNamespace getVariable "allPlayableUnits"))) then {
                  [_x, _monitoredUnits] call _deleteFunc;
                };
              } forEach _units;

              if ((count _monitoredUnits) == 0) then {
                _vehicle setVariable ["monitoredUnits", nil];
                _getInVarSet = _vehicle getVariable "getInVarSet";
                if (isNil "_getInVarSet") then {
                  [_vehicle, "GetIn", true] call WF_reverseFuncCheck;
                };
              };
            };
          };
        };
      };

      (_vehicle getVariable "reverseFuncList") pushBack ["GetIn", _reverseFunc];
    };
  } else {
    _getInVarSet set [0, _handleGetIn];
    _getInVarSet set [1, 5];
    (_getInVarSet select 2) pushBack _unitAndSeat;
  };

  _monitorScriptHandle = [_vehicle] execVM "scripts\server\procedures\WP_aiGetInVehicleMonitor.sqf";
  _getInVarSet set [3, _monitorScriptHandle];
} else {
  _getInWaitingList pushBack _x;
  _getInVarSet set [1, 5];
};
