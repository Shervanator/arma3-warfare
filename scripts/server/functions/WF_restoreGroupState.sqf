params ["_savedGroup", "_side"];

_group = createGroup _side;

_units = _savedGroup select 0;
_vehicles = _savedGroup select 1;
_groupSettings = _savedGroup select 2;

_patrolPosition = _groupSettings select 0;
_patrolRadius = _groupSettings select 1;

_group setVariable ["patrolPosition", _patrolPosition];
_group setVariable ["patrolRadius", _patrolRadius];

_newVehicles = [];

{
  _classNameVehicle = _x select 0;
  _vehicleHealth = _x select 1;
  _vehiclePos = _x select 2;

  _vehicle = objNull;

  if (_classNameVehicle isKindOf "Air") then {
    _vehicle = createVehicle [_classNameVehicle, _vehiclePos, [], 0, "FLY"];
  } else {
    _vehicle = _classNameVehicle createVehicle _vehiclePos;
  };

  _newVehicles pushback _vehicle;

  _vehicleHitPointNames = _vehicleHealth select 0;
  _vehicleDamageValues = _vehicleHealth select 2;

  for "_i" from 0 to ((count _vehicleHitPointNames) - 1) do {
    _vehicle setHitPointDamage [(_vehicleHitPointNames select _i), (_vehicleDamageValues select _i)];
  };

  _group addVehicle _vehicle;

  _vehicle addEventHandler ["killed", {
    _killerGroup = group (_this select 1);
    _killerWallet = _killerGroup getVariable "wallet";
    if (!(isNil "_killerWallet")) then {
      _killerGroup setVariable ["wallet", _killerWallet + 10];
      (format ["killed get money: $%1", _killerWallet + 10]) remoteExec ["hint", 0];
    };
  }];
} forEach _vehicles;

{
  _className = _x select 0;
  _unitHealth = _x select 1;
  _unitPos = _x select 2;
  _vehicleIndex = _x select 3;
  _vehicleRole = _x select 4;

  _className createUnit [_unitPos, _group, "newUnit = this"];

  _hitPointNames = _unitHealth select 0;
  _damageValues = _unitHealth select 2;
  for "_i" from 0 to ((count _hitPointNames) - 1) do {
    newUnit setHitPointDamage [(_hitPointNames select _i), (_damageValues select _i)];
  };

  if (_vehicleIndex >= 0 && count _vehicleRole > 0) then {
    _vehicle = _newVehicles select _vehicleIndex;
    _roleType = _vehicleRole select 0;

    switch (toLower _roleType) do {
      case "driver": { newUnit moveInDriver _vehicle };
      case "cargo": { newUnit moveInCargo _vehicle };
      case "turret": { newUnit moveInTurret [_vehicle, _vehicleRole select 1] };
      case "commander": { newUnit moveInCommander _vehicle };
      case "gunner": { newUnit moveInGunner _vehicle };
    };
  };

  newUnit addEventHandler ["killed", {
    _killerGroup = group (_this select 1);
    _killerWallet = _killerGroup getVariable "wallet";
    if (!(isNil "_killerWallet")) then {
      _killerGroup setVariable ["wallet", _killerWallet + 10];
      (format ["killed get money: $%1", _killerWallet + 10]) remoteExec ["hint", 0];
    };
  }];

} forEach _units;

[_group, _patrolPosition, _patrolRadius] call BIS_fnc_taskPatrol;

_group
