extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("toggled",self,"_on_toggled")


func _on_toggled(button_pressed):
	if button_pressed:
		icon = preload("../assets/button_translate.drawio.png")
	else:
		icon = preload("../assets/button_rotate.drawio.png")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if not event.pressed:
				pressed = not pressed
				get_tree().set_input_as_handled()
