extends Node3D

func set_length(length: float):
	$BulletWakeVolume.size.y = length
	$Debug.mesh.height = length
