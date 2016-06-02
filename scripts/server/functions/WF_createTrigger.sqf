params ["_position", "_size"];

_trg = createTrigger ["EmptyDetector", _position];
_trg setTriggerArea [_size, _size, 0, false];
_trg setTriggerActivation ["ANY", "PRESENT", false];
_trg setTriggerStatements ["this", "", ""];
_trg
