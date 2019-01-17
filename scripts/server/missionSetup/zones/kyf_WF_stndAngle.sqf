/* Standardize Angle Function:
Author: kyfohatl

This function takes any angle in degrees and gives back it's equivalent on the scale of 0 to 360 degrees,
eliminating negative and >360 angles.
*/

params ["_angle"];
private ["_angle", "_stndAngle"];

_stndAngle = 0;

if (_angle > 0) then {
  _stndAngle = _angle - ((floor (_angle / 360)) * 360);
} else {
  _angle = _angle * -1;
  _stndAngle = 360 + ((floor (_angle / 360)) * 360) - _angle;
};

_stndAngle
