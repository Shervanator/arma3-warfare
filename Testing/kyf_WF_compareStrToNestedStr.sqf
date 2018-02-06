/*
*** UPDATE INCORRECT DESCRIPTION
Function for comparing an integer string to an integer that is nested/ part of a larger string
 (e.g. "12" to "zone12"). The number in the string strats from a specific pos and can either end at
the end of the string or at a given "end symbol" (for example a "_").

Parameters:
_intStr: Integer in string form to compare to
_string: The string in which the int is nested in
_start: The index at which int starts in the string
(optional) _endSymbol: A symbol or letter that marks the end of the int. If left empty
the function will read till the end of the string.
(optional) _esInstance: Which instance of the endsymbol within the string, in case it hase multiple occurences.

Returns:
Boolean, whether or not the int was equal to the nested int.

Author: kyfohatl
*/

private ["_intStr", "_string", "_start", "_endSymbol", "_intStr", "_isEqual", "_countNestedInt"];
params ["_intStr", "_string", "_start", "_endSymbol", "_esInstance"];

_isEqual = false;

// Same number of digits?
_countNestedInt = 0;
if (isNil "_endSymbol") then {
  _countNestedInt = (count _string) - _start;
} else {
  if (isNil "_esInstance") then {
    _parameters = [_string, _endSymbol];
  } else {
    _parameters = [_string, _endSymbol, _esInstance];
  };

  _countNestedInt = (_parameters call kyf_WF_findSymbolInStr) - _start;
};

// If number of digits is the same, compare the numbers
if ((count _intStr) == _countNestedInt) then {
  if ((_string select [_start, _countNestedInt]) isEqualTo _intStr) then {
    _isEqual = true;
  };
};

_isEqual
