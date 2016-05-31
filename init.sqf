if (isServer) then {
  call compile preprocessFileLineNumbers "scripts\server\init.sqf";
  _handle = execVM "scripts\server\gameManager.sqf";
} else {
  hint "Welcome Client! How are you?";
};
