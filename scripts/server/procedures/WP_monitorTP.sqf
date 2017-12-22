private [];
params ["_vehiclesOrig", "_grp", "_sideStr"];

// to do:
// what heppens if vehilce is destroyed?
// what happens if unit does not get in?
// what happens if unit is in combat?
// what happens if unit for some reason is assigned to some other vehicle?
// what happens when glitch handler deltes a unit?  ---> dont think this matters
// The monitorPos func should run BEFORE this script so thast any pos request are updated before this script runs

_objective = _grp getVariable "currentObjective";
_objectivePos = getPos _objectivePos;
_vehicles = +_vehiclesOrig;
//------------------------------------------------------------------------------
// function to check if tp vehicle has reached max capacity (used later)
_isAtMaxCap = {
  private ["_vehicle", "_return"];
  params ["_vehicle"];

  _return = false;
  if (({alive _x} count (crew _vehicle)) >= ((_vehicle getVariable "countOrigCrew") + (_vehicle getVariable "transportSoldier"))) then {
    _return = true;
  };

  _return
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// function to make sure that a vehicle is carrying our intended units
_hasRelevantUnits = {
  private ["_vehicle", "_return"];
  params ["_vehicle"];

  _return = false;
  {
    if (_x in (units _grp)) exitWith {
      _return = true;
    };
  } forEach (crew _vehicle);

  _return
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// function to remove a vehicle from further consideration as a tp vehicle by this instance of the script
_removeVehicleFromScript = {
  private ["_vehicle"];
  params ["_vehicle"];

  _vehicle setVariable ["_tpState", nil];
  _vehicle setVariable ["pickUpList", nil];
  (missionNamespace getVariable (_sideStr + "transportVehicles")) pushBack _vehicle;
  _vehiclesOrig deleteAt (_vehiclesOrig find _vehicle);
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// function that sets the vehicle to the transporting state
_setToTransportingState = {
  private ["_vehicle"];
  params ["_vehicle"];

  _vehicle setVariable ["tpState", ["transporting", ***]];
  _transportingTP pushBack _vehicle; // *"_transportingTP" can be defined further down and it still does not matter, the func should work just fine
  // *** HERE U GIVE THE VEHICLE A WAYPOINT AT THE NEAREST ROAD!!!    <------- RESUME HERE!
  // *** THE WAYPOINT NEEDS TO BE ABOUT 1.1 KM AWAY FROM THE ACTUAL OBJECTIVE!
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Check which units actually needs tp
_units = [];
{
  private ["_tpVehicle", "_tpLoopCount"];
  private _includeUnit = true;

  if ((vehicle _x) == _x) then { // unit is not in a v
    if (((getPos _x) distanceSqr _objectivePos) > 2250000) then { // unit is not too close to objtv
      _tpVehicle = _x getVariable "tpVehicle";

      if (isNil "_tpVehicle") then { // exclude all units already assigned to another tp vehicle or rejected units
        // these units are now far enough, not in a vehicle, not already assigned to another vehicle and not rejected
        _units pushBack _x;
      };
    };
  };
} forEach (units _grp);
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// categorize vehicles based on which phase they are in
_freeTP = [];
_pickUpTP = [];
_getInTP = [];
_transportingTP = [];

for [{private _i = 0; private ["_v", "_tpState"]}, {_i < (count _vehicles)}, {_i = _i + 1}] do {
  _v = _vehicles select _i;
  _tpState = _v getVariable "tpState";
  if (isNil "_tpState") then {
    _v setVariable ["_tpState", ["free", ***]];
    _tpState = ["free", ***];
  };

  switch (_tpState select 0) do {
    case "free": {_freeTP pushBack _v};
    case "pickUp": {_pickUpTP pushBack _v};
    case "getIn": {_getInTP pushBack _v};
    case "transporting": {_transportingTP pushBack _v};
  };
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// free tp
if !(_freeTP isEqualTo []) then {

  {
    if ([_x] call _isAtMaxCap) then {
      if ([_x] call _hasRelevantUnits) then {
        [_x] call _setToTransportingState;
      } else {
        [_x] call _removeVehicleFromScript;
      };
    } else {
      if (_units isEqualTo []) then { // i.e. 1. no units need tp OR 2. units that need tp are in vehicles already
        if ([_x] call _hasRelevantUnits) then {
          [_x] call _setToTransportingState;
        } else {
          [_x] call _removeVehicleFromScript;
        };
      } else {
        // Prepare to go pickup the closest unit and those around it
        private ["_vehiclePos", "_minDist", "_minUnit", "_minIndex", "_destination"];

        while {(count _units) > 0} do { // A while loop instead of a for do one because we are not deleting units in order and thus an _i = _i - 1 would confuse the order
          _vehiclePos = getPos _x;
          _minDist = -1;
          _minUnit = objNull;
          _minIndex = -1;
          for [{private _i = 0; private ["_u", "_distance"]}, {_i < (count _units)}, {_i = _i + 1}] do {
            _u = _units select _i;
            _distance = (getPos _u) distanceSqr _vehiclePos;
            if ((_distance < _minDist) or (_minDist == -1)) then {
              _minDist = _distance;
              _minUnit = _u;
              _minIndex = _i;
            };
          };

          _destination = [getPos _minUnit, 300] call WF_getNearRoadOrSafePos; // ** May need to balance the 300m rad later
          _units deleteAt _minIndex;
          if !(_destination isEqualTo false) exitWith {
            // *** set wp for vehicle at destination pos
            _x setVariable ["tpState", ["pickUp", ***]];
            _x setVariable ["pickUpList", [[_minUnit, 0]]];
            _minUnit setVariable ["tpVehicle", _x]; // So this unit won't be considered as needing tp next loop
            // no need to pushBack into _pickUpTP as the vehicle will probably take some time to get there
          };

          // At this point the closest unit is neither near a road or a safe pos, so we will not give him tp. Instead we will try the next closest unit
          // The unit will now be partially rejected, meaning it will not be considered for tp for a number of loops to save on calc
          _minUnit setVariable ["tpVehicle", ["partialRejection", 0]];
        };
      };
    };
  } forEach _freeTP;
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// pickup tp
if !(_pickUpTP isEqualTo []) then {
  for [{private _i = 0; private ["_v", "_vehiclePos", "_destination", "_getIn", "_pickUpList"]}, {_i < (count _pickUpTP)}, {_i = _i + 1}] do {
    _v = _pickUpTP select _i;
    _vehiclePos = getPos _v;
    _destination = (_v getVariable "tpState") select 1; // *** Couldn't/shouldn't we use the waypoint pos here?

    // Has vehicle reached its pickup destination
    if ((_vehiclePos distanceSqr _destination) < 1600) then {
      _getIn = [];
      _pickUpList = _v getVariable "pickUpList";

      // remove association with this vehicle in case the units do not get in then add them to the list of units needing tp
      {
        private ["_unit"];

        _unit = _x select 0;
        if (alive _unit) then {
          _unit setVariable ["tpVehicle", nil];
          _units pushBack _unit;
        };
      } forEach _pickUpList;

      _v setVariable ["pickUpList", []];

      // Order any units close enough to get in
      for [{private _i = 0; private ["_u"]}, {_i < (count _units)}, {_i = _i + 1}] do { // *** come back to this
        if ([_v] call _isAtMaxCap) exitWith {}; // Make sure you do not exceed the max capacity of the vehicle
        _u = _units select _i;
        if ((_vehiclePos distanceSqr (getPos _u)) <= 90000) then {
          _pickUpList pushBack [_u, 0];
          _u setVariable ["tpVehicle", _v];

          if ((behaviour _u) != "COMBAT") then {
            _u assignAsCargo _v;
            _getIn pushBack _u;
          };

          _units deleteAt _i;
          _i = _i - 1;
        };
      };

      if !(_getIn isEqualTo []) then {
        _getIn orderGetIn true;
      };

      // If there were no units to pickup then set tp state to "free", else set it the the "getIn" phase
      if (_pickUpList isEqualTo []) then { // in case no one is at the destination when the vehicle arrives (killed or moved on)
        _v setVariable ["tpState", ["free", ***]];
        _v setVariable ["pickUpList", nil];
      } else {
        _v setVariable ["tpState", ["getIn", ***]];
        _getInTP pushBack _v;
      };
    };
  };
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// getIn tp
if !(_getInTP isEqualTo []) then {
  {
    private ["_v", "_pickUpList"];

    _v = _x;
    _pickUpList = _x getVariable "pickUpList";
    for [{private _i = 0; private ["_element", "_unit", "_removeFromList", "_loopCount"]}, {_i < (count _pickUpList)}, {_i = _i + 1}] do {
      _element = _pickUpList select _i;
      _unit = _element select 0;
      _removeFromList = false;
      _rejected = false;
      // If unit is not alive, remove from list
      if !(alive _unit) then {
        _removeFromList = true;
      } else {
        // Check to see if unit has gotten into the vehicle yet
        if !((vehicle _unit) == _unit) then {
          _removeFromList = true;
        } else {
          // If it hasn't, then has the unit taken too long to get in?
          _loopCount = _element select 1;
          if (_loopCount > 100) then {
            _removeFromList = true;
            _rejected = true;
          } else {
            // If it hasn't then has it been assgined to the vehicle and told to get in yet?
            if ((assignedVehicle _unit) isEqualTo _v) then {
              // If it has then give it another order at the loop counts below if not in combat
              if ((_loopCount == 40) or (_loopCount == 80)) then {
                if ((behaviour _unit) != "COMBAT") then {
                  [_unit] orderGetIn true;
                };
              };
            } else {
              // If it hasn't then assign and order it to get in if not in combat
              if ((behaviour _unit) != "COMBAT") then {
                _unit assignAsCargo _v;
                [_unit] orderGetIn true;
              };
            };

            // If unit hasn't gotten in and hasn't taken too long up the loop count by 1 (regardless of combat mode or not)
            _element set [1, (_element select 1) + 1];
          };
        };
      };

      if (_removeFromList) then {
        if (_rejected) then {
          _unit setVariable ["tpVehicle", "rejected"]; // Unit is rejected and will not be considred for tp for the remainder of THIS INSTANCE of tp for this group
          // *** Remember to implement later on: As this instance of script ends, all "tpVehicle" (esp rejections) states on units and other vars on vehicles involved (e.g "pickUpList") must be set to nil
        } else {
            _unit setVariable ["tpVehicle", nil]; // Now if a unit that has already gotten in gets out of the vehicle for whatever reason before reaching objectvie, it can be reconsidered for tp if it still needs it.
            // This is because if a unit gets in, then _removeFromList is set to true. Thus unit is not considered attached to a vehicle and if disembarks will be reconsidered for TP is scripts has not tyer finished.
        };

        _pickUpList deleteAt _i;
        _i = _i - 1;
      };
    };

    if (_pickUpList isEqualTo []) then { // i.e. no more units waiting to get in
      _v setVariable ["pickUpList", nil];

      if ([_v] call _isAtMaxCap) then {
        [_v] call _setToTransportingState;
      } else {
        _v setVariable ["tpState", ["free", ***]];
      };
    };
  } forEach _getInTP;
};
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Transporting tp
if !(_transportingTP isEqualTo []) then {
  {
    private ["_vehicle", "_tpState"];

    _vehicle = _x;
    _tpState = _vehicle getVariable "tpState";
    // Check if the objective is still the same
    if ((_tpState select 2) isEqualTo _objective) then {
      // Objective has not changed so see if you are close enough to destination
      if (((getPos _vehicle) distanceSqr (_tpState select 1)) < 1600) then {
        // Disembark units
        {
          if ((vehicle _x) == _vehicle) then {
            unassignVehicle _x;
          };
        } forEach (units _grp);

        _vehicle setVariable ["tpState", ["free", ***]];
      };
    } else {
      // Objective has changed
      if ([_vehicle] call _isAtMaxCap) then { // If vehicle is full just change destination and give new waypoint at nearest rd if possible
        _tpState set [1, /* *** NEAREST RD TO OBJCTV*/];
        _tpState set [2, _objective];
        // *** Give new wp to vehicle
      } else {
        // Vehicle is not at max cap so set to free state to see if any other units need picking up now that the objective has changed
        _vehicle setVariable ["tpState", ["free", ***]];
      };
    };
  } forEach _transportingTP;
};
//------------------------------------------------------------------------------
