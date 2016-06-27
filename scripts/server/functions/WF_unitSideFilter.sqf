private ["_units", "_sides", "_output"];
params ["_units", "_sides"];

_output = [];

{
  _unit = _x;

  {
    if (side _unit == _x) exitWith {
      _output pushBack _unit;
    };
  } forEach _sides;
} forEach _units;

_output
