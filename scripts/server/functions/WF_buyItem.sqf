private ["_group", "_unit", "_wallet", "_price", "_ammoType"];
params ["_unit", "_ammoType"];

_group = group _unit;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_ITEM_" + _ammoType);

if (_wallet >= _price) then {
  _unit addItemToBackpack _ammoType;

  _group setVariable ["wallet", _wallet - _price];
  _wallet = _group getVariable "wallet";
};

(format ["$%1", _wallet]) remoteExec ["hint", 0];
