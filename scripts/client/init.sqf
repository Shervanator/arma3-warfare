/*matt addAction ["Build Rifleman", { (_this select 1) remoteExec ["WF_buildUnit", 2] } ];*/
_side = "West";
_faction = faction player;

switch (side player) do {
	case west: {_side = "1"};
	case east: {_side = "0"};
	case resistance: {_side = "3"};
};


//---------------------------BUYING UNITS------------------------------
//---------------------------------------------------------------------
/*_units = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Men' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");*/
/*WF_units (side => [[config, price]])*/
_units = (side player) call WF_units;
_unitMenu = [];
{
	_configEntry = _x select 0;

	_unitMenu pushBack [ getText (_configEntry >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildUnit", 2]}, [configName _configEntry], -1, false, false, "", "" ];
} forEach _units;

_cars =  (side player) call WF_vehicleCars;
_carMenu = [];
{
	_configEntry = _x select 0;

	_carMenu pushBack [ getText (_configEntry >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}, [configName _configEntry], -1, false, false, "", "" ];
} forEach _cars;

_armored =  (side player) call WF_vehicleArmored;
_armoredMenu = [];
{
	_configEntry = _x select 0;

	_armoredMenu pushBack [ getText (_configEntry >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}, [configName _configEntry], -1, false, false, "", "" ];
} forEach _armored;

_air = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Air' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_airMenu = [];
{
	_airMenu pushBack [ getText (_x >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _air;

_support = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Support' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_supportMenu = [];
{
	_supportMenu pushBack [ getText (_x >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _support;

_autonomous = ("getNumber (_x >> 'side') == " + _side + " && getText (_x >> 'vehicleClass') == 'Autonomous' && getText (_x >> 'faction') == '" + _faction + "'") configClasses (configFile >> "CfgVehicles");
_autonomousMenu = [];
{
	_autonomousMenu pushBack [ getText (_x >> 'displayName'), {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}, [configName _x], -1, false, false, "", "" ];
} forEach _autonomous;

_weapons = "true" configClasses (configFile >> "CfgWeapons");
_weaponMenu = [];
{
	_weaponMenu pushBack [ configName _x, {[_this select 1, (_this select 3) select 0] remoteExec ["WF_buyWeapon", 2]}, [configName _x], -1, false, false, "", ""];
} forEach _weapons;



menu = [
	[ "Build Units", {}, [], -1, false, false, "", "" ],
	_unitMenu,

	[ "Build Vehicles", {}, [], -1, false, false, "", "" ],
	[
		[ "Cars", {}, [], -1, false, false, "", "" ],
		_carMenu,
		[ "Armored", {}, [], -1, false, false, "", "" ],
		_armoredMenu,
		[ "Air", {}, [], -1, false, false, "", "" ],
		_airMenu,
		[ "Autonomous", {}, [], -1, false, false, "", "" ],
		_autonomousMenu,
		[ "Support", {}, [], -1, false, false, "", "" ],
		_supportMenu
	],

	[ "Build Weapons", {}, [], -1, false, false, "", "" ],
	_weaponMenu
];
[ menu, matt, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;

//---------------------------BUYING WEAPONS------------------------------
//-----------------------------------------------------------------------
