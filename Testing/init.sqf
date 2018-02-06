// ***TO DO!!!
 /*AT some point the exit point info defined in missionConstructionResources on missionNamespace need to be removed as they no longer will be
 necessary. Perhaps in some sort of kyf_WF_missionConstructionCleanup file or something like that. In the following form:

{
  missionNamespace setVariable [_markerName + _x, nil];
} forEach ["_Link", "_LinkD2", "_LinkD"];*/
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/*Initialize the global zones var. This var will be used here because some of the ncessary
mission construction functions (namely findZone and findShortestPath) require this global var. During the execution
of the actual mission however, the mission construction files will not run and hence this var
will contain the finished version of the zone info.*/
kyf_WG_allZones = [];
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for adding important zone info to the zone array for future use

_addBasicZoneInfo = {
  private ["_zone"];
  params ["_zone"];

  _centre = markerPos _zone;
  _centreX = _centre select 0;
  _centreY = _centre select 1;
  _size = markerSize _zone;
  _sizeA = _size select 0;
  _sizeB = _size select 1;
  _rotation = [markerDir _zone] call kyf_WF_stndAngle; // ***is standardizing the angle necessary?

  _cornerPoints = [];
  {
    _cornerPoints pushBack (_x call _rotateAndTranslate);
  } forEach [[-_sizeA, 0], [_sizeA, 0], [0, -_sizeB], [0, _sizeB]]; // These are the four corner points of the elipse marker
  // (where the major and minor axis intersect the parameter), translated so that the centre of the elipse is at the origin, and unrotated
  // so that the elipse is at a 0 degree rotation. See diagram elipse rotation 1.

  //----------------------------------------------------------------------------
  // now add exit point information

  _exitPointInfo = [];

  for [{private _i = 0; private _zoneNumberStr = _zone select [8, (count _zone) - 8]}, {_i < (count _exitPointsUnsorted)}, {_i = _i + 1}] do {
    // see if the exit point belongs this zone (i.e. has the same zone number)
    _zep = _exitPointsUnsorted select _i;
    _start = ([_zep, "z", 2] call kyf_WF_findSymbolInStr) + 1; // in format kyf_zep12_z2, the second instance of "z" is our start point

    // The zone number in format kyf_zone12 can be aquired by selecting between 8 and (count _zone) - 8
    if ([_zoneNumberStr, _zep, _start] call kyf_WF_compareStrToNestedStr) then {
      // format [exit point pos, exit point link pos, next zone, distance between them squared, distance between them]
      // Defined in kyf_WF_missionConstructionResources.sqf
      _zepIndex = _zepIndex + 1; // This exit point now has a unique number of _zepIndex which corresponds to the index it occupies in the _hashTable array.
      _hashTable pushBack []; // _hashTable select _zepIndex will now provide us with an array unique to this exit point, where we can store paths in our A* algorithm
      _linkPos = getMarkerPos (missionNamespace getVariable [_zep + "_Link"]);
      _exitPointInfo pushBack [_zepIndex, getMarkerPos _zep, [[_linkPos, false] call kyf_WF_findZone, _linkPos], missionNamespace getVariable [_zep + "_LinkD2"], missionNamespace getVariable [_zep + "_LinkD"]];
    };
  };
  //----------------------------------------------------------------------------

  [_i, [_centre, _sizeA, _sizeB, _rotation, _cornerPoints], _exitPointInfo];
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for taking the ALREADY TRANSLATED and unrotated corner points of an elipse about the origin, and the rotating
// and un-translating them back to their original position
// The points are rotated as if the centre of the elipse is at the origin, then we un-translate them to their original pos
// This allows us to find the coordinates of the corner points of the original elipse

_rotateAndTranslate = {
  private ["_xVal", "_yVal"];
  params ["_xVal", "_yVal"];

  [(_xVal * (Cos _rotation)) - (_yVal * (sin _rotation)) + _centreX, (_yVal * (cos _rotation)) + (_xVal * (sin _rotation)) + _centreY]
  // Based on the formula for rotation of a point around the origin with (x1, y1) and a rotation of @ degrees
  // x2 = x1Cos@ - y1Sin@, y2 = y1Cos@ + x1Sin@
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for taking line segments and creating zone divisions with them
// *** Show detailed working out

_createDivisions = {
  private ["_lineSegments", "_divisions", "_line1m", "_line1c", "_line1Seg", "_hasReachedElipse", "_endLoop", "_line2m", "_line2c", "_line2Seg", "_xVal", "_yVal", "_isIn"];
  params ["_lineSegments"];

  _divisions = [];

  {
    // Figure out where the segment lines and midway lines intersect
    _line1Seg = _x select 0;

    // Segment lines
    _line1m = (_x select 1) select 0;
    _line1c = (_x select 1) select 1;
    // Midway lines
    _line1Midm = (_x select 2) select 0;
    _line1Midc = (_x select 2) select 1;

    _hasReachedElipse = false;
    _endLoop = false;

    {
      _line2m = (_x select 1) select 0;
      _line2c = (_x select 1) select 1;
      _line2Seg = _x select 0;

      // Find the intersection point of the segment perpendicular lines
      _xVal = (_line2c - _line1c) / (_line1m - _line2m); // *** SHOW WORKING OUT
      _yVal = _line1m * _xVal + _line1c; // point _xVal, _yVal is where the segment lines intersect

      // Check to see if the intersect inside the elipse
      _isIn = [_centreX, _centreY, _rotation, _sizeA, _sizeB, [_xVal, _yVal]] call kyf_WF_isPointInEllipse;

      if (_isIn or _hasReachedElipse) then {
        // Find intersection point of midway perpendicular lines to find the pos of the centre of the division
        _line2Midm = (_x select 2) select 0;
        _line2Midc = (_x select 2) select 1;

        _xValCentre = (_line2Midc - _line1Midc) / (_line1Midm - _line2Midm);
        _yValCentre = _line1Midm * _xValCentre + _line1Midc;

        // Record division and its details
        _divisions pushBack [_line1Seg, _line2Seg, [_xValCentre, _yValCentre]];

        if !(_hasReachedElipse) then { // i.e. if isIn is true, then we have reached the elipse, hence _hasReachedElipse = true
          _hasReachedElipse = true;
        } else {
          if !(_isIn) then { // i.e. we have reached the elipse but this intersection is outside --> Record this last division and no more.
            _endLoop = true;
          };
        };
      };

      if (_endLoop) exitWith {};

    } forEach (_lineSegments select 1);
  } forEach (_lineSegments select 0);
};
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Divide the zone into segments
// See exhibit elipse segmentation 1 for a good illustration of this function  *** will need to redo this! ***

_divideZone = {
  private ["_point1", "_point2", "_point3", "_point4", "_allLineSegments", "_pointA", "_pointB", "_length", "_pointAX", "_pointAY", "_pointBX", "_pointBY", "_segmentLength", "_k", "_normalizedX", "_normalizedY", "_lineEquation", "_m", "_c", "_lineSegments"];
  params ["_point1", "_point2", "_point3", "_point4"];

  //----------------------------------------------------------------------------
  // Break up the axis into equal segemnts
  _allLineSegments = [];

  {
    _pointA = _x select 0;
    _pointB = _x select 1;
    _length = _x select 2; // length here represents half the length of the axis, in meters

    _pointAX = _pointA select 0;
    _pointAY = _pointA select 1;
    _pointBX = _pointB select 0;
    _pointBY = _pointB select 1;

    _segmentLength = 2 * _length / (floor (_length / 1000)); // *** SHOW WORKING OUT

    //--------------------------------------------------------------------------
    // Normalize the line (assume point A is the start and point B is the end)
    // Normalization formula: distance traveled in x or y or z, divided by the lenght of the line
    _k = 2 * _length; // _k represents the total lenght of the line from point A to point B
    _normalizedX = _segmentLength * (_pointBX - _pointAX) / _k; // When normalized, 1 unit represents 1 meter of movement. Thus in order to advance at the correct segment length every time we add x or y, we must multiply by _segmentLength
    _normalizedY = _segmentLength * (_pointBY - _pointAY) / _k; // i.e. every time we add _normalized x and y, we move the appropriate segment Length (which is somewhere around 2km) down the line, breaking the line up into roughly 2km segments.
    //--------------------------------------------------------------------------

    _lineEquation = [_pointA, _pointB] call kyf_WF_getSLEqn;
    _m = _lineEquation select 0; // _m = gradient
    _c = _lineEquation select 1; // _c = y-int

    _lineSegments = [];
    for [{private _i = 1; private _startX = _pointA select 0; private _startY = _pointA select 1; private ["_xValSeg", "_yValSeg", "_xValMid", "_yValMid"]}, {_i <= (floor (_length / 1000))}, {_i = _i + 1}] do {

      // Get x and y val of the segment point to get the equation of the perpendicular segment line
      _xValSeg = _startX + _i * _normalizedX;
      _yValSeg = _startY + _i * _normalizedY;

      // Get x and y val of the midway point to get the equation of the perpendicular line that runs through it
      _xValMid = _xValSeg - (_normalizedX / 2);
      _yValMid = _yValSeg - (_normalizedY / 2);

      _lineSegments pushBack [_i * _segmentLength, [-1 / _m, _yValSeg + (_xValSeg / _m)], [-1 / _m, _yValMid + (_xValMid / _m)]]; // The second element is the equation of the line representing this segment, which runs perpendicular to the line connecting points A and B (hence mPerp = -1 / mAB),
      //while the third element is the equation of the line running perpendicular to AB at the midway point of the segment. See Perpendicular segment line Equation 1
      // With this method the very first point is not included (pointA) but the very last one is (pointB). The idea here is that we use the <= _distance method to distinguish the segments from one another.
      // *** SHOW MORE EXPLANATION
    };

    _allLineSegments pushBack _lineSegments;
  } forEach [[_point1, _point2, _sizeA], [_point3, _point4, _sizeB]]; // Each array represents a major axis of the elipse.
  //----------------------------------------------------------------------------

  // Now combine the horizontal and vertical line segments to create zone divisions
  // Then place them all in an array
  _divisions = [];

};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Take all zone markers and put them in an array

_zonesUnsorted = [];
_exitPointsUnsorted = [];
_zoneCount = 0;
{
  if ((_x select [0, 8]) isEqualTo "kyf_zone") then {
    _zonesUnsorted pushBack _x;
    _zoneCount = _zoneCount + 1;
  } else {
    if ((_x select [0, 7]) isEqualTo "kyf_zep") then { // zep = zone exit point
      _exitPointsUnsorted pushBack _x;
    };
  };
} forEach allMapMarkers;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Sort the zones in order and add their info and segments
_allZones = [];
_zepIndex = -1; // Used to give each exit point a unique number, which will come very usefull in creating a hash table-like data structure later on
missionNamespace setVariable ["kyf_zepHashTable", []];
_hashTable = missionNamespace getVariable "kyf_zepHashTable"; // zep are organised based on _zepIndex in this table.

for [{private _i = 0}, {_i < _zoneCount}, {_i = _i + 1}] do {
  for [{private _n = 0; private ["_zone"]}, {_n < (count _zonesUnsorted)}, {_n = _n + 1}] do {
    _zone = _zonesUnsorted select _n;

    if ([str _i, _zone, 8] call kyf_WF_compareStrToNestedStr) exitWith {
      _allZones pushBack ([_zone] call _addBasicZoneInfo);
      _zonesUnsorted deleteAt _n;
    };
  };
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Complete exit point information
// Add the unique index of the link to the linkInfo array within the exit point
{
  private ["_linkInfo", "_linkPos", "_linkZone"];

  {
    _linkInfo = _x select 2;
    _linkPos = _linkInfo select 1;
    _linkZone = _linkInfo select 0;

    {
      if (_linkPos isEqualTo (_x select 1)) exitWith {
         _linkInfo pushBack (_x select 0);
      };
    } forEach ((_allZones select _linkZone) select 2);

  } forEach (_x select 2);

} forEach _allZones;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Now pre-calculate all optimal land routs for each division and save them in the zone array
{
  private _zone = _x;

  {
    private [];
  } forEach (_zone select 3);
} forEach _allZones;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/*xVal = ((getMarkerPos "start") select 0) + 100;
yVal = (getMarkerPos "start") select 1;

while {xVal < ((getMarkerPos "end") select 0)} do {
  _marker = createMarker [str xVal, [xVal, yVal]];
  _marker setMarkerShape "ICON";
  _marker setMarkerType "hd_dot";
  _marker setMarkerColor "ColorGreen";
  xVal = xVal + 100;
};*/
