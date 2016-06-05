
private [ "_vehicle", "_child", "_depth" ];

_vehicle = _this select 0;
_child = _this select 1;

//Add passed child index to depth array
_depth = _vehicle getVariable [ "LARs_menuDepth", [] ];
_depth pushBack _child;
_vehicle setVariable [ "LARs_menuDepth", _depth ];

_vehicle call LARs_fnc_menuShow;
