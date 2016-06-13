params ["_group", "_vehicleClass"];

_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_VEHICLE_" + _vehicleClass);

if (_wallet >= _price) then {
  _vehicle = _vehicleClass createVehicle (getPos (leader _group));
  _group addVehicle _vehicle;
  _group setVariable ["wallet", _wallet - _price];

  _wallet = _group getVariable "wallet";
};
(format ["$%1", _wallet]) remoteExec ["hint", 0];
