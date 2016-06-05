
private [ "_vehicle" ];

_vehicle = _this;

_vehicle call LARs_fnc_menuClear;

//Clear _vehicle of menu variables
_vehicle setVariable [ "LARs_menuDepth", nil ];
_vehicle setVariable [ "LARs_currentActions", nil ];
_vehicle setVariable [ "LARs_activeMenu", nil ];
{
	_vehicle removeAction ( _x select 1 );
}forEach ( _vehicle getVariable [ "LARs_defaultActions", [] ] );
_vehicle setVariable [ "LARs_defaultActions", nil ];
_vehicle setVariable [ "LARs_menuSystemActive", nil ];
_vehicle setVariable [ "LARs_MenuDistance", nil ];
