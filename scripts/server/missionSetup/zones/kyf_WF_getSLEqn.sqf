/* Get equation of a straight line function:
Author: kyfohatl

This function takes two points and returns the gradient and y-intercept of the resulting line inbetween them,
which are necessary to get the equation of the line*/

private ["_pointA", "_pointB", "_pointAX", "_pointAY", "_pointBX", "_pointBY", "_gradient", "_yIntercept"];
params ["_pointA", "_pointB"];

// Based off of the formula y = mx + c where "m" is the gradient and "c" is the y-intercept
_pointAX = _pointA select 0;
_pointAY = _pointA select 1;
_pointBX = _pointB select 0;
_pointBY = _pointB select 1;

_gradient = (_pointBY - _pointAY) / (_pointBX - _pointAX);

_yIntercept = _pointAY - _gradient * _pointAX;

[_gradient, _yIntercept]
