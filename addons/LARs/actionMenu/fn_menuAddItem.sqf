
private[ "_newMenu", "_find", "_depthX", "_child", "_childMenus", "_nul", "_popped", "_currentDepth" ];

params[
	[ "_vehicle", objNull, [ objNull ] ],
	[ "_item", [], [ [], "" ] ],
	[ "_depth", [], [ [] ] ],
	[ "_pos", -1, [ 0 ] ],
	[ "_isGlobal", false, [ false ] ]
];

if ( { typeName _isGlobal isEqualTo typeName _x }count [ objNull, sideUnknown, grpNull, [], 0 ] > 0 || ( typeName _isGlobal isEqualTo typeName true && { _isGlobal } ) ) then {
	_this set [ 4, false ];
	[ _this, "LARs_fnc_meuAddItem", _isGlobal, false ] call BIS_fnc_MP;
};

if ( typeName _item isEqualTo typeName "" ) then {
	_item = missionNamespace getVariable [ _item, [] ];
};

_newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] );
_find = _newMenu;

{
	_depthX = _x;
	_child = -1;
	{
		if ( typeName ( _x select 0 ) isEqualTo typeName [] ) then {
			_child = _child + 1;
			if ( _child isEqualTo _depthX ) exitWith {
				 _find = _x;
			};
		};
	}forEach _find;
}forEach _depth;

 _childMenus = 0;
if ( _pos isEqualTo -1 ) then {
	{
		_nul = _find pushBack _x;
	}forEach _item;
}else{
	_popped = _find select [ _pos, ( count _find ) -1 ];
	for "_i" from _pos to ( count _find ) -1 do {
		_nul = _find deleteAt _i;
	};
	{
		if !( typeName( _x select 0 ) isEqualTo typeName "" ) then {
			 _childMenus = _childMenus + 1;
		};
		 _find set [ _pos + _forEachIndex, _x ];
	}forEach _item;
	{
		_nul = _find pushBack _x;
	}forEach _popped;
};

_currentDepth = _vehicle getVariable [ "LARs_menuDepth", [] ];
if ( count _currentDepth >= count _depth ) then {
	if (  _childMenus > 0 && { _currentDepth select [ 0, count _depth ] isEqualTo _depth && _currentDepth select ( count _depth ) <= _pos } ) then {
		_currentDepth set [ count _depth, ( _currentDepth select ( count _depth )) +  _childMenus ];
	};
};

_vehicle setVariable [ "LARs_activeMenu",  _newMenu ];

if ( !isNull player && { isNil { player getVariable [ "LARs_remoteMenu", nil ] } } ) then {
	_vehicle call LARs_fnc_menuShow;
};

true
