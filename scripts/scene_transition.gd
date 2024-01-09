extends CanvasLayer

func change_scene(scene: PackedScene) -> void:
	$AnimationPlayer.play_backwards("fade_out")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(scene)
	$AnimationPlayer.play("fade_out")

func reload_scene() -> void:
	$AnimationPlayer.play_backwards("fade_out")
	await $AnimationPlayer.animation_finished
	get_tree().reload_current_scene()
	$AnimationPlayer.play("fade_out")
