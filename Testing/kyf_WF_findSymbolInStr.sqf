/* Function for finding a symbol or letter within a string. The instance parameter will determine
which occurance of the symbol we are after, in case of multiple occurances of the same symbol in
the string. If left empty, the first instance will be returned.

Parameters:
_string: string to be provided
_symbol: symbol/ letter we are after
(optional) _instance = which instance of the symbol

Returns:
integer, showing the index of the symbol within the string. If the symbol is not found,
-1 is returned.

Author: kyfohatl
*/

private ["_string", "_symbol", "_instance", "_return"];
params ["_string", "_symbol", "_instance"];

_return = -1;

for [{private _i = 0; private _continue = true}, {(_i < (count _string)) and _continue}, {_i = _i + 1}] do {
  if ((_string select [_i, 1]) isEqualTo _symbol) then {
    if (isNil "_instance") then {
      _return = _i;
      _continue = false;
    } else {
      if (_instance == 1) then {
        _return = _i;
        _continue = false;
      } else {
        _instance = _instance - 1;
      };
    };
  };
};

_return
