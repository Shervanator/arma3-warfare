/* Function for adding an element to any index in an array.

Parameters:
_array: The array to be modified
_element: The element to be added
_index: The index at which the element is to be inserted

Returns:
Nothing

Author: kyfohatl */

private ["_array", "_element", "_index", "_countArray"];
params ["_array", "_element", "_index"];

_countArray = count _array;

if ((_index == _countArray) or (_countArray == 0)) then { // i.e. element is to be added to the end of the array or the array is empty

  _array set [_index, _element];
} else {

  for [{private _i = (count _array) - 1}, {_i >= 0}, {_i = _i - 1}] do {

    _array set [_i + 1, _array select _i];

    if (_i == _index) exitWith {
      _array set [_index, _element];
    };
  };
};
