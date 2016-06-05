params ["_unit"];

_group = group _unit;

_wallet = _group getVariable "wallet";
"O_G_Soldier_F" createUnit [ getPos _unit, _group ];
_group setVariable ["wallet", _wallet - 100];

_wallet = _group getVariable "wallet";
((str _wallet) + (str _group)) remoteExec ["hint", 0];
