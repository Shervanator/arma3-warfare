params ["_actUnits"];

{
  _n = format ["%1", _x];
  _n remoteExec ["hint", 0, true];
  sleep 1;
} forEach _actUnits;
