// Performs necessary actions before the commander of each side runs each time

private ["_westArray", "_eastArray", "_westVars", "_eastVars", "_isP", "_allWestGrps", "_allWestPlayerSqds", "_allWestAISqds", "_allEastGrps", "_allEastPlayerSqds", "_allEastAISqds", "_westCommanderHandle", "_eastCommanderHandle"];
params ["_westArray", "_eastArray"];

_westVars = +_westArray;
_eastVars = +_eastArray;

_isP = {
  private ["_grp", "_allSidePlayerSqds", "_allSideAISqds"];
  params ["_grp", "_allSidePlayerSqds", "_allSideAISqds"];

  if (isPlayer (leader _grp)) then {
    _allSidePlayerSqds pushBack _grp;
  } else {
    _allSideAISqds pushBack _grp;
  };
};

_allWestGrps = [];
_allWestPlayerSqds = [];
_allWestAISqds = [];
_allEastGrps = [];
_allEastPlayerSqds = [];
_allEastAISqds = [];
{
  switch (side _x) do {
    case west: {
      _allWestGrps pushBack _x;
      [_x, _allWestPlayerSqds, _allWestAISqds] call _isP;
    };

    case east: {
      _allEastGrps pushBack _x;
      [_x, _allEastPlayerSqds, _allEastAISqds] call _isP;
    };
  };
} forEach allGroups;

_westVars pushBack _allWestGrps;
_westVars pushBack _allWestPlayerSqds;
_westVars pushBack _allWestAISqds;
_eastVars pushBack _allEastGrps;
_eastVars pushBack _allEastPlayerSqds;
_eastVars pushBack _allEastAISqds;


_westCommanderHandle = _westVars execVM "scripts\server\commander_determine_order.sqf";
_eastCommanderHandle = _eastVars execVM "scripts\server\commander_determine_order.sqf";
