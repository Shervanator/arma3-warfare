params ["_side"];
_units = [];

switch (_side) do {
  case east: {
    _units = WF_opForVehiclesCar;
  };

  case west: {
    _units = WF_bluForVehiclesCar;
  };
};

_units