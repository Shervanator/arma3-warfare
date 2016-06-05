#define ACTIONMENUCOLOR  [ "#FFC403", getText( missionConfigFile >> "LARs_actionMenuColor" ) ] select isText( missionConfigFile >> "LARs_actionMenuColor" )

private [ "_defaultActions", "_error" ];

//*****************************
//* Process default variables *
//*****************************

_error = false;

//Check menu
if !( ( _this select [ 0, 1 ] ) params [
	[ "_menu", [], [ [], "" ] ]
]) then {
	if ( _menu isEqualTo [] || ( typeName _menu isEqualTo typeName "" && { isNil{ missionNamespace getVariable [ _menu, nil ] } } ) ) then {
		"Supplied menu is invalid" call BIS_fnc_error;
		_error = true;
	};
};

//Check vehicle
if !( ( _this select [ 1, 1 ] ) params [
		[ "_vehicle", player, [ objNull ] ]
	]
) then {
	if ( isNull _vehicle ) then {
		"Supplied object is invalid" call BIS_fnc_error;
		_error = true;
	};
};

if ( _vehicle getVariable [ "LARs_menuSystemActive", false ] ) then {
//		format [ "Supplied object ( %1 ) already has an active menu system", _vehicle ] call BIS_fnc_error;
//		_error = true;
	_vehicle call LARs_fnc_menuExit;
};


//Exit if there was an error with _vehicle or _menu
if ( _error ) exitWith { false };

//Check optional variables
( _this select [ 2, 3 ] )  params [
	[ "_shared", false, [ objNull, sideUnknown, grpNull, [], true, 0 ] ],		//clients to apply menu to
	[ "_menuDistance", 5, [ 0 ] ],												//Distance to show menu at
	[ "_controls", [ true, true, true, false ], [ [] ], [ 4 ] ]					//Navigation actions to show
];

//Start menu on shared clients
if ( { typeName _shared isEqualTo typeName _x }count [ objNull, sideUnknown, grpNull, [], 0 ] > 0 || ( typeName _shared isEqualTo typeName true && { _shared } ) ) then {
	[ [ _menu, _vehicle, false, _menuDistance, _controls ], "LARs_fnc_menuStart", _shared, true, false ] call BIS_fnc_MP;
};

//Exit if we dont have  UI
if ( !hasInterface ) exitWith {
	false
};

//*********
//* START *
//*********


//Apply default actions for meu navigation
_defaultActions = [];
{
	if ( _controls select _forEachIndex ) then {
		_defaultActions pushBack [ _x, ( _vehicle addAction _x ) ];
	};
}forEach [
	//MENU HIDE - does nothing but hide actionMenu via true in the hide on use param
	[format[ "<t color='%1'>[] MENU HIDE</t>", ACTIONMENUCOLOR ], {}, "", -1, false, true, "", format [ "_this distance _target < %1", _menuDistance ] ],  //Always show if menu system is active
	//MENU HOME - Only show if we are deeper than 1 level
	[ "<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_sidebar_hide_up.paa' size='0.7' /> MENU HOME</t>", { ( _this select 0 ) call LARs_fnc_menuReset }, "", -1, false, false, "", format [ "count ( _target getvariable [ 'LARs_menuDepth', [] ] ) > 1 && _this distance _target < %1", _menuDistance ] ],
	//MENU BACK - Only show if we are deeper than base menu
	[ "<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_sidebar_show.paa' size='0.7' /> MENU BACK</t>", { ( _this select 0 ) call LARs_fnc_menuDOWN }, "", -20, false, false, "", format [ "count ( _target getvariable [ 'LARs_menuDepth', [] ] ) > 0 && _this distance _target < %1", _menuDistance ] ],
	//MENU EXIT - Remove menu and clear variables
	["<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_exit_cross_ca.paa' size='0.7' /> REMOVE MENU</t>", { ( _this select 0 ) call LARs_fnc_menuExit }, "", -20, false, false, "", format [ "_this distance _target < %1", _menuDistance ] ]
];

//Save menu variables on object
_vehicle setVariable [ "LARs_defaultActions", _defaultActions ];
_vehicle setVariable [ "LARs_currentActions", [] ];
_vehicle setVariable [ "LARs_menuDepth", [] ];
_vehicle setVariable [ "LARs_menuSystemActive", true ];
_vehicle setVariable [ "LARs_activeMenu", _menu ];
_vehicle setVariable [ "LARs_MenuDistance", _menuDistance ];

//If the vehicle is a player add an event to hide the players menu in the event he is also looking at another object with a menu system
if ( !( isNull player ) && { _vehicle isEqualTo player } ) then {
	_actionMenuEH = [] spawn {
		while { true } do {
			sleep 0.5;
			if ( !isNull cursorTarget ) then {
				if ( cursorTarget getVariable [ "LARs_menuSystemActive", false ] && { player distance cursorTarget <= ( cursorTarget getVariable [ "LARs_MenuDistance", 15 ] ) } ) then {
					_target = cursorTarget;
					player setVariable [ "LARs_remoteMenu", cursorTarget ];
					player call LARs_fnc_menuClear;
					{
						player removeAction ( _x select 1 );
					}forEach ( player getVariable [ "LARs_defaultActions", [] ] );
					waitUntil { sleep 0.2; !( cursorTarget isEqualTo _target ) || { player distance cursorTarget >= ( cursorTarget getVariable [ "LARs_MenuDistance", 15 ] ) } };
					player setVariable [ "LARs_remoteMenu", nil ];
					_defaultActions = [];
					{
						_defaultActions pushBack [ _x select 0, player addAction ( _x select 0 ) ];
					}forEach ( player getVariable [ "LARs_defaultActions", [] ] );
					player setVariable [ "LARs_defaultActions", _defaultActions ];
					player call LARs_fnc_menuShow;
				};
			};
		};
	};
};

_vehicle call LARs_fnc_menuShow;

//Return success menu start
true
