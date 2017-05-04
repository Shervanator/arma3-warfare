private ["_allVehicles", "_crewCount", "_class", "_func"];
params ["_allVehicles"];

_crewCount = 0;
for [{private _i = 0; private ["_vehicleCfg", "_cfg"]}, {_i < (count _allVehicles)}, {_i = _i + 1}] do {
  _vehicleCfg = _allVehicles select _i;

  _cfg = _vehicleCfg >> "hasDriver";
  if !(isNull _cfg) then {
    if ((getNumber _cfg) == 1) then {
      _crewCount = _crewCount + 1;
    };
  };

  _func = {
    private ["_cfg"];
    params ["_cfg"];

    if !(isNull _cfg) then {
      if ((count _cfg) > 0) then {
        for [{private _i = 0; private ["_entry"]}, {_i < (count _cfg)}, {_i = _i + 1}] do {
          _entry = _cfg select _i;
          if (((configName _entry) find "Cargo") == -1) then {
            _crewCount = _crewCount + 1;
          };

          [_entry >> "Turrets"] call _func;
        };
      };
    };
  };

  [_vehicleCfg >> "Turrets"] call _func;
};

_crewCount
