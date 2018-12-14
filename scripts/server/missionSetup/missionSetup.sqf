// ***TO DO!!!
 /*AT some point the exit point info defined in missionConstructionResources on missionNamespace need to be removed as they no longer will be
 necessary. Perhaps in some sort of kyf_WF_missionConstructionCleanup file or something like that. In the following form:

{
  missionNamespace setVariable [_markerName + _x, nil];
} forEach ["_Link", "_LinkD2", "_LinkD"];*/

//------------------------------------------------------------------------------
#define ZONE_TAG "kyf_zone"
#define ZEP_TAG "kyf_zep"

#define HASH_TABLE_NAME "kyf_zepHashTable"
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
      // exit point format [index identifier, pos, [link zone, link pos], distance from pos to linkPos squared, distance from pos to linkPos]
    };
  };
  //----------------------------------------------------------------------------

  [_i, [_centre, _sizeA, _sizeB, _rotation, _cornerPoints], _exitPointInfo] // Return val. This is what a zone looks like after this function has run.
  // format: [zone index identifier, [basic geometrical info], array containing all exit points]
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
// Divide the zone into segments
// See exhibit elipse segmentation 1 for a good illustration of this function
#define idealSegmentSize 2000 // Size of segments in meters that the function will try to divide each axis in

_segmentZoneAxis = {
  private ["_point1", "_point2", "_point3", "_point4", "_allLineSegments", "_pointA", "_pointB", "_length", "_pointAX", "_pointAY", "_pointBX", "_pointBY", "_segmentCount", "_segmentLength", "_normalizedX", "_normalizedY", "_lineEquation", "_m", "_c", "_lineSegments"];
  params ["_point1", "_point2", "_point3", "_point4"]; // The four corner points of the elipse

  //----------------------------------------------------------------------------
  // Break up the axis into equal segemnts
  _allLineSegments = [];

  {
    _pointA = _x select 0;
    _pointB = _x select 1;
    _length = 2 * (_x select 2); // length here represents the length of the axis, in meters (i.e. 2 * _sizeA or 2 * _sizeB)

    _pointAX = _pointA select 0;
    _pointAY = _pointA select 1;
    _pointBX = _pointB select 0;
    _pointBY = _pointB select 1;

    _segmentCount = floor (_length / idealSegmentSize);
    _segmentLength = _length / _segmentCount; // see exhibit elipse segmentation 1 for explanation

    //--------------------------------------------------------------------------
    // Normalize the line (assume point A is the start and point B is the end)
    // Normalization formula: distance traveled in x or y or z, divided by the lenght of the line
    _normalizedX = _segmentLength * (_pointBX - _pointAX) / _length; // When normalized, 1 unit represents 1 meter of movement. Thus in order to advance at the correct segment length every time we add x or y, we must multiply by _segmentLength
    _normalizedY = _segmentLength * (_pointBY - _pointAY) / _length; // i.e. every time we add _normalized x and y, we move the appropriate segment Length (which is somewhere around idealSegmentSize) down the line, breaking the line up into roughly idealSegmentSize segments.
    //--------------------------------------------------------------------------

    _lineEquation = [_pointA, _pointB] call kyf_WF_getSLEqn;
    _m = _lineEquation select 0; // _m = gradient
    _c = _lineEquation select 1; // _c = y-int

    _lineSegments = [];
    for [{private _i = 1; private _startX = _pointA select 0; private _startY = _pointA select 1; private ["_xValSeg", "_yValSeg", "_xValMid", "_yValMid"]}, {_i <= _segmentCount}, {_i = _i + 1}] do {

      // Get x and y val of the segment point to get the equation of the perpendicular segment line
      _xValSeg = _startX + _i * _normalizedX;
      _yValSeg = _startY + _i * _normalizedY;

      // Get x and y val of the midway point to get the equation of the perpendicular line that runs through it
      _xValMid = _xValSeg - (_normalizedX / 2);
      _yValMid = _yValSeg - (_normalizedY / 2);

      _lineSegments pushBack [_i * _segmentLength, [-1 / _m, _yValSeg + (_xValSeg / _m)], [-1 / _m, _yValMid + (_xValMid / _m)]]; // The second element is the equation of the line representing this segment, which runs perpendicular to the line connecting points A and B (hence mPerp = -1 / mAB),
      //while the third element is the equation of the line running perpendicular to AB at the midway point of the segment. See Perpendicular segment line Equation 1
      // With this method the very first point is not included (pointA) but the very last one is (pointB). The idea here is that we use the <= _distance method to distinguish the segments from one another.
    };

    _allLineSegments pushBack _lineSegments;
  } forEach [[_point1, _point2, _sizeA], [_point3, _point4, _sizeB]]; // Each array represents a major axis of the elipse.

  /* _allLineSegments format: [_axisASegments, _axisBSegments]
  Where each _axisSegments array is [[seg1, perpLineEqn, perpHalfwayLineEqn], [seg2, perpLineEqn, perpHalfwayLineEqn], ...] */
  _allLineSegments
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for taking axis line segments and creating zone divisions with them
// *** Show detailed working out

_createDivisions = {
  private ["_lineSegments", "_zoneGeoInfo", "_centreX", "_centreY", "_sizeA", "_sizeB", "_rotation", "_divisions", "_line1m", "_line1c", "_line1Seg", "_hasReachedElipse", "_endLoop", "_line2m", "_line2c", "_line2Seg", "_xVal", "_yVal", "_isIn"];
  params ["_lineSegments", "_zoneGeoInfo"];

  _centreX = (_zoneGeoInfo select 0) select 0;
  _centreY = (_zoneGeoInfo select 0) select 1;
  _sizeA = _zoneGeoInfo select 1;
  _sizeB = _zoneGeoInfo select 2;
  _rotation = _zoneGeoInfo select 3;

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

      // Check to see if the intersect point is inside the elipse
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

  _divisions // format = [div1 info, div2 info, ...] with each division format = [_line1Seg, _line2Seg, centre point of the division]
};
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

// START
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Take all zone and exit point markers and put them in their corresponding array

_zonesUnsorted = [];
_exitPointsUnsorted = [];
_zoneCount = 0;
{
  if ((_x select [0, 8]) isEqualTo ZONE_TAG) then {
    _zonesUnsorted pushBack _x;
    _zoneCount = _zoneCount + 1;
  } else {
    if ((_x select [0, 7]) isEqualTo ZEP_TAG) then { // zep = zone exit point
      _exitPointsUnsorted pushBack _x;
    };
  };
} forEach allMapMarkers;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Sort the zones in order and add their basic info and segments

kyf_WG_allZones = []; /*Initialize the global zones var. This var will be used here (instead of a local var) because some of the ncessary
mission construction functions (namely findZone and findShortestPath) require this global var. During mission runtime however, the mission
construction files will not run and hence this var will contain the finished version of the zone info.*/

_zepIndex = -1; // Used to give each exit point a unique number, which will come very usefull in creating a hash table-like data structure later on
missionNamespace setVariable [HASH_TABLE_NAME, []];
_hashTable = missionNamespace getVariable HASH_TABLE_NAME; // zep are organised based on _zepIndex in this table.

for [{private _i = 0}, {_i < _zoneCount}, {_i = _i + 1}] do {
  for [{private _n = 0; private ["_zone"]}, {_n < (count _zonesUnsorted)}, {_n = _n + 1}] do {
    _zone = _zonesUnsorted select _n;

    if ([str _i, _zone, 8] call kyf_WF_compareStrToNestedStr) exitWith {
      kyf_WG_allZones pushBack ([_zone] call _addBasicZoneInfo);
      // Each zone now looks like the following format: [zone index identifier, [basic geometrical info], exit point info]
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
    // exit point format [index identifier, pos, [link zone, link pos], distance from pos to linkPos squared, distance from pos to linkPos]
    _linkInfo = _x select 2;
    _linkPos = _linkInfo select 1;
    _linkZone = _linkInfo select 0;

    {
      if (_linkPos isEqualTo (_x select 1)) exitWith {
         _linkInfo pushBack (_x select 0);
         // exit point format after this: [index identifier, pos, [link zone, link pos, link index identifier], distance from pos to linkPos squared, distance from pos to linkPos]
      };
    } forEach ((kyf_WG_allZones select _linkZone) select 2); // = each exit point of the link zone

  } forEach (_x select 2) // = _exitPointInfo;

} forEach kyf_WG_allZones;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Divide the zone into divisions

// Initialize necessary array
kyf_WG_zoneDivisions = []; /*containing geometrical data for divisions of each zone. A zone's index in the kyf_WG_allZones array corresponds
to it's index in this array.*/

// Fill up _zoneDivisions
for [{private _i = 0; private ["_zoneCornerPoints"]}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  _zone = kyf_WG_allZones select _i;
  _zoneCornerPoints = (_zone select 1) select 4;
  _segmentInfo = _zoneCornerPoints call _segmentZoneAxis;
  kyf_WG_zoneDivisions pushBack ([_segmentInfo, _zone select 1] call _createDivisions);
  /*Because these zone divisions are created in the same order as zones in the allZones array, the index of a zone in the allZones array
  corresponds to its index in the zoneDivisions array*/
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Pre-calculate optimal land routs for each division and save them on division info

// Initialize necessary array
kyf_WG_zoneDivisionPaths = []; // containing all pre-calculated land paths for each zone division

// Loop through each zone and create paths for each of its divisions
for [{private _zoneIndex = 0; private _countZones = count kyf_WG_zoneDivisions; private ["_zoneDivs", "_zonePaths"]}, {_zoneIndex < _countZones}, {_zoneIndex = _zoneIndex + 1}] do {
  _zoneDivs = kyf_WG_zoneDivisions select _zoneIndex; // = all divisions for that zone = [div1, div2, div3, ...]
  _zonePaths = []; // Array will contain all paths for all divisions of this zone

  // Loop through each diviiosn and create paths
  {
    private _centre = _x select 2;
    private _divPaths = []; /*All paths of this div. They are arranged in the same order as the zones in kyf_WG_allZones. So using the index of a zone,
    we can find the shortest path to it from this divisions*/

    // Loop through each zone and create paths to each division on that zone
    for [{private _i = 0; private ["_targetZone", "_targetPaths"]}, {_i < _countZones}, {_i = _i + 1}] do {
      if (_i != _zoneIndex) then { // Make sure we are not creating paths to our own zone
        _targetZone = kyf_WG_zoneDivisions select _i; // _targetZone = array of all the diviions of the zone we are targeting

        if ((count (([_centre, ((_targetZone select 0) select 2), _zoneIndex, _i] call kyf_WF_findShortestPath) select 0)) != 2) then { /* Do a random pathing test to make sure
          that we can path to this zone, and not waste time trying to find a path to a zone we cannot reach division by division.*/
          _targetPaths pushBack []; // empty array represents all the paths to this target zone

          // Loop through each division of target zone and create a path to it
          for [{private _n = 0; private ["_targetDiv"]}, {_n < (count _targetZone)}, {_n = _n + 1}] do {
            _targetDiv = _targetZone select _n;
            _targetPaths pushBack ([_centre, (_targetDiv select 2), _zoneIndex, _i] call kyf_WF_findShortestPath); /* Find shortest path between the centre of the two divisions
            and place it in the paths array, in the same order as the divisions are arranged in the target zone, so that using that divisions index we can find the quickest path
            to it from various divisions around the map.*/
          };

          _divPaths pushBack _targetPaths;
        } else { // i.e. we cannot path to this zone
          _divPaths pushBack [];
        };
      } else { // i.e. this is our own zone and there is no need to create a path to it
        _divPaths pushBack [];
      };
    };

    _zonePaths pushBack _divPaths;
  } forEach _zoneDivs;

  kyf_WG_zoneDivisionPaths pushBack _zonePaths;
};






/*xVal = ((getMarkerPos "start") select 0) + 100;
yVal = (getMarkerPos "start") select 1;

while {xVal < ((getMarkerPos "end") select 0)} do {
  _marker = createMarker [str xVal, [xVal, yVal]];
  _marker setMarkerShape "ICON";
  _marker setMarkerType "hd_dot";
  _marker setMarkerColor "ColorGreen";
  xVal = xVal + 100;
};*/
