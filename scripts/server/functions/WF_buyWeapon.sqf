params ["_unit", "_weaponClass"];

_currentWeapon = currentWeapon _unit;
hint _currentWeapon;
_unit removeWeaponGlobal _currentWeapon;
_unit addWeaponGlobal _weaponClass;
