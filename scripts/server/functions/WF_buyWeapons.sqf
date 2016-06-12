params ["_unit", "_weaponClass"];

_currentWeapon = currentWeapon _unit;
_unit removeWeaponGlobal _currentWeapon;
_unit addWeaponGlobal _weaponClass;
