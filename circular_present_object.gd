extends Node2D

@onready var circular_object_scene := preload("res://circle.tscn")

func _ready():
	var resolution: int = get_parent().present_resolution
	
	for i in resolution:
		var circular_object: RigidBody2D = circular_object_scene.instantiate()
		circular_object.collision_layer = int(pow(2.0, i))
		circular_object.collision_mask = int(pow(2.0, i))
		
		add_child(circular_object)
		#circular_object.position = Vector2.ZERO
