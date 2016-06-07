params ["_group", "_vehicleClass", "_price"];

_wallet = _group getVariable "wallet";

if (_wallet >= _price) then {
  _vehicleClass createUnit [ getPos (leader _group), _group ];
  _group setVariable ["wallet", _wallet - _price];

  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
