private ["_object", "_type", "_input", "_list", "_reverseFunc"];
params ["_object", "_type", "_input"];

_list = _object getVariable "reverseFuncList";
if !(isNil "_list") then {
  {
    if ((_x select 0) == _type) exitWith {
      _reverseFunc = _x select 1;
      _input call _reverseFunc;
    };
  } forEach _list;
};
