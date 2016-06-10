params ["_side"];
_units = [];

switch (_side) do {
  case east: {
    _units = WF_opForVehiclesArmored;
  };

  case west: {
    _units = WF_bluForVehiclesArmored;
  };
};

_units
