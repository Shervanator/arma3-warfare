private ["_grp"];
params ["_grp"];

{
  private ["_reverseFuncList"];

  _reverseFuncList = _x getVariable "reverseFuncList";
  if !(isNil "_reverseFuncList") then {
    {
      (_x select 2) call (_x select 1);
    } forEach _reverseFuncList;
  };
} forEach ([_grp, false] call WF_getGrpVehicles);

{
  private ["_reverseFuncList"];

  _reverseFuncList = _x getVariable "reverseFuncList";
  if !(isNil "_reverseFuncList") then {
    {
      (_x select 2) call (_x select 1);
    } forEach _reverseFuncList;
  };
} forEach (units _grp);
