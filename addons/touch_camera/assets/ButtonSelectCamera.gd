extends OptionButton

export (Array, String) var camera_names
export (Array, NodePath) var camera_nodes


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(camera_nodes)):
		if len(camera_names) > i:
			add_item(camera_names[i],i)
		else:
			add_item(camera_nodes[i],i)
		set_item_tooltip(i,camera_nodes[i])
	connect("item_selected",self,"_on_item_selected")


func _on_item_selected(idx:int):
	get_node(get_item_tooltip(idx)).current = true
