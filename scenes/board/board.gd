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
	spawn_piece(piece_i_scene, 0, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func spawn_piece(piece_escene: PackedScene, start_col: int, start_row: int):
	current_piece = piece_escene.instantiate()
	add_child(current_piece)
	current_piece.position = Vector2(start_col * BLOCK_SIZE, start_row * BLOCK_SIZE)
	


func _on_timer_timeout() -> void:
	move_piece_down()
	
	
	
func move_piece_down():
	current_piece.position.y += BLOCK_SIZE 
