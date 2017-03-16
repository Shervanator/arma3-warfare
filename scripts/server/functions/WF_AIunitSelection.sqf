private ["_grpType", "_sideStr", "_moneyOrig", "_incomePerMinute", "_money", "_upperLimit", "_lowerLimit", "_template", "_numbTemplate", "_unitTypeNumbers", "_units", "_totalBT", "_totalCost", "_bt", "_lowerLimitBT"];
params ["_grpType", "_sideStr", "_moneyOrig", "_incomePerMinute"];

_money = +_moneyOrig;
_upperLimit = missionNamespace getVariable (_grpType + "AIGrpUpperLimit");
_lowerLimit = missionNamespace getVariable (_grpType + "AIGrpLowerLimit");
_template = missionNamespace getVariable (_sideStr + _grpType + "Template");

_numbTemplate = [];
{
  _numbTemplate pushBack (_x select 1);
} forEach _template;

_unitTypeNumbers = [];
{
  _unitTypeNumbers pushBack 0;
} forEach _numbTemplate;

_units = [];
_totalBT = 0;
_totalCost = 0;
_lowerLimitBT = -1;
for [{private _i = 0; private ["_index", "_shortestBT", "_unit", "_unitCost"]}, {_i < (_upperLimit - 1)}, {_i = _i + 1}] do {
  _index = [_unitTypeNumbers, _numbTemplate] call WF_findHighestPercentGap;
  _unitTypeNumbers set [_index, (_unitTypeNumbers select _index) + 1];
  _unitTemplate = +((_template select _index) select 2);

  _shortestBT = (((_template select _index) select 3) - _money) / _incomePerMinute;
  for [{private _i = 0; private ["_cost"]}, {_i < (count _unitTemplate)}, {_i = _i + 1}] do {
    _cost = missionNamespace getVariable ("WF_cost_" + (configName (_unitTemplate select _i)));
    if ((((_cost - _money) / _incomePerMinute) - _shortestBT) > 10) then {
      _unitTemplate deleteAt _i;
      _i = _i - 1;
    };
  };

  _unit = _unitTemplate select (floor (random (count _unitTemplate)));
  _unitCost = missionNameSpace getVariable ("WF_cost_" + (configName _unit));
  _bt = _totalBT + ((_unitCost - _money) / _incomePerMinute);

  if (((_i + 1) > _lowerLimit) and ((_bt - _lowerLimitBT) > 10)) exitWith {};

  if ((_i + 1) == _lowerLimit) then {
    _lowerLimitBT = _bt;
  };

  _units pushBack _unit;
  _totalBT = _bt;
  _totalCost = _totalCost + _unitCost;
  _money = _money - _unitCost;
};

[_units, _totalBT, _totalCost]
