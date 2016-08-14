private ["_vehicle", "_units", "_grp", "_resetLocks", "_countDriverPos", "_countGunnerPos", "_countCommanderPos", "_countCargoPos", "_allTurretPos", "_vehicleCanMove", "_turretPos", "_countTurretPos", "_checklist", "_alreadyRegistered", "_element", "_cargoIndex", "_turretIndex", "_hasVehicle", "_assignedVehicle"];
params ["_vehicle", "_units", "_grp", "_resetLocks", "_vehicleIsNew"];

_countDriverPos = _vehicle emptyPositions "Driver";
_countGunnerPos = _vehicle emptyPositions "Gunner";
_countCommanderPos = _vehicle emptyPositions "Commander";
_countCargoPos = _vehicle emptyPositions "Cargo";
_allTurretPos = fullCrew [_vehicle, "turret", true];
_vehicleCanMove = true;

_turretPos = [];
{
  if ((isNull (_x select 0)) and ((_x select 4) isEqualTo false)) then {
    _turretPos pushBack (_x select 3);
  };
} forEach _allTurretPos;

_countTurretPos = count _turretPos;
if ((_countGunnerPos + _countCommanderPos + _countCargoPos + _countTurretPos) > 0) then {
  _checklist = missionNameSpace getVariable ((str (side _grp)) + "ai_vehicle_transport_checklist");
  if (_resetLocks) then {
    if (_countCargoPos > 0) then {
      _vehicle lockCargo true;
    };
    {
      _vehicle lockTurret [_x, true];
    } forEach _turretPos;
  };

  _alreadyRegistered = false;
  {
    _element = _x;
    if ((_element select 0) isEqualTo _vehicle) exitWith {
      _alreadyRegistered = true;
      if (canMove _vehicle) then {
        {
          if !(_x in (_element select 1)) then {
            (_element select 1) pushBack _x;
          };
        } forEach _units;
      } else {
        _checklist deleteAt (_checklist find _element);
        _vehicleCanMove = false;
      };
    };
  } forEach _checklist;

  if !(_alreadyRegistered) then {
    _checklist pushBack [_vehicle, _units, _grp];
  };

  if (_vehicleCanMove) then {
    _cargoIndex = 0;
    _turretIndex = 0;
    {
      if ((((getPos _x) distanceSqr (getPos _vehicle)) < 160000) and (vehicle _x == _x) and ((_countGunnerPos + _countCommanderPos + _countCargoPos + _countTurretPos) > 0)) then {
        _hasVehicle = false;
        _assignedVehicle = assignedVehicle _x;
        if !(isNull _assignedVehicle) then {
          if (canMove _assignedVehicle) then {
            _hasVehicle = true;
          };
        };

        if !(_hasVehicle) then {
          if (_countDriverPos > 0) then {
            _x assignAsDriver _vehicle;
            _countDriverPos = _countDriverPos - 1;
          } else {
            if (_countGunnerPos > 0) then {
              _x assignAsGunner _vehicle;
              _countGunnerPos = _countGunnerPos - 1;
            } else {
              if (_countCommanderPos > 0) then {
                _x assignAsCommander _vehicle;
                _countCommanderPos = _countCommanderPos - 1;
              } else {
                if (_countTurretPos > 0) then {
                  _vehicle lockTurret [_turretPos select _turretIndex, false];
                  _x assignAsTurret [_vehicle, _turretPos select _turretIndex];
                  _countTurretPos = _countTurretPos - 1;
                  _turretIndex = _turretIndex + 1;
                } else {
                  _vehicle lockCargo [_cargoIndex, false];
                  _x assignAsCargo _vehicle;
                  _countCargoPos = _countCargoPos - 1;
                  _cargoIndex = _cargoIndex + 1;
                };
              };
            };
          };

          [_x] orderGetIn true;
        };
      };
    } forEach _units;
  };
};
