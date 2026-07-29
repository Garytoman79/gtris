class_name Board

extends Node2D

const BLOCK_SIZE = 32
const COLUMNS = 10
const ROWS = 20

var grid = []
var current_piece = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for y in range(ROWS):
		var row = []
		for x in range(COLUMNS):
			row.append(null) # null = celda vacia
		grid.append(row)
		
	var piece_i_scene = preload("res://piezas/piece_i.tscn")
	spawn_piece(piece_i_scene, 5, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func spawn_piece(piece_escene: PackedScene, start_col: int, start_row: int):
	current_piece = piece_escene.instantiate()
	add_child(current_piece)
	current_piece.position = Vector2(start_col * BLOCK_SIZE, start_row * BLOCK_SIZE)
	current_piece.piece_locked.connect(_on_piece_locked)
	
	
	
func _on_piece_locked():
	$Timer.stop()
	register_piece_in_grid(current_piece)
	call_deferred("spawn_next_piece")



func _on_timer_timeout() -> void:
	move_piece_down()
	
	
	
func move_piece_down():
	if can_move_down():
		current_piece.position.y += BLOCK_SIZE 
	
	
	
func register_piece_in_grid(piece: Node2D):
	for block in piece.get_node("CanvasGroup").get_children():
		var cell = get_grid_cell(block)
		
		grid[cell.y][cell.x] = true
		
		
		
func spawn_next_piece():
	var piece_i_scene = preload("res://piezas/piece_i.tscn")
	
	spawn_piece(piece_i_scene, 5, 0)
	$Timer.start()
	
	
	
func can_move_down() -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = get_grid_cell(block)
		var next_row = cell.y + 1
		
		if next_row >= ROWS:
			return false
		
		if grid[next_row][cell.x] != null:
			return false
	
	return true
	
	
func get_grid_cell(block: Node2D) -> Vector2:
	var world_pos = block.global_position - global_position
	var col = int(world_pos.x / BLOCK_SIZE)
	var row = int(world_pos.y / BLOCK_SIZE)
	return Vector2i(col, row)
