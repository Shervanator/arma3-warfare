
private[ "_newMenu", "_find", "_depthX", "_child", "_childMenu", "_currentDepth" ];

params[
	[ "_vehicle", objNull, [ objNull ] ],
	[ "_depth", [], [ [] ] ],
	[ "_pos", -1, [ 0 ] ],
	[ "_isGlobal", false, [ false ] ]
];

if ( isNull _vehicle ) exitWith { false };

if ( { typeName _isGlobal isEqualTo typeName _x }count [ objNull, sideUnknown, grpNull, [], 0 ] > 0 || ( typeName _isGlobal isEqualTo typeName true && { _isGlobal } ) ) then {
	_this set [ 3, false ];
	[ _this, "LARs_fnc_meuAddItem", _isGlobal, false ] call BIS_fnc_MP;
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

 _childMenu = false;
if ( _pos >= 0 ) then {
	if ( (( count _find ) -1 ) >= _pos ) then {
		if ( (( count _find ) -1 ) > _pos && { typeName( _find select ( _pos + 1 ) select 0 ) isEqualTo typeName [] } ) then {
			_nul = _find deleteAt ( _pos + 1 );
			_childMenu = true;
		};
		_find deleteAt _pos;
	};
}else{
	if ( typeName (( _find select (( count _find ) -1 )) select 0 ) isEqualTo typeName [] ) then {
		_nul = _find deleteAt (( count _find ) -1 );
		_childMenu = true;
	};
	_nul = _find deleteAt (( count _find ) -1 );
};

_currentDepth = _vehicle getVariable [ "LARs_menuDepth", [] ];
if (  _childMenu && { ( _currentDepth select [ 0, count _depth ] ) isEqualTo _depth } ) then {
	_currentDepth = _depth;
};
_vehicle setVariable [ "LARs_menuDepth", _currentDepth ];

_vehicle setVariable [ "LARs_activeMenu",  _newMenu ];

if ( !isNull player && { isNil { player getVariable [ "LARs_remoteMenu", nil ] } } ) then {
	_vehicle call LARs_fnc_menuShow;
};

true
