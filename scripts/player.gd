extends CharacterBody2D

const TILE_SIZE := 16
const SPEED := 100.0

var is_moving := false
var move_direction := Vector2.ZERO
var target_position := Vector2.ZERO


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
	# Cases in which a key was previously held (move_direction)
	if move_direction == Vector2.UP and Input.is_action_pressed("move_up"):
		return Vector2.UP
	if move_direction == Vector2.DOWN and Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	if move_direction == Vector2.LEFT and Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	if move_direction == Vector2.RIGHT and Input.is_action_pressed("move_right"):
		return Vector2.RIGHT

	# Cases in which a key was released (no move_direction currently)
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
		return

	move_and_collide(move_direction * step_distance)
