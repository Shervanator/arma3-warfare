/* Function for checking if a point lies inside an ellipse or outside
Author: kyfohatl
*/

private ["_centreX", "_centreY", "_rotation", "_a", "_b", "_point", "_return", "_pointX", "_pointY", "_p", "_q", "_cos", "_sin"];
params ["_centreX", "_centreY", "_rotation", "_a", "_b", "_point"];

_return = false;

_pointX = _point select 0;
_pointY = _point select 1;

_p = _pointX - _centreX;
_q = _pointY - _centreY;
_cos = cos _rotation;
_sin = sin _rotation;

if ((((((_p * _cos) + (_q * _sin)) ^ 2) / (_a ^ 2)) + ((((_p * _sin) - (_q * _cos)) ^ 2) / (_b ^ 2))) <= 1) then {
  _return = true;
};

_return

// *** SHOW WORKING OUT
