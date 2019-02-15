/* Contains debug settings for testing AI pathing. Comment out the master setting to disable completely, or comment out individual 
settings to disable debug for individual files */

// "Master" setting. Commenting this setting out will stop all AI pathing debug
#define DEBUG_TEST_AI_PATHING 1

#ifdef DEBUG_TEST_AI_PATHING
  // Enables debug for getPath function
  #define DEBUG_AI_PATHING_GETPATH 1

  // Enables debug for getZoneDiv function
  #define DEBUG_LOG_AI_PATHING_GET_ZONE_DIV 1

  // Enables visualization of getZoneDiv function on the map and via hints
  #define DEBUG_VISUAL_AI_PATHING_GET_ZONE_DIV 1
#endif