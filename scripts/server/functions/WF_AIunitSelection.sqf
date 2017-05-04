private ["_grpType", "_sideStr", "_moneyOrig", "_incomePerMinute", "_currentUnitCount", "_money", "_upperLimit", "_lowerLimit", "_template", "_numbTemplate", "_typeCount", "_idealGrpSize", "_units", "_totalBT", "_finalBT", "_return"];
params ["_grpType", "_sideStr", "_moneyOrig", "_incomePerMinute", "_currentUnitCount"];

_money = +_moneyOrig;
_upperLimit = missionNamespace getVariable (_grpType + "AIGrpUpperLimit");
_lowerLimit = missionNamespace getVariable (_grpType + "AIGrpLowerLimit");
_template = missionNamespace getVariable (_sideStr + _grpType + "Template");
_return = [];

_numbTemplate = [];
{
  _numbTemplate pushBack (_x select 1);
} forEach _template;

_typeCount = [];
{
  _typeCount pushBack 0;
} forEach _numbTemplate;

_idealGrpSize = _lowerLimit + floor (random (_upperLimit + 1 - _lowerLimit));
_units = [];
_totalBT = 0;
for [{private _i = 1; private _unitSize = 0; private _lowerLimitBT = -1; private ["_index", "_unitTemplate", "_shortestBT", "_unit", "_unitCost"]}, {_i <= _idealGrpSize}, {_i = _i + 1}] do {
  _index = [_typeCount, _numbTemplate] call WF_findHighestPercentGap;
  _typeCount set [_index, (_typeCount select _index) + 1];
  _unitTemplate = +((_template select _index) select 2);

  _shortestBT = (((_template select _index) select 3) - _money) / _incomePerMinute;
  if (_shortestBT < 0) then {
    _shortestBT = 0;
  };

  for [{private _i = 0; private ["_cost"]}, {_i < (count _unitTemplate)}, {_i = _i + 1}] do {
    _cost = missionNamespace getVariable ("WF_cost_" + (configName (_unitTemplate select _i)));
    if ((((_cost - _money) / _incomePerMinute) - _shortestBT) > 10) then {
      _unitTemplate deleteAt _i;
      _i = _i - 1;
    };
  };

  _unit = _unitTemplate select (floor (random (count _unitTemplate)));
  _unitCost = missionNameSpace getVariable ("WF_cost_" + (configName _unit));

  if (_grpType == "inf") then {
    _unitSize = _i;
  } else {
    _unitSize = [_units + [_unit]] call WF_countEssentialVehicleCrew;
  };

  if (_unitSize > (WFG_unitCap - _currentUnitCount)) exitWith {
    _units = [];
  };

  _totalBT = (_unitCost - _money) / _incomePerMinute;
  if (_totalBT < 0) then {
    _totalBT = 0;
  };

  if (_i == _lowerLimit) then {
    _lowerLimitBT = _totalBT;
  };

  if ((_i > _lowerLimit) and ((_totalBT - _lowerLimitBT) > 10)) exitWith {};

  _units pushBack _unit;
  _money = _money - _unitCost;
};

if ((count _units) >= _lowerLimit) then {
  _finalBT = -1 * _money / _incomePerMinute; // _finalBT is the total time it takes to build this group given the money and income per minute.
  if (_finalBT < 0) then {
    _finalBT = 0;
  };
  _return = [_units, _finalBT, _moneyOrig - _money, _grpType];
};

_return
