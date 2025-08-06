@tool
extends Control

const threedENV = preload("res://addons/hackpal/hackpad_3d_env.tscn")

func _ready() -> void:
	$HackyViewport.add_child(threedENV.instantiate())
	$HackyTextureReck.texture = $HackyViewport.get_texture()

	
func _on_texture_rect_resized() -> void:
	$HackyViewport.size = $HackyTextureReck.size

func _process(delta: float) -> void:
	$HackyTextureReck.texture = $HackyViewport.get_texture()
