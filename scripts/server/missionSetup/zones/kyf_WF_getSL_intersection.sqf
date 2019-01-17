/* Function for finding the intersection of two straight lines, given their queations

Parameters:
_lin1m = slope of the first line
_line1c = y-intercept of the first line 
_lin2m = slope of the second line
_line2c = y-intercept of the second line 

Returns: The coordinates (2D) of the intersection point 

Author: kyfohatl */

private ["_line1m", "_line1c", "_line2m", "_line2c"];
params ["_line1m", "_line1c", "_line2m", "_line2c"];

private _xVal = (_line2c - _line1c) / (_line1m - _line2m);
private _yVal = _line1m * _xVal + _line1c;

[_xVal, _yVal]