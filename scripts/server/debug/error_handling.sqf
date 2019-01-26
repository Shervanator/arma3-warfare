// Contains various setting on handling errors

// General
#define ERROR_LOG_START(FUNC) diag_log format ["******************************** ERROR START FILE: %1 ********************************", FUNC]
#define ERROR_LOG_END(FUNC) diag_log format ["******************************** ERROR END FILE: %1 ********************************", FUNC]