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

_hashTable = +(missionNamespace getVariable "kyf_zepHashTable");
_bestPath = [[_startPos, _endPos], _startPos distanceSqr _endPos]; // The default return vale, as a straight path between startPos and endPos

if !((_startZone == _endZone) or (_startZone == -1) or (_endZone == -1)) then {  /*If the destination and start pos are both in the same zone, or if either the _startZone or _endZone are undefined (kyf_WF_findZone returned -1),
  then the script won't bother pathing zones and instead will keep _bestPath (the return value) as a straight course between startPos and endPos.*/

  private _bestCompletedPath = [];
  private _pathQue = [[-1, _startPos, [_startPos], _startZone, 0, 0, 0]]; // path format: [path identifier number, current pos, [path], current zone, total path cost so far, distSqr form endPos, path cost + remaining dist]

  while {(count _pathQue) > 0} do {
    // select the highest priority oath in que and expand
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
        _pathHistory append [_zepPos, _zepLinkPos]; // new line needed because append does not return anything
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
        if !(_bestCompletedPath isEqualTo []) then {
          if ((_bestCompletedPath select 1) <= (_pathCost + _remainingDist)) then {
            // i.e. This path has already exceeded the current shortest completed path and should not be considered anymore
            _addPath = false;
          };
        };

        if (_addPath) then {
          // i.e. This is the fastest path to this pos so far, and it does not exceed the shortest completed path so far if one exists
          _hashTable set [_linkIndex, [_pathHistory, _pathCost]]; // This is the new quickest way to this pos

          private _totalCost = _pathCost + _remainingDist;

          if (_linkZone == _endZone) then { // Does this path lead us to the target zone?

            // We already know that there is no completed path shorter than this, and that we have not reached this point through a quicker path
            // So this is the new shortest path
            _pathHistory pushBack _endPos;
            _bestCompletedPath = [_pathHistory, _totalCost];

          } else {
            // Find the correct ranking for this path in pathQue by comparing its _pathCost + _remainingDist to that of other paths
            private _rank = 0;
            if !(_pathQue isEqualTo []) then {
              for [{private _i = (count _pathQue) - 1}, {_i >= 0}, {_i = _i - 1}] do {
                if (_totalCost > ((_pathQue select _i) select 6)) exitWith {_rank = _i + 1};
              };
            };

            // Now add path to correct pos in the pathQue array
            [_pathQue, [_linkIndex, _linkPos, _pathHistory, _linkZone, _pathCost, _remainingDist, _totalCost], _rank] call kyf_WF_pushBackToIndex;
          };
        };
      };
    } forEach ((kyf_WG_allZones select (_currentPath select 3)) select 2); // forEach exitPoint in the _exitPointInfo array of the zone
  };
};

_bestPath
