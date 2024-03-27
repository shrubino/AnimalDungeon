extends Sprite2D

class_name Enemy


@onready var controller = get_parent()
@export var health : int
@export var sightRange = 10

enum state {idle, attack, stun}
var gridPosition : Vector2i
var tilemap
var player 
var currentstate = state.idle
var walljump = 0

func _ready():
	pass # Replace with function body.

func checkforrange():
	if player == null:
		return
	var differenceX = abs(gridPosition.x - player.gridPosition.x)
	var differenceY = abs(gridPosition.y - player.gridPosition.y)
	if differenceX + differenceY <= sightRange:
		currentstate = state.attack

