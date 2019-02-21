/* Initiates and runs through all of the main setup functions 

Parameters:
  -NONE
  
Returns:
  -NONE
  
Author: kyfohatl */

//--------------------------------------------------------------------------------------
// Compile functions

// Compile zone related functions
kyf_WF_compareStrToNestedStr = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_compareStrToNestedStr.sqf";
kyf_WF_findShortestPath = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_findShortestPath.sqf";
kyf_WF_findSymbolInStr = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_findSymbolInStr.sqf";
kyf_WF_addZepInfo = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\addZepInfo.sqf";
kyf_WF_getSL_intersection = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_getSL_intersection.sqf";
kyf_WF_getSLEqn = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_getSLEqn.sqf";
kyf_WF_isPointInEllipse = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_isPointInEllipse.sqf";
kyf_WF_pushBackToIndex = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_pushBackToIndex.sqf";
kyf_WF_saveZonePaths = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_saveZonePaths.sqf";
kyf_WF_stndAngle = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\zones\kyf_WF_stndAngle.sqf";
kyf_WF_findZone = compileFinal preprocessFileLineNumbers "scripts\server\ai_pathing\kyf_WF_findZone.sqf";

// Compile database saving related functions
kyf_WF_saveSetupInfoToDatabase = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\kyf_WF_saveSetupInfoToDatabase.sqf";

//--------------------------------------------------------------------------------------
// Compile and run necessary functions

// Run resource functions (such as exit points and their links)
kyf_WF_missionConstructionResources = compileFinal preprocessFileLineNumbers "scripts\server\missionSetup\resources\kyf_WF_missionConstructionResources.sqf";
call kyf_WF_missionConstructionResources;

//--------------------------------------------------------------------------------------
// Execute scripts

// Main script for turning zone markers into zone and pathing data
[] execVM "scripts\server\missionSetup\zones\zoneSetup.sqf";