extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_language()
	_set_menu()	
	_set_language_options()
	
	
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
	$PanelContainer/MenuContainer/PlayButton.text = tr("MENU_PLAY")
	$PanelContainer/MenuContainer/ControlsButton.text = tr("MENU_CONTROLS")
	$PanelContainer/MenuContainer/LanguageButton.text = tr("MENU_LANGUAGE")
	$PanelContainer/MenuContainer/ExitButton.text = tr("MENU_EXIT")


func _set_language_options() -> void:
	var available_langs = TranslationServer.get_loaded_locales()
	
	for lang in available_langs:
		var translation = TranslationServer.get_translation_object(lang)
		var language_name = translation.get_message("LANG_NAME")
		
		$PanelContainer/MenuContainer/LanguageOptionButton.add_item(language_name)
		$PanelContainer/MenuContainer/LanguageOptionButton.set_item_metadata(
			$PanelContainer/MenuContainer/LanguageOptionButton.item_count - 1,
			lang
		)

	_set_current_lang()
	

func _set_current_lang() -> void:
	var current_lang = TranslationServer.get_locale()
	
	for i in range($PanelContainer/MenuContainer/LanguageOptionButton.item_count):
		if $PanelContainer/MenuContainer/LanguageOptionButton.get_item_metadata(i) == current_lang:
			$PanelContainer/MenuContainer/LanguageOptionButton.select(i)
			break
			
			
func _save_language(language: String) -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "language", language)
	config.save("user://settings.cfg")


func _load_language() -> String:
	var config = ConfigFile.new()
	
	if config.load("user://settings.cfg") == OK:
		return config.get_value("settings", "language", "")
	
	return ""
		
		
func _on_language_option_button_item_selected(index: int) -> void:
	var selected_lang = $PanelContainer/MenuContainer/LanguageOptionButton.get_item_metadata(index)
	
	TranslationServer.set_locale(selected_lang)
	_set_menu()
	_save_language(selected_lang)
	
	$PanelContainer/MenuContainer/LanguageOptionButton.visible = false


func _on_language_button_pressed() -> void:
	$PanelContainer/MenuContainer/LanguageOptionButton.visible = not $PanelContainer/MenuContainer/LanguageOptionButton.visible


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/board/board.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls_menu/controls_menu.tscn")
