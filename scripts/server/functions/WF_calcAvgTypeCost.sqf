private ["_unitTypes", "_totCost"];
params ["_unitTypes"];

_totCost = 0;
{
  _totCost = (_x select 1) + _totCost;
} forEach _unitTypes;

_avgCost = _totCost / (count _unitTypes);
_avgCost
