extends Node2D

class GridNode:
	var g_cost = 0
	var h_cost = 0
	var parent: GridNode = null
	var position: Vector2i
	var is_wall = false

	func _init(p_position: Vector2i):
		position = p_position

	func f_cost():
		return g_cost + h_cost

@export var cell_size = Vector2i(64, 64)
var grid_size
var grid = []
var start = Vector2i.ZERO
var end = Vector2i(5, 5)
var open_set = []
var closed_set = []

func _ready():
	get_tree().root.size_changed.connect(initialize_grid)
	initialize_grid()
	update_path()
	

func initialize_grid():
	grid_size = Vector2i(get_viewport_rect().size) / cell_size
	grid = []
	for x in range(grid_size.x):
		var row = []
		for y in range(grid_size.y):
			var node = GridNode.new(Vector2i(x, y))
			row.append(node)
		grid.append(row)
	update_path()

func _input(event):
	if event is InputEventMouseButton:
		# Add/remove wall
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var pos = Vector2i(event.position) / cell_size
			if pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y:
				var node = grid[pos.x][pos.y]
				node.is_wall = not node.is_wall
			update_path()
			queue_redraw()
		# Move start
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			start = Vector2i(event.position) / cell_size
			update_path()
			queue_redraw()
		# Move end
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			end = Vector2i(event.position) / cell_size
			update_path()
			queue_redraw()

func update_path():
	var path = find_path(start, end)
	var points = PackedVector2Array()
	for node in path:
		points.append(Vector2(node.position.x * cell_size.x, node.position.y * cell_size.y) + Vector2(cell_size.x, cell_size.y) / 2)

	$Line2D.points = points

func find_path(start_pos, end_pos):
	var start_node = grid[start_pos.x][start_pos.y]
	var end_node = grid[end_pos.x][end_pos.y]
	open_set.clear()
	closed_set.clear()
	open_set.append(start_node)

	while open_set.size() > 0:
		var current_node = open_set[0]
		for node in open_set:
			if node.f_cost() < current_node.f_cost() or (node.f_cost() == current_node.f_cost() and node.h_cost < current_node.h_cost):
				current_node = node

		open_set.erase(current_node)
		closed_set.append(current_node)

		if current_node == end_node:
			return retrace_path(start_node, end_node)

		for neighbor in get_neighbors(current_node):
			if neighbor.is_wall or neighbor in closed_set:
				continue

			var new_movement_cost_to_neighbor = current_node.g_cost + get_distance(current_node, neighbor)
			if neighbor not in open_set or new_movement_cost_to_neighbor < neighbor.g_cost  :
				neighbor.g_cost = new_movement_cost_to_neighbor
				neighbor.h_cost = get_distance(neighbor, end_node)
				neighbor.parent = current_node

				if neighbor not in open_set:
					open_set.append(neighbor)

	return []

func get_neighbors(node):
	var neighbors = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue

			var check_x = node.position.x + x
			var check_y = node.position.y + y

			if check_x >= 0 and check_x < grid_size.x and check_y >= 0 and check_y < grid_size.y:
				neighbors.append(grid[check_x][check_y])

	return neighbors

func get_distance(node_a, node_b):
	var dst_x = abs(node_a.position.x - node_b.position.x)
	var dst_y = abs(node_a.position.y - node_b.position.y)

	if dst_x > dst_y:
		return 14 * dst_y + 10 * (dst_x - dst_y)
	return 14 * dst_x + 10 * (dst_y - dst_x)

func retrace_path(start_node, end_node):
	var path = []
	var current_node = end_node
	while current_node != start_node:
		path.append(current_node)
		current_node = current_node.parent
	path.reverse()
	return path

func _draw():
	draw_grid()
	fill_walls()
	draw_rect(Rect2(start * cell_size, cell_size), Color.GREEN_YELLOW)
	draw_rect(Rect2(end * cell_size, cell_size), Color.ORANGE_RED)
	
func draw_grid():
	for x in grid_size.x + 1:
		draw_line(Vector2(x * cell_size.x, 0), Vector2(x * cell_size.x, grid_size.y * cell_size.y), Color.DARK_GRAY, 2.0)
	for y in grid_size.y + 1:
		draw_line(Vector2(0, y * cell_size.y), Vector2(grid_size.x * cell_size.x, y * cell_size.y), Color.DARK_GRAY, 2.0)

func fill_walls():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y].is_wall:
				draw_rect(Rect2(x * cell_size.x, y * cell_size.y, cell_size.x, cell_size.y), Color.DARK_GRAY)


