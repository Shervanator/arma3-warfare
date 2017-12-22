private [];
params ["_units", "_side"];

_sideStr = str _side;
_needSeats = count _units;
_allTPVehicles = missionNamespace getVariable (_sideStr + "transportVehicles");
_availableTP = [];
_busyTP = [];
_chosen = [];

// group transport vehicles into "available" and "busy"
{
  if (_x getVariable "isOnMission") then {
    _busyTP pushBack _x;
  } else {
    _availableTP pushBack _x;
  };
} forEach _allTPVehicles;

// Order the tp arrays from lowest seat count to highest (used later)
_orderArray = {
  private ["_vehilces", "_ordered", "_minSeats", "_smallestTP", "_seatCount"];
  params ["_vehilces"];

  _ordered = [];
  while {(count _vehilces) > 0} do {
    _minSeats = -1;
    _smallestTP = objNull;
    {
      _seatCount = getNumber (configFile >> "cfgVehicles" >> typeOf _x >> "transportSoldier");
      if ((_seatCount < _minSeats) or (_minSeats == -1)) then {
        _minSeats = _seatCount;
        _smallestTP = _x;
      };
    } forEach _vehicles;

    _ordered pushBack _smallestTP;
    _vehicles deleteAt (_vehicles find _smallestTP);
  }:

  _ordered
};

_availableTP = [_availableTP] call _orderArray;
_busyTP = [_busyTP] call _orderArray;

// Function will take an array of vehicles and see which one (or ones) has enough seats for all units. If no one vehicle has enough seats, it tries to use multiple
_checkAvailableSeats = {
  private ["_vehicles"];
  params ["_vehicles"];

  if ((count _vehicles) > 0) then {
    // Because these have been ordered from smallest to largest, the code will select the smallest vehicle necessary that can carry all the units
    // See if one vehicle is enough
    {
      _seatCount = getNumber (configFile >> "cfgVehicles" >> typeOf _x >> "transportSoldier");
      if (_seatCount >= _needSeats) then {
        _chosen pushBack _x;
      };
    } forEach _vehicles;

    // If one vehicle is not big enough, it tries multiple.
    if ((count _chosen) <= 0) then {
      for [{private _i = 0; private _bigTP = _vehicles select ((count _vehicles) - 1); private _bigSeats = getNumber (configFile >> "cfgVehicles" >> typeOf _bigTP >> "transportSoldier"); private ["_smallTP", "_smallSeats"]}, {_i < ((count _vehicles) - 1)}] do {
        _smallTP = _vehicles select _i;
        _smallSeats = getNumber (configFile >> "cfgVehicles" >> typeOf _bigTP >> "transportSoldier");
        if ((_bigSeats + _smallSeats) >= _needSeats) exitWith {
          _chosen pushBack _bigTP;
          _chosen pushBack _smallTP;
        };
      };
    };
  };

// return array of vehicles
  _chosen
};

//------------------------------------------------------------------------------
// TP decision making
//------------------------------------------------------------------------------

// First check for available TP vehicles
if ((count _availableTP) > 0) then {
  _chosen = [_availableTP] call _checkAvailableSeats;
};

// If available TP is not enough/ not avaialable
if (((count _busyTP) > 0) and ((count _chosen) <= 0)) then {
  _chosen = [_busyTP] call _checkAvailableSeats;
};
