private ["_undecidedGroups", "_allObjectives", "_preferredObjectives", "_side"];
params ["_undecidedGroups", "_allObjectives", "_side"];

_sideStr = str _side;

{
  (_x select 0) setVariable [(_sideStr + "preferredGroups"), []];
} forEach _allObjectives;

while {(count _undecidedGroups) > 0} do {

_preferredObjectives = [];

  {
    _preferredObjectives pushBackUnique ([_x, _allObjectives, _side] call WF_findBestObjective);
  } forEach _undecidedGroups;

  _undecidedGroups = [];

  {
    private ["_objective", "_thershold", "_forceStrength", "_grp"];
    _objective = _x select 0;
    _thershold = _x select 2;
    _forceStrength = 0;
    _allPreferredgroups = _objective getVariable (_sideStr + "preferredGroups");
    //if thershold has not been reached???

    while {(count _allPreferredgroups) > 0} do {

      if (_forceStrength > _thershold) exitWith {
        _allObjectives = _allObjectives - [_x];
        _undecidedGroups append _allPreferredgroups;
      };

      _minPoints = -1;
      {
        if (((_x getVariable "objectivePoints") < _minPoints) or (_minPoints == -1)) then {
          _minPoints = _x getVariable "objectivePoints";
          _grp = _x;
        };
      } forEach _allPreferredgroups;

      [_grp, _objective] call WF_setWaypoint;
      _forceStrength = _forceStrength + ([units _grp] call WF_estimateForceStrength);
      _allPreferredgroups = _allPreferredgroups - [_grp];
    };
  // grp setObjective AND Thershold = Thershold + grpStrength
  } forEach _preferredObjectives;
};

/*_preferredTown = (_preferredObjectives select 0) select 0;
hint (str (_preferredTown getVariable ((str _side) + "preferredGroups")));
"marker5" setMarkerPos (getPos ((_preferredObjectives select 0) select 0));*/
