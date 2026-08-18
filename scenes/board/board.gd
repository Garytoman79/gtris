class_name Board

extends Node2D

#region Constantes y configuración
const BLOCK_SIZE = 32
const COLUMNS = 10
const ROWS = 20
const DROP_SPEED = 0.05
const LINES_PER_LEVEL = 10
const SPEED_DECREASE_PER_LEVEL = 0.02 	# cuánto se reduce el intervalo por nivel
const MIN_SPEED = 0.1 					# velocidad máxima (no bajar de este intervalo)
const DAS_DELAY = 0.25      			# tiempo antes de empezar a repetir
const DAS_SPEED = 0.1     				# velocidad de repetición una vez arrancado
const HUD_WIDTH = 190
const LAYOUT_GAP = 32
#endregion


#region Variables de estado
var grid: Array = []
var current_piece: Node2D = null
var next_piece_scene: PackedScene = null
var gravity_time := 0.0
var lines_cleared := 0
var level := 1
var das_timer := 0.0
var das_direction := 0     # -1 izquierda, 1 derecha, 0 sin dirección activa
var das_active := false    # si ya está en fase de repetición rápida
var drop_locked := false
var is_game_over := false
var is_new_record := false
#endregion


#region Piezas disponibles
var pieces: Array[PackedScene] = [
		preload("res://piezas/piece_i.tscn"),
		preload("res://piezas/piece_j.tscn"),
		preload("res://piezas/piece_l.tscn"),
		preload("res://piezas/piece_o.tscn"),
		preload("res://piezas/piece_s.tscn"),
		preload("res://piezas/piece_t.tscn"),
		preload("res://piezas/piece_z.tscn")
	]
#endregion


#region Ciclo de vida de Godot
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_center_playfield)
	_center_playfield()
	$GameLayout/HUD/GameOverPanel.visible = false
	_set_ui()
	_prepare_pause_dialog()
	
	for y in range(ROWS):
		var row = []
		for x in range(COLUMNS):
			row.append(null) # null = celda vacia
		grid.append(row)
		
	next_piece_scene = pieces.pick_random()
	
	_update_next_piece_preview()
	_spawn_piece(5, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_horizontal_input(delta)
	
	if Input.is_action_just_pressed("rotate_right"):
		if _rotate_piece_right():
			$RotateRightSound.play()
	if Input.is_action_just_pressed("rotate_left"):
		if _rotate_piece_left():
			$RotateLeftSound.play()
		
		
func _physics_process(delta: float) -> void:
	gravity_time += delta
	
	if drop_locked and not Input.is_action_pressed("move_down"):
		drop_locked = false

	var interval = _get_current_speed()

	if Input.is_action_pressed("move_down") and not drop_locked:
		interval = DROP_SPEED

	if gravity_time >= interval:
		gravity_time = 0.0
		_move_piece_down()
		
		
# Pausa y dialogo para Salir/Continuar
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$QuitConfirmationDialog.popup_centered()
		get_tree().paused = true
		
		
func _prepare_pause_dialog() -> void:
	$QuitConfirmationDialog.dialog_text = tr("QUIT_CONFIRM_TEXT")
	$QuitConfirmationDialog.get_ok_button().text = tr("QUIT_CONFIRM_EXIT")
	$QuitConfirmationDialog.get_cancel_button().text = tr("QUIT_CONFIRM_CONTINUE")
	
	
func _set_ui() -> void:
	$GameLayout/HUD/LevelTextLabel/LevelLabel.text = tr("BOARD_LEVEL")
	$GameLayout/HUD/LinesTextLabel/LinesLabel.text = tr("BOARD_LINES")
	$GameLayout/HUD/NextTitle.text = tr("BOARD_NEXT")
	
	$GameLayout/HUD/RecordPanel/RecordSection/RecordLabel.text = tr("BOARD_RECORD")
	$GameLayout/HUD/RecordPanel/RecordSection/RecordPlayerLabel.text = HighScoreManager.record_player
	$GameLayout/HUD/RecordPanel/RecordSection/RecordLinesLabel.text = str(HighScoreManager.record_lines) + " " + tr("BOARD_LINES")
	
	$GameLayout/HUD/GameOverPanel/GameOverVBox/GameOverLabel.text = tr("GAME_OVER_TITLE")
	$GameLayout/HUD/GameOverPanel/GameOverVBox/NewRecordLabel.text = tr("GAME_OVER_NEW_RECORD")
	$GameLayout/HUD/GameOverPanel/GameOverVBox/RecordLinesLabel.text = tr("BOARD_LINES")
	$GameLayout/HUD/GameOverPanel/GameOverVBox/GameOverActionButton.text = tr("GAME_OVER_BACK_MENU")
	$GameLayout/HUD/GameOverPanel/GameOverVBox/PlayerNameLineEdit.placeholder_text = tr("GAME_OVER_PLAYER_NAME")
#endregion


#region Spawn de piezas
func _spawn_piece(start_col: int, start_row: int):
	var scene_to_spawn = next_piece_scene
	
	current_piece = scene_to_spawn.instantiate()
	$GameLayout/Playfield.add_child(current_piece)
	current_piece.position = Vector2(start_col * BLOCK_SIZE, start_row * BLOCK_SIZE)
	
	if _is_spawn_blocked():
		_trigger_game_over()
		return
	
	gravity_time = 0.0
	
	# Si la tecla de bajada ya estaba pulsada al aparecer la pieza, la bloqueamos
	# hasta que el jugador la suelte, para que no herede la caída rápida.
	drop_locked = Input.is_action_pressed("move_down")
	
	next_piece_scene = pieces.pick_random()
	_update_next_piece_preview()
	
	
func _spawn_next_piece():
	_spawn_piece(5, 0)


func _update_next_piece_preview() -> void:
	for child in $GameLayout/HUD/NextPiecePreview.get_children():
		child.queue_free()
		
	var preview_instance = next_piece_scene.instantiate()
	$GameLayout/HUD/NextPiecePreview.add_child(preview_instance)
	_center_preview_piece(preview_instance)
	
	
func _center_preview_piece(piece: Node2D) -> void:
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF

	for child in piece.get_node("CanvasGroup").get_children():
		var block := child as Node2D
		var block_position := piece.to_local(block.global_position)

		min_x = minf(min_x, block_position.x)
		min_y = minf(min_y, block_position.y)
		max_x = maxf(max_x, block_position.x + BLOCK_SIZE)
		max_y = maxf(max_y, block_position.y + BLOCK_SIZE)

	var piece_center := Vector2(
		(min_x + max_x) / 2.0,
		(min_y + max_y) / 2.0
	)

	piece.position = -piece_center
#endregion


#region Movimiento y caída
func _move_piece_down():
	if _can_move_down():
		current_piece.position.y += BLOCK_SIZE 
		return
		
	_lock_piece()
	
	
func _lock_piece():
	_register_piece_in_grid(current_piece)
	$LandSound.play()
	_clear_completed_lines()
	call_deferred("_spawn_next_piece")


func _get_current_speed() -> float:
	var speed = 0.5 - (level - 1) * SPEED_DECREASE_PER_LEVEL
	
	return max(speed, MIN_SPEED)
#endregion


#region Movimiento lateral (DAS)
func _handle_horizontal_input(delta: float) -> void:
	var direction = 0
	
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	if direction == 0:
		das_timer = 0.0
		das_active = false
		das_direction = 0
		return
		
	if direction != das_direction:
		# Cambio de dirección o primera pulsación: mover una vez ya
		das_direction = direction
		das_timer = 0.0
		das_active = false
		_try_move_horizontal(direction)
		return
		
	das_timer += delta
	
	if not das_active:
		if das_timer >= DAS_DELAY:
			das_active = true
			das_timer = 0.0
			_try_move_horizontal(direction)
	else:
		if das_timer >= DAS_SPEED:
			das_timer = 0.0
			_try_move_horizontal(direction)
	
	
func _try_move_horizontal(direction: int) -> void:
	if _can_move_horizontal(direction):
		current_piece.position.x += direction * BLOCK_SIZE
#endregion


#region Rotación
func _rotate_piece_right() -> bool:
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
		
	if _can_rotate(new_positions):
		var blocks = canvas_group.get_children()
		for i in range(blocks.size()):
			blocks[i].position = new_positions[i]
		
		return true
			
	return false
	
			
func _rotate_piece_left() -> bool:
	var canvas_group = current_piece.get_node("CanvasGroup")
	var pivot = current_piece.get_node("Pivot").position
	var new_positions = []
	
	for block in canvas_group.get_children():
		var rel_x = (block.position.x - pivot.x) / BLOCK_SIZE
		var rel_y = (block.position.y - pivot.y) / BLOCK_SIZE
		var new_rel_x = -rel_y
		var new_rel_y = rel_x
		var new_pos = pivot - Vector2(new_rel_x * BLOCK_SIZE, new_rel_y * BLOCK_SIZE)
		
		new_positions.append(new_pos)
		
	if _can_rotate(new_positions):
		var blocks = canvas_group.get_children()
		for i in range(blocks.size()):
			blocks[i].position = new_positions[i]
			
		return true
		
	return false


func _can_rotate(new_positions: Array) -> bool:
	var canvas_group = current_piece.get_node("CanvasGroup")

	for pos in new_positions:
		# Posición futura del bloque, expresada dentro de Playfield.
		var position_in_playfield = (
			current_piece.position
			+ canvas_group.position
			+ pos
		)

		# floori() conserva correctamente los negativos:
		# -0.5 pasa a -1, no a 0.
		var col = floori(position_in_playfield.x / BLOCK_SIZE)
		var row = floori(position_in_playfield.y / BLOCK_SIZE)

		if col < 0 or col >= COLUMNS or row < 0 or row >= ROWS:
			return false

		if grid[row][col] != null:
			return false

	return true
#endregion


#region Grid y colisiones
func _register_piece_in_grid(piece: Node2D):
	for block in piece.get_node("CanvasGroup").get_children():
		var cell = _get_grid_cell(block)
		
		grid[cell.y][cell.x] = block
	
	
func _can_move_down() -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = _get_grid_cell(block)
		var next_row = cell.y + 1
		
		if next_row >= ROWS:
			return false
		
		if grid[next_row][cell.x] != null:
			return false
	
	return true
	
	
# direction define hacia que lado se comprueba. izq: -1; dcha: 1
func _can_move_horizontal(direction: int) -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = _get_grid_cell(block)
		var next_col = cell.x + direction
		
		if next_col < 0 or next_col >= COLUMNS:
			return false
			
		if grid[cell.y][next_col] != null:
			return false
	return true
	
	
func _get_grid_cell(block: Node2D) -> Vector2i:
	var world_pos = block.global_position - $GameLayout/Playfield.global_position
	var col = floori(world_pos.x / BLOCK_SIZE)
	var row = floori(world_pos.y / BLOCK_SIZE)
	return Vector2i(col, row)
	
	
func _center_playfield() -> void:
	var viewport_size = get_viewport_rect().size
	var board_width = COLUMNS * BLOCK_SIZE
	var board_height = ROWS * BLOCK_SIZE
	var layout_width = HUD_WIDTH + LAYOUT_GAP + board_width
	var game_over_panel = $GameLayout/HUD/GameOverPanel
	
	$TextureRect.position = Vector2.ZERO
	$TextureRect.size = viewport_size
	
	$GameLayout.position = Vector2(
		(viewport_size.x - layout_width) / 2.0,
		(viewport_size.y - board_height) / 2.0
	)

	$GameLayout/Playfield.position = Vector2(HUD_WIDTH + LAYOUT_GAP, 0)
	
	game_over_panel.position = Vector2(
		(board_width - game_over_panel.size.x) / 2.0 + 100 + LAYOUT_GAP, # Esto es un apaño 'a ojo' pero parece que funciona
		(board_height - game_over_panel.size.y) / 2.0
	)
#endregion


#region Líneas completas y nivel
func _is_row_complete(row: int) -> bool:
	for col in range(COLUMNS):
		if grid[row][col] == null:
			return false
			
	return true
	
	
func _clear_completed_lines():
	var row = ROWS - 1
	var cleared_this_turn = 0

	while row >= 0:
		if _is_row_complete(row):
			_remove_row(row)
			_move_rows_down(row)
			
			cleared_this_turn += 1
			# No decrementamos row.
			# Queremos volver a comprobar la misma fila,
			# porque acaba de caer otra encima.
		else:
			row -= 1
			
	if cleared_this_turn > 0:
		_update_lines_and_level(cleared_this_turn)
		if cleared_this_turn < 4:
			$LineClearSound.play()
		else:
			$TetrisSound.play()
	
	
func _remove_row(row: int):
	for col in range(COLUMNS):
		grid[row][col].queue_free()
		grid[row][col] = null
		
		
func _move_rows_down(from_row: int):
	for row in range(from_row, 0, -1):
		for col in range(COLUMNS):
			grid[row][col] = grid[row - 1][col]

			if grid[row][col] != null:
				grid[row][col].position.y += BLOCK_SIZE

			grid[row - 1][col] = null


func _update_lines_and_level(new_lines: int) -> void:
	lines_cleared += new_lines
	$GameLayout/HUD/LinesTextLabel/LinesValue.text = str(lines_cleared)
	
	@warning_ignore("integer_division")
	var new_level = 1 + (lines_cleared / LINES_PER_LEVEL)
	
	if new_level != level:
		level = new_level
		$GameLayout/HUD/LevelTextLabel/LevelValue.text = str(level)
		$LevelUpSound.play()
#endregion


#region Game Over
func _is_spawn_blocked() -> bool:
	for block in current_piece.get_node("CanvasGroup").get_children():
		var cell = _get_grid_cell(block)
		if grid[cell.y][cell.x] != null:
			return true
	return false
	
	
func _trigger_game_over() -> void:
	is_game_over = true
	
	set_process(false)
	set_physics_process(false)
	
	var game_over_panel = $GameLayout/HUD/GameOverPanel
	var game_over_label = $GameLayout/HUD/GameOverPanel/GameOverVBox/GameOverLabel
	var new_record_label = $GameLayout/HUD/GameOverPanel/GameOverVBox/NewRecordLabel
	var record_lines_label = $GameLayout/HUD/GameOverPanel/GameOverVBox/RecordLinesLabel
	var player_name_line_edit = $GameLayout/HUD/GameOverPanel/GameOverVBox/PlayerNameLineEdit
	var action_button = $GameLayout/HUD/GameOverPanel/GameOverVBox/GameOverActionButton
	
	is_new_record = lines_cleared > HighScoreManager.record_lines
	
	if is_new_record:
		new_record_label.visible = true
		record_lines_label.visible = true
		player_name_line_edit.visible = true
		
		record_lines_label.text = tr("BOARD_LINES") + ": " + str(lines_cleared)
		action_button.text = tr("GAME_OVER_SAVE_RECORD")
	else:
		new_record_label.visible = false
		record_lines_label.visible = false
		player_name_line_edit.visible = false
		
		action_button.text = tr("GAME_OVER_BACK_MENU")
	
	game_over_panel.visible = true
	_center_playfield()
	
	$GameOverSound.play()
	$BackgroundMusic.stop()
#endregion


func _on_quit_confirmation_dialog_canceled() -> void:
	get_tree().paused = false


func _on_quit_confirmation_dialog_confirmed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_game_over_action_button_pressed() -> void:
	if is_new_record:
		var player_name = $GameLayout/HUD/GameOverPanel/GameOverVBox/PlayerNameLineEdit.text.strip_edges()
		
		if player_name.is_empty():
			return
		
		HighScoreManager.save_record(player_name, lines_cleared)
	
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
