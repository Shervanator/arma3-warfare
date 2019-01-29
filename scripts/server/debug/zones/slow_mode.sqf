/* This function will allow a time delay based on key presses by the server. Used in various debug scripts that display certain infromation (like markers)
and then change that information, and the person doing the debugging can decide how quickly or slowly this information is displayed by including this 
file into the relevant script, and making sure that DEBUG_SETUP_ZONES_SLOW_MODE is defined

Parameters:
	-NONE

Returns:
	-NONE

Author: kyfohatl
*/

#include "..\debug_settings.sqf"

// This variable will determine how long/short the delay is between debug ticks
kyf_WG_DEBUG_SETUP_smVal = DEBUG_SETUP_SM_DEFAULT_VAL;

#ifdef DEBUG_SETUP_ZONES_SLOW_MODE
  if !(isDedicated) then {
    hint format ["Zone Setup Debug: Slow mode enabled. Press DOWNARROW/UPARROW to increase/deacrese the speed of debug markers appearing on the map by %1 seconds", DEBUG_SETUP_SM_INCREMENT_AMOUNT];
    
    private _processKeyPress = {
      private _key = _this select 1;
      
      switch (_key) do {
        case UPARROWKEY_DIK: { 
          if (kyf_WG_DEBUG_SETUP_smVal >= DEBUG_SETUP_SM_SLOWEST) then {
          hint "Already at slowest setting";
          } else {
          kyf_WG_DEBUG_SETUP_smVal = kyf_WG_DEBUG_SETUP_smVal + DEBUG_SETUP_SM_INCREMENT_AMOUNT;
          hint format ["Delay increased to %1 seconds", kyf_WG_DEBUG_SETUP_smVal];
          };
        };
        
        case DOWNARROW_DIK: {
          if (kyf_WG_DEBUG_SETUP_smVal <= DEBUG_SETUP_SM_FASTEST) then {
          hint "Already at fastest setting";
          } else {
          kyf_WG_DEBUG_SETUP_smVal = kyf_WG_DEBUG_SETUP_smVal - DEBUG_SETUP_SM_INCREMENT_AMOUNT;
          hint format ["Delay reduced to %1 seconds", kyf_WG_DEBUG_SETUP_smVal];
          };
        };
      };
      
      // false must be returned so that the eventhandler does not override all keyboard buttons
      false
    };
    
    private _handleKeyDown = (findDisplay 12) displayAddEventHandler ["KeyDown", _processKeyPress];
  } else {
    diag_log "ERROR: slow mode enabled on dedicated server. This function was not written to run on a dedicated server. Please run on client server.";
  };
#endif