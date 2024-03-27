extends Sprite2D

class_name Item 
enum itemtypes {apple, key, fish, duckling}
@export var itemname: itemtypes 
@export var item_position: Vector2i


func _ready():
	match itemname: 
		itemtypes.duckling:
			print(Global.duckcounter)
			region_rect = Rect2((Global.duckcounter*8),176, 8, 8)
		itemtypes.fish: 
			region_rect.position = Vector2i(16,136)
		itemtypes.apple:
			region_rect.position = Vector2i(120,40)
		itemtypes.key:
			region_rect.position = Vector2i(24,48)
