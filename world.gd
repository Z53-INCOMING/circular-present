extends Node2D

## Number of points around the present circle. Max is 32 for godot reasons.
@export var present_resolution := 16

## Radius of the present circle, in pixels
@export var present_radius := 512.0

## Artificial multiplier to the force exerted on all bodies
@export var time_stiffness := 1.0

@export var camera_u := 0.0

@onready var color_picker := $ColorPicker

@onready var circular_present_object_scene := preload("res://circular_present_object.tscn")

var uy_flipped := false

var sharp_fade := true

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		camera_u += delta * 3.0
	if Input.is_action_pressed("ui_down"):
		camera_u -= delta * 3.0
	if Input.is_action_just_released("scroll up"):
		camera_u += TAU / 16.0
	if Input.is_action_just_released("scroll down"):
		camera_u -= TAU / 16.0
	camera_u = wrapf(camera_u, 0.0, TAU)
	
	if Input.is_action_just_pressed("toggle_color_picker"):
		color_picker.visible = !color_picker.visible
	
	if Input.is_action_just_pressed("add_circle"):
		create_shape(0)
	if Input.is_action_just_pressed("add_square"):
		create_shape(1)
	if Input.is_action_just_pressed("add_pillar"):
		create_shape(2)
	
	if Input.is_action_just_pressed("ui_accept"):
		uy_flipped = !uy_flipped
	if Input.is_action_just_pressed("toggle_sharp_fade"):
		sharp_fade = !sharp_fade

func create_shape(shape: int) -> void:
	var object := circular_present_object_scene.instantiate()
	
	object.color = color_picker.color
	object.shape = shape
	object.global_position = get_global_mouse_position()
	
	add_child(object)
