params ["_unit", "_weaponClass"];

_group = group _unit;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_WEAPON_" + _weaponClass);

if (_wallet >= _price) then {
  _currentWeapon = currentWeapon _unit;
  _unit removeWeaponGlobal _currentWeapon;
  _unit addWeaponGlobal _weaponClass;

  _group setVariable ["wallet", _wallet - _price];
  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
