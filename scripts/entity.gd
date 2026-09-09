extends CharacterBody2D
const TILE_SIZE := 16
const SPEED := 100.0
var is_moving := false
var move_direction := Vector2.ZERO
var facing_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var keep_playing_animation := false
var active_breakable_cell := Vector2i(-1, -1)
var tiles_to_move := 0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var tilemap: TileMap = get_node("../TileMap")

func _ready() -> void:
	target_position = global_position
	animated_sprite_2d.play("idle_r")
	
func get_random_direction() -> Vector2:
	var directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]
	
	return directions.pick_random()

func move_animation(direction: Vector2) -> void:
	if direction == Vector2.UP:
		animated_sprite_2d.play("walking_north")
		facing_direction = Vector2.UP
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("walking_south")
		facing_direction = Vector2.DOWN
	elif direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = true
		facing_direction = Vector2.LEFT
		animated_sprite_2d.play("walking")
	elif direction == Vector2.RIGHT:
		facing_direction = Vector2.RIGHT
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("walking")

func idle_animation() -> void:
	if facing_direction == Vector2.UP:
		animated_sprite_2d.play("idle_north")
	elif facing_direction == Vector2.DOWN:
		animated_sprite_2d.play("idle_south")
	elif facing_direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("idle_r")
	elif facing_direction == Vector2.RIGHT:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle_r")

func choose_random_movement():
	move_direction = get_random_direction()
	tiles_to_move = randi_range(2, 6)
	print("Tiles to move: " +  str(tiles_to_move))
	start_move(move_direction)
	move_animation(move_direction)

func _physics_process(delta):
	if is_moving:
		move_to_target(delta)
	else: 
		if randf() < 0.01: #
			choose_random_movement()
			if is_moving == false: #if interfere with wall, idle
				idle_animation()
		else: #if zero, idle
			idle_animation()
		

func start_move(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	facing_direction = direction
	if is_moving:
		return
	if test_move(global_transform, direction * TILE_SIZE):
		return	
	move_direction = direction
	target_position = global_position + direction * TILE_SIZE
	is_moving = true

func move_to_target(delta: float) -> void:
	var remaining := target_position - global_position
	var step_distance := SPEED * delta
	if remaining.length() <= step_distance:
		global_position = target_position
		tiles_to_move -= 1
		if is_moving:
			
			var current_cell := tilemap.local_to_map(tilemap.to_local(global_position))
			break_active_tile(current_cell)
			is_moving = false
			apply_tile_effects()
			print(tiles_to_move)
			if tiles_to_move > 0:
				start_move(move_direction)
			
	move_and_collide(move_direction * step_distance)

func apply_tile_effects() -> void:
	var tile_data := get_current_tile_data()
	if tile_data == null:
		return
	var tile_type: String = tile_data.get_custom_data("tile_type")
	if tile_type == "arrow":
		var forced_direction: Vector2 = tile_data.get_custom_data("direction")
		force_move(forced_direction)
	elif tile_type == "ice":
		force_move(move_direction)
	elif tile_type == "breakaway":
		activate_breakable()

func force_move(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	if test_move(global_transform, direction * TILE_SIZE):
		return
	move_direction = direction
	target_position = global_position + direction * TILE_SIZE
	is_moving = true
	move_animation(direction)

func activate_breakable() -> void:
	var cell := tilemap.local_to_map(tilemap.to_local(global_position))
	active_breakable_cell = cell
	tilemap.set_cell(0, cell, 4, Vector2i(9, 1), 0) #about to break tile

func break_active_tile(cell) -> void:
	if active_breakable_cell == Vector2i(-1, -1):
		return
	tilemap.set_cell(0, active_breakable_cell, 4, Vector2i(10, 2), 0) # broken/hole tile
	active_breakable_cell = Vector2i(-1, -1)

func get_current_tile_data() -> TileData:
	var cell := tilemap.local_to_map(tilemap.to_local(global_position))
	return tilemap.get_cell_tile_data(0, cell)
