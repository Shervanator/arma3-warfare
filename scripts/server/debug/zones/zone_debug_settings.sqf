/* Debug settings related to zones */

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
  #define DEBUG_SETUP_SM_INCREMENT_AMOUNT 0.5

  #define UPARROWKEY_DIK 200
  #define DOWNARROW_DIK 208
#endif

// Creating paths between zones divisions and saving them to a database
#define DEBUG_SETUP_PREDEF_PATHS 1

// Enabling will reuslt in zone paths to be displayed one by one using markers. Works alongside slow mode. Used in test_zone_paths.sqf
#define DEBUG_ZONE_PATHS 1