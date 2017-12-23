private ["_unitsSnapshot", "_paramSnapshot", "_unit", "_pos", "_side", "_include", "_includeSide"];

_unitsSnapshot = +allUnits;
_paramSnapshot = +WG_monitorPosParam;
{
  _unit = _x;
  _pos = getPos _unit;
  _side = side _unit;
  {
    _include = false;
    _includeSide = _x select 3;
    if !(isNil "_includeSide") then {
      if (_side == _includeSide) then {
        _include == true;
      };
    };

    if (_include) then {
      if (((abs (((_x select 0) select 0) - (_pos select 0))) > (_x select 1)) or ((abs (((_x select 0) select 1) - (_pos select 1))) > (_x select 1))) then {
        (_x select 2) pushBack _unit;
      };
    };
  } forEach _paramSnapshot;
} forEach _allUnitsSnapshot;
