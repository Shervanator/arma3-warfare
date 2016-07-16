private ["_group"];
params ["_group"];

{
  if (vehicle _x != _x) then {
    deleteVehicle (vehicle _x);
  };
  deleteVehicle _x;
} forEach (units _group);

deleteGroup _group;
