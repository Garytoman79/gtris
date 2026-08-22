extends Control


#region Referencias a nodos
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleMarginContainer/TitleLabel

@onready var lateral_movement_description: Label = $PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/LateralMovementRow/MarginContainer/DescriptionLabel
@onready var down_movement_description: Label = $PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/DownMovementRow/MarginContainer/DescriptionLabel
@onready var left_rotate_description: Label = $PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/LeftRotateMovementRow/MarginContainerLeft/LeftDescriptionLabel
@onready var right_rotate_description: Label = $PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/RightRotateMovementRow/MarginContainerRight/RightDescriptionLabel
@onready var pause_description: Label = $PanelContainer/VBoxContainer/RowsMarginContainer/RowsVBoxContainer/PauseRow/MarginContainer/DescriptionLabel

@onready var back_button: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/BackButton
#endregion


func _ready() -> void:
	_set_controls_text()


func _set_controls_text() -> void:
	title_label.text = tr("MENU_CONTROLS")
	lateral_movement_description.text = tr("CONTROLS_LATERAL_MOVEMENT")
	down_movement_description.text = tr("CONTROLS_FAST_DOWN")
	left_rotate_description.text = tr("CONTROLS_ROTATE_LEFT")
	right_rotate_description.text = tr("CONTROLS_ROTATE_RIGHT")
	pause_description.text = tr("CONTROLS_PAUSE_EXIT")
	back_button.text = tr("MENU_BACK")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
