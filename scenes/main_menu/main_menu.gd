extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_language()
	set_menu()	
	set_language_options()


func set_language() -> void:
	var saved_lang = load_language()
	var available_langs = TranslationServer.get_loaded_locales()
	
	if saved_lang != "" and saved_lang in available_langs:
		TranslationServer.set_locale(saved_lang)
		return
		
	var system_lang = OS.get_locale_language()
	
	if system_lang in available_langs:
		TranslationServer.set_locale(system_lang)
	else:
		TranslationServer.set_locale("en")
		
		
func set_menu() -> void:
	$MenuContainer/PlayButton.text = tr("MENU_PLAY")
	$MenuContainer/ControlsButton.text = tr("MENU_CONTROLS")
	$MenuContainer/LanguageButton.text = tr("MENU_LANGUAGE")
	$MenuContainer/ExitButton.text = tr("MENU_EXIT")


func set_language_options() -> void:
	var available_langs = TranslationServer.get_loaded_locales()
	
	for lang in available_langs:
		var translation = TranslationServer.get_translation_object(lang)
		var language_name = translation.get_message("LANG_NAME")
		
		$MenuContainer/LanguageOptionButton.add_item(language_name)
		$MenuContainer/LanguageOptionButton.set_item_metadata(
			$MenuContainer/LanguageOptionButton.item_count - 1,
			lang
		)

	set_current_lang()
	

func set_current_lang() -> void:
	var current_lang = TranslationServer.get_locale()
	
	for i in range($MenuContainer/LanguageOptionButton.item_count):
		if $MenuContainer/LanguageOptionButton.get_item_metadata(i) == current_lang:
			$MenuContainer/LanguageOptionButton.select(i)
			break
			
			
func save_language(language: String) -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "language", language)
	config.save("user://settings.cfg")


func load_language() -> String:
	var config = ConfigFile.new()
	
	if config.load("user://settings.cfg") == OK:
		return config.get_value("settings", "language", "")
	
	return ""
	
	
func _on_language_option_button_item_selected(index: int) -> void:
	var selected_lang = $MenuContainer/LanguageOptionButton.get_item_metadata(index)
	
	TranslationServer.set_locale(selected_lang)
	set_menu()
	save_language(selected_lang)
	
	$MenuContainer/LanguageOptionButton.visible = false


func _on_language_button_pressed() -> void:
	$MenuContainer/LanguageOptionButton.visible = not $MenuContainer/LanguageOptionButton.visible
