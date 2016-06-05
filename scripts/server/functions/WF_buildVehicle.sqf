params ["_group", "_vehicleClass"];

_wallet = _group getVariable "wallet";

if (_wallet >= 600) then {
  _vehicle = _vehicleClass createVehicle (getPos (leader _group));
  _group addVehicle _vehicle;
  _group setVariable ["wallet", _wallet - 600];

  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
