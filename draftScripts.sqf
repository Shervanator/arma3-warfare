/* A bad attempt at making divisions of a zone eliptical rather than like a rectangle.
It does not fully cover an elipse and hence for now will not be used */

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
        #ifdef SETUP_ZONE_DEBUG_MAJOR
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