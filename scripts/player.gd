extends CharacterBody2D
const TILE_SIZE := 16
const SPEED := 100.0
var is_moving := false
var move_direction := Vector2.ZERO
var target_position := Vector2.ZERO

@onready var tilemap: TileMap = get_node("../TileMap")

func _ready() -> void:
	target_position = global_position

func _physics_process(delta: float) -> void:
	if is_moving:
		move_to_target(delta)
		return
	var direction := get_input_direction()
	if direction != Vector2.ZERO:
		start_move(direction)

func get_input_direction() -> Vector2:
	if move_direction == Vector2.UP and Input.is_action_pressed("move_up"):
		return Vector2.UP
	if move_direction == Vector2.DOWN and Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	if move_direction == Vector2.LEFT and Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	if move_direction == Vector2.RIGHT and Input.is_action_pressed("move_right"):
		return Vector2.RIGHT
	if Input.is_action_pressed("move_up"):
		return Vector2.UP
	if Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2.RIGHT
	return Vector2.ZERO

func start_move(direction: Vector2) -> void:
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
		is_moving = false
		apply_tile_effects()
		return
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

func force_move(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	if test_move(global_transform, direction * TILE_SIZE):
		return
	move_direction = direction
	target_position = global_position + direction * TILE_SIZE
	is_moving = true

func get_current_tile_data() -> TileData:
	var cell := tilemap.local_to_map(tilemap.to_local(global_position))
	return tilemap.get_cell_tile_data(0, cell)
