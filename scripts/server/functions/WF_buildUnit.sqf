params ["_group", "_vehicleClass"];

_wallet = _group getVariable "wallet";

if (_wallet >= 200) then {
  _vehicleClass createUnit [ getPos (leader _group), _group ];
  _group setVariable ["wallet", _wallet - 200];

  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
