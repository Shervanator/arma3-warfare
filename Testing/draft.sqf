_divideZone = {
  private [];
  params ["_point1", "_point2", "_point3", "_point4"];

  //----------------------------------------------------------------------------
  // Break up the axis into equal segemnts
  _allLineSegments = [];

  {
    _length = _x select 2; // length here represents half the length of the axis, in meters
    _segmentLength = 2 * _length / (floor (_length / 1000)); // *** SHOW WORKING OUT
  } forEach [[_point1, _point2, _sizeA], [_point3, _point4, _sizeB]]; // Each array represents a major axis of the elipse.
  //----------------------------------------------------------------------------

  // Now combine the horizontal and vertical line segments to create zone divisions
  // Then place them all in an array
  _divisions = [];

};
