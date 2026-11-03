extends Node2D
class_name Voronoi_gen

var init_polygon :Array[Vector2]= []
var all_sites :Array[Vector2] = []
var polygon_data_for_sites :Dictionary = {}

func _ready() -> void:
	init_polygon = [
		Vector2(0,0),
		Vector2(get_viewport_rect().size.x, 0),
		Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y),
		Vector2(0, get_viewport_rect().size.y)]

	
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		all_sites.push_back(get_global_mouse_position())
		polygon_data_for_sites.clear()
		_voronoi_generator(all_sites)
		queue_redraw()
		
		
func _draw() -> void:
	for site in polygon_data_for_sites:
		var poly_lines :Array[Vector2]= polygon_data_for_sites[site].duplicate()
		poly_lines.push_back(poly_lines[0])
		var r:= randf_range(0.3, 0.8)
		var g:= randf_range(0.3, 0.8)
		var b:= randf_range(0.3, 0.8)
		draw_colored_polygon(PackedVector2Array(polygon_data_for_sites[site]), Color(r,g,b,1))
		draw_polyline(PackedVector2Array(poly_lines), Color.BLACK, 2.0, true)
		draw_circle(site, 5.0, Color.BLACK, 1)


func _get_bisector(a :Vector2, b :Vector2) -> Array[float]:
	var A :float = 2*(b.x - a.x)
	var B :float = 2*(b.y - a.y)
	var C :float = b.x*b.x - a.x*a.x + b.y*b.y - a.y*a.y
	return [A, B, C]


func _is_inside(p :Vector2, bound :Array[float]) -> bool:
	if p.x*bound[0] + p.y*bound[1] <= bound[2]:
		return true
	else:
		return false

func _get_intersection(s :Vector2, e :Vector2, bound :Array[float]):
	var numenator :float = bound[2] - bound[0]*s.x - bound[1]*s.y
	var denomenator :float = bound[0]*(e.x-s.x) + bound[1]*(e.y-s.y)
	var t :float = numenator/denomenator
	return Vector2(s.x + (t*(e.x-s.x)),s.y + (t*(e.y-s.y)))
	

func _clip_polygon(bisector :Array[float], polygon :Array[Vector2]) -> Array[Vector2]:
	var new_polygon :Array[Vector2]= []
	for i in range(0, polygon.size()):
		var cases :Array[bool]= [_is_inside(polygon[i], bisector), _is_inside(polygon[(i+1)%polygon.size()], bisector)]
		if cases == [true, true]:
			new_polygon.push_back(polygon[(i+1)%polygon.size()])
		elif cases == [true, false]:
			new_polygon.push_back(_get_intersection(polygon[i], polygon[(i+1)%polygon.size()], bisector))
		elif cases == [false, true]:
			new_polygon.push_back(_get_intersection(polygon[i], polygon[(i+1)%polygon.size()], bisector))
			new_polygon.push_back(polygon[(i+1)%polygon.size()])
		else:
			continue	
	return new_polygon
	
	
func _voronoi_generator(sites :Array[Vector2]):
	for a in sites:
		var poly_of_a :Array[Vector2]= init_polygon
		for b in sites:
			if b != a:
				var boundary :Array[float]= _get_bisector(a, b)
				poly_of_a = _clip_polygon(boundary, poly_of_a)
			polygon_data_for_sites[a] = poly_of_a
