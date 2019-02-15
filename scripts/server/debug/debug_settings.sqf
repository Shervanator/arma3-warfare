/* The "all in one" debug file. Include all debug settings from various categories in this one file so that when it is in turn included in a file, 
all debug settings will be loaded onto that file */

// General debug
#define LIGHT_DEBUG 1
#define NORMAL_DEBUG 1
#define MAJOR_DEBUG 1
#define EXTREME_DEBUG 1

#define DEBUG_LOG_START(FUNC) diag_log format ["----------------------------- DEBUG START: %1 -----------------------------", FUNC]
#define FILE_INTRO "File:"
#define DEBUG_LOG_END(FUNC) diag_log format ["----------------------------- DEBUG END: %1 -----------------------------", FUNC]

//------------------------------------------------------------------------------
// Zone setup debug
#include "zones\zone_debug_settings.sqf"

// AI pathing settings
#include "ai_pathing\ai_pathing_settings.sqf"