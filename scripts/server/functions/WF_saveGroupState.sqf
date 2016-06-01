params ["_group"];

_units = [];
_vehicles = [];

{
  _className = typeOf _x;
  _unitHealth = getAllHitPointsDamage _x;
  _unitPos = getPos _x;

  _classNameVehicle = "";
  _vehicleHealth = [];
  _vehiclePos = []; // TODO: come back to this as vehicle will spawn on unit

  if ((vehicle _x != _x) && !((vehicle _x) in _vehicles)) then {
    _vehicle = vehicle _x;

    _classNameVehicle = typeOf _vehicle;
    _vehicleHealth = getAllHitPointsDamage _vehicle;
    _vehicles pushBack _vehicle;
    _vehiclePos = getPos _vehicle;
  };

  _units pushBack [_className, _unitHealth, _unitPos, _classNameVehicle, _vehicleHealth, _vehiclePos];
} forEach (units _group);

_units
