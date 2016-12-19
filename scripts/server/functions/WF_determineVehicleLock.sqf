/*MUST setVariable any new units to be monitored on the vehicle, and also remove any units to be removed from monitoring via getVariable and deleteAt BEFORE executing this function!*/

private ["_vehicle", "_units", "_grp", "_side", "_emptyPosLocked", "_countDriverPos", "_countGunnerPos", "_countCommanderPos", "_countCargoPos", "_allTurretPos", "_turretPos", "_countTurretPos", "_alreadyRegistered", "_element", "_cargoIndex", "_turretIndex", "_getInWaitingList", "_countEmptySeats", "_getInVarSet", "_hasVehicle", "_assignedVehicle", "_unitAndSeat", "_handleKilled", "_killedEHList", "_driver", "_handleGetIn", "_handleGetOut", "_funcExistsOnVehicle", "_funcExistsOnUnit", "_reverseFunc", "_obj", "_monitorFunc"];
params ["_vehicle", "_grp", "_side"];

if !(isNil {_vehicle getVariable "monitoredUnits"}) then {
  _units = +(_vehicle getVariable "monitoredUnits");

  if (canMove _vehicle) then {
    _countDriverPos = _vehicle emptyPositions "Driver";
    _countGunnerPos = _vehicle emptyPositions "Gunner";
    _countCommanderPos = _vehicle emptyPositions "Commander";
    _allCargoPos = fullCrew [_vehicle, "cargo", true];
    _allTurretPos = fullCrew [_vehicle, "turret", true];

    _cargoPos = [];
    {
      if (isNull (_x select 0)) then {
        _cargoPos pushBack (_x select 2);
      };
    } forEach _allCargoPos;

    _turretPos = [];
    {
      if (isNull (_x select 0)) then {
        _turretPos pushBack (_x select 3);
      };
    } forEach _allTurretPos;

    _countCargoPos = count _cargoPos;
    _countTurretPos = count _turretPos;
    if ((_countDriverPos + _countGunnerPos + _countCommanderPos + _countCargoPos + _countTurretPos) > 0) then {
      _lockFunc = {
        if (_countCargoPos > 0) then {
          {
            _vehicle lockCargo [_x, true];
          } forEach _cargoPos;
        };

        if (_countTurretPos > 0) then {
          {
            _vehicle lockTurret [_x, true];
          } forEach _turretPos;
        };

        _vehicle setVariable ["emptyPosLocked", true];
      };

      _emptyPosLocked = _vehicle getVariable "emptyPosLocked";
      if (isNil "_emptyPosLocked") then {
        call _lockFunc;
      } else {
        if !(_emptyPosLocked) then {
          call _lockFunc;
        };
      };

      _cargoIndex = 0;
      _turretIndex = 0;
      {
        _getInWaitingList = _vehicle getVariable "getInWaitingList";
        _countEmptySeats = _countDriverPos + _countGunnerPos + _countCommanderPos + _countCargoPos + _countTurretPos;
        if ((((getPos _x) distanceSqr (getPos _vehicle)) < 90000) and (vehicle _x == _x) and (_countEmptySeats > 0) and (alive _x) and ((behaviour _x) != "COMBAT")) then {
          _hasVehicle = false;
          _assignedVehicle = assignedVehicle _x;
          if !(isNull _assignedVehicle) then {
            if (canMove _assignedVehicle) then {
              if (_assignedVehicle isEqualTo _vehicle) then {
                if !(isNil "_getInWaitingList") then {
                  if (_x in _getInWaitingList) then {
                    _hasVehicle = true;
                  };
                };
              } else {
                _hasVehicle = true;
              };
            } else {
              [_assignedVehicle, "GetIn", [_assignedVehicle, false, _side, [_x], 2]] call WF_runReverseFuncType;
            };
          };

          _getInVarSet = _vehicle getVariable "getInVarSet";
          if !(_hasVehicle) then {
            private ["_seatIsUnassigned", "_unitAssigned", "_loopCount", "_seat"];

            _seatIsUnassigned = {
              private ["_input", "_unassigned"];
              params ["_input"];

              _unassigned = true;
              if !(isNil "_getInVarSet") then {
                if (_input in (_getInVarSet select 3)) then {
                  _unassigned = false;
                };
              };

              _unassigned
            };

            _unitAssigned = false;
            _loopCount = 0;
            _unitAndSeat = [];
            _seat = [];
            while {(!(_unitAssigned) and (_loopCount < _countEmptySeats))} do {
              if (_countDriverPos > 0) then {
                _seat = ["driver"];
                if ([_seat] call _seatIsUnassigned) then {
                  _unitAndSeat = [_x, "driver"];
                  _x assignAsDriver _vehicle;
                  _unitAssigned = true;
                };

                _countDriverPos = _countDriverPos - 1;
              } else {
                if (_countGunnerPos > 0) then {
                  _seat = ["gunner"];
                  if ([_seat] call _seatIsUnassigned) then {
                    _unitAndSeat = [_x, "gunner"];
                    _x assignAsGunner _vehicle;
                    _unitAssigned = true;
                  };

                  _countGunnerPos = _countGunnerPos - 1;
                } else {
                  if (_countCommanderPos > 0) then {
                    _seat = ["commander"];
                    if ([_seat] call _seatIsUnassigned) then {
                      _unitAndSeat = [_x, "commander"];
                      _x assignAsCommander _vehicle;
                      _unitAssigned = true;
                    };

                    _countCommanderPos = _countCommanderPos - 1;
                  } else {
                    if (_countTurretPos > 0) then {
                      _seat = [_turretPos select _turretIndex, "turret"];
                      if ([_seat] call _seatIsUnassigned) then {
                        _unitAndSeat = [_x, _turretPos select _turretIndex, "turret"];
                        _vehicle lockTurret [_turretPos select _turretIndex, false];
                        _x assignAsTurret [_vehicle, _turretPos select _turretIndex];
                        _unitAssigned = true;
                      };

                      _countTurretPos = _countTurretPos - 1;
                      _turretIndex = _turretIndex + 1;
                    } else {
                      _seat = [_cargoPos select _cargoIndex, "cargo"];
                      if ([_seat] call _seatIsUnassigned) then {
                        _unitAndSeat = [_x, _cargoPos select _cargoIndex, "cargo"];
                        _vehicle lockCargo [_cargoPos select _cargoIndex, false];
                        _x assignAsCargo _vehicle;
                        _unitAssigned = true;
                      };

                      _countCargoPos = _countCargoPos - 1;
                      _cargoIndex = _cargoIndex + 1;
                    };
                  };
                };
              };

              _loopCount = _loopCount + 1;
            };

            if (_unitAssigned) then {
              [_x] orderGetIn true;
              _handleKilled = _x addEventHandler ["Killed", {
                private ["_unit", "_killedEHList", "_vehicle"];
                _unit = _this select 0;
                _killedEHList = _unit getVariable "killedEHList";
                {
                  if ((_x select 1) == _thisEventHandler) exitWith {
                    _vehicle = _x select 0;
                    [_vehicle, "GetIn", [_vehicle, false, _side, [_unit], 1]] call WF_runReverseFuncType;
                  };
                } forEach _killedEHList;
              }];

              _killedEHList = _x getVariable "killedEHList";
              if (isNil "killedEHList") then {
                _x setVariable ["killedEHList", [[_vehicle, _handleKilled]]];
              } else {
                _killedEHList pushBack [_vehicle, _handleKilled];
              };

              if (isNil "_getInWaitingList") then {
                _driver = driver _vehicle;
                if !(isNull _driver) then {
                  if !(isPlayer _driver) then {
                    _driver disableAI "MOVE";
                  };
                };

                _handleGetIn = _vehicle addEventHandler ["GetIn", {
                  [_this select 0, "GetIn", [_this select 0, false, _side, [_this select 2]]] call WF_runReverseFuncType;
                }];

                _vehicle setVariable ["getInWaitingList", [_x]];
                if (isNil "_getInVarSet") then {
                  _handleGetOut = _vehicle addEventHandler ["GetOut", {
                    [_this select 0, "GetIn", [_this select 0, false, _side, [_this select 2], 0]] call WF_runReverseFuncType;
                  }];

                  _getInVarSet = [_handleGetIn, 5, [_unitAndSeat], [_seat], _handleGetOut];
                  _vehicle setVariable ["getInVarSet", _getInVarSet];
                } else {
                  _getInVarSet set [0, _handleGetIn];
                  _getInVarSet set [1, 5];
                  (_getInVarSet select 2) pushBack _unitAndSeat;
                  (_getInVarSet select 3) pushBack _seat;
                };

                _monitorFunc = {
                  private ["_input", "_varList", "_index", "_vehicle", "_removeFunc", "_getInVarSet", "_getInWaitingList"];
                  params ["_input", "_varList", "_index"];

                  _vehicle = _input select 0;
                  _removeFunc = false;
                  if !(isNil "_vehicle") then {
                    _getInVarSet = _vehicle getVariable "getInVarSet";
                    _getInWaitingList = _vehicle getVariable "getInWaitingList";
                    if (!(isNil "_getInVarSet") and !(isNil "_getInWaitingList")) then {
                      _getInVarSet set [1, (_getInVarSet select 1) - 1];
                      if ((_getInVarSet select 1) <= 0) then {
                        [_vehicle, "GetIn", [_vehicle, false, _side, _getInWaitingList, 0]] call WF_runReverseFuncType;
                      };
                    } else {
                      _removeFunc = true;
                    };
                  } else {
                    _removeFunc = true;
                  };

                  if (_removeFunc) then {
                    _varList deleteAt _index;
                    _index = _index - 1;
                  };

                  _index
                };

                [_side] call WF_MonitorFuncListExists;
                (missionNamespace getVariable ("monitorFunctions" + (str _side))) pushBack [[_vehicle, "GetIn"], _monitorFunc, [_vehicle]];
              } else {
                _getInWaitingList pushBack _x;
                _getInVarSet set [1, 5];
                (_getInVarSet select 2) pushBack _unitAndSeat;
                (_getInVarSet select 3) pushBack _seat;
              };

              _funcExistsOnVehicle = [_vehicle, "GetIn", false] call WF_reverseFuncCheck;
              _funcExistsOnUnit = [_x, "GetIn", false] call WF_reverseFuncCheck;

              if (!(_funcExistsOnVehicle) and !(_funcExistsOnUnit)) then {
                _reverseFunc = {
                  private ["_vehicle", "_completeReverse", "_side", "_unitsOrig", "_unassign", "_units", "_getInWaitingList", "_getInVarSet", "_monitoredUnits", "_driver", "_unitAndSeatList", "_killedEHList", "_deleteFunc", "_emptyPosLocked"];
                  params ["_vehicle", "_completeReverse", "_side", "_unitsOrig", "_unassign"];

                  _units = +_unitsOrig;
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
                      [_side, [_vehicle, "GetIn"], true] call WF_monitorFuncCheck;
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

                        if (alive _unit) then {
                          unassignVehicle _unit;
                        };

                        [_unit, "GetIn", true] call WF_reverseFuncCheck;
                      } forEach (_getInVarSet select 2);

                      _vehicle removeEventHandler ["GetOut", _getInVarSet select 4];
                      _vehicle setVariable ["getInVarSet", nil];
                    };

                    {
                      _vehicle lockCargo [_x select 2, false];
                    } forEach (fullCrew [_vehicle, "cargo", true]);

                    {
                      _vehicle lockTurret [_x select 3, false];
                    } forEach (fullCrew [_vehicle, "turret", true]);

                    _emptyPosLocked = _vehicle getVariable "emptyPosLocked";
                    if !(isNil "_emptyPosLocked") then {
                      _vehicle setVariable ["emptyPosLocked", nil];
                    };

                    if !(isNil "_monitoredUnits") then {
                      _vehicle setVariable ["monitoredUnits", nil];
                      [_vehicle, "GetIn", true] call WF_reverseFuncCheck;
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
                          [_side, [_vehicle, "GetIn"], true] call WF_monitorFuncCheck;
                          if !(isNull _driver) then { // potential issue here if the driver whose AI was disabled is NOT the same as the driver who is currently assigned to the vehicle (however that may occur).
                            if !(isPlayer _driver) then {
                              _driver enableAI "MOVE";
                            };
                          };
                        };
                      } else {
                        _vehicle setVariable ["getInWaitingList", nil];
                        _vehicle removeEventHandler ["GetIn", _getInVarSet select 0];
                        [_side, [_vehicle, "GetIn"], true] call WF_monitorFuncCheck;
                        if !(isNull _driver) then {
                          if !(isPlayer _driver) then {
                            _driver enableAI "MOVE";
                          };
                        };
                      };
                    };

                    if !(isNil "_unassign") then {
                      if !(isNil "_getInVarSet") then {
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

                          [_x, "GetIn", true] call WF_reverseFuncCheck;
                        } forEach _units;

                        if ((count _unitAndSeatList) == 0) then {
                          _vehicle removeEventHandler ["GetOut", _getInVarSet select 4];
                          _vehicle setVariable ["getInVarSet", nil];
                        };
                      };

                      if ((_unassign > 0) and !(isNil "_monitoredUnits")) then {
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

                (_vehicle getVariable "reverseFuncList") pushBack ["GetIn", _reverseFunc, [_vehicle, true, _vehicle getVariable "monitoredUnits"]];
                (_x getVariable "reverseFuncList") pushBack ["GetIn", _reverseFunc, [_vehicle, false, [_x], 0]]; // Perhaps set unassign to 1?
              } else {
                if (_funcExistsOnVehicle) then {
                  _obj = _vehicle;
                } else {
                  _obj = _x;
                };

                {
                  if ((_x select 0) == "GetIn") then {
                    _reverseFunc = _x select 1;
                  };
                } forEach (_obj getVariable "reverseFuncList");

                if !(_funcExistsOnUnit) then {
                  (_x getVariable "reverseFuncList") pushBack ["GetIn", _reverseFunc, [_vehicle, false, [_x], 0]];
                } else {
                  (_vehicle getVariable "reverseFuncList") pushBack ["GetIn", _reverseFunc, [_vehicle, true, _vehicle getVariable "monitoredUnits"]];
                };
              };
            };
          };
        };
      } forEach _units;
    };
  } else {
    [_vehicle, "GetIn", [_vehicle, true, _side, _vehicle getVariable "monitoredUnits"]] call WF_runReverseFuncType;
  };
};
