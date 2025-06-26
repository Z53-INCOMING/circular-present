extends Node2D

## Number of points around the present circle. Max is 32 for godot reasons.
@export var present_resolution := 16

## Radius of the present circle, in pixels
@export var present_radius := 512.0

## Artificial multiplier to the force exerted on all bodies
@export var time_stiffness := 1.0

@export var camera_u := 0.0

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		camera_u += delta * 3.0
	if Input.is_action_pressed("ui_down"):
		camera_u -= delta * 3.0
	camera_u = wrapf(camera_u, 0.0, TAU)
