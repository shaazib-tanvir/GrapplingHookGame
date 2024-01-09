extends Area2D

@export var position_parent: Node2D

func _process(_delta):
	position = position_parent.position + Vector2(0, -position_parent.scale.x * 16)
