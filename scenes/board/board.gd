class_name Board

extends Node2D

const BLOCK_SIZE = 32
const COLUMNS = 10
const ROWS = 20
const NORMAL_SPEED = 0.5
const DROP_SPEED = 0.05

var grid = []
var current_piece = null
var gravity_time := 0.0

var pieces = [
		preload("res://piezas/piece_i.tscn"),
		preload("res://piezas/piece_j.tscn"),
		preload("res://piezas/piece_l.tscn"),
		preload("res://piezas/piece_o.tscn"),
		preload("res://piezas/piece_s.tscn"),
		preload("res://piezas/piece_t.tscn"),
		preload("res://piezas/piece_z.tscn")
	]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for y in range(ROWS):
		var row = []
		for x in range(COLUMNS):
			row.append(null) # null = celda vacia
		grid.append(row)
		
	
	spawn_piece(5, 0)
	
	print(grid.size())

	for row in grid:
		print(row.size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		if can_move_horizontal(-1):
			current_piece.position.x -= BLOCK_SIZE

	if Input.is_action_just_pressed("move_right"):
		if can_move_horizontal(1):
			current_piece.position.x += BLOCK_SIZE
			
	if Input.is_action_just_pressed("rotate"):
		rotate_piece()
		
		
func _physics_process(delta: float) -> void:
	gravity_time += delta

	var interval = NORMAL_SPEED

	if Input.is_action_pressed("move_down"):
		interval = DROP_SPEED

	if gravity_time >= interval:
		gravity_time = 0.0
		move_piece_down()
	
	
func spawn_piece(start_col: int, start_row: int):
	current_piece = pieces.pick_random().instantiate()
	add_child(current_piece)
	current_piece.position = Vector2(start_col * BLOCK_SIZE, start_row * BLOCK_SIZE)
	
	gravity_time = 0.0
	
	
func move_piece_down():
	if can_move_down():
		current_piece.position.y += BLOCK_SIZE 
	else:
		lock_piece()
	
	
func rotate_piece():
	var canvas_group = current_piece.get_node("CanvasGroup")
	var pivot = current_piece.get_node("Pivot").position
	var new_positions = []
	
	for block in canvas_group.get_children():
		var rel_x = (block.position.x - pivot.x) / BLOCK_SIZE
		var rel_y = (block.position.y - pivot.y) / BLOCK_SIZE
		var new_rel_x = -rel_y
		var new_rel_y = rel_x
		var new_pos = pivot + Vector2(new_rel_x * BLOCK_SIZE, new_rel_y * BLOCK_SIZE)
		
		new_positions.append(new_pos)
		
	if can_rotate(new_positions):
		var blocks = canvas_group.get_children()
		for i in range(blocks.size()):
			blocks[i].position = new_positions[i]
	
	
func lock_piece():
	register_piece_in_grid(current_piece)
	clear_completed_lines()
	call_deferred("spawn_next_piece")
	
	
func register_piece_in_grid(piece: Node2D):
	for block in piece.get_node("CanvasGroup").get_children():
		var cell = get_grid_cell(block)
		
		# grid[cell.y][cell.x] = true
		grid[cell.y][cell.x] = block
		
		
func spawn_next_piece():
	spawn_piece(5, 0)
	
	
func can_move_down() -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = get_grid_cell(block)
		var next_row = cell.y + 1
		
		if next_row >= ROWS:
			return false
		
		if grid[next_row][cell.x] != null:
			return false
	
	return true
	
	
# direction define hacia que lado se comprueba. izq: -1; dcha: 1
func can_move_horizontal(direction: int) -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = get_grid_cell(block)
		var next_col = cell.x + direction
		
		if next_col < 0 or next_col >= COLUMNS:
			return false
			
		if grid[cell.y][next_col] != null:
			return false
	return true
	
	
func can_rotate(new_positions: Array) -> bool:
	for pos in new_positions:
		var world_pos = current_piece.position + pos
		var col = int(world_pos.x / BLOCK_SIZE)
		var row = int(world_pos.y / BLOCK_SIZE)
		
		if col < 0 or col >= COLUMNS or row < 0 or row >= ROWS:
			return false
		
		if grid[row][col] != null:
			return false
	
	return true
	
	
func get_grid_cell(block: Node2D) -> Vector2:
	var world_pos = block.global_position - global_position
	var col = int(world_pos.x / BLOCK_SIZE)
	var row = int(world_pos.y / BLOCK_SIZE)
	return Vector2i(col, row)
	
	
func is_row_complete(row: int) -> bool:
	for col in range(COLUMNS):
		if grid[row][col] == null:
			return false
			
	return true
	
	
func clear_completed_lines():
	var row = ROWS - 1

	while row >= 0:
		if is_row_complete(row):
			remove_row(row)
			move_rows_down(row)
			# No decrementamos row.
			# Queremos volver a comprobar la misma fila,
			# porque acaba de caer otra encima.
		else:
			row -= 1
			
			
func remove_row(row: int):
	for col in range(COLUMNS):
		grid[row][col].queue_free()
		grid[row][col] = null
		
		
func move_rows_down(from_row: int):
	for row in range(from_row, 0, -1):
		for col in range(COLUMNS):
			grid[row][col] = grid[row - 1][col]

			if grid[row][col] != null:
				grid[row][col].position.y += BLOCK_SIZE

			grid[row - 1][col] = null
