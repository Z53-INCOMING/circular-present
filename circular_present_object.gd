extends Node2D

@onready var circular_object_scene := preload("res://circle.tscn")

@export var color: Color = Color.WHITE

var present_resolution := 1

var present_radius := INF

var time_stiffness := 1.0

var selected := -1

func _ready():
	present_resolution = get_parent().present_resolution
	present_radius = get_parent().present_radius
	time_stiffness = get_parent().time_stiffness
	
	for i in present_resolution:
		var circular_object: RigidBody2D = circular_object_scene.instantiate()
		circular_object.collision_layer = int(pow(2.0, i))
		circular_object.collision_mask = int(pow(2.0, i))
		
		circular_object.color = color
		
		add_child(circular_object)

func _process(delta):
	var camera_u: float = get_parent().camera_u
	
	var distance_between_present_objects := (present_radius * TAU) / present_resolution
	
	for i in present_resolution:
		# Index and getting stuff
		var previous_index := present_resolution - 1 if i == 0 else i - 1
		var next_index := 0 if i == present_resolution - 1 else i + 1
		
		var previous: RigidBody2D = get_child(previous_index)
		var next: RigidBody2D = get_child(next_index)
		var current: RigidBody2D = get_child(i)
		
		# Calculate the distance in S1xE2
		var previous_distance := Vector3(previous.global_position.x, previous.global_position.y, 0.0).distance_to(
			Vector3(current.global_position.x, current.global_position.y, distance_between_present_objects)
		)
		
		var next_distance := Vector3(next.global_position.x, next.global_position.y, 0.0).distance_to(
			Vector3(current.global_position.x, current.global_position.y, distance_between_present_objects)
		)
		
		# Subtract the distance from the desired distance and get the normalized vector pointing from the current object towards the target
		# This is how springs work I think
		var previous_force := (previous.global_position - current.global_position).normalized() * (previous_distance - distance_between_present_objects)
		var next_force := (next.global_position - current.global_position).normalized() * (next_distance - distance_between_present_objects)
		
		current.apply_central_impulse((previous_force + next_force) * 0.5 * delta * time_stiffness)
		
		# Fade out the object if it's far away on the u axis
		current.modulate.a = pow(1.0 - absf(angle_difference((float(i) / float(present_resolution)) * TAU - PI, camera_u - PI) / PI), 2.0)
	
	if selected != -1:
		var closest_to_mouse = get_child(selected)
		
		closest_to_mouse.apply_central_impulse((get_global_mouse_position() - closest_to_mouse.global_position) * 0.5)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var camera_u_index := int((get_parent().camera_u / TAU) * present_resolution)
				var closest_to_mouse = get_child(camera_u_index)
				
				if get_global_mouse_position().distance_to(closest_to_mouse.global_position) < 64.0:
					selected = camera_u_index
			else:
				selected = -1
