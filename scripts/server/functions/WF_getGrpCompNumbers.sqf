private ["_units", "_unitType", "_countTypes", "_unit", "_index", "_template"];
params ["_units"];

_template = missionNameSpace getVariable "allUnitTypes";
_countTypes = [];
{
  _countTypes pushBack [_x, 0];
} forEach _template;

{
  if (vehicle _x == _x) then {
    _unit = _x;
    } else {
      if (((assignedVehicleRole _x) select 0) == "cargo") then {
        _unit = _x;
        } else {
          _unit = vehicle _x;
        };
    };
  _unitType = missionNameSpace getVariable ("unitType_" + (typeOf _unit));
  /*if (isNil "_unitType") then {hint (str (typeOf _unit)); _unitType = "Other";};*/
  _index = _template find _unitType;
  _countTypes set [_index, [(_countTypes select _index) select 0 ,((_countTypes select _index) select 1) + 1]];
} forEach _units;

_countTypes
