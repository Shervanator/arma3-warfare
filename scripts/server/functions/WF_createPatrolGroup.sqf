
// village: 2 groups + apc
// town: 3 groups + apc + tank
// airport: 4 groups + 2 apcs + tank + ?motorized
// city: 4 groups + 2 apcs + tank

params ["_town"];
_position = getPos _town;
_side = _town getVariable "townOwner";
_townType = _town getVariable "type";
_patrolTypes = [];
_groups = [];

switch (_side) do {
  case resistance: {
    switch (_townType) do {
      case "village": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"), 2, 60];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Mechanized" >> "HAF_MechInfSquad"), 1, 100];
      };
      case "town": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"), 3, 100];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Mechanized" >> "HAF_MechInfSquad"), 1, 120];
        _patrolTypes pushBack [["I_MBT_03_cannon_F"], 1, 120];
      };
      case "city": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Mechanized" >> "HAF_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["I_MBT_03_cannon_F"], 1, 180];
      };
      case "airport": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Mechanized" >> "HAF_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["I_MBT_03_cannon_F"], 1, 180];
        _patrolTypes pushBack [["I_Heli_light_03_unarmed_F"], 1, 800];
        _patrolTypes pushBack [["I_Heli_light_03_F"], 1, 600];
      };
    };
  };

  case east: {
    switch (_townType) do {
      case "village": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"), 2, 60];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Mechanized" >> "OIA_MechInfSquad"), 1, 100];
      };
      case "town": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"), 3, 100];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Mechanized" >> "OIA_MechInfSquad"), 1, 120];
        _patrolTypes pushBack [["O_MBT_02_cannon_F"], 1, 120];
      };
      case "city": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Mechanized" >> "OIA_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["O_MBT_02_cannon_F"], 1, 180];
      };
      case "airport": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Mechanized" >> "OIA_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["O_MBT_02_cannon_F"], 1, 180];
        _patrolTypes pushBack [["O_Heli_Light_02_unarmed_F"], 1, 800];
        _patrolTypes pushBack [["O_Heli_Light_02_F"], 1, 600];
      };
    };
  };

  case west: {
    switch (_townType) do {
      case "village": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad"), 2, 60];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Mechanized" >> "BUS_MechInfSquad"), 1, 100];
      };
      case "town": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad"), 3, 100];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Mechanized" >> "BUS_MechInfSquad"), 1, 120];
        _patrolTypes pushBack [["B_MBT_01_cannon_F"], 1, 120];
      };
      case "city": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Mechanized" >> "BUS_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["B_MBT_01_cannon_F"], 1, 180];
      };
      case "airport": {
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad"), 4, 150];
        _patrolTypes pushBack [(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Mechanized" >> "BUS_MechInfSquad"), 2, 180];
        _patrolTypes pushBack [["B_MBT_01_cannon_F"], 1, 180];
        _patrolTypes pushBack [["B_Heli_Light_01_F"], 1, 800];
        _patrolTypes pushBack [["B_Heli_Light_01_armed_F"], 1, 600];
      };
    };
  };
};

{
  for "_i" from 0 to ((_x select 1) - 1) do {
    _radius = (_x select 2);
    _safeSpawnPos = [_position, 0, _radius, 8, 0, 20, 0] call BIS_fnc_findSafePos;
    _grp = [_safeSpawnPos, _side, (_x select 0)] call BIS_fnc_spawnGroup;

    [_grp, _position, _radius] call BIS_fnc_taskPatrol;
    _grp setVariable ["patrolPosition", _position];
    _grp setVariable ["patrolRadius", _radius];
    _groups pushBack _grp;
  };
} forEach _patrolTypes;

_groups
