/* Returns the best path between two points. If both points are within zones, the best predefined path is chosen and otherwise a straight path 
between them is returned.

Parameters:
	- _start and _end: Position 2D or 3D of the starting and ending position
  
Returns:
  - _path: Array of positions, indicating the path that must be travelled
  
Author: kyfohatl */

private ["_start", "_end"];
params ["_start", "_end"];

private _data = [];
private _simplePath = false;

{
  // Get the zone of the point
  private _zone = [_x, true] call kyf_WF_findZone;

  // Check if point is inside a zone
  if (_zone == -1) exitWith {
    // Point not inside a zone, complicated pathing is not required
    _simplePath = true;
  };

  // Get the division of the point withing the zone
  private _div = [_x, _zone] call kyf_WF_getZoneDiv;

  // Now we must keep the zone and division index of the point to find the correct path
  _data pushBack (_zone select 0);
  _data pushBack (_div select 0);
} forEach [_start, _end];

// Initialize return value
private _path = [];

private _startZone = _data select 0;
private _startDiv = _data select 1;
private _tgtZone = _data select 2;
private _tgtDiv = _data select 3;

// Now get the correct path
if (_simplePath) then {
  // Make a straight path from start to end
  _path = [_start, _end];
} else {
  _path = (((kyf_WG_zoneDivisionPaths select _startZone) select _startDiv) select _tgtZone) select _tgtDiv;
};

_path