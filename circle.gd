extends RigidBody2D

var color := Color.WHITE

func _ready():
	$Visual.color = color
