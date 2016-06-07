params ["_side"];
_units = [];

switch (_side) do {
  case east: {
    _units = WF_opForUnits;
  };

  case west: {
    _units = WF_bluForUnits;
  };
};

_units
