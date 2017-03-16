private ["_unitConfigs", "_side", "_totalCost", "_type", "_parents", "_notEnoughChips", "_sideStr", "_money", "_group", "_hqPos", "_unitClass", "_price", "_safeSpawnPos", "_skill", "_vehicle"];
params ["_unitConfigs", "_side", "_totalCost", "_type", "_parents"];

_notEnoughChips = false;
_sideStr = str _side;
_money = missionNamespace getVariable (_sideStr + "money");

if (_money >= _totalCost) then {
  _group = createGroup _side;
  _hqPos = missionNameSpace getVariable ((str (side _group)) + "HQPos");
  {
    _unitClass = configName _x;
    _price = missionNamespace getVariable ("WF_cost_" + _unitClass);
    _money = _money - _price;

    _safeSpawnPos = [_hqPos, 0, 100, 8, 0, 10, 0] call BIS_fnc_findSafePos;
    _skill = 1;
    if ("Man" in ([_x, true] call BIS_fnc_returnParents)) then {
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
  } forEach _unitConfigs;

  missionNamespace setVariable [_sideStr + _type + "InQue", nil];

  if !(isNil "_parents") then {
    {
      _x pushBack _group;
    } forEach _parents;
  };

  missionNamespace setVariable [_sideStr + "money", _money];
} else {
  _notEnoughChips = true;
};

_notEnoughChips
