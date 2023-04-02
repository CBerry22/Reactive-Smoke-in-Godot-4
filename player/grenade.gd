extends RigidBody3D

@export var smoke_volume: PackedScene



func _on_explode_timer_timeout():
	var smoke = smoke_volume.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	queue_free()
