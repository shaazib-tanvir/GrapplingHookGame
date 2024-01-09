extends Area2D

@export var next_level: PackedScene

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SceneTransition.change_scene(next_level)
