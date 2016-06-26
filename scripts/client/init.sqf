_side = side player;
_faction = faction player;

titleMenu = [[ "Purchase", {}, [], -1, false, false, "", "" ]];
_subMenu = [];
{
	_buildFunction = _x select 2;
	_allAvailableUnitTypes = missionNamespace getVariable ("WF_arrayTypes_" + (str _side) + (_x select 0));
	_unitMenu = [];

	{
		_configEntry = _x select 0;
		_unitMenu pushback [getText (_configEntry >> "displayName"), _buildFunction, [configName _configEntry], -1, false, false, "", ""];
	} forEach _allAvailableUnitTypes;

	_subMenu pushBack [ (_x select 1), {}, [], -1, false, false, "", "" ];
	_subMenu pushBack _unitMenu;

} forEach [
	["infantry", "Build Infantry", {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildUnit", 2]}],
	["car", "Build Light Vehicle", {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}],
	["armored", "Build Heavy Vehicle", {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}],
	["air", "Build Flying Vehicle", {[group (_this select 1), (_this select 3) select 0] remoteExec ["WF_buildVehicle", 2]}],
	["bangSticks", "Cook Bang Sticks", {[_this select 1, (_this select 3) select 0] remoteExec ["WF_buyWeapons", 2]}],
	["ammo", "Munitions", {[_this select 1, (_this select 3) select 0] remoteExec ["WF_buyItem", 2]}],
	["items", "Gear Up Cowboy", {[_this select 1, (_this select 3) select 0] remoteExec ["WF_buyItem", 2]}],
	["backpacks", "Put your shit in", {[_this select 1, (_this select 3) select 0] remoteExec ["WF_buyBackpack", 2]}]
];

titleMenu pushBack _subMenu;

switch (_side) do {
	case east: {[ titleMenu, matt, true, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;};
	case west: {[ titleMenu, ehsan, true, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;};
};

/*{[_this select 1 !selects instigator! , (_this select 3 !selects arguments!) select 0 !Selects first argument!] remoteExec [(_this select 3) select 1, 2]}*/
