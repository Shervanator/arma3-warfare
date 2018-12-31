// ***TO DO!!!
 /*- AT some point the exit point info defined in missionConstructionResources on missionNamespace need to be removed as they no longer will be
 necessary. Perhaps in some sort of kyf_WF_missionConstructionCleanup file or something like that. In the following form:

{
  missionNamespace setVariable [_markerName + _x, nil];
} forEach ["_Link", "_LinkD2", "_LinkD"];

- Test if a very small zone (smaller than IDEAL_SEGMENT_SIZE) is segmented into just 1 segment properly as it should be

- What happens if a point is overlapped by two zones? */

//------------------------------------------------------------------------------
// DEBUG
#include "scripts\debug\debug_settings.sqf"

//------------------------------------------------------------------------------
#define ZONE_TAG "kyf_zone"
#define ZEP_TAG "kyf_zep"
#define ZN_LETCOUNT 8

// Ideal size of zone axis segments in meters
#define IDEAL_SEGMENT_SIZE 200

#define HASH_TABLE_NAME "kyf_zepHashTable"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for adding basic exit point information to a zone

_add_zep_info = {
  private ["_zepIndex", "_exitPointsUnsorted", "_zoneInfo"];
  params ["_zepIndex", "_exitPointsUnsorted", "_zoneInfo"];

  private _zoneName = _zoneInfo select 2;

  // DEBUG
  #ifdef MAJOR_DEBUG
    diag_log DEBUG_TITLE;
    diag_log "ZEP DEBUG:";
    diag_log format ["Parent Zone: %1", _zoneName];
  #endif
  //END DEBUG

  private _exitPointInfo = [];

  for [{private _i = 0; private _zoneNumberStr = _zoneName select [ZN_LETCOUNT, (count _zoneName) - ZN_LETCOUNT]; private ["_linkPos", "_zep", "_start"]}, {_i < (count _exitPointsUnsorted)}, {_i = _i + 1}] do {
    _zep = _exitPointsUnsorted select _i;

    // Isolate the name of the owning zone from the name of the zep. In format kyf_zep12_z2, the second instance of "z" is our start point
    _start = ([_zep, "z", 2] call kyf_WF_findSymbolInStr) + 1;

    // See if the exit point belongs this zone (i.e. has the same zone number). The zone number in format kyf_zone12 can be aquired by selecting between ZN_LETCOUNT and (count _zoneName) - ZN_LETCOUNT
    if ([_zoneNumberStr, _zep, _start] call kyf_WF_compareStrToNestedStr) then {
      // Assign exit point a unique number _zepIndex which corresponds to the index it occupies in the hash table array.
      _zepIndex = _zepIndex + 1;

      /* Hash table where zep's are organized based on _zepIndex. Table select _zepIndex will now provide us with an array unique to this exit point, where we can store paths in our A* algorithm,
      although the array is empty at this point */
      (missionNamespace getVariable HASH_TABLE_NAME) pushBack [];

      // DEBUG
      // Debug exit point linkage
      #ifdef EXTREME_DEBUG
        diag_log "Exit point link debug:";
        diag_log format ["Exit marker: %1", _zep];
        diag_log format ["Link marker: %1", missionNamespace getVariable (_zep + "_Link")];
      #endif
      // END DEBUG

      _linkPos = getMarkerPos (missionNamespace getVariable (_zep + "_Link"));

      // exit point format [index identifier, pos, [link zone, link pos], distance from pos to linkPos squared, distance from pos to linkPos]
      _exitPointInfo pushBack [_zepIndex, getMarkerPos _zep, [[_linkPos, false] call kyf_WF_findZone, _linkPos], missionNamespace getVariable (_zep + "_LinkD2"), missionNamespace getVariable (_zep + "_LinkD")];

      // DEBUG
      #ifdef MAJOR_DEBUG
        diag_log "zep format: [index identifier, pos, [link zone, link pos], distance from pos to linkPos squared, distance from pos to linkPos]";
        diag_log _exitPointInfo;
      #endif
      // END DEBUG
    };
  };

  _zoneInfo pushBack _exitPointInfo;
  _zepIndex
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for finding the corner points of an elipse
/* The centre of the elipse is placed on the origin and the rotation of the elipse set to 0. The corner points are then found easiliy. From there, the corner points are rotated
based on the angle of the elipse, and then translated to the elipse's original position to obtain the true corner points of the elipse.
Based on the formula for rotation of a point around the origin with (x1, y1) and a rotation of @ degrees: x2 = x1Cos@ - y1Sin@, y2 = y1Cos@ + x1Sin@*/

_getElipseCornerPoint = {
  private ["_xVal", "_yVal", "_rotation", "_centreX", "_centreY"];
  params ["_xVal", "_yVal", "_rotation", "_centreX", "_centreY"];

  [(_xVal * (Cos _rotation)) - (_yVal * (sin _rotation)) + _centreX, (_yVal * (cos _rotation)) + (_xVal * (sin _rotation)) + _centreY]
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for adding important zone info to the zone array for future use

_addBasicZoneInfo = {
  private ["_zone", "_zoneIndex"];
  params ["_zone", "_zoneIndex"];

  private _centre = markerPos _zone;
  private _centreX = _centre select 0;
  private _centreY = _centre select 1;
  private _size = markerSize _zone;
  private _sizeA = _size select 0;
  private _sizeB = _size select 1;

  // Standardize rotation angle of the marker. Rotation has to be negated for some reason for calculations to work properly
  private _rotation = -([markerDir _zone] call kyf_WF_stndAngle); // ***is standardizing the angle necessary?

  // These are the four corner points of the elipse marker (where the major and minor axis intersect the parameter),
  // translated so that the centre of the elipse is at the origin, and unrotated
  // so that the elipse is at a 0 degree rotation. See diagram elipse rotation 1.
  private _cornerPoints = [];
  {
    _cornerPoints pushBack ([_x select 0, _x select 1, _rotation, _centreX, _centreY] call _getElipseCornerPoint);
  } forEach [[-_sizeA, 0], [_sizeA, 0], [0, -_sizeB], [0, _sizeB]];

  // DEBUG
  // Create debug markers to show the position of the zones
  #ifdef MAJOR_DEBUG
    private _zoneMarker = createMarker [(str _centre) + "Area", _centre];
    _zoneMarker setMarkerShape "ELLIPSE";
    _zoneMarker setMarkerDir -_rotation;
    _zoneMarker setMarkerSize [_sizeA, _sizeB];
    _zoneMarker setMarkerColor "ColorRed";
    _zoneMarker setMarkerAlpha 0.4;

    private _centreMarker = createMarker [str _centre, _centre];
    _centreMarker setMarkerShape "ICON";
    _centreMarker setMarkerType "hd_dot";
    _centreMarker setMarkerColor "ColorRed";

    {
      private _corner = createMarker [str _x, _x];
      _corner setMarkerShape "ICON";
      _corner setMarkerType "hd_dot";
      _corner setMarkerColor "ColorRed";
    } forEach _cornerPoints;
  #endif
  // END DEBUG

  // Return val. This is what a zone looks like after this function has run. Format: [zone index identifier, [basic geometrical info], zone marker name]
  [_zoneIndex, [_centre, _sizeA, _sizeB, _rotation, _cornerPoints], _zone]
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Divide the zone into segments
// See exhibit elipse segmentation 1 for a good illustration of this function

_segmentZoneAxis = {
  private ["_point1", "_point2", "_point3", "_point4", "_sizeA", "_sizeB"];
  params ["_point1", "_point2", "_point3", "_point4", "_sizeA", "_sizeB"]; // The four corner points of the elipse and half the length of the two axis

  //----------------------------------------------------------------------------
  // Break up the axis into equal segemnts
  private _allLineSegments = [];

  {
    private _pointA = _x select 0;
    private _pointB = _x select 1;
    private _length = 2 * (_x select 2); // length here represents the length of the axis, in meters (i.e. 2 * _sizeA or 2 * _sizeB)

    private _pointAX = _pointA select 0;
    private _pointAY = _pointA select 1;
    private _pointBX = _pointB select 0;
    private _pointBY = _pointB select 1;

    // Find the segment length closest to IDEAL_SEGMENT_SIZE that divides the lenghts of the axis into equal segments
    private _segmentCount = floor (_length / IDEAL_SEGMENT_SIZE);

    // Make the entire zone just one segment by default, in case the IDEAL_SEGMENT_SIZE is larger than the dimensions of the zone (protect against zero divisor)
    private _segmentLength = _length;

    // If IDEAL_SEGMENT_SIZE is smaller than the zone, then break the zone up into multiple segments
    if (_segmentCount > 0) then {
      _segmentLength = _length / _segmentCount; // see exhibit elipse segmentation 1 for explanation
    };

    //--------------------------------------------------------------------------
    // Normalize the line (assume point A is the start and point B is the end)
    // Normalization formula: distance traveled in x or y or z, divided by the lenght of the line
    private _normalizedX = _segmentLength * (_pointBX - _pointAX) / _length; // When normalized, 1 unit represents 1 meter of movement. Thus in order to advance at the correct segment length every time we add x or y, we must multiply by _segmentLength
    private _normalizedY = _segmentLength * (_pointBY - _pointAY) / _length; // i.e. every time we add _normalized x and y, we move the appropriate segment Length (which is somewhere around IDEAL_SEGMENT_SIZE) down the line, breaking the line up into roughly IDEAL_SEGMENT_SIZE segments.
    //--------------------------------------------------------------------------

    private _lineEquation = [_pointA, _pointB] call kyf_WF_getSLEqn;
    private _m = _lineEquation select 0; // _m = gradient
    private _c = _lineEquation select 1; // _c = y-int

    private _lineSegments = [];
    for [{private _i = 1; private _startX = _pointA select 0; private _startY = _pointA select 1; private ["_xValSeg", "_yValSeg", "_xValMid", "_yValMid"]}, {_i <= _segmentCount}, {_i = _i + 1}] do {

      // Get x and y val of the segment point to get the equation of the perpendicular segment line
      _xValSeg = _startX + _i * _normalizedX;
      _yValSeg = _startY + _i * _normalizedY;

      // Get x and y val of the midway point to get the equation of the perpendicular line that runs through it
      _xValMid = _xValSeg - (_normalizedX / 2);
      _yValMid = _yValSeg - (_normalizedY / 2);

      // DEBUG
      // Place a marker for both segment points and the middle of each segment
      #ifdef MAJOR_DEBUG
        private _segMarker = createMarker [str ([_xValSeg, _yValSeg]), [_xValSeg, _yValSeg]];
        _segMarker setMarkerShape "ICON";
        _segMarker setMarkerType "hd_dot";
        _segMarker setMarkerColor "ColorBlue";

        private _midSegMarker = createMarker [str ([_xValMid, _yValMid]),[_xValMid, _yValMid]];
        _midSegMarker setMarkerShape "ICON";
        _midSegMarker setMarkerType "hd_dot";
        _midSegMarker setMarkerColor "ColorGreen";
      #endif
      // END DEBUG

      /* The second element is the equation of the line representing this segment, which runs perpendicular to the line connecting points A and B (hence mPerp = -1 / mAB),
      while the third element is the equation of the line running perpendicular to AB at the midway point of the segment. See Perpendicular segment line Equation 1.
      With this method the very first point is not included (pointA) but the very last one is (pointB). The idea here is that we use the <= _distance method to distinguish the segments from one another.*/
      _lineSegments pushBack [_i * _segmentLength, [-1 / _m, _yValSeg + (_xValSeg / _m)], [-1 / _m, _yValMid + (_xValMid / _m)]];
    };

    _allLineSegments pushBack _lineSegments;
  } forEach [[_point1, _point2, _sizeA], [_point3, _point4, _sizeB]]; // Each array represents a major axis of the elipse.

  // DEBUG
  // Print out all line segment info to rpt file
  #ifdef MAJOR_DEBUG
    diag_log DEBUG_TITLE;
    diag_log format ["%1 %2", FILE_INTRO, __FILE__];
    diag_log "Axis segment debug:";
    diag_log "All line segments: format - [_axisASegments, _axisBSegments]";

    {
      {
        diag_log "Each axis segemnt has format: [seg, perpLineEqn, perpHalfwayLineEqn]";
        diag_log _x;
      } forEach _x; // Each axis segement
    } forEach _allLineSegments;

    diag_log DEBUG_END;
  #endif
  // END DEBUG

  /* _allLineSegments format: [_axisASegments, _axisBSegments]
  Where each _axisSegments array is [[seg1, perpLineEqn, perpHalfwayLineEqn], [seg2, perpLineEqn, perpHalfwayLineEqn], ...] */
  _allLineSegments
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Function for taking axis line segments and creating zone divisions with them
// See elipse divisions for a detailed illustrations

_createDivisions = {
  private ["_lineSegments", "_zoneGeoInfo", "_centreX", "_centreY", "_sizeA", "_sizeB", "_rotation", "_divisions", "_line1m", "_line1c", "_line1Seg", "_passedMid", "_countDiv", "_line2m", "_line2c", "_line2Seg", "_xVal", "_yVal", "_isIn"];
  params ["_lineSegments", "_zoneGeoInfo"];

  _centreX = (_zoneGeoInfo select 0) select 0;
  _centreY = (_zoneGeoInfo select 0) select 1;
  _sizeA = _zoneGeoInfo select 1;
  _sizeB = _zoneGeoInfo select 2;
  _rotation = _zoneGeoInfo select 3;

  _divisions = [];

  /* For each segement line of axis A, find all intersections with segment lines of axis B - starting from the first segment of axis B and working the way up
  to the other end of the axis. Any intersection before reaching the elipse is ignored. After reaching the elipse, all intersections are recorded till the first 
  intersection which is outside the elipse. A division represented by two segment lines is the area enclosed by them and the PREVIOUS segment lines */
  {
    // Figure out where the segment lines and midway lines intersect
    _line1Seg = _x select 0;

    // Segment lines
    _line1m = (_x select 1) select 0;
    _line1c = (_x select 1) select 1;
    // Midway lines
    _line1Midm = (_x select 2) select 0;
    _line1Midc = (_x select 2) select 1;

    _passedMid = false;

    /* Use _countDiv to keep track of how many divisions were created. */
    _countDiv = count _divisions;

    {
      _line2m = (_x select 1) select 0;
      _line2c = (_x select 1) select 1;
      _line2Seg = _x select 0;

      // Check if the mid-point of the elipse has been passed
      if (_line2seg > _sizeB) then {
        _passedMid = true;
      };

      // Find the intersection point of the segment perpendicular lines
      _xVal = (_line2c - _line1c) / (_line1m - _line2m);
      _yVal = _line1m * _xVal + _line1c; // point _xVal, _yVal is where the segment lines intersect

      // Check if the intersection point is inside the elipse
      _isIn = [_centreX, _centreY, _rotation, _sizeA, _sizeB, [_xVal, _yVal]] call kyf_WF_isPointInEllipse;

      /* Record all divisions where segement lines intersect inside the elipse, and the first division where segment lines intersect outside, once passed
      the mid-point of the elipse (this last one accounts for the eliptical shape, instead of a straight-edged rectangle) */
      if (_isIn or _passedMid) then {
        // Find intersection point of midway perpendicular lines to find the pos of the centre of the division
        _line2Midm = (_x select 2) select 0;
        _line2Midc = (_x select 2) select 1;

        _xValCentre = (_line2Midc - _line1Midc) / (_line1Midm - _line2Midm);
        _yValCentre = _line1Midm * _xValCentre + _line1Midc;

        // DEBUG
        #ifdef MAJOR_DEBUG
          private _divMarker = createMarker [str ([_xValCentre, _yValCentre]), [_xValCentre, _yValCentre]];
          _divMarker setMarkerShape "ICON";
          _divMarker setMarkerType "hd_dot";
          _divMarker setMarkerColor "ColorBrown";
        #endif
        // END DEBUG

        // Record division and its details
        _divisions pushBack [_line1Seg, _line2Seg, [_xValCentre, _yValCentre]];
      };

      // If we have passed the mid-point of the elipse, and the intersection of segment lines was not inside the elipse, then that was the last segment we need to record */
      if (_passedMid and !_isIn) exitWith {};

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

private _zonesUnsorted = [];
private _exitPointsUnsorted = [];
private _zoneCount = 0;
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
// Sort the zones in order and add their basic info

/*Initialize the global zones var. This var will be used here (instead of a local var) because some of the ncessary
mission construction functions (namely findZone and findShortestPath) require this global var. During mission runtime however, the mission
construction files will not run and hence this var will contain the finished version of the zone info.*/
kyf_WG_allZones = [];

missionNamespace setVariable [HASH_TABLE_NAME, []];

// Index sort and place zones in kyf_WG_allZones based on their name. So "kyf_zone0" will be at index 0 while "kyf_zone2" will be at index 2
for [{private _i = 0}, {_i < _zoneCount}, {_i = _i + 1}] do {
  for [{private _n = 0; private ["_zone"]}, {_n < (count _zonesUnsorted)}, {_n = _n + 1}] do {
    _zone = _zonesUnsorted select _n;

    if ([str _i, _zone, 8] call kyf_WF_compareStrToNestedStr) exitWith {

      // Each zone will have the following format: [zone index identifier, [basic geometrical info], Zone marker name]
      kyf_WG_allZones pushBack ([_zone, _i] call _addBasicZoneInfo);

      _zonesUnsorted deleteAt _n;
    };
  };
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Now add basic exit point information to each zone

// _zepIndex is used to give each exit point a unique number, which will come very usefull in creating a hash table-like data structure later on
for [{private _i = 0; private _zepIndex = -1}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {

  // After adding exit point info, a zone will have the following format: [zone index, [basic geometrical info], zone marker name, exit point information]
  _zepIndex = [_zepIndex, _exitPointsUnsorted, kyf_WG_allZones select _i] call _add_zep_info;
};


// DEBUG
#ifdef MAJOR_DEBUG
  diag_log DEBUG_TITLE;
  diag_log format ["%1 %2", FILE_INTRO, __FILE__];
  diag_log format ["kyf_WG_allZones: %1", kyf_WG_allZones];
  diag_log DEBUG_END;
#endif
// END DEBUG

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Complete exit point information
// Add the unique index of the link to the linkInfo array within the exit point. This allows identification of the link by comparing a single number, rather than positions.

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
    } forEach ((kyf_WG_allZones select _linkZone) select 3); // = each exit point of the link zone

  } forEach (_x select 3) // = _exitPointInfo;

} forEach kyf_WG_allZones;

// DEBUG
#ifdef MAJOR_DEBUG
  diag_log DEBUG_TITLE;
  diag_log format ["%1 %2", FILE_INTRO, __FILE__];
  diag_log "Exit point and link index identifier debug: Each zep should have the index identifier of their link in their link info array";

  {
    diag_log format ["---------------- %1 ----------------", _x select 2];

    {
      diag_log "Exit point format: [index identifier, pos, [link zone, link pos, link index identifier], distance from pos to linkPos squared, distance from pos to linkPos]";
      diag_log _x;
    } forEach (_x select 3); // _exitPointInfo

  } forEach kyf_WG_allZones;
  
  diag_log DEBUG_END;
#endif
// END DEBUG


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Divide the zone into divisions

// Initialize necessary array containing geometrical data for divisions of each zone. A zone's index in the kyf_WG_allZones array corresponds to it's index in this array
kyf_WG_zoneDivisions = [];

// Fill up _zoneDivisions
for [{private _i = 0; private _elipseInfo = []}, {_i < (count kyf_WG_allZones)}, {_i = _i + 1}] do {
  private _zone = kyf_WG_allZones select _i;
  private _zoneGeoInfo = _zone select 1;

  _elipseInfo = +(_zoneGeoInfo select 4);
  _elipseInfo pushBack (_zoneGeoInfo select 1);
  _elipseInfo pushBack (_zoneGeoInfo select 2);

  _segmentInfo = _elipseInfo call _segmentZoneAxis;
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
