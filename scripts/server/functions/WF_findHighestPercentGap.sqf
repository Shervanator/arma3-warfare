private ["_comp", "_template", "_total", "_portion", "_highestPgap", "_index", "_i", "_portionGap"];
params ["_comp", "_template"];

_total = 0;
{
  _total = _total + _x;
} forEach _comp;

_portion = [];
{
  _portion pushBack (_x / _total);
} forEach _comp;

_highestPgap = -2;
_index = 0;
for "_i" from 0 to ((count _portion) - 1) do {
  _portionGap = (_template select _i) - (_portion select _i);
  if (_portionGap > _highestPgap) then {
    _highestPgap = _portionGap;
    _index = _i;
  };
};

_index
