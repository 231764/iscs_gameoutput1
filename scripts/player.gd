extends CharacterBody2D

const TILE_SIZE := 16
const SPEED := 100.0

var is_moving := false
var move_direction := Vector2.ZERO
var facing_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var keep_playing_animation := false

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready() -> void:
	target_position = global_position
	animated_sprite_2d.play("idle_r")


func _physics_process(delta: float) -> void:
	move_to_target(delta)
	if is_moving == false: 
		if facing_direction == Vector2.UP: animated_sprite_2d.play("idle_north")
		elif facing_direction == Vector2.DOWN: animated_sprite_2d.play("idle_south")
		else: animated_sprite_2d.play("idle_r")

	var direction = get_input_direction()
	start_move(direction)


func move_animation(direction: Vector2) -> void:
	if direction == Vector2.UP:
		animated_sprite_2d.play("walking_north")
		facing_direction = Vector2.UP
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("walking_south")
		facing_direction = Vector2.DOWN
	elif direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = true;
		facing_direction = Vector2.RIGHT
		animated_sprite_2d.play("walking")
	elif direction == Vector2.RIGHT:
		facing_direction = Vector2.RIGHT
		animated_sprite_2d.flip_h = false;
		animated_sprite_2d.play("walking")
	

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
	
	move_animation(direction)

func move_to_target(delta: float) -> void:
	var remaining := target_position - global_position
	var step_distance := SPEED * delta
	if remaining.length() <= step_distance:
		global_position = target_position
		is_moving = false
		return

	move_and_collide(move_direction * step_distance)
	
