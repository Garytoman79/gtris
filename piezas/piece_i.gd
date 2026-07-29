extends Node2D

signal piece_locked
var already_locked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Posición de la pieza: ", global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_piece_area_body_entered(body: Node2D) -> void:
	if already_locked:
		return
			
	already_locked = true
	piece_locked.emit()
	print("Tocó: ", body.name, " - fijando pieza")
