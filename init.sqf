if (isServer) then {
  _handle = execVM "scripts\server\gameManager.sqf";
} else {
  hint "Welcome Client! How are you?";
};
