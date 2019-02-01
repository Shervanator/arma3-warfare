/* Given the slope of two straight lines, this function will reutnr the angle betwen them

Parameters:
  - _m1 and _m2: The slope of the two lines
  - _type: Int. If 0, the original angle value will be returned. If 1, the acute angle will be returned and if 2 the obtuse angle 
  will be returned

Returns:
  - _angle: The angle between the two lines in degrees

Author: kyfohatl
*/

private ["_m1", "_m2", "_type"];
params ["_m1", "_m2", "_type"];

_angle = atan ((_m1 - _m2) / (1 + (_m1 * _m2)));

// Get positive value for angle in case arctan returns a negative value
if (_angle < 0) then {
  _angle = 180 + _angle;
};

// Check which angle is required (acute, obtuse or original value)
if (_type != 0) then {
  if (_type == 1) then {

    // The acute angle is desired
    if (_angle > 90) then {
      _angle = 180 - _angle;
    };

  } else {

    // The obtuse angle is desired
    if (_angle < 90) then {
      _angle = 180 - _angle;
    };
  };
};

_angle