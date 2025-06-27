extends Node2D

@onready var circular_object_scene := preload("res://circle.tscn")
@onready var circular_visual_scene := preload("res://circle_visual.tscn")

@onready var square_object_scene := preload("res://square.tscn")
@onready var square_visual_scene := preload("res://square_visual.tscn")

@export var color: Color = Color.WHITE
## 0 is a circle, 1 is a square
@export var shape := 0

var present_resolution := 1

var present_radius := INF

var time_stiffness := 1.0

var selected := -1

var uy_flipped := false

var mouse_offset := Vector2.ZERO

func _ready():
	present_resolution = get_parent().present_resolution
	present_radius = get_parent().present_radius
	time_stiffness = get_parent().time_stiffness
	
	var object_scene
	var object_visual_scene
	
	match shape:
		0:
			object_scene = circular_object_scene
			object_visual_scene = circular_visual_scene
		1:
			object_scene = square_object_scene
			object_visual_scene = square_visual_scene
	
	for i in present_resolution:
		var object: RigidBody2D = object_scene.instantiate()
		object.collision_layer = int(pow(2.0, i))
		object.collision_mask = int(pow(2.0, i))
		
		add_child(object)
	
	for i in present_resolution:
		var circular_visual: Polygon2D = object_visual_scene.instantiate()
		
		circular_visual.color = color
		
		add_child(circular_visual)

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
		
		var desired_rotation := lerp_angle(previous.rotation, next.rotation, 0.5)
		current.apply_torque_impulse(angle_difference(current.rotation, desired_rotation) * delta * time_stiffness * 216.0)
		
		# Update the polygon
		var polygon: Polygon2D = get_child(i + present_resolution)
		
		polygon.global_transform = current.global_transform
		polygon.modulate.a = pow(1.0 - absf(angle_difference((float(i) / float(present_resolution)) * TAU - PI, camera_u - PI) / PI), 2.0)
		
		if uy_flipped:
			polygon.global_position.y = (1.0 - (i / float(present_resolution - 1))) * 1440.0
			polygon.modulate.a = pow(1.0 - absf((current.global_position.y - ((camera_u / TAU) * 1440.0)) / 1440.0), 2.0)
	
	if Input.is_action_just_pressed("ui_accept"):
		uy_flipped = !uy_flipped
	
	if selected > -1:
		var closest_to_mouse = get_child(selected)
		
		closest_to_mouse.apply_central_impulse((get_global_mouse_position() - closest_to_mouse.global_position) * delta * 216.0)
		closest_to_mouse.linear_damp = 16.0
	elif selected == -2:
		for i in present_resolution:
			var object = get_child(i)
			
			object.apply_central_impulse((get_global_mouse_position() - object.global_position) * delta * 216.0)
			object.linear_damp = 16.0
	else:
		for i in present_resolution:
			var object = get_child(i)
			
			object.linear_damp = 0.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var camera_u_index := int((get_parent().camera_u / TAU) * present_resolution)
				if uy_flipped:
					camera_u_index = int((1.0 - (get_global_mouse_position().y / 1440.0)) * float(present_resolution))
					if camera_u_index >= present_resolution:
						camera_u_index = present_resolution - 1
				
				var closest_to_mouse = get_child(camera_u_index)
				
				if uy_flipped:
					if absf(get_global_mouse_position().x - closest_to_mouse.global_position.x) < 64.0:
						selected = -2 if event.button_index == MOUSE_BUTTON_LEFT else camera_u_index
						mouse_offset = get_global_mouse_position() - closest_to_mouse.global_position
				else:
					if get_global_mouse_position().distance_to(closest_to_mouse.global_position) < 64.0:
						selected = -2 if event.button_index == MOUSE_BUTTON_LEFT else camera_u_index
						mouse_offset = get_global_mouse_position() - closest_to_mouse.global_position
			else:
				selected = -1
