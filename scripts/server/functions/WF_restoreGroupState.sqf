params ["_savedGroups", "_side"];

_groups = [];

{
  _group = createGroup _side;
  _groups pushBack _group;

  {
    _className = _x select 0;
    _unitHealth = _x select 1;
    _unitPos = _x select 2;

    _classNameVehicle = _x select 3;
    _vehicleHealth = _x select 4;
    _vehiclePos = _x select 5;

    _className createUnit [_unitPos, _group, "newUnit = this"];

    _hitPointNames = _unitHealth select 0;
    _damageValues = _unitHealth select 2;
    for "_i" from 0 to ((count _hitPointNames )- 1) do {
      newUnit setHitPointDamage [(_hitPointNames select _i), (_damageValues select _i)];
    };

    if (_classNameVehicle != "") then {
      _vehicle = _classNameVehicle createVehicle _vehiclePos;
      _vehicleHitPointNames = _vehicleHealth select 0;
      _vehicleDamageValues = _vehicleHealth select 2;
      for "_i" from 0 to ((count _vehicleHitPointNames) - 1) do {
        _vehicle setHitPointDamage [(_vehicleHitPointNames select _i), (_vehicleDamageValues select _i)];
      };

      _group addVehicle _vehicle;
    };
  } forEach _x;
} forEach _savedGroups;

_groups
