/* This function will return the shortest path between two positions, but specific for mission setup. It is the same as 
findShortestPath, except that it deletes the starting and ending positions as these are not a necessary part of predefined 
paths and would simply take up extra memory space.

Parameters:

Returns:

Author: kyfohatl */

private ["_startPos", "_endPos", "_allowWater", "_startZoneInfo", "_endZoneInfo"];
params ["_startPos", "_endPos", "_allowWater", "_startZoneInfo", "_endZoneInfo"];

// Create path
private _path = [_startPos, _endPos, _allowWater, _startZoneInfo, _endZoneInfo] call kyf_WF_findShortestPath;

// Now delete the start and end positions as they are just division centres
(_path select 0) deleteAt ((count (_path select 0)) - 1);
(_path select 0) deleteAt 0;

_path