# This class is a container for Touch events that are fed through the input event
# pipeline by the touch_camera plugin
class_name TouchEvent


class Drag extends InputEventAction:
	var touch_count : int
	var relative : Vector2

	func _init(_touch_count, _relative):
		touch_count = _touch_count
		relative = _relative



class Pinch extends InputEventAction:
	var touch_count : int # number of fingers detected
	var relative : float  # change of point spread
	var scale : float	  # proportion "actual point spread" by "previous point spread"

	func _init(_touch_count, _relative, _scale):
		touch_count = _touch_count
		relative 	= _relative
		scale 		= _scale
