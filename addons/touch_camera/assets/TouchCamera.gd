extends Spatial
class_name TouchCamera, "tcam_icon_3d.drawio.png"

export(NodePath) var button_cam_mode

export(float) var c_speed = 1.5
export(float) var c_rotate = 0.01

export(float) var wheel_step_dist = 0.20
export(float) var max_center_dist = 30.0

var current setget _set_cam_current, _get_cam_current

export(float) var touch_zoom_speed := 0.1
export(float) var touch_ymove_speed := 0.01
export(float) var touch_xzmove_speed := 0.005

var pitch
var yaw
var turn_center_dist = 0.0

onready var button_cam_mode_node : BaseButton = get_node(button_cam_mode)

func _ready():
	set_process_unhandled_input(true)
	set_physics_process(true)
	pitch = rotation.x
	yaw = rotation.y
	turn_center_dist = $Camera.transform.origin.z
	$Camera.transform = Transform.IDENTITY.translated(Vector3(0,0,turn_center_dist))


func _unhandled_input(event):
	if $Camera.current:
		if button_cam_mode_node.pressed:
			_handle_translate_event(event)
		else:
			_handle_rotate_event(event)


func _handle_translate_event(event):
	if event is TouchEvent.Drag:
		if event.touch_count == 1:
			# translate camera rotation center plane (x-z-plane)
			var viewangle = global_rotation.y
			var global_drag = event.relative.rotated(-viewangle)
			global_translate(Vector3(-global_drag.x,0,-global_drag.y) * touch_xzmove_speed * move_speed_scaling())
			get_tree().set_input_as_handled()
		else:
			# translate camera rotation center height (y-axis)
			global_translate(Vector3(0,event.relative.y,0) * touch_ymove_speed * move_speed_scaling())
			update_cam_pose()
			get_tree().set_input_as_handled()
	elif event is TouchEvent.Pinch:
		# move camera from/towawrds rotation center
		turn_center_dist -= event.relative * touch_zoom_speed
		turn_center_dist = clamp(turn_center_dist, 0, max_center_dist)
		update_cam_pose()
		get_tree().set_input_as_handled()
	if event is InputEventMouseButton:
		# mouse wheel translates camera rotation center height (y-axis)
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					global_translate(Vector3(0,wheel_step_dist,0))
				BUTTON_WHEEL_DOWN:
					global_translate(Vector3(0,-wheel_step_dist,0))
			update_cam_pose()
			get_tree().set_input_as_handled()


func _handle_rotate_event(event):
	if event is TouchEvent.Drag:
		if event.touch_count == 1:
			# rotate camera
			yaw = fmod(yaw - event.relative.x * c_rotate, 2*PI)
			pitch = clamp(pitch - event.relative.y * c_rotate, -PI/2, PI/2)
			update_cam_pose()
			get_tree().set_input_as_handled()
		else:
			# translate camera rotation center height (y-axis)
			global_translate(Vector3(0,event.relative.y,0) * touch_ymove_speed * move_speed_scaling())
			update_cam_pose()
			get_tree().set_input_as_handled()
	elif event is TouchEvent.Pinch:
		# move camera from/towawrds rotation center
		turn_center_dist -= event.relative * touch_zoom_speed
		turn_center_dist = clamp(turn_center_dist, 0, max_center_dist)
		update_cam_pose()
		get_tree().set_input_as_handled()
	if event is InputEventMouseButton:
		# mouse wheel changes distance from camera to camera rotation center
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					turn_center_dist += wheel_step_dist
					if turn_center_dist > max_center_dist:
						turn_center_dist = max_center_dist
				BUTTON_WHEEL_DOWN:
					turn_center_dist -= wheel_step_dist
					if turn_center_dist < 0:
						turn_center_dist = 0
			update_cam_pose()
			get_tree().set_input_as_handled()


func _process(delta):
	var any_action_pressed = false
	if $Camera.current:
		var direction = Vector2.ZERO
		if Input.is_action_pressed("ui_left"):
			direction -= Vector2(1,0)
			any_action_pressed = true
		if Input.is_action_pressed("ui_right"):
			direction += Vector2(1,0)
			any_action_pressed = true
		if Input.is_action_pressed("ui_down"):
			direction -= Vector2(0,1)
			any_action_pressed = true
		if Input.is_action_pressed("ui_up"):
			direction += Vector2(0,1)
			any_action_pressed = true
		direction = direction.normalized()
		var global_drag = direction.rotated(global_rotation.y)
		global_translate(Vector3(global_drag.x,0,-global_drag.y) * c_speed * delta)
	$CenterDot.visible = any_action_pressed or TouchCameraEventInputManager.touch_count > 0


func update_cam_pose():
	$Camera.transform.origin.z = turn_center_dist
	set_rotation(Vector3(pitch, yaw, 0))


func move_speed_scaling() -> float:
	if turn_center_dist < 0.1*max_center_dist:
		return 1.0
	else:
		return turn_center_dist / (0.1*max_center_dist)

func _set_cam_current(state:bool):
	$Camera.current = state
	
func _get_cam_current():
	return $Camera.current
	
