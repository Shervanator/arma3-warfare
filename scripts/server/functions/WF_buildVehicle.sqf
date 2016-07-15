private ["_notEnoughChips", "_skill", "_vehicle"];
params ["_group", "_vehicleClass"];

_notEnoughChips = false;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_cost_" + _vehicleClass);
_skill = 1 - (random 0.3);

if (_wallet >= _price) then {
  _vehicle = _vehicleClass createVehicle (getPos (leader _group));
  _group addVehicle _vehicle;
  _vehicle setSkill _skill;
  _group setVariable ["wallet", _wallet - _price];
} else {
  _notEnoughChips = true;
};
/*(format ["$%1", _wallet]) remoteExec ["hint", 0];*/
_notEnoughChips
