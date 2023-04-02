extends Node3D

@export var voxel_size := 1.0
@export var smoke_volume: PackedScene

var sphere_radius = 5
var current_layer = 0
var max_layers = sphere_radius + 1
var max_volume = 100
var volume = 0

func _ready():
	# Create the initial voxel at the center
	create_volume(Vector3.ZERO)

func _process(delta):
	if current_layer < max_layers && volume < max_volume:
		current_layer += 1
		start_build_layer(current_layer)

func start_build_layer(layer):
	for x in range(-sphere_radius, sphere_radius + 1):
		for y in range(-sphere_radius, sphere_radius + 1):
			for z in range(-sphere_radius, sphere_radius + 1):
				if round(sqrt(x * x + y * y + z * z)) == layer:
					var pos = Vector3(x, y, z)
					if is_occupied(pos):
						continue
						
					if round(sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z)) <= sphere_radius:
						create_volume(pos)
						
func create_volume(pos: Vector3):
	var v = smoke_volume.instantiate()
	add_child(v)
	v.position = pos
	volume += 1

func is_occupied(pos: Vector3) -> bool:
	var state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = global_transform * pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = state.intersect_point(query)
	if result:
		return true
	else:
		return false
