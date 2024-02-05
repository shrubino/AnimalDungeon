extends Sprite2D

@export var goblin_position : Vector2i
@onready var tilemap = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func ready():
	goblin_position = Vector2i(randi_range(1, tilemap.width-1), randi_range(1, tilemap.height-1))

func update_position(new_position):
	pass
	
func _on_player_moved():
	goblin_position += Vector2i(0,1)
