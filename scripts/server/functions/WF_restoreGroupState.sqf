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

    _unit = _className createUnit [_unitPos, _group];
    for "_i" from 0 to (count (_unitHealth select 0) - 1) do {
      _unit setHitPointDamage ((_unitHealth select 0) select _i) ((_unitHealth select 2) select _i);
    };

    if (_classNameVehicle != "") then {
      _vehicle = _classNameVehicle createVehicle _vehiclePos;
      for "_i" from 0 to (count (_vehicleHealth select 0) - 1) do {
        _vehicle setHitPointDamage ((_vehicleHealth select 0) select _i) ((_vehicleHealth select 2) select _i);
      };

      _group addVehicle _vehicle;
    };
  } forEach _x;
} forEach _savedGroups;

_groups
