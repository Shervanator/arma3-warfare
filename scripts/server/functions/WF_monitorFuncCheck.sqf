private ["_side", "_identity", "_delete", "_funcExists", "_monitorFuncList"];
params ["_side", "_identity", "_delete"];

_funcExists = false;
_monitorFuncList = missionNamespace getVariable ("monitorFunctions" + (str _side));
if !(isNil "_monitorFuncList") then {
  for [{private _i = 0}, {_i < (count _monitorFuncList)}, {_i = _i + 1}] do {
    if (((_monitorFuncList select _i) select 0) isEqualTo _identity) then {
      _funcExists = true;
      if (_delete) then {
        _monitorFuncList deleteAt _i;
        _i = _i - 1;
      };
    };
  };
};

_funcExists
