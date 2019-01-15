// Controls main debug settings

// General debug
#define LIGHT_DEBUG 1
#define NORMAL_DEBUG 1
#define MAJOR_DEBUG 1
#define EXTREME_DEBUG 1

#define DEBUG_LOG_START(FUNC) diag_log format ["----------------------------- DEBUG START: %1 -----------------------------", FUNC]
#define FILE_INTRO "File:"
#define DEBUG_LOG_END(FUNC) diag_log format ["----------------------------- DEBUG END: %1 -----------------------------\n", FUNC]

//------------------------------------------------------------------------------
// Zone setup debug

// General setup
#define SETUP_ZONE_DEBUG_NORMAL 1
#define SETUP_ZONE_DEBUG_MAJOR 1
#define SETUP_ZONE_DEBUG_EXTREME 1

/* Pathfinding slow mode: Setting to 1 will enable slow mode for pathfinding algorithm. Slow mode will slow down and visualize on the 
map the best path determined. Note that command only works when running on a clinet server! */
#define DEBUG_SETUP_ZONES_SLOW_MODE 1

// In slow mode, the value of the setting equates to the number of seconds that the slow mode debug markers last on the map before deletion
#ifdef DEBUG_SETUP_ZONES_SLOW_MODE
  #define DEBUG_SETUP_SM_SLOWEST 10
  #define DEBUG_SETUP_SM_MEDIUM 5
  #define DEBUG_SETUP_SM_FASTEST 0
  #define DEBUG_SETUP_SM_DEFAULT_VAL DEBUG_SETUP_SM_SLOWEST
#endif