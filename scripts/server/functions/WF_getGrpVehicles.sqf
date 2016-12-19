private ["_grp", "_functionalOnly", "_vehicles", "_vehicle", "_assignedVehicle"];
params ["_grp", "_functionalOnly"];

_vehicles = [];
{
  _vehicle = vehicle _x;
  if (_vehicle != _x) then {
    if (_functionalOnly) then {
      if (canMove _vehicle) then {
        _vehicles pushBackUnique _vehicle;
      };
    } else {
      _vehicles pushBackUnique _vehicle;
    };
  } else {
    _assignedVehicle = assignedVehicle _x;
    if !(isNull _assignedVehicle) then {
      if (_functionalOnly) then {
        if (canMove _assignedVehicle) then {
          _vehicles pushBackUnique _assignedVehicle;
        };
      } else {
        _vehicles pushBackUnique _assignedVehicle;
      };
    };
  };
} forEach (units _grp);

_vehicles
