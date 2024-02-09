extends Enemy

@onready var tilemap = controller.tilemap

func _ready():
	enemy_position = Vector2i(randi_range(1, controller.width-1), randi_range(1, controller.height-1))
	print(controller.width)


func update_position(new_position):
	pass
	
func _on_player_moved():
	self.enemy_position += Vector2i(randi_range(-1, 1), randi_range(-1, 1))
	self.position = tilemap.map_to_local(self.enemy_position)
	
	
