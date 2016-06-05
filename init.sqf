if (isServer) then {
  call compile preprocessFileLineNumbers "scripts\server\init.sqf";
  _handle = execVM "scripts\server\gameManager.sqf";
};

if (hasInterface) then {
  hint "Welcome Client! How are you?";
  _handle2 = execVM "scripts\client\init.sqf";
};
