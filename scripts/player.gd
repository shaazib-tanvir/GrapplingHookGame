extends CharacterBody2D

@export_category("Movement")
@export var terminal_speed: float
@export var jump_height: float
@export var time_constant: float

@export_category("Grappling Hook")
@export var max_scale: float
@export var grappling_speed: float

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_velocity: float
var animated_sprite: AnimatedSprite2D

var grappling_hook: Node2D
var rope: Sprite2D
var hook: Area2D
var grappling: bool = false
var is_grappled: bool = false
var grapple_direction: Vector2
var grapple_position: Vector2

func _ready():
	animated_sprite = $AnimatedSprite2D
	rope = $GrapplingHook/Rope
	hook = $GrapplingHook/Hook
	grappling_hook = $GrapplingHook
	
	hook.body_entered.connect(grappled)
	
	rope.scale.x = 0
	animated_sprite.play("idle")
	jump_velocity = sqrt(2 * gravity * jump_height)

func _process(delta):
	jump()
	animate()
	grapple(delta)

func grapple(delta):
	if is_grappled:
		grapple_direction = (grapple_position - global_position).normalized()
		grappling_hook.rotation = -grapple_direction.angle_to(Vector2.UP)
	
	if not is_grappled and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		grappling = true
		grappling_hook.visible = true
		grappling_hook.rotation = get_local_mouse_position().angle() + PI / 2
		
		if rope.scale.x <= max_scale:
			rope.scale.x += grappling_speed * delta
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		grappling = false
		is_grappled = false
		grappling_hook.visible = false
		rope.scale.x = 0

func grappled(body: Node2D):
	if is_grappled or not grappling or not body.is_in_group("Environment"):
		return
	
	grapple_position = hook.get_node("HookPivot").global_position
	grapple_direction = (grapple_position - global_position).normalized()
	is_grappled = true

func jump():
	if $JumpTimer.is_stopped() and Input.is_action_just_pressed("jump"):
		$JumpTimer.start()
	
	if not $JumpTimer.is_stopped() and is_on_floor():
		velocity.y = -jump_velocity
		$JumpTimer.stop()

func animate():
	if animated_sprite.flip_h and velocity.x > 0:
		animated_sprite.flip_h = false
	elif not animated_sprite.flip_h and velocity.x < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if abs(velocity.x) > 0.1 * terminal_speed:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

func _physics_process(delta):
	move(delta)

func move(delta):
	var acceleration: Vector2 = Vector2((1 / time_constant) * (Input.get_axis("left", "right") * terminal_speed - velocity.x), gravity)
	velocity += acceleration * delta
	
	if is_grappled:
		var grapple_direction_3d: Vector3 = to_vector3(grapple_direction)
		velocity = to_vector2(grapple_direction_3d.cross(to_vector3(velocity).cross(grapple_direction_3d)))
	
	move_and_slide()

func to_vector3(vector: Vector2) -> Vector3:
	return Vector3(vector.x, vector.y, 0)

func to_vector2(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.y)
