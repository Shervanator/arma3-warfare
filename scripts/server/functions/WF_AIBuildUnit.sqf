private ["_unitConfig", "_group", "_side", "_notEnoughChips", "_unitClass", "_wallet", "_price", "_vehicle", "_safeSpawnPos", "_skill", "_hqPos"];
params ["_unitConfig", "_group", "_side"];

_notEnoughChips = false;
_hqPos = missionNameSpace getVariable ((str (side _group)) + "HQPos");
_unitClass = configName _unitConfig;
_wallet = _group getVariable "wallet";
_price = missionNamespace getVariable ("WF_cost_" + _unitClass);

if (_wallet >= _price) then {
  _group setVariable ["unitInQue", false];
  _group setVariable ["wallet", _wallet - _price];
  _safeSpawnPos = [_hqPos, 0, 100, 8, 0, 10, 0] call BIS_fnc_findSafePos;
  _skill = 1;

  if ("Man" in ([_unitConfig, true] call BIS_fnc_returnParents)) then {
    _unitClass createUnit [_safeSpawnPos, _group, "", _skill];
  } else {
    _vehicle = _unitClass createVehicle _safeSpawnPos;
    _group addVehicle _vehicle;
    createVehicleCrew _vehicle;
    (crew _vehicle) join _group;
    _vehicle setSkill _skill;
    _vehicle setVariable ["monitoredUnits", [leader _group]];
    [_vehicle, _group, _side] call WF_determineVehicleLock;
  };
} else {
  _notEnoughChips = true;
  _group setVariable ["unitInQue", _unitConfig];
};

_notEnoughChips
