
private [ "_vehicle" ];

_vehicle = _this;

//Clear depth array
_vehicle setVariable [ "LARs_menuDepth", [] ];

_vehicle call LARs_fnc_menuShow;
