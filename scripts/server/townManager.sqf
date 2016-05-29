params ["_town"];

sleep 1;
_trg = createTrigger ["EmptyDetector", (getMarkerPos _town)];
_trg setTriggerArea [50, 50, 0, false];
_trg setTriggerActivation ["ANY", "PRESENT", false];
_trg setTriggerStatements ["this", "", ""];
sleep 2;
[(list _trg), _town] execFSM "scripts\server\fsm\townController.fsm";
//"aa" remoteExec ["hint", 0];
//_trg setTriggerStatements ["this", "[thisList, _town] execFSM 'scripts\server\fsm\townController.fsm'", ""];
