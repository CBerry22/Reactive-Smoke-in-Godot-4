extends Node3D

@export var bullet_wake_scene: PackedScene

@onready var barrel: Node3D = $Barrel

func shoot():
	var wake = bullet_wake_scene.instantiate()
