extends Control

@onready var main = $"../../../"
@onready var btnResumir = $MarginContainer/CenterContainer/VBoxContainer/btnResumir
@onready var btnSair = $MarginContainer/CenterContainer/VBoxContainer/btnSair

func _process(_delta):
	if (!btnResumir.has_focus() && !btnSair.has_focus()):
		btnResumir.grab_focus()

func _on_btn_resumir_pressed() -> void:
	main.handle_pause_menu()

func _on_btn_sair_pressed() -> void:
	main.handle_pause_menu()
	main.handle_back_to_menu()
