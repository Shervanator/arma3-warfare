/* A* algorithm that finds the quickest path between two positions while considering zones

Parameters:
 _startPos: position - The starting position
 _endPos: position - The destination
 (optional) _startZoneInfo: integer - referring to the starting zone's index in the kyf_WG_allZones array
 (optional) _endZoneInfo: integer - referring to the destination zone's index in the kyf_WG_allZones array

 Return:
 An array with 2 elements:
 0: An array of positions showing the shortest path from start to end. If start and end are in the same zone, or if either is not in any zone, then it is a straight path from start to end.
 1: Total distance that needs to be travelled to follow this path.

 Author: kyfohatl*/

// DEBUG
#include "..\..\debug\debug_settings.sqf"
// END DEBUG

#include "..\setup_settings\zone_settings.sqf"

private ["_startPos", "_endPos", "_startZoneInfo", "_endZoneInfo", "_startZone", "_endZone", "_hashTable", "_bestPath"];
params ["_startPos", "_endPos", "_startZoneInfo", "_endZoneInfo"];

//------------------------------------------------------------------------------
// find zone info if not provided

// *** is this bit necessary???
_startZone = -1;
_endZone = -1;

if (isNil "_startZoneInfo") then {
  _startZone = [_startPos, false] call kyf_WF_findZone;
} else {
  if (_startZoneInfo == -1) then {
    _startZone = [_startPos, false] call kyf_WF_findZone;
  } else {
    _startZone = _startZoneInfo;
  };
};

if (isNil "_endZoneInfo") then {
  _endZone = [_endPos, false] call kyf_WF_findZone;
} else {
  if (_endZoneInfo == -1) then {
    _endZone = [_endPos, false] call kyf_WF_findZone;
  } else {
    _endZone = _endZoneInfo;
  };
};

//------------------------------------------------------------------------------
// Now path with an A* algorithm

/* Each element of this "table" is an array representing an exit point. The index of the array in the table is the unique index identifier of the zep. 
The paths built in this function that pass through an exit point will be saved in the corresponding array of this table, and should another path pass through 
the same exit point, we can check if said path reached this same spot with less cost, preventing more costly paths (and endless loops) from being fully explored. */
_hashTable = +(missionNamespace getVariable HASH_TABLE_NAME);

_bestPath = [];

if !((_startZone == _endZone) or (_startZone == -1) or (_endZone == -1)) then {  /*If the destination and start pos are both in the same zone, or if either the _startZone or _endZone are undefined (kyf_WF_findZone returned -1),
  then the script won't bother pathing zones and instead will keep _bestPath (the return value) as a straight course between startPos and endPos.*/

  // path format: [path identifier number, current pos, [[path positions], [path names]], current zone, total path cost so far, distSqr form endPos, path cost + remaining dist]
  // [path names] are only kept for debug purposes at the momnet, so that a log of the shortest path can be read
  private _pathQue = [[-1, _startPos, [[_startPos], ["start"]], _startZone, 0, 0, 0]];

  while {(count _pathQue) > 0} do {
    // select the highest priority path in que and expand
    private _currentPath = +(_pathQue select 0); // Copy because we are about to delete _pathQue select 0 shortly
    private _curentPosIndex = _currentPath select 0; // i.e. _zepIndex = unique number representing our path. start inex = -1 and endpos inex = -2
    private _currentPos = _currentPath select 1;

    _pathQue deleteAt 0;

    // Check which paths the exit points in the zone lead to and create new paths for _pathQue
    {
      private _zep = _x; // _zep = zone exit point
      private _zepIndex = _zep select 0;
      private _zepPos = _zep select 1;

      if !(_zepIndex isEqualTo _curentPosIndex) then { // Make sure that we are not backtracking through the path we already came from

        // calculate where this exit point leads to and how much is added to the travel distance
        private _linkInfo = _zep select 2;
        private _linkZone = _linkInfo select 0;
        private _linkPos = _linkInfo select 1;
        private _linkIndex = _linkInfo select 2;
        private _pathHistory = +(_currentPath select 2);

        (_pathHistory select 0) append [_zepPos, _linkPos]; // new line needed because append does not return anything

        // DEBUG
        // Adds the names of the points along the path, so that they can be identified easily in a log
        #ifdef SETUP_ZONE_DEBUG_EXTREME
          private _zepName = _zep select 5;
          private _linkName = "";
          
          // Find the link marker name
          {
            if (_linkIndex == (_x select 0)) then {
              _linkName = _x select 5;
            };
          } forEach ((kyf_WG_allZones select _linkZone) select 3); // For each exit point of the link zone

          (_pathHistory select 1) append [_zepName, _linkName];
        #endif
        // END DEBUG
        
        private _remainingDist = _linkPos distanceSqr _endPos;

        private _pathCost = (_currentPath select 4) + (_currentPos distanceSqr _zepPos) + (_zep select 3); // _pathCost = total path cost up to this point + distance from our pos to the zep + distance between the zep and its link
        private _bestAlternatePath = _hashTable select _linkIndex;

        private _addPath = true;

        // Check the hash table in case we have already arrived at the same point via another path
        if !(_bestAlternatePath isEqualTo []) then {
          if ((_bestAlternatePath select 1) < _pathCost) then {
            // i.e. Another path already exists to this pos that arrives with lower path cost, hence there is no need to continue this path
            _addPath = false;
          };
        };

        // If a completed path exists, check if we have not already exceeded the path cost of that to prevent wasting time
        if !(_bestPath isEqualTo []) then {
          if ((_bestPath select 1) <= (_pathCost + _remainingDist)) then {
            // i.e. This path has already exceeded the current shortest completed path and should not be considered anymore
            _addPath = false;
          };
        };

        /* If a path can be added, then add path to both the "hash table" element representing the link point we will arrive in. If the final zone is reached, set this as the 
        best path so far, otherwise rank this path in terms of path cost in the path que */
        if (_addPath) then {
          // i.e. This is the fastest path to this pos so far, and it does not exceed the shortest completed path so far if one exists
          _hashTable set [_linkIndex, [_pathHistory select 0, _pathCost]]; // This is the new quickest way to this pos

          private _totalCost = _pathCost + _remainingDist;

          if (_linkZone == _endZone) then { // Does this path lead us to the target zone?

            // We already know that there is no completed path shorter than this, and that we have not reached this point through a quicker path
            // So this is the new shortest path
            (_pathHistory select 0) pushBack _endPos;

            //DEBUG
            #ifdef SETUP_ZONE_DEBUG_EXTREME
              (_pathHistory select 1) append ["end"];
            #endif
            //END DEBUG

            _bestPath = [_pathHistory, _totalCost];

          } else {
            // Find the correct ranking for this path in pathQue by comparing its _pathCost + _remainingDist to that of other paths
            private _rank = 0;
            if !(_pathQue isEqualTo []) then {
              for [{private _i = (count _pathQue) - 1}, {_i >= 0}, {_i = _i - 1}] do {
                if (_totalCost >= ((_pathQue select _i) select 6)) exitWith {_rank = _i + 1};
              };
            };

            // Now add path to correct pos in the pathQue array
            [_pathQue, [_linkIndex, _linkPos, _pathHistory, _linkZone, _pathCost, _remainingDist, _totalCost], _rank] call kyf_WF_pushBackToIndex;
          };
        };
      };
    } forEach ((kyf_WG_allZones select (_currentPath select 3)) select 3); // forEach exitPoint in the _exitPointInfo array of the zone
  };
};

if (_bestPath isEqualTo []) then {
  _bestPath = [[[_startPos, _endPos], ["start", "end"]], _startPos distanceSqr _endPos]; // The default return vale, as a straight path between startPos and endPos
};

// DEBUG
// Log the final chosen path in marker names and positions
#ifdef SETUP_ZONE_DEBUG_EXTREME
  DEBUG_LOG_START(__FILE__);
  diag_log format ["Checking shortest path from startPos %1 in zone %2 to endPos %3 in zone %4:", _startPos, _startZoneInfo, _endPos, _endZoneInfo];
  diag_log ((_bestPath select 0) select 1);
  DEBUG_LOG_END(__FILE__);
#endif

// Map out the chosen path if slow mode is enabled
#ifdef DEBUG_SETUP_ZONES_SLOW_MODE
  private _debugMarkers = [];

  for [{private _i = 0; private _positions = (_bestPath select 0) select 0}, {_i < (count _positions)}, {_i = _i + 1}] do {
    private _markerPos = _positions select _i;
    private _marker = createMarker [(str _markerPos) + "_DEBUG_SLOW_MODE", _markerPos];
    _marker setMarkerShape "ICON";

    if ((_i == 0) or (_i == ((count _positions) - 1))) then {
      _marker setMarkerType "mil_triangle";
    } else {
      _marker setMarkerType "hd_dot";
    };

    _marker setMarkerColor "ColorPink";
    _debugMarkers pushBack _marker;
  };

  // Delay marker deletion by an appropriate amount based on chosen setting
  sleep kyf_WG_DEBUG_SETUP_smVal;

  // Now delete pathfinding debug markers
  {
    deleteMarker _x;
  } forEach _debugMarkers;
#endif
//END DEBUG

// Return format: [full path, total path cost], where full path is an array of all positions
[(_bestPath select 0) select 0, _bestPath select 1]
