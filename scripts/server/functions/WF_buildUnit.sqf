params ["_unit", "_vehicleClass"];

_group = group _unit;

_wallet = _group getVariable "wallet";
_vehicleClass createUnit [ getPos _unit, _group ];
_group setVariable ["wallet", _wallet - 100];

_wallet = _group getVariable "wallet";
((str _wallet) + (str _group)) remoteExec ["hint", 0];
