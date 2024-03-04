extends Sprite2D

class_name Enemy


@onready var controller = get_parent()
@export var health : int
@export var sightRange = 10

enum state {idle, attack, stun}
var enemy_position : Vector2i
var tilemap
var player 
var currentstate = state.idle

func _ready():
	pass # Replace with function body.

func checkforrange():
	if player == null:
		return
	var differenceX = abs(enemy_position.x - player.gridPosition.x)
	var differenceY = abs(enemy_position.y - player.gridPosition.y)
	if differenceX + differenceY <= sightRange:
		currentstate = state.attack


