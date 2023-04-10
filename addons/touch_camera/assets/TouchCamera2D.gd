extends Camera

class_name TouchCamera2D, "tcam_icon_2d.drawio.png"

export(float) var wheel_scale_step = 1.1

var pixel2meter 


func _ready():
	_recalc_pixel2meter()
	get_viewport().connect("size_changed",self,"_recalc_pixel2meter")
	

func _unhandled_input(event):
	if current:
		if event is TouchEvent.Drag:
			# translate camera
			translate(Vector3(-event.relative.x,event.relative.y,0) * pixel2meter)
			get_tree().set_input_as_handled()
		elif event is TouchEvent.Pinch:
			# zoomcamera
			size /= event.scale
			_recalc_pixel2meter()
			get_tree().set_input_as_handled()
		if event is InputEventMouseButton:
			# mouse wheel zooms camera
			if event.pressed:
				match event.button_index:
					BUTTON_WHEEL_UP:
						size *= wheel_scale_step
					BUTTON_WHEEL_DOWN:
						size /= wheel_scale_step
				_recalc_pixel2meter()
				get_tree().set_input_as_handled()


func _recalc_pixel2meter():
	var viewsize = get_viewport().size.x if keep_aspect == KEEP_WIDTH else get_viewport().size.y
	pixel2meter = size / viewsize
