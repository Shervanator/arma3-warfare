params ["_group", "_vehicleClass"];

_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_UNIT_" + _vehicleClass);

if (_wallet >= _price) then {
  _vehicleClass createUnit [ getPos (leader _group), _group ];
  _group setVariable ["wallet", _wallet - _price];

  _wallet = _group getVariable "wallet";
};
/*(format ["$%1", _wallet]) remoteExec ["hint", 0];*/
