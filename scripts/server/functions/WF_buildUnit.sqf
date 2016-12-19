private ["_notEnoughChips", "_wallet", "_group", "_price", "_vehicleClass", "_skill", "_unit"];
params ["_group", "_vehicleClass"];

_notEnoughChips = false;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_cost_" + _vehicleClass);
_skill = 1;

if (_wallet >= _price) then {
  _vehicleClass createUnit [getPos (leader _group), _group, "", _skill];
  _group setVariable ["wallet", _wallet - _price];
} else {
  _notEnoughChips = true;
};
/*(format ["$%1", _wallet]) remoteExec ["hint", 0];*/
_notEnoughChips
