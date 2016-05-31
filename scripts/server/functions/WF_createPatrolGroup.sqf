
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

  case west: {
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
};

{
  for "_i" from 0 to ((_x select 1) - 1) do {
    _grp = [_position vectorAdd [(random (_x select 2)), (random (_x select 2)), 0], _side, (_x select 0)] call BIS_fnc_spawnGroup;
    [_grp, _position, (_x select 2)] call BIS_fnc_taskPatrol;
    _groups pushBack _grp;
  };
} forEach _patrolTypes;

_groups