/* "Ensures" that the get_division_debug functions running in parallel do not get mixed up. In reality this is very bad "parallel programming", and odd timings 
could easily cause multiple scripts accessing the data at the same time. However since this is a minor debug function with a very small use case, it should 
get the job done while being quick to write compared to a proper parallel programming approach.

NOTE: This procedure must be run by execVM and NOT call, since it gets suspended.

Parameters:
  - None directly. Parameters used to execute get_division_debug are stored in a golbal variable called "kyf_DG_aiPathing_VisPathManager_params" 

Returns:
  - NONE 
  
Author: kyfohatl */

// Wait till a parameter is given
waitUntil {(count (kyf_DG_aiPathing_VisPathManager_params)) > 0};

private _i = 0;
private _keepLooping = true;

while {_keepLooping} do {
  private _handle = (kyf_DG_aiPathing_VisPathManager_params select _i) execVM "scripts\server\debug\ai_pathing\get_division_debug.sqf";

  // Wait unitil the procedure has finished executing before moving on to the next
  // For some reason waitUntil is giving wierd errors where the handle becomes nil, and so a while loop is used instead
  while {true} do {
    if (isNil "_handle") exitWith {};
    if (isNull _handle) exitWith {};

    sleep 1;
  };
 
  _i = _i + 1;

  // Decide if the debug manager can stop running or not
  if (_i == (count kyf_DG_aiPathing_VisPathManager_params)) then {
    // We have reached the last element in the parameter array
    // Since parameters are handed in pairs, the manager should only stop if there are an even number of parameters in the paramter array
    if (((count kyf_DG_aiPathing_VisPathManager_params) % 2) == 0) then {
      // Even number of parameters. We can exit
      _keepLooping = false;
    } else {
      // There is an odd number of parameters and we must wait for at least one more before we are finished
      waitUntil {_i < (count kyf_DG_aiPathing_VisPathManager_params)};
    };
  };
};