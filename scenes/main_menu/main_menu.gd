extends Control

#region Referencias a nodos
@onready var play_button: Button = $PanelContainer/MenuContainer/PlayButton
@onready var controls_button: Button = $PanelContainer/MenuContainer/ControlsButton
@onready var language_button: Button = $PanelContainer/MenuContainer/LanguageButton
@onready var screen_mode_button: Button = $PanelContainer/MenuContainer/ScreenModeButton
@onready var exit_button: Button = $PanelContainer/MenuContainer/ExitButton

@onready var language_option_button: OptionButton = $PanelContainer/MenuContainer/LanguageOptionButton
@onready var screen_mode_option_button: OptionButton = $PanelContainer/MenuContainer/ScreenModeOptionButton
#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_language()
	_set_menu()	
	_set_language_options()
	_set_current_screen_mode()
	_remove_radio_buttons()
	
	
func _set_language() -> void:
	var saved_lang = _load_language()
	var available_langs = TranslationServer.get_loaded_locales()
	
	if saved_lang != "" and saved_lang in available_langs:
		TranslationServer.set_locale(saved_lang)
		return
		
	var system_lang = OS.get_locale_language()
	
	if system_lang in available_langs:
		TranslationServer.set_locale(system_lang)
	else:
		TranslationServer.set_locale("en")
		
		
func _set_menu() -> void:
	play_button.text = tr("MENU_PLAY")
	controls_button.text = tr("MENU_CONTROLS")
	language_button.text = tr("MENU_LANGUAGE")
	screen_mode_button.text = tr("MENU_SCREEN")
	exit_button.text = tr("MENU_EXIT")

	screen_mode_option_button.set_item_text(0, tr("MENU_SCREEN_WINDOWED"))
	screen_mode_option_button.set_item_text(1, tr("MENU_SCREEN_FULL"))

func _set_language_options() -> void:
	var available_langs = TranslationServer.get_loaded_locales()
	
	for lang in available_langs:
		var translation = TranslationServer.get_translation_object(lang)
		var language_name = translation.get_message("LANG_NAME")
		
		language_option_button.add_item(language_name)
		language_option_button.set_item_metadata(
			language_option_button.item_count - 1,
			lang
		)

	_set_current_lang()
	

func _set_current_lang() -> void:
	var current_lang = TranslationServer.get_locale()
	
	for i in range(language_option_button.item_count):
		if language_option_button.get_item_metadata(i) == current_lang:
			language_option_button.select(i)
			break
			
			
func _save_language(language: String) -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("settings", "language", language)
	config.save("user://settings.cfg")


func _load_language() -> String:
	var config = ConfigFile.new()
	
	if config.load("user://settings.cfg") == OK:
		return config.get_value("settings", "language", "")
	
	return ""
	

func _set_current_screen_mode() -> void:
	var current_mode = _load_screen_mode()
	
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	screen_mode_option_button.select(
		0 if current_mode == DisplayServer.WINDOW_MODE_WINDOWED else 1
	)
	
func _save_screen_mode(mode: int) -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("settings", "screen_mode", mode)
	config.save("user://settings.cfg")


func _load_screen_mode() -> int:
	var config = ConfigFile.new()
	
	if config.load("user://settings.cfg") == OK:
		return config.get_value("settings", "screen_mode", 0)
	
	return 0
		
		
func _remove_radio_buttons() -> void:
	var language_popup = language_option_button.get_popup()
	var screen_mode_popup = screen_mode_option_button.get_popup()

	for i in range(language_popup.item_count):
		language_popup.set_item_as_radio_checkable(i, false)

	for i in range(screen_mode_popup.item_count):
		screen_mode_popup.set_item_as_radio_checkable(i, false)
		
		
func _on_language_option_button_item_selected(index: int) -> void:
	var selected_lang = language_option_button.get_item_metadata(index)
	
	TranslationServer.set_locale(selected_lang)
	_set_menu()
	_save_language(selected_lang)
	
	language_option_button.visible = false


func _on_language_button_pressed() -> void:
	language_option_button.visible = not language_option_button.visible


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/board/board.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls_menu/controls_menu.tscn")


func _on_screen_mode_button_pressed() -> void:
	screen_mode_option_button.visible = not screen_mode_option_button.visible


func _on_screen_mode_option_button_item_selected(index: int) -> void:
	var mode: int
	
	if index == 0:
		mode = DisplayServer.WINDOW_MODE_WINDOWED
	else:
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		
	DisplayServer.window_set_mode(mode)
	_save_screen_mode(mode)
