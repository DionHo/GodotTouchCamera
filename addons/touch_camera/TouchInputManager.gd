extends Node


# Stores last touch positions in a {index: position} map
var last_touch = {}
var _centroid:Vector2
var _std_deviation:float

var touch_count setget ,get_touch_count


func _ready():
	set_process_unhandled_input(true)


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenDrag:
		_on_screen_drag(event)
	elif event is InputEventScreenTouch:
		_on_screen_touch(event)


func _on_screen_touch(event : InputEventScreenTouch):
	if event.pressed:
		last_touch[event.index] = event.position
		_update_centroid_and_deviation()
	else:
		last_touch.erase(event.index)
		if len(last_touch) > 0:
			_update_centroid_and_deviation()


func _on_screen_drag(event : InputEventScreenDrag):
	if not last_touch.has(event.index):
		# something went wrong in the event order!
		# Execute _on_screen_touch manually and drop the drag event processing
		var simulate_event = InputEventScreenTouch.new()
		simulate_event.pressed = true
		simulate_event.index = event.index
		simulate_event.position = event.position
		_on_screen_touch(simulate_event)
		return

	var touch_count = len(last_touch)
	if touch_count > 0:
		# The event.relative infomation can be unreliable for multitouch use cases
		# Recalculate relative movement using nearest neighbor instead of touch.index
		var event_index = _get_nearest_touch_index(event.position)
		var event_relative = event.position - last_touch[event_index]

		var new_touch = last_touch
		new_touch[event_index] = event.position
		var new_centroid = _calc_centroid(new_touch)
		var new_std_deviation = _calc_std_deviation(new_centroid, new_touch)

		var relative_drag : Vector2 = new_centroid - _centroid
		var relative_pinch	: float = new_std_deviation - _std_deviation
		var scale_pinch 	: float	= new_std_deviation / _std_deviation if _std_deviation > 0 else 1.0

		# reset last values to new values
		last_touch = new_touch
		_centroid = new_centroid
		_std_deviation = new_std_deviation

		# Feed either Pinch or drag event into the pipeline, whatever has the greater amount
		var relative_drag_len =  relative_drag.length()
		if relative_drag_len/2.0 > abs(relative_pinch) or touch_count == 1 :
			Input.parse_input_event(TouchEvent.Drag.new(touch_count, relative_drag))
		else:
			Input.parse_input_event(TouchEvent.Pinch.new(touch_count, relative_pinch, scale_pinch))


func get_touch_count() -> int:
	return len(last_touch)


func _get_nearest_touch_index(pos:Vector2) -> int:
	var idx : int = last_touch.keys()[0]
	var idx_dist := pos.distance_squared_to(last_touch[idx])
	for i in last_touch:
		var i_dist = pos.distance_squared_to(last_touch[i])
		if i_dist < idx_dist:
			idx_dist = i_dist
			idx = i
	return idx


func _calc_centroid(touch_poitions) -> Vector2:
	var c = Vector2.ZERO
	for p in touch_poitions:
		c += touch_poitions[p]
	return c / len(touch_poitions)


func _calc_std_deviation(centroid : Vector2, touch_poitions) -> float:
	var d = 0.0
	for p in touch_poitions:
		d += centroid.distance_squared_to(touch_poitions[p])
	return sqrt(d / len(touch_poitions))


func _update_centroid_and_deviation():
	_centroid = _calc_centroid(last_touch)
	_std_deviation = _calc_std_deviation(_centroid, last_touch)
