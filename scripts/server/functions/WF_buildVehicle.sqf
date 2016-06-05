params ["_unit", "_vehicleClass"];

_group = group _unit;

_wallet = _group getVariable "wallet";
_vehicle = _vehicleClass createVehicle (getPos _unit);
_group addVehicle _vehicle;
_group setVariable ["wallet", _wallet - 100];

_wallet = _group getVariable "wallet";
((str _wallet) + (str _group)) remoteExec ["hint", 0];
