_side = side player;
_faction = faction player;

titleMenu = [[ "Purchase Units", {}, [], -1, false, false, "", "" ]];
_subMenu = [];
{
	_buildFunction = _x select 2;
	_allAvailableUnitTypes = missionNamespace getVariable ("WF_arrayTypes_" + (str _side) + (_x select 0));
	_unitMenu = [];

	if (_x select 0 != "bangSticks" && _x select 0 != "ammo") then
	{
		{
			_configEntry = _x select 0;
			_unitMenu pushback [getText (_configEntry >> "displayName"), {[group (_this select 1), (_this select 3) select 0] remoteExec [(_this select 3) select 1, 2]}, [configName _configEntry, _buildFunction], -1, false, false, "", ""];
		} forEach _allAvailableUnitTypes;
	}
	else
	{
		if (_x select 0 == "bangSticks") then
		{
			{
				_configEntry = _x select 0;
				_unitMenu pushBack [ getText (_configEntry >> "displayName"), {[_this select 1, (_this select 3) select 0] remoteExec [(_this select 3) select 1, 2]}, [configName _configEntry, _buildFunction], -1, false, false, "", ""];
			} forEach _allAvailableUnitTypes;
		}
		else
		{
			{
				_configEntry = _x select 0;
				_unitMenu pushBack [ getText (_configEntry >> "displayName"), {[_this select 1, (_this select 3) select 0] remoteExec [(_this select 3) select 1, 2]}, [configName _configEntry, _buildFunction], -1, false, false, "", ""];
			} forEach _allAvailableUnitTypes;
		}
	};
	_subMenu pushBack [ (_x select 1), {}, [], -1, false, false, "", "" ];
	_subMenu pushBack _unitMenu;

} forEach [["infantry", "Build Infantry", "WF_buildUnit"], ["car", "Build Light Vehicle", "WF_buildVehicle"], ["armored", "Build Heavy Vehicle", "WF_buildVehicle"], ["air", "Build Flying Vehicle", "WF_buildVehicle"], ["bangSticks", "Cook Bang Sticks", "WF_buyWeapons"], ["ammo", "Munitions", "WF_buyAmmo"]];

titleMenu pushBack _subMenu;

switch (_side) do {
	case east: {[ titleMenu, matt, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;};
	case west: {[ titleMenu, ehsan, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;};
};

/*{[_this select 1 !selects instigator! , (_this select 3 !selects arguments!) select 0 !Selects first argument!] remoteExec [(_this select 3) select 1, 2]}*/
