/* Function for comparing a string to a nested string (a string that is part of a larger string,
e.g. "12" to "zone12"). The nested string strats from a specific pos and can either end at
the end of the string or at a given "end symbol" which is not part of the nested string
 itslef (for example a "_").

Parameters:
_refStr: The reference string to compare to
_string: The larger string which contains the nested string
_start: The index at which the nested string starts (index)
(optional) _endSymbol: A symbol or letter that marks the end of the nested string, BUT IS NOT PART OF IT,
meaning the next symbol after the nested string. If left empty, the function will read till the end of the string.
(optional) _esInstance: Which instance of the endsymbol within the string, in case it hase multiple occurences.

Returns:
Boolean, whether or not the ref string was equal to the nested string.

Author: kyfohatl
*/

private ["_refStr", "_string", "_start", "_endSymbol", "_refStr", "_isEqual", "_countNestedStr"];
params ["_refStr", "_string", "_start", "_endSymbol", "_esInstance"];

_isEqual = false;

// Same number of symbols?
_countNestedStr = 0;
if (isNil "_endSymbol") then {
  _countNestedStr = (count _string) - _start;
} else {
  if (isNil "_esInstance") then {
    _parameters = [_string, _endSymbol];
  } else {
    _parameters = [_string, _endSymbol, _esInstance];
  };

  _countNestedStr = (_parameters call kyf_WF_findSymbolInStr) - _start;
};

// If the count is the same, compare the symbols
if ((count _refStr) == _countNestedStr) then {
  if ((_string select [_start, _countNestedStr]) isEqualTo _refStr) then {
    _isEqual = true;
  };
};

_isEqual
