private ["_side", "_needSeats"];
params ["_side", "_needSeats"];

_sideStr = str _side;
// both tpq and alltp are dynamic constantly changing arrays, hence a copy must be used to avoid the array changing mid-code
_TPQ = +(missionNamespace getVariable (_sideStr + "TPQue"));
_allTP = +(missionNamespace getVariable (_sideStr + "transportVehicles"));
_chosen = []; // This will contain the transport vehicle/s that will tp the grp

//------------------------------------------------------------------------------
// seperate available tp into one array
_availableTP = [];
{
  private ["_busy"];
  _busy = _x getVariable "isOnMission";
  if (isNil "_busy") then {
    _availableTP pushBack _x;
  } else {
    if !(_busy) then {
      _availableTP pushBack _x;
    };
  };
} forEach _allTP;

if ((count _availableTP) > 0) then {
  //----------------------------------------------------------------------------
  // Order the tp array from lowest seat count to highest (used later)
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

  // ***_needSeats = take grp and call a func which determines which sqd memebers need tp (distance to obj and distance from leader)***
  // IT IS BETTER IF THIS IS DONE IN COMMANDER DETERMINE ORDERS, JUST WHEN THE OBJECTIVE IS DECIDED SO THAT WE CAN ALSO DETERMINE IF TP IS NEEDED FOR THAT GRP OR NOT

  //----------------------------------------------------------------------------
  // Determine TP vehicle/s
  // Take the tp vehicle array and see which one (or ones) has enough seats for all units. If no one vehicle has enough seats, it tries to use multiple
  // Because vehicles have been ordered from smallest to largest, the code will select the smallest vehicle necessary that can carry all the units
  for [{private _i = 0; private _success = false; private ["_totalSeats"]}, {_i < (count _availableTP)}, {_i = _i + 1}] do {
    _totalSeats = 0;
    for [{private _a = _i; private ["_element"]}, {_a > 0}, {_a = _a - 1}] do { // Every time _i goes up, one more vehicle is added to the total tp necessary. This is for large grps in need of multiple tp vehicles.
      _element = _availableTP select ((count _availableTP) - _a);
      _totalSeats = _totalSeats + getNumber (configFile >> "cfgVehicles" >> typeOf _element >> "transportSoldier");
      _chosen pushBack _element;
    };

    for [{private _a = 0}, {_a < ((count _availableTP) - _i)}, {_a = _a + 1}] do {
      if (((getNumber (configFile >> "cfgVehicles" >> typeOf _x >> "transportSoldier")) + _totalSeats) >= _needSeats) exitWith {
        _chosen pushBack _x;
        _success = true;
      };
    };

    if (_success) exitWith {};
    _chosen = [];
  };
};

// ***NOTE FOR PURCHASE TP AI: IF _chosen IS EMPTY AND _availableTP == _allTP, THEN THESE FACTORS SHOULD SIGNIFICANTLY INCREASE THE CHANCE OF AI PURCHASING MORE TP, ALONGSIDE WITH HOW LARGE THE TP QUE IS.
