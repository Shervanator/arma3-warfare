/* Function for creating markers, setting their type, colour and alpha

Parameters:
  - _name: string representing the marker name
  - _pos: position 2D or 3D representing the position of the marker
  - _shape: String, shape of the marker
  - _type: String, type of the marker
  - _color: String, marker color
  - (optional) _alpha: Float, from 0 to 1, represents transparency

Returns:
  - String: Name of the marker created

Author: kyfohatl
*/

private ["_name", "_pos", "_shape", "_type", "_color", "_alpha"];
params ["_name", "_pos", "_shape", "_type", "_color", "_alpha"];

private _marker = createMarker [_name, _pos];
_marker setMarkerShape _shape;
_marker setMarkerType _type;
_marker setMarkerColor _color;

if !(isNil "_alpha") then {
  _marker setMarkerAlpha _alpha;
};

_marker