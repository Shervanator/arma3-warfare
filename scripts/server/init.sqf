WFG_commanderCycleTime = 30;
WFG_baseIncome = 20;
WFG_villageIncome = 10;
WFG_townIncome = 20;
WFG_AirportIncome = 30;
WG_grpLimit = 11;

_WF_opForInfAPUnits = [
  configFile >> "CfgVehicles" >> "O_Soldier_F",
  configFile >> "CfgVehicles" >> "O_Soldier_lite_F",
  configFile >> "CfgVehicles" >> "O_Soldier_GL_F",
  configFile >> "CfgVehicles" >> "O_Soldier_AR_F",
  configFile >> "CfgVehicles" >> "O_Soldier_TL_F",
  configFile >> "CfgVehicles" >> "O_Soldier_A_F",
  configFile >> "CfgVehicles" >> "O_recon_F",
  configFile >> "CfgVehicles" >> "O_recon_TL_F",
  configFile >> "CfgVehicles" >> "O_Soldier_AAR_F",
  configFile >> "CfgVehicles" >> "O_Soldier_AAT_F",
  configFile >> "CfgVehicles" >> "O_Soldier_AAA_F",
  configFile >> "CfgVehicles" >> "O_support_MG_F",
  configFile >> "CfgVehicles" >> "O_soldierU_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AR_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AAR_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AAT_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AAA_F",
  configFile >> "CfgVehicles" >> "O_soldierU_TL_F",
  configFile >> "CfgVehicles" >> "O_soldierU_A_F",
  configFile >> "CfgVehicles" >> "O_SoldierU_GL_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAP"];
} forEach _WF_opForInfAPUnits;

_WF_opForInfATUnits = [
  configFile >> "CfgVehicles" >> "O_Soldier_LAT_F",
  configFile >> "CfgVehicles" >> "O_Soldier_AT_F",
  configFile >> "CfgVehicles" >> "O_recon_LAT_F",
  configFile >> "CfgVehicles" >> "O_soldierU_LAT_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AT_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAT"];
} forEach _WF_opForInfATUnits;

_WF_opForInfSupportUnits = [
  configFile >> "CfgVehicles" >> "O_medic_F",
  /*configFile >> "CfgVehicles" >> "O_soldier_repair_F",
  configFile >> "CfgVehicles" >> "O_engineer_U_F",
  configFile >> "CfgVehicles" >> "O_engineer_F",*/
  configFile >> "CfgVehicles" >> "O_recon_medic_F",
  configFile >> "CfgVehicles" >> "O_soldierU_medic_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infSupport"];
} forEach _WF_opForInfSupportUnits;

_WF_opForInfSpecialUnits = [
  configFile >> "CfgVehicles" >> "O_soldier_M_F",
  configFile >> "CfgVehicles" >> "O_soldier_exp_F",
  configFile >> "CfgVehicles" >> "O_spotter_F",
  configFile >> "CfgVehicles" >> "O_sniper_F",
  configFile >> "CfgVehicles" >> "O_recon_M_F",
  configFile >> "CfgVehicles" >> "O_recon_exp_F",
  configFile >> "CfgVehicles" >> "O_soldierU_exp_F",
  configFile >> "CfgVehicles" >> "O_soldierU_M_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infSpecial"];
} forEach _WF_opForInfSpecialUnits;

_WF_opForInfAAUnits = [
  configFile >> "CfgVehicles" >> "O_Soldier_AA_F",
  configFile >> "CfgVehicles" >> "O_soldierU_AA_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAA"];
} forEach _WF_opForInfAAUnits;

_WF_bluForInfAPUnits = [
  configFile >> "CfgVehicles" >> "B_Soldier_F",
  configFile >> "CfgVehicles" >> "B_Soldier_lite_F",
  configFile >> "CfgVehicles" >> "B_Soldier_GL_F",
  configFile >> "CfgVehicles" >> "B_Soldier_AR_F",
  configFile >> "CfgVehicles" >> "B_Soldier_TL_F",
  configFile >> "CfgVehicles" >> "B_Soldier_A_F",
  configFile >> "CfgVehicles" >> "B_recon_F",
  configFile >> "CfgVehicles" >> "B_recon_TL_F",
  configFile >> "CfgVehicles" >> "B_Soldier_AAR_F",
  configFile >> "CfgVehicles" >> "B_Soldier_AAT_F",
  configFile >> "CfgVehicles" >> "B_Soldier_AAA_F",
  configFile >> "CfgVehicles" >> "B_support_MG_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAP"];
} forEach _WF_bluForInfAPUnits;

_WF_bluForInfATUnits = [
  configFile >> "CfgVehicles" >> "B_Soldier_LAT_F",
  configFile >> "CfgVehicles" >> "B_Soldier_AT_F",
  configFile >> "CfgVehicles" >> "B_recon_LAT_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAT"];
} forEach _WF_bluForInfATUnits;

_WF_bluForInfSupportUnits = [
  configFile >> "CfgVehicles" >> "B_medic_F",
  /*configFile >> "CfgVehicles" >> "B_soldier_repair_F",
  configFile >> "CfgVehicles" >> "B_engineer_F",*/
  configFile >> "CfgVehicles" >> "B_recon_medic_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infSupport"];
} forEach _WF_bluForInfSupportUnits;

_WF_bluForInfSpecialUnits = [
  configFile >> "CfgVehicles" >> "B_soldier_M_F",
  configFile >> "CfgVehicles" >> "B_soldier_exp_F",
  configFile >> "CfgVehicles" >> "B_spotter_F",
  configFile >> "CfgVehicles" >> "B_sniper_F",
  configFile >> "CfgVehicles" >> "B_recon_M_F",
  configFile >> "CfgVehicles" >> "B_recon_exp_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infSpecial"];
} forEach _WF_bluForInfSpecialUnits;

_WF_bluForInfAAUnits = [
  configFile >> "CfgVehicles" >> "B_Soldier_AA_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAA"];
} forEach _WF_bluForInfAAUnits;

_WF_opForTransportUnarmedUnits = [
  configFile >> "CfgVehicles" >> "O_MRAP_02_F",
  configFile >> "CfgVehicles" >> "O_Quadbike_01_F",
  configFile >> "CfgVehicles" >> "O_Truck_02_transport_F",
  configFile >> "CfgVehicles" >> "O_Truck_02_covered_F",
  configFile >> "CfgVehicles" >> "O_Truck_03_transport_F",
  configFile >> "CfgVehicles" >> "O_Truck_03_covered_F",
  configFile >> "CfgVehicles" >> "O_Heli_Light_02_unarmed_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "TPU"];
} forEach _WF_opForTransportUnarmedUnits;

_WF_bluForTransportUnarmedUnits = [
  configFile >> "CfgVehicles" >> "B_MRAP_01_F",
  configFile >> "CfgVehicles" >> "B_Quadbike_01_F",
  configFile >> "CfgVehicles" >> "B_Truck_01_transport_F",
  configFile >> "CfgVehicles" >> "B_Truck_01_covered_F",
  configFile >> "CfgVehicles" >> "B_Heli_Light_01_stripped_F",
  configFile >> "CfgVehicles" >> "B_Heli_Light_01_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_03_unarmed_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_03_unarmed_green_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "TPU"];
} forEach _WF_bluForTransportUnarmedUnits;

_WF_opForTransportArmedUnits = [
  configFile >> "CfgVehicles" >> "O_MRAP_02_gmg_F",
  configFile >> "CfgVehicles" >> "O_MRAP_02_hmg_F",
  configFile >> "CfgVehicles" >> "O_APC_Wheeled_02_rcws_F",
  configFile >> "CfgVehicles" >> "O_Heli_Light_02_unarmed_F",
  configFile >> "CfgVehicles" >> "O_Heli_Transport_04_bench_F",
  configFile >> "CfgVehicles" >> "O_Heli_Transport_04_covered_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "TPA"];
} forEach _WF_opForTransportArmedUnits;

_WF_bluForTransportArmedUnits = [
  configFile >> "CfgVehicles" >> "B_MRAP_01_gmg_F",
  configFile >> "CfgVehicles" >> "B_MRAP_01_hmg_F",
  configFile >> "CfgVehicles" >> "B_APC_Wheeled_01_cannon_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_01_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_01_camo_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_03_F",
  configFile >> "CfgVehicles" >> "B_Heli_Transport_03_black_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "TPA"];
} forEach _WF_bluForTransportArmedUnits;

_WF_opForArmorTankUnits = [
  configFile >> "CfgVehicles" >> "O_APC_Tracked_02_cannon_F",
  configFile >> "CfgVehicles" >> "O_MBT_02_cannon_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "tank"];
} forEach _WF_opForArmorTankUnits;

_WF_opForArmorAAUnits = [
  configFile >> "CfgVehicles" >> "O_APC_Tracked_02_AA_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "vehicleAA"];
} forEach _WF_opForArmorAAUnits;

_WF_bluForArmorTankUnits = [
  configFile >> "CfgVehicles" >> "B_APC_Tracked_01_rcws_F",
  configFile >> "CfgVehicles" >> "B_MBT_01_cannon_F",
  configFile >> "CfgVehicles" >> "B_MBT_01_TUSK_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "tank"];
} forEach _WF_bluForArmorTankUnits;

_WF_bluForArmorAAUnits = [
  configFile >> "CfgVehicles" >> "B_APC_Tracked_01_AA_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "vehicleAA"];
} forEach _WF_bluForArmorAAUnits;

_WF_opForAirHeliUnits = [
  configFile >> "CfgVehicles" >> "O_Heli_Light_02_F",
  configFile >> "CfgVehicles" >> "O_Heli_Light_02_v2_F",
  configFile >> "CfgVehicles" >> "O_Heli_Attack_02_F",
  configFile >> "CfgVehicles" >> "O_Heli_Attack_02_black_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "Heli"];
} forEach _WF_opForAirHeliUnits;

_WF_opForAirJetUnits = [
  configFile >> "CfgVehicles" >> "O_Plane_CAS_02_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "Jet"];
} forEach _WF_opForAirJetUnits;

_WF_bluForAirHeliUnits = [
  configFile >> "CfgVehicles" >> "B_Heli_Light_01_armed_F",
  configFile >> "CfgVehicles" >> "B_Heli_Attack_01_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "Heli"];
} forEach _WF_bluForAirHeliUnits;

_WF_bluForAirJetUnits = [
  configFile >> "CfgVehicles" >> "B_Plane_CAS_01_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "Jet"];
} forEach _WF_bluForAirJetUnits;

_WF_AICantBuyInf = [
configFile >> "CfgVehicles" >> "B_Soldier_SL_F",
configFile >> "CfgVehicles" >> "B_G_Soldier_SL_F",
configFile >> "CfgVehicles" >> "O_Soldier_SL_F",
configFile >> "CfgVehicles" >> "O_SoldierU_SL_F",
configFile >> "CfgVehicles" >> "B_officer_F",
configFile >> "CfgVehicles" >> "O_officer_F",
configFile >> "CfgVehicles" >> "O_crew_F",
configFile >> "CfgVehicles" >> "B_crew_F",
configFile >> "CfgVehicles" >> "O_Pilot_F",
configFile >> "CfgVehicles" >> "B_Pilot_F",
configFile >> "CfgVehicles" >> "O_helicrew_F",
configFile >> "CfgVehicles" >> "B_helicrew_F",
configFile >> "CfgVehicles" >> "O_helipilot_F",
configFile >> "CfgVehicles" >> "B_Helipilot_F",
configFile >> "CfgVehicles" >> "O_diver_F",
configFile >> "CfgVehicles" >> "B_diver_F",
configFile >> "CfgVehicles" >> "O_diver_TL_F",
configFile >> "CfgVehicles" >> "B_diver_TL_F",
configFile >> "CfgVehicles" >> "O_diver_exp_F",
configFile >> "CfgVehicles" >> "B_diver_exp_F",
configFile >> "CfgVehicles" >> "O_recon_JTAC_F",
configFile >> "CfgVehicles" >> "B_recon_JTAC_F",
configFile >> "CfgVehicles" >> "O_soldier_repair_F",  // come back to this unit and the ones below once engineers/repair has been implemented for the AI
configFile >> "CfgVehicles" >> "B_soldier_repair_F",
configFile >> "CfgVehicles" >> "O_engineer_U_F",
configFile >> "CfgVehicles" >> "O_engineer_F",
configFile >> "CfgVehicles" >> "B_engineer_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "infAP"];
} forEach _WF_AICantBuyInf;

_WF_otherUnits = [
  configFile >> "CfgVehicles" >> "B_Truck_01_mover_F",
  configFile >> "CfgVehicles" >> "O_Truck_03_device_F",
  configFile >> "CfgVehicles" >> "B_Truck_01_box_F",
  configFile >> "CfgVehicles" >> "C_Kart_01_Blu_F",
  configFile >> "CfgVehicles" >> "C_SUV_01_F",
  configFile >> "CfgVehicles" >> "C_Hatchback_01_sport_F",
  configFile >> "CfgVehicles" >> "C_Kart_01_Red_F",
  configFile >> "CfgVehicles" >> "C_SUV_01_F",
  configFile >> "CfgVehicles" >> "C_Hatchback_01_sport_F"
];

{
  missionNamespace setVariable ["unitType_" + (configName _x), "Other"];
} forEach _WF_otherUnits;

missionNameSpace setVariable ["allUnitTypes", ["infAP", "infAT", "infSupport", "infSpecial", "infAA", "TPU", "TPA", "tank", "vehicleAA", "Heli", "Jet", "Other"]];
missionNamespace setVariable ["EASTinfTemplate", [["infAP", 0.6, _WF_opForInfAPUnits], ["infAT", 0.2, _WF_opForInfATUnits], ["infSupport", 0.1, _WF_opForInfSupportUnits], ["infSpecial", 0.07, _WF_opForInfSpecialUnits], ["infAA", 0.03, _WF_opForInfAAUnits], ["TPU", 0, _WF_opForTransportUnarmedUnits], ["TPA", 0, _WF_opForTransportArmedUnits], ["tank", 0, _WF_opForArmorTankUnits], ["vehicleAA", 0, _WF_opForArmorAAUnits], ["Heli", 0, _WF_opForAirHeliUnits], ["Jet", 0, _WF_opForAirJetUnits], ["Other", 0]]];  // the first element in this array needs to be of the same order as it is in the "allUnitTypes" template!
missionNamespace setVariable ["WESTinfTemplate", [["infAP", 0.6, _WF_bluforInfAPUnits], ["infAT", 0.2, _WF_bluforInfATUnits], ["infSupport", 0.1, _WF_bluforInfSupportUnits], ["infSpecial", 0.07, _WF_bluforInfSpecialUnits], ["infAA", 0.03, _WF_bluforInfAAUnits], ["TPU", 0, _WF_bluForTransportUnarmedUnits], ["TPA", 0, _WF_bluForTransportArmedUnits], ["tank", 0, _WF_bluforArmorTankUnits], ["vehicleAA", 0, _WF_bluforArmorAAUnits], ["Heli", 0, _WF_bluforAirHeliUnits], ["Jet", 0, _WF_bluforAirJetUnits], ["Other", 0]]];
missionNameSpace setVariable ["EASTarmorTemplate", [["infAP", 0, _WF_opForInfAPUnits], ["infAT", 0, _WF_opForInfATUnits], ["infSupport", 0, _WF_opForInfSupportUnits], ["infSpecial", 0, _WF_opForInfSpecialUnits], ["infAA", 0, _WF_opForInfAAUnits], ["TPU", 0, _WF_opForTransportUnarmedUnits], ["TPA", 0, _WF_opForTransportArmedUnits], ["tank", 0.9, _WF_opForArmorTankUnits], ["vehicleAA", 0.1, _WF_opForArmorAAUnits], ["Heli", 0, _WF_opForAirHeliUnits], ["Jet", 0, _WF_opForAirJetUnits], ["Other", 0]]];
missionNameSpace setVariable ["WESTarmorTemplate", [["infAP", 0, _WF_bluforInfAPUnits], ["infAT", 0, _WF_bluforInfATUnits], ["infSupport", 0, _WF_bluforInfSupportUnits], ["infSpecial", 0, _WF_bluforInfSpecialUnits], ["infAA", 0, _WF_bluforInfAAUnits], ["TPU", 0, _WF_bluForTransportUnarmedUnits], ["TPA", 0, _WF_bluForTransportArmedUnits], ["tank", 0.9, _WF_bluForArmorTankUnits], ["vehicleAA", 0.1, _WF_bluForArmorAAUnits], ["Heli", 0, _WF_opForAirHeliUnits], ["Jet", 0, _WF_opForAirJetUnits], ["Other", 0]]];
missionNameSpace setVariable ["EASTairTemplate", [["infAP", 0, _WF_opForInfAPUnits], ["infAT", 0, _WF_opForInfATUnits], ["infSupport", 0, _WF_opForInfSupportUnits], ["infSpecial", 0, _WF_opForInfSpecialUnits], ["infAA", 0, _WF_opForInfAAUnits], ["TPU", 0, _WF_opForTransportUnarmedUnits], ["TPA", 0, _WF_opForTransportArmedUnits], ["tank", 0, _WF_opForArmorTankUnits], ["vehicleAA", 0, _WF_opForArmorAAUnits], ["Heli", 1, _WF_opForAirHeliUnits], ["Jet", 0, _WF_opForAirJetUnits], ["Other", 0]]];
missionNameSpace setVariable ["WESTairTemplate", [["infAP", 0, _WF_bluforInfAPUnits], ["infAT", 0, _WF_bluforInfATUnits], ["infSupport", 0, _WF_bluforInfSupportUnits], ["infSpecial", 0, _WF_bluforInfSpecialUnits], ["infAA", 0, _WF_bluforInfAAUnits], ["TPU", 0, _WF_bluForTransportUnarmedUnits], ["TPA", 0, _WF_bluForTransportArmedUnits], ["tank", 0, _WF_bluForArmorTankUnits], ["vehicleAA", 0, _WF_bluForArmorAAUnits], ["Heli", 1, _WF_bluForAirHeliUnits], ["Jet", 0, _WF_bluForAirJetUnits], ["Other", 0]]];

missionNameSpace setVariable ["infPortion", 0.6];
missionNameSpace setVariable ["armorPortion", 0.3];
missionNameSpace setVariable ["airPortion", 0.1];

WF_createPatrolGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createPatrolGroup.sqf";
WF_saveGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_saveGroupState.sqf";
WF_restoreGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_restoreGroupState.sqf";
WF_deleteGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_deleteGroup.sqf";
WF_createTrigger = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createTrigger.sqf";
WF_buildUnit = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildUnit.sqf";
WF_buildVehicle = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildVehicle.sqf";
WF_AIBuildUnit = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_AIBuildUnit.sqf";
WF_buyWeapons = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyWeapons.sqf";
WF_buyItem = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyItem.sqf";
WF_buyBackpack = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyBackpack.sqf";
WF_setWaypoint = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_setWaypoint.sqf";
WF_findBestObjective = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_findBestObjective.sqf";
WF_estimateForceStrength = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_estimateForceStrength.sqf";
WF_purchaseAI = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_purchaseAI.sqf";
WF_unitSideFilter = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_unitSideFilter.sqf";
WF_getEnemySides = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_getEnemySides.sqf";
WF_getGrpCompNumbers = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_getGrpCompNumbers.sqf";

[west, "WEST1"] call BIS_fnc_addRespawnInventory;
[west, "WEST2"] call BIS_fnc_addRespawnInventory;
