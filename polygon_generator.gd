@tool
extends Polygon2D

@export var radius := 64.0

@export_range(3, 256) var side_count := 3

func _process(delta):
	var poly = PackedVector2Array()
	
	var angle := 0.0
	for i in side_count:
		poly.append(Vector2.from_angle(angle) * radius)
		
		angle += TAU / side_count
	
	polygon = poly
