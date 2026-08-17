extends Control


func _ready() -> void:
	_set_controls_text()


func _set_controls_text() -> void:
	$PanelContainer/VBoxContainer/TitleMarginContainer/TitleLabel.text = tr("MENU_CONTROLS")
	$PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/LateralMovementRow/MarginContainer/DescriptionLabel.text = tr("CONTROLS_LATERAL_MOVEMENT")
	$PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/DownMovementRow/MarginContainer/DescriptionLabel.text = tr("CONTROLS_FAST_DOWN")
	$PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/LeftRotateMovementRow/MarginContainerLeft/LeftDescriptionLabel.text = tr("CONTROLS_ROTATE_LEFT")
	$PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/RightRotateMovementRow/MarginContainerRight/RightDescriptionLabel.text = tr("CONTROLS_ROTATE_RIGHT")
	$PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/PauseRow/MarginContainer/DescriptionLabel.text = tr("CONTROLS_PAUSE_EXIT")
	$PanelContainer/VBoxContainer/ButtonMarginContainer/BackButton.text = tr("MENU_BACK")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
