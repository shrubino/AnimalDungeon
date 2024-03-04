extends Sprite2D

class_name Item 
enum itemtypes {apple, key, fish}
@export var itemname: itemtypes 
@export var item_position: Vector2i

func _ready():
	match itemname: 
		itemtypes.fish: 
			region_rect.position = Vector2i(16,136)
		itemtypes.apple:
			region_rect.position = Vector2i(120,40)
		itemtypes.key:
			region_rect.position = Vector2i(24,48)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
