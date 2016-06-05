The actionMenu system provides a useable multi depth menu in the form of addActions. It has a simple structure of addAction parameters in the form of a multidimension array as seen below.

menu = [
	action,
	[
		//child menu
		action
	]
];

An action is the same as the full parameter list used in an Arma3 addAction command.
[title, script, arguments, priority, showWindow, hideOnUse, shortcut, condition]
See https://community.bistudio.com/wiki/addAction for further details.
An actions code MUST be in the form of code {} not string.

For instance..
menu = [
	[ "Menu 0", {}, [], -1, false, false, "", "" ],
	[
		[ "Option 0", {hint "This is option 0 of sub menu 0"}, [], -1, false, false, "", "" ],
		[ "Option 1", {hint "This is option 1 of sub menu 0"}, [], -1, false, false, "", "" ]
	],
	[ "Menu 1", {}, [], -1, false, false, "", "" ],
	[
		[ "Option 0", {hint "This is option 0 of sub menu 1"}, [], -1, false, false, "", "" ],
		[ "Option 1", {hint "This is option 1 of sub menu 1"}, [], -1, false, false, "", "" ],
		[ "Menu 1-0", {}, [], -1, false, false, "", "" ],
		[
			[ "Option 0", {hint "This is option 0 of sub menu 1-0"}, [], -1, false, false, "", "" ],
			[ "Option 1", {hint "This is option 1 of sub menu 1-0"}, [], -1, false, false, "", "" ]
		]
	]
];
[ menu, player, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;


[ _menu, _vehicle, _shared, _menuDistance, _controls( HIDE, HOME, BACK, REMOVE ) ] call LARs_fnc_menuStart;

_menu - An array of actions to show, child menu actions follow their parent contained in an array - also supports as STRING the name of a global variable containing a menu structure so a _shared menu does not have to be passed over the network
_vehicle( optional ) - Object to apply menu to, defaults to player if not provided.
_shared( optional ) - Clients to also show menu for - follows BIS_fnc_MP convention ( bool, obj, side, client etc ) - ( default false ) if TRUE will pass to all clients, false does NOT pass to server but is used internally to not share, as automaticall added for JIP.
_menuDistance( optional ) - Default distance actions will be visible from, applied to ALL actions, overrides default 15m for non player actions ( default 5m )
_controls( optional ) - An array of booleans on whether to show the default menu navigation options ( default [ true, true, true, false ] )
	The options being
	HIDE - Closes the actionMenu.
	HOME - Returns menu to root. Only appears when you are deeper than one sub menu.
	BACK - Returns you to the previous menu.
	REMOVE - Closes the actionMenu and removes the menu from the vehicle, as such it is turned off by default.

To use simple copy the LARs folder from this test mission into yours and copy the CfgFunctions from the description.ext into yours.
If you already have a CfgFunctions just add my #include 'LARs\actionMenu.cpp'.

Other functions available are..

LARs_fnc_menuAddItem
[ _vehicle, _item, _depth, _pos, _isGlobal ] call LARs_fnc_addMenuItem;

_vehicle - Is the object holding the menu you want to change.
_item - Is a menu structure, can be one action or action plus submenu or a combination of multiples of these, also supports as STRING the name of a global variable containing a menu structure so a _shared item does not have to be passed over the network
_depth( optional )  - Is an array of the path to current sub menu the item/s are to be added to, if not provided then the root menu is used. e.g [] would be the root menu, [ 1, 0 ] would be the first submenu (0) of the second submenu (1) of the root menu. Think of it like a breadcrumb.
_pos( optional ) - position in menu item will be inserted into, if not provided item will be added to the end of menu
_isGlobal - Same as BIS_fnc_MP options, menu will be passed and inserted into the menus of the provided targets

Taking the menu example from above to add a new option into menu 1-0 inbetween option 0 and option 1 we would..
newMenu = [
	[ "Inseted Option", {hint "This option was inserted into Menu 1-0"}, [], -1, false, false, "", "" ]
];
[ player, newMenu, [ 1, 0 ], 1 ] call LARs_fnc_menuAddItem;


LARs_fnc_menuRemoveItem
[ _vehicle, _depth, _pos, _isGlobal ] call LARs_fnc_addMenuItem;

_vehicle - Is the object holding the menu you want to change.
_depth( optional ) - Is an array of the path to current sub menu the item/s are to be removed from, If not provided then root menu is used. e.g [] would be the root menu, [ 1, 0 ] would be the first submenu (0) of the second submenu (1) of the root menu. Think of it like a breadcrumb.
_pos( optional )  - position of item in menu to be removed, If the item has a child menu this will also be removed. If not provided then last menu item is removed.
_isGlobal - Same as BIS_fnc_MP options, menu will be passed and removed from the menus of the provided targets

Continuing with the menu example to remove the option we just inserted into menu 1-0 we would..
[ player, [ 1, 0 ], 1 ] call LARs_fnc_menuRemoveItem;


Other things to note..
Menus can be multidepth and there is no limit.
Each action should have a priority of -1 to make sure they ordered properly.
Instead of a bolean for hideOnUse you can also set it to -1, 0 or 1
	false - leaves action menu open
	true - closes action Menu
	-1 - closes action menu and exits menu system
	0 - leaves action menu open and resets menu system
	1 - closes action menu and resets menu system
Otherwise everything else works as per an addAction

The color of the default actionMenu controls can be changed by using LARs_actionMenuColor = "#FFC403"; in your description.ext and replacing the hex number with your own.
http://www.colorpicker.com/ is an easy place to find your color numbers.

Some variables are available for mission designers to query that maybe of some help.
"LARs_remoteMenu" - Only available on a player that has their own active actionMenu but is currently viewing a menu from another object - returns the object else nil
"LARs_menuDepth" - current menu path being displayed
"LARs_menuSystemActive" - true if object has an active actionMenu else nil
"LARs_activeMenu" - The current active menu structure

This info can also be found in LARs\actionMenu\info.txt
Downloaded from : https://dl.orangedox.com/AUqbKfUPwa2zDiBVwu/actionMenu2.VR.zip