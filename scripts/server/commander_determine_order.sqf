private ["_hqMarker", "_towns", "_side", "_allSideGrps", "_allSidePlayerGrps", "_allSideAIGrps", "_preferredElement", "_sideStr"];
params ["_hqMarker", "_towns", "_side", "_allSideGrps", "_allSidePlayerGrps", "_allSideAIGrps"];

_sideStr = str _side;
_hqPos = getMarkerPos _hqMarker;
_grpTypeNumbers = [];
_enemySides = [_side] call WF_getEnemySides;
_allAllyTowns = missionNameSpace getVariable (_sideStr + "locations");

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// RUN MONITOR FUNCTIONS
/*_monitorFuncList = missionNamespace getVariable ("monitorFunctions" + _sideStr);
if !(isNil "_monitorFuncList") then {
  for [{private _i = 0; private ["_element"]}, {_i < (count _monitorFuncList)}, {_i = _i + 1}] do {
    _element = _monitorFuncList select _i;
    _i = [(_element select 2), _monitorFuncList, _i] call (_element select 1);
  };
};*/

//------------------------------------------------------------------------------
// RUN VEHICLE LOCK AND GET IN VEHICLE SCRIPTS
/*{
  private ["_grp"];
  _grp = _x;
  {
    if (canMove _x) then {
      if (isNil {_x getVariable "monitoredUnits"}) then {
        _x setVariable ["monitoredUnits", [leader _grp]];
      };

      [_x, _grp, _side] call WF_determineVehicleLock;
    };
  } forEach ([_grp, true] call WF_getGrpVehicles);
} forEach _teamAIGroups;*/

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Commander income & money
_countVillage = {(_x getVariable "type") == "village"} count _allAllyTowns;
_countTown = {(_x getVariable "type") == "town"} count _allAllyTowns;
_countAirport = {(_x getVariable "type") == "airport"} count _allAllyTowns;
_income = WFG_baseIncome + (_countVillage * WFG_villageIncome) + (_countTown * WFG_townIncome) + (_countAirport * WFG_AirportIncome);
_money = (missionNamespace getVariable (_sideStr + "money")) + _income;
missionNamespace setVariable [_sideStr + "money", _money];
_incomePerMinute = (_income * 60) / WFG_commanderCycleTime;

// Has income changed? Used later on in unit purchase and construction decision making
_incomeChanged = false;
_prevIncome = missionNamespace getVariable (_sideStr + "income");
if (isNil "_prevIncome") then {
  missionNamespace setVariable [_sideStr + "income", _income];
  _incomeChanged = true;
} else {
  if (_income != _prevIncome) then {
    missionNamespace setVariable [_sideStr + "income", _income];
    _incomeChanged = true;
  };
};

// TEMP PLAYER MONEY!!!!!!!!
{
  _wallet = _x getVariable "wallet";
  if (isNil "_wallet") then {
    _x setVariable ["wallet", 500];
  } else {
  _x setVariable ["wallet", (_wallet + _income / 5)];
  };
} forEach _allSidePlayerGrps;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Calculate unit cap (UC)
_UC_countUnits = 0;
{
  _UC_countUnits = _UC_countUnits + (count (units _x));
} forEach _allSideGrps;

_unitCapPortion = _UC_countUnits / WFG_unitCap;
//------------------------------------------------------------------------------
// PURCHASE AI

_stopPurchaseLoop = false;
while {!_stopPurchaseLoop} do {
  // Build from que or select a new type?
  _runPurchaseAI = true;
  _buildQue = missionNameSpace getVariable (_sideStr + "buildQue");
  if (!(_incomeChanged) and !(isNil "_buildQue")) then {
    if ((count _buildQue) > 0) then {
      _runPurchaseAI = false;
      diag_log "diag!!! building from que";
      missionNamespace setVariable [_sideStr + "buildQue", nil];
    };
  } else {
    // Not sure this is necessary but the purpose is to ensure _buildQue is defined outside of the "if (_runPurchaseAI)" code bracket should it return as nil in the code above.
    _buildQue = [];
  };
  //

  if (_runPurchaseAI) then {
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    // Unit Purchase AI
    _buildUnitArray = [];
    if (_UC_countUnits < WFG_unitCap) then {
      private _excess = 0;
      // select best group type
      _strTemplate = +(missionNamespace getVariable (_sideStr + "allGrpTypes"));
      _numbTemplate = +(missionNamespace getVariable (_sideStr + "portionTemplate"));

      for [{private _i = 0; private _reference = -1; private ["_type", "_avgCost", "_size", "_minutes", "_portion", "_timeGap"]}, {_i < (count _strTemplate)}, {_i = _i + 1}] do {
        _type = _strTemplate select _i;
        _avgCost = missionNamespace getVariable (_type + _sideStr + "avgCost");
        _size = missionNamespace getVariable (_type + "AIGrpLowerLimit");

        if (!(isNil "_avgCost") and !(isNil "_size")) then { // Accounting for types like "other" that have undef avg cost and size
          _minutes = ((_avgCost * _size) - _money) / _incomePerMinute;
          if (_minutes < 0) then {
            _minutes = 0;
          };

          if (_reference == -1) then {
            _reference = _minutes; // Since _strTemplate is already in order of lowest avg cost to highest (done in server init), the first element will be the cheapest on avg and hence the reference.
          } else {
            _portion = _numbTemplate select _i;
            _timeGap = _minutes - _reference;
            if (_timeGap > 30) then {
              _excess = _excess + _portion;
              _numbTemplate set [_i, 0];
            } else {
              if (_timeGap > 15) then {
                _excess = _excess + (_portion / 2);
                _numbTemplate set [_i, _portion / 2];
              };
            };
          };
        };
      };

      // Redistribute any excess portions from above ---------------------------
      if (_excess > 0) then {
        private _sum = 1 - _excess;
        for [{private _i = 0; private ["_element"]}, {_i < (count _numbTemplate)}, {_i = _i + 1}] do {
          _element = _numbTemplate select _i;
          _numbTemplate set [_i, _element + ((_element / _sum) * _excess)];
        };
      };
      diag_log "diag!!! _numbTemplate";
      diag_log _numbTemplate;
      //------------------------------------------------------------------------

      _grpTypePortions = [];
      {
        _grpTypePortions pushBack 0;
      } forEach _numbTemplate;

      {
        private ["_type", "_index"];

        _type = _x getVariable "grpType";
        if (isNil "_type") then {
          _x setVariable ["grpType", "other"];
          _type = "other";
        };

        _index = _strTemplate find _type;
        _grpTypePortions set [_index, (_grpTypePortions select _index) + 1];
      } forEach _allSideAIGrps;

      _grpTypeToBuild = _strTemplate select ([_grpTypePortions, _numbTemplate] call WF_findHighestPercentGap);
      diag_log "diag!!! _grpTypeToBuild";
      diag_log _grpTypeToBuild;

      // Plan out selected group type
      _buildUnitArray = [_grpTypeToBuild, _sideStr, _money, _incomePerMinute, _UC_countUnits] call WF_AIunitSelection;
      diag_log "diag!!! _buildUnitArray";
      diag_log _buildUnitArray;
    };

    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Other options (such as construction) go here

    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Spend money on the best option
    _decisionPool = [];

    // Unit formula
    if ((count _buildUnitArray) > 0) then {
      _buildUnitArray pushBack "units";
      _buildUnitArray pushBack (((_buildUnitArray select 1) + 1) * _unitCapPortion * WFG_AIunitFactor); // The +1 is to avoid a zero minut build time skewing the formula (as x 0 = 0). WFG_AIunitFactor should be relatively high to enhance the effect of _unitCapPortion.
      _decisionPool pushBack _buildUnitArray;
    };

    // Other fomulae go here (e.g. construction formula)

    // Find the lowest points (i.e. "best" option)
    _bestPoints = -1;
    _buildQue = [];
    {
      if (((_x select ((count _x) - 1)) < _bestPoints) or (_bestPoints == -1)) then {
        _buildQue = _x;
      };
    } forEach _decisionPool;
  };

  diag_log "diag!!! _buildQue";
  diag_log _buildQue;
  // Build / purchase the best option
  switch (_buildQue select ((count _buildQue) - 2)) do {
    case "units": {
      _stopPurchaseLoop = [_buildQue select 0, _side, _buildQue select 2, _buildQue select 3, [_allSideGrps, _allSideAIGrps]] call WF_AIBuildUnit;
    };

    case "contruction": {
      //construct
    };

    default {
      _stopPurchaseLoop = true;
    };
  };

  if (_stopPurchaseLoop) then {
    diag_log "diag!!! no money!";
    missionNamespace setVariable [_sideStr + "buildQue", _buildQue];
  };
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
_allObjectivesOrig = [];

// Determine defensive objectives
{
  private ["_enemyForces", "_enemyStrength"];
  if ((_x getVariable "WF_townState") == "alert") then {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;

    _friendlyForces = [];
    {
      {
        if (alive _x) then {
          _friendlyForces pushBack _x;
        };
      } forEach (units _x);
    } forEach (_x getVariable "patrolForces");

    _enemyStrength = [_enemyForces] call WF_estimateForceStrength;
    _friendlyStrength = [_friendlyForces] call WF_estimateForceStrength;
    // If _enemyStrength > strength of Patrol forces, then the town will be considered as a potential defensive objective.
    if (_enemyStrength > _friendlyStrength) then {
      _allObjectivesOrig pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3, (_enemyStrength - _friendlyStrength) * 1.2]; // The third element in the objective array is the strenght thershold that must be overcome in order to deal with the objective.
    };
  };
} forEach _allAllyTowns;

// Determine offensive objectives
_enemyTowns = [];
_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 0)) + "locations")); // These location vars are defined in gameManager, initially as an empty array and then each town a side owns is added to it.
_enemyTowns append (missionNameSpace getVariable ((str (_enemySides select 1)) + "locations"));
{
  private ["_enemyForces"];
  private _enemyStrength = 0;
  if ((_x getVariable "WF_townState") == "alert") then {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;
    _enemyStrength = [_enemyForces] call WF_estimateForceStrength;
  } else {
    _enemyForces = [list (_x getVariable "alertZone"), _enemySides] call WF_unitSideFilter;
    _enemyStrength = ([_enemyForces] call WF_estimateForceStrength) + (_x getVariable "patrolForceStrength"); // When a patrol squad is despawned (despawnTownPatrol.sqf), it's strength is calculated and saved on the town as a var for easy access.
  };

  _allObjectivesOrig pushBack [_x, ((getPos _x) distanceSqr _hqPos) / 3, (_enemyStrength) * 2];
} forEach _enemyTowns;

{
  (_x select 0) setVariable [(_sideStr + "preferredGroups"), []];
} forEach _allObjectivesOrig;

_undecidedGroups = +_allSideGrps;
_allObjectivesCopy = +_allObjectivesOrig;
diag_log "diag!!! _undecidedGroups";
diag_log _undecidedGroups;
while {(count _undecidedGroups) > 0} do {

  private _preferredObjectives = [];
  private _objtvList = _allObjectivesCopy;
  if ((count _allObjectivesCopy) <= 0) then { // If all available objectives have reached thershold, this will ensure that any remaining groups do not stand around idle and instead go to whatever objective they prefer.
    _objtvList = _allObjectivesOrig;
  };

  diag_log "diag!!! _undecidedGroups in loop";
  diag_log _undecidedGroups;
  {
    diag_log ["diag!!! GRP", _x];
    _preferredObjectives pushBackUnique ([_x, _objtvList, _side] call WF_findBestObjective);
  } forEach _undecidedGroups;

  _undecidedGroups = [];
  {
    private ["_objective", "_thershold", "_forceStrength", "_grpsAndPoints", "_newObjective", "_currentObjective", "_objectivePos"];
    private _grp = grpNull;
    _objective = _x select 0;
    _thershold = _x select 2;
    _forceStrength = 0;
    _grpsAndPoints = _objective getVariable (_sideStr + "preferredGroups");
    diag_log ["diag!!! objective and prefGrps", _objective, _grpsAndPoints];

    while {(count _grpsAndPoints) > 0} do {
      if (((count _allObjectivesCopy) > 0) and (_forceStrength > _thershold)) exitWith { // *** If the number of objectives left reaches 0 but we have not assigned all our grps it will have a problem!
        diag_log ["diag!!! Thershold reached", _objective, _side];
        _allObjectivesCopy = _allObjectivesCopy - [_x];
        {
          _undecidedGroups pushBack (_x select 0);
        } forEach _grpsAndPoints;
      };

      _minPoints = -1;
      {
        if (((_x select 1) < _minPoints) or (_minPoints == -1)) then {
          _minPoints = _x select 1;
          _grp = _x select 0;
        };
      } forEach _grpsAndPoints;

      _newObjective = true;
      _currentObjective = _grp getVariable "currentObjective";
      if !(isNil "_currentObjective") then {
        if ((_currentObjective == _objective) and (count (waypoints _grp) <= 1)) then {
          [_grp, _objective] call WF_reassignWaypoint;
          _newObjective = false;
        };
      };

      if (_newObjective) then {
        _grp setVariable ["currentObjective", _objective];
        _objectivePos = getPos _objective;
        [_grp, _objectivePos, 10] call WF_setWaypoint;
      };

      diag_log ["diag!!! grp and decided objective", _objective];
      _forceStrength = _forceStrength + ([units _grp] call WF_estimateForceStrength);
      _grpsAndPoints deleteAt (_grpsAndPoints find [_grp, _minPoints]);
      diag_log _grpsAndPoints;
    };
  } forEach _preferredObjectives;
};
