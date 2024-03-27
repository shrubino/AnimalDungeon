extends Enemy


func _ready():
	gridPosition = Vector2i(randi_range(-(controller.width-1), controller.width-1), randi_range(-(controller.height-1), controller.height-1))


func update_position(new_position):
	pass
	
func _on_player_moved():
	checkforrange()
	var targetposition : Vector2i
	if currentstate == state.idle:
		targetposition = Vector2i(randi_range(-1, 1), randi_range(-1, 1))
	else:
		var differenceX = (gridPosition.x - player.gridPosition.x)
		var differenceY = (gridPosition.y - player.gridPosition.y)
		if differenceX != 0:
			targetposition.x = (differenceX)/abs(differenceX) * -1
		if differenceY != 0:
			targetposition.y = (differenceY)/abs(differenceY) * -1
		if targetposition + gridPosition == player.gridPosition:
			attackplayer()
			return
	controller.test_cell(targetposition, self)
	self.position = tilemap.map_to_local(self.gridPosition)

func attackplayer():
	player.takedamage(1)


