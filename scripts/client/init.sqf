/*matt addAction ["Build Rifleman", { (_this select 1) remoteExec ["WF_buildUnit", 2] } ];*/
_side = "West";
_faction = faction player;

switch (side player) do {
	case west: {_side = "1"};
	case east: {_side = "0"};
	case resistance: {_side = "3"};
};
_units = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Men' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");

_unitMenu = [];
{
	_unitMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildUnit", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _units;

_cars = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Car' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_carMenu = [];
{
	_carMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _cars;

_armor = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Armored' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_armorMenu = [];
{
	_armorMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _armor;

_air = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Air' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_airMenu = [];
{
	_airMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _air;

_support = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Support' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_supportMenu = [];
{
	_supportMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _support;

_autonomous = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Autonomous' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_autonomousMenu = [];
{
	_autonomousMenu pushBack [ getText (_x >> 'displayName'), {[(_this select 1), group ((_this select 3) select 0)] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _autonomous;

menu = [
	[ "Build Units", {}, [], -1, false, false, "", "" ],
	[
		[ "Infantry", {}, [], -1, false, false, "", "" ],
		_unitMenu
	],

	[ "Build Vehicles", {}, [], -1, false, false, "", "" ],
	[
		[ "Cars", {}, [], -1, false, false, "", "" ],
		_carMenu,
		[ "Armored", {}, [], -1, false, false, "", "" ],
		_armorMenu,
		[ "Air", {}, [], -1, false, false, "", "" ],
		_airMenu,
		[ "Autonomous", {}, [], -1, false, false, "", "" ],
		_autonomousMenu,
		[ "Support", {}, [], -1, false, false, "", "" ],
		_supportMenu
	]
];
[ menu, matt, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;
