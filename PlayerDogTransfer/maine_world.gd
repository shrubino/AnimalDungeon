extends Node2D

@export_category("Basics")
@export var width = 100
@export var height = 100
@export var player_position = Vector2i(10,10)
@onready var tilemap = $TileMap
@onready var tileset = tilemap.tile_set
@onready var playerdog = $TileMap/PlayerDog
@onready var positionlabel = $TileMap/PlayerDog/positionlabel
@onready var goblin_scene = load("res://goblin_1.tscn")
@onready var goblin_instance = goblin_scene.instantiate()
@onready var numberofgoblins = 50
@onready var goblin_positions = []
signal player_moved


@export_category("Organicness")
@export var o_type = FastNoiseLite.TYPE_VALUE
@export var o_gain = 0.1
@export var o_octaves = 5
@export var o_lacunarity = 2
@export var o_frequency = .7

@export_category("Size")
@export var s_type = FastNoiseLite.TYPE_VALUE
@export var s_gain = 0.1
@export var s_octaves = 5
@export var s_lacunarity = 2
@export var s_frequency = .4

#and generators
var rng = RandomNumberGenerator.new()

func _ready():
	playerdog.position = tilemap.map_to_local(player_position)
	add_user_signal("TurnChanged")
	generate_map()

func generate_noise(type, gain, octaves, lacunarity, frequency):
	# generate randomly seeded simplex noise map
	var name = FastNoiseLite.new()
	name.noise_type = type
	name.seed = randi()
	name.frequency = frequency
	name.fractal_octaves = octaves
	name.fractal_lacunarity = lacunarity
	name.fractal_gain = gain
	var grid = {}
	for x in height:
		for y in width:
			var rand = name.get_noise_2d(x,y) + 1
			grid[Vector2i(x, y)] = rand
	return grid

func generate_map():
	map_addBackground()
	map_addBiomes()
	map_addPatterns()
	map_addBorder()
	map_addEnemies()

func map_addBackground():
	for x in width:
		for y in height:
					tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(1,1))

func map_addBorder():
	for x in width:
			tilemap.set_cell(0, Vector2i(x,0), 0, Vector2i(1,0))
			tilemap.set_cell(0, Vector2i(x,height), 0, Vector2i(1,2))
	for y in height:
			tilemap.set_cell(0, Vector2i(0,y), 0, Vector2i(0,1))
			tilemap.set_cell(0, Vector2i(width,y), 0, Vector2i(2,1))
	tilemap.set_cell(0, Vector2i(0,0), 0, Vector2i(0,0))
	tilemap.set_cell(0, Vector2i(width,0), 0, Vector2i(2,0))
	tilemap.set_cell(0, Vector2i(0,height), 0, Vector2i(0,2))
	tilemap.set_cell(0, Vector2i(width,height), 0, Vector2i(2,2))

func map_addEnemies():
	for x in range(numberofgoblins):
		var new_goblin = goblin_scene.instantiate()
		new_goblin.position = tilemap.map_to_local(new_goblin.goblin_position)
		add_child(new_goblin)
		goblin_positions.append(new_goblin)
		playerdog.player_moved.connect(new_goblin._on_player_moved)
	

func map_addPatterns():
	for x in width:
		for y in height:
			if rng.randf() > .99:
				tilemap.set_pattern(0, Vector2i(x,y), tileset.get_pattern(randi_range(0,15)))

func map_addBiomes():
	var org = generate_noise(o_type, o_gain, o_octaves, o_lacunarity, o_frequency)
	var size = generate_noise(s_type, s_gain, s_octaves, s_lacunarity, s_frequency)
	for x in width:
		for y in height:
			var pos = Vector2i(x,y)
			if org[pos] > 0.6 and size[pos] < 0.4:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(0,2)), 0)
			if org[pos] > 0.8 and size[pos] > 0.95:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(13,15), randi_range(3,4)), 0)
			if org[pos] < 0.5 and size[pos] < 0.5:
				tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(randi_range(0,7), randi_range(20,21)), 0)

func between(val, start, end):
	if start <= val and val < end:
		return true

func _unhandled_input(event):
	if Input.is_action_just_pressed("SW"):
		test_cell(Vector2i(-1,1))
		playerdog.flip_h = true
		player_turn()
	elif Input.is_action_just_pressed("SE"):
		test_cell(Vector2i(1,1))
		playerdog.flip_h = false
		player_turn()
	elif Input.is_action_just_pressed("S"):
		test_cell(Vector2i(0,1))
		player_turn()
	elif Input.is_action_just_pressed("N"):
		test_cell(Vector2i(0,-1))
		player_turn()
	elif Input.is_action_just_pressed("NW"):
		test_cell(Vector2i(-1,-1))
		playerdog.flip_h = true
		player_turn()
	elif Input.is_action_just_pressed("NE"):
		test_cell(Vector2i(1,-1))
		playerdog.flip_h = false
		player_turn()
	elif Input.is_action_just_pressed("E"):
		test_cell(Vector2i(1,0))
		playerdog.flip_h = false
		player_turn()
	elif Input.is_action_just_pressed("W"):
		test_cell(Vector2i(-1,0))
		playerdog.flip_h = true
		player_turn()

func player_turn():
	playerdog.emit_signal("player_moved")

func update_position():
	playerdog.position = tilemap.map_to_local(player_position)
	positionlabel.text = str(player_position)
	test_for_goblin()
	
func test_cell(coords: Vector2i):
	var shift_jump = 1
	if Input.is_action_pressed("shift_jump"):
		shift_jump = playerdog.shift_move_multiplier
	else :
		shift_jump = 1
	var testingcell = player_position + coords 
	var data = tilemap.get_cell_tile_data(0, testingcell)
	if data:
		if data.get_custom_data_by_layer_id(0) == 1:
			if playerdog.walljump:
				player_position += (-2 * coords)
				update_position()
			else:
				pass
		else: 
			player_position += coords * shift_jump
			update_position()

func test_for_goblin():
	for goblin in goblin_positions:
		if is_instance_valid(goblin) and player_position == goblin.goblin_position:
			goblin.queue_free()
			goblin_positions.erase(goblin)
