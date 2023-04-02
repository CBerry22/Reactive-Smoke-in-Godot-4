extends CharacterBody3D

@export var move_speed := 500.0
@export var drag := 30.0 
@export var jump_force := 10.0
@export var air_speed := 50.0
@export var air_drag := 11.0 
@export var look_sensitivity := 0.3
@export var bullet_wake_scene: PackedScene
@export var smoke_grenade: PackedScene
@export var frag_grenade: PackedScene

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/PlayerCamera
@onready var current_speed := move_speed

@onready var selected_grenade = smoke_grenade

var gravity := 20.0
var can_shoot := true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 75)
		
	if event.is_action_pressed("throw_grenade"):
		throw_grenade()
		
	if event.is_action_pressed("item_1"):
		selected_grenade = smoke_grenade
		
	if event.is_action_pressed("item_2"):
		selected_grenade = frag_grenade

func _physics_process(delta):
	if Input.is_action_pressed("fire"):
		shoot()
	
	if !is_on_floor():
		velocity.y -= gravity * delta
	
		
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_force
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if direction:
		if is_on_floor():
			velocity.x = direction.x * current_speed * delta
			velocity.z = direction.z * current_speed * delta
		else:
			velocity.x += direction.x * air_speed * delta
			velocity.z += direction.z * air_speed * delta
			var vel = Vector3(velocity.x, 0, velocity.z).limit_length(current_speed * delta)
			velocity.x = vel.x
			velocity.z = vel.z

	_add_drag(delta)
	move_and_slide()

func _add_drag(delta):
	if !is_on_floor():
		var vel = velocity.move_toward(Vector3.ZERO, air_drag * delta)
		velocity.x = vel.x
		velocity.z = vel.z
	else:
		var vel = velocity.move_toward(Vector3.ZERO, drag * delta)
		velocity.x = vel.x
		velocity.z = vel.z
		
func throw_grenade():
	var grenade = selected_grenade.instantiate()
	add_child(grenade)
	grenade.global_position = head.global_position
	grenade.apply_impulse(-head.global_transform.basis.z * 10.0)

func shoot():
	if !can_shoot: return
	can_shoot = false
	
	$AnimationPlayer.play("fire")
	
	var space_state = get_world_3d().direct_space_state
	var from = head.global_position
	var to = from + -head.global_transform.basis.z * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var hit_position: Vector3
	var result = space_state.intersect_ray(query)
	if result:
		hit_position = result.position
	else:
		hit_position = to
		
	var wake = bullet_wake_scene.instantiate()
	add_child(wake)
	wake.global_position = (from + hit_position) / 2
	wake.look_at(hit_position)
	wake.set_length(from.distance_to(hit_position))

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'fire':
		can_shoot = true
