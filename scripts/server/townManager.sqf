params ["_town"];

_trg = createTrigger ["EmptyDetector", (getMarkerPos _town)];
_trg setTriggerArea [50, 50, 0, false];
_trg setTriggerActivation ["ANY", "PRESENT", true];
//_trg setTriggerStatements ["this", "_n = str (random 100); _n remoteExec ['hint', 0, true]", "_n = str (random 100); _n remoteExec ['hint', 0, true]"];
_trg setTriggerStatements ["this", "[thisList] execVM 'scripts\server\townMonitor.sqf'", ""];
