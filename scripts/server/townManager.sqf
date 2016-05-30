params ["_town"];

_trg = createTrigger ["EmptyDetector", (getPos _town)];
_trg setTriggerArea [50, 50, 0, false];
_trg setTriggerActivation ["ANY", "PRESENT", false];
_trg setTriggerStatements ["this", "", ""];

sleep 2; // TODO: come back to this
[(list _trg), _town] execFSM "scripts\server\fsm\townController.fsm";
