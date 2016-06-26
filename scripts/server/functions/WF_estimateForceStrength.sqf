private ["_strengthPoints", "_allForces", "_vehicle", "_vehicleAlreadySaved"];
params ["_allForces"];

_strengthPoints = 0;
_randomVarName = str (random 100000);
_deleteVar = [];

if (!(isNil "_allForces")) then {
  {
    if ((_x isKindOf "Man") and ((vehicle _x) == _x)) then {
      _strengthPoints = _strengthPoints + 1;
    } else {
      // JETS are ignored as they are not tied to a force of a specific area and instead travel through the map rapidly
      _vehicle = _x;

      if (_x isKindOf "Man") then {
        _vehicle = vehicle _x;
      };

      if (({alive _x} count (crew _vehicle)) > 0) then {
        _vehicleAlreadySaved = _vehicle getVariable _randomVarName;
        if (isNil "_vehicleAlreadySaved") then {
          if (_vehicle isKindOf "Car") then {
            if (_vehicle isKindOf "Wheeled_APC_F") then {
              _strengthPoints = _strengthPoints + 4;
            } else {
              if (_vehicle isKindOf "Truck_F") then {
                _strengthPoints = _strengthPoints - 1;
              } else {
                _strengthPoints = _strengthPoints + 0;
              };
            };
          };

          if (_vehicle isKindOf "Tank") then {
            _strengthPoints = _strengthPoints + 7;
          };

          if (_vehicle isKindOf "Helicopter") then {
            _strengthPoints = _strengthPoints + 4;
          };

          if (_vehicle isKindOf "Boat_F") then {
            _strengthPoints = _strengthPoints + 1;
          };
          if (_vehicle isKindOf "StaticWeapon") then {
            _strengthPoints = _strengthPoints + 0;  // not necessary, only here if it is decided to give static weapons more value
          };

          _strengthPoints = _strengthPoints + (({alive _x} count (crew _vehicle)) + 1);
          _vehicle setVariable [_randomVarName, true];
          _deleteVar pushBack _vehicle;
        };
      };
    };
  } forEach _allForces;

  {
    _x setVariable [_randomVarName, nil];
  } forEach _deleteVar;
};

_strengthPoints
