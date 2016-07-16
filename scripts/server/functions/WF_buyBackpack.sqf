private ["_group", "_unit", "_wallet", "_price", "_backpackType"];
params ["_unit", "_backpackType"];

_group = group _unit;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_BACKPACK_" + _backpackType);

if (_wallet >= _price) then {
  _unit addBackpackGlobal _backpackType;

  _group setVariable ["wallet", _wallet - _price];
  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
