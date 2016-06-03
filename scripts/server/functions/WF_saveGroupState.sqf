params ["_group"];

_units = [];
_vehiclesUnique = [];
_vehicles = [];
_groupSettings = [_group getVariable "patrolPosition", _group getVariable "patrolRadius"];

{
  _className = typeOf _x;
  _unitHealth = getAllHitPointsDamage _x;
  _unitPos = getPos _x;
  _vehicle = vehicle _x;
  _vehicleRole = assignedVehicleRole _x;

  _vehicleIndex = -1;

  if (_vehicle != _x) then {
    _vehicleIndex = _vehiclesUnique find _vehicle;
    
    if (_vehicleIndex < 0) then {
      _classNameVehicle = typeOf _vehicle;
      _vehicleHealth = getAllHitPointsDamage _vehicle;

      _vehiclePos = getPos _vehicle;

      _vehicles pushBack [_classNameVehicle, _vehicleHealth, _vehiclePos];
      _vehiclesUnique pushBack _vehicle;
      _vehicleIndex = (count _vehiclesUnique) - 1;
    };
  };

  _units pushBack [_className, _unitHealth, _unitPos, _vehicleIndex, _vehicleRole];
} forEach (units _group);

[_units, _vehicles, _groupSettings]
