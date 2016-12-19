private ["_object", "_type", "_delete", "_funcExists", "_reverseFuncList"];
params ["_object", "_type", "_delete"];

_funcExists = false;
_reverseFuncList = _object getVariable "reverseFuncList";

if !(isNil "_reverseFuncList") then {
  for [{private _i = 0}, {_i < (count _reverseFuncList)}, {_i = _i + 1}] do {
    if (((_reverseFuncList select _i) select 0) == "_type") then {
      _funcExists = true;
      if (_delete) then {
        _reverseFuncList deleteAt _i;
        _i = _i - 1;
      };
    };
  };

  if (((count _reverseFuncList) == 0) and _delete) then {
    _object setVariable ["reverseFuncList", nil];
  };
} else {
  if !(_delete) then {
    _object setVariable ["reverseFuncList", []];
  };
};

_funcExists
