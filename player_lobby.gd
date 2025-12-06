extends CanvasLayer

@export var laps: int = 3 # Min 3

@onready var player_1_button = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player1Button
@onready var player_1_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player1Button/SpriteJogador1
@onready var player_2_button = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player2Button
@onready var player_2_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player2Button/SpriteJogador2
@onready var player_3_button = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player3Button
@onready var player_3_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player3Button/SpriteJogador3
@onready var player_4_button = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player4Button
@onready var player_4_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player4Button/SpriteJogador4

@onready var pressioneParaCriar = "res://Sprites/Titles/pressione_para_criar_title.png"


@onready var lobby_container = $PlayersMarginContainer
@onready var sprites_container = $SpritesMarginContainer
@onready var controls_container = $ControlsMarginContainer
@onready var name_container = $NameCenterContainer

@onready var background = $Background
@onready var black_background = $BlackBackground
@onready var back_button = $BackButton
@onready var start_button = $PlayersMarginContainer/PlayerLobby/VBoxContainer/CenterContainer/StartButton
@onready var ok_button = $NameCenterContainer/VBoxContainer/CenterContainer3/OkButton


@onready var game_scene = preload("res://caverna_deserto.tscn")
@onready var game

@onready var player_selecting = 0
@onready var players_on_lobby = 0
@onready var player_sprite_num = [0,0,0,0]
@onready var player_sprite_setup = ["","","",""]

@onready var player_active = [false,false,false,false]
@onready var player_names = ["","","",""]

@onready var sprites := {
	"1": {
		sprite_path = "res://Sprites/Chars/Char1-1-Icon.png",
		player_sprite_setup = "1-1",
	},
	"2": {
		sprite_path = "res://Sprites/Chars/Char1-2-Icon.png",
		player_sprite_setup = "1-2",
	},
	"3": {
		sprite_path = "res://Sprites/Chars/Char1-3-Icon.png",
		player_sprite_setup = "1-3",
	},
	"4": {
		sprite_path = "res://Sprites/Chars/Char1-4-Icon.png",
		player_sprite_setup = "1-4",
	},
	"5": {
		sprite_path = "res://Sprites/Chars/Char2-1-Icon.png",
		player_sprite_setup = "2-1",
	},
	"6": {
		sprite_path = "res://Sprites/Chars/Char2-2-Icon.png",
		player_sprite_setup = "2-2",
	},
	"7": {
		sprite_path = "res://Sprites/Chars/Char2-3-Icon.png",
		player_sprite_setup = "2-3",
	},
	"8": {
		sprite_path = "res://Sprites/Chars/Char2-4-Icon.png",
		player_sprite_setup = "2-4",
	},
	"9": {
		sprite_path = "res://Sprites/Chars/Char3-1-Icon.png",
		player_sprite_setup = "3-1",
	},
	"10": {
		sprite_path = "res://Sprites/Chars/Char3-2-Icon.png",
		player_sprite_setup = "3-2",
	},
	"11": {
		sprite_path = "res://Sprites/Chars/Char3-3-Icon.png",
		player_sprite_setup = "3-3",
	},
	"12": {
		sprite_path = "res://Sprites/Chars/Char3-4-Icon.png",
		player_sprite_setup = "3-4",
	},
	"13": {
		sprite_path = "res://Sprites/Chars/Char4-1-Icon.png",
		player_sprite_setup = "4-1",
	},
	"14": {
		sprite_path = "res://Sprites/Chars/Char4-2-Icon.png",
		player_sprite_setup = "4-2",
	},
	"15": {
		sprite_path = "res://Sprites/Chars/Char4-3-Icon.png",
		player_sprite_setup = "4-3",
	},
	"16": {
		sprite_path = "res://Sprites/Chars/Char4-4-Icon.png",
		player_sprite_setup = "4-4",
	}
}

func _ready():	
	game = game_scene.instantiate()
	background.show()
	
	lobby_menu()
	hide_buttons()

func _process(_delta):
	if (is_instance_valid(lobby_container) && lobby_container.visible):
		handleLobbyInputs()
	if (is_instance_valid(name_container) && name_container.visible):
		handleNameInputs()

func handleLobbyInputs():
	# Back
	if Input.is_action_just_pressed("pause"):
		if (check_ready_status()):
			game_start()
	if Input.is_action_just_pressed("back"):
		back_to_menu()
	# Players
	if Input.is_action_just_pressed("activate_p1"):
		activate_p1()
	if Input.is_action_just_pressed("activate_p2"):
		activate_p2()
	if Input.is_action_just_pressed("activate_p3"):
		activate_p3()
	if Input.is_action_just_pressed("activate_p4"):
		activate_p4()
	# Sprite Selection
	if Input.is_action_just_pressed("next_sprite_p1"):
		show_next_sprite(1)
	if Input.is_action_just_pressed("next_sprite_p2"):
		show_next_sprite(2)
	if Input.is_action_just_pressed("next_sprite_p3"):
		show_next_sprite(3)
	if Input.is_action_just_pressed("next_sprite_p4"):
		show_next_sprite(4)
	if Input.is_action_just_pressed("last_sprite_p1"):
		show_last_sprite(1)
	if Input.is_action_just_pressed("last_sprite_p2"):
		show_last_sprite(2)
	if Input.is_action_just_pressed("last_sprite_p3"):
		show_last_sprite(3)
	if Input.is_action_just_pressed("last_sprite_p4"):
		show_last_sprite(4)
	# Disabilitar navegação da UI
	if Input.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("ui_up"):
		get_viewport().set_input_as_handled()
	if Input.is_action_pressed("ui_down"):
		get_viewport().set_input_as_handled()

func handleNameInputs():
	# Back
	if Input.is_action_just_pressed("pause"):
		if (is_instance_valid(lobby_container)):
			lobby_menu()
	if Input.is_action_just_pressed("back"):
		if (is_instance_valid(lobby_container)):
			lobby_menu()

func game_start():
	incrementaPlayers()
	if (check_ready_status()):
		lobby_container.queue_free()
		background.queue_free()
		back_button.queue_free()
		start_button.queue_free()
		game.player_number = players_on_lobby
		game.player_names = player_names
		game.laps = laps
		game.player_controls_setup = [1,2,3,4]
		add_child(game)

func lobby_menu():
	#sprites_container.hide()
	#controls_container.hide()
	name_container.hide()
	black_background.hide()
	lobby_container.show()
	fade_in(lobby_container)
	
	show_buttons()
	show_names()
	#$BackButton.show()
	grab_focus()

func name_menu():
	var nameLineEdit = name_container.get_node("VBoxContainer/CenterContainer2/NameLineEdit")
	nameLineEdit.text = ""
	#sprites_container.hide()
	#controls_container.hide()
	black_background.show()
	lobby_container.hide()
	name_container.show()
	fade_in(name_container)
	grab_focus()

func show_names():
	player_1_button.text = "Player 1"
	player_2_button.text = "Player 2"
	player_3_button.text = "Player 3"
	player_4_button.text = "Player 4"
	if (player_names[0] != ""):
		player_1_button.text = player_names[0]
	if (player_names[1] != ""):
		player_2_button.text = player_names[1]
	if (player_names[2] != ""):
		player_3_button.text = player_names[2]
	if (player_names[3] != ""):
		player_4_button.text = player_names[3]

func check_ready_status() -> bool:
	var i = 0
	if (players_on_lobby == 0):
		return false
	while (i < players_on_lobby):
		if (player_names[i] == ""):
			return false
		if (player_sprite_num[i] == 0):
			return false
		i += 1
	return true

#func select_sprite_menu():	
	#lobby_container.hide()
	#controls_container.hide()
	#
	#sprites_container.show()
	#fade_in(sprites_container)
	#
	#$BackButton.hide()
	#start_button.hide()
	#grab_focus()

#func controls_menu():
	#sprites_container.hide()
	#lobby_container.hide()
	#
	#controls_container.show()
	#fade_in(controls_container)
	#
	#$BackButton.hide()
	#start_button.hide()
	#grab_focus()
	#check_all_controls()

func fade_out(obj):
	obj.modulate.a = 1.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 0.0, 1.0)
	
func fade_in(obj):
	obj.modulate.a = 0.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 1.0, 1.0)


func hide_buttons():
	if (player_active[0]):
		player_2_button.hide()
	if (player_active[1]):
		player_2_button.hide()
	if (player_active[2]):
		player_3_button.hide()
	if (player_active[3]):
		player_4_button.hide()
	if (check_ready_status() == false):
		start_button.disabled = true

func show_buttons():
	if (player_active[0]):
		player_2_button.show()
	if (player_active[1]):
		player_2_button.show()
	if (player_active[2]):
		player_3_button.show()
	if (player_active[3]):
		player_4_button.show()
	if (check_ready_status() == true):
		start_button.disabled = false


#func update_sprite_lobby(sprite_path):
	#var player_sprite
	#match player_selecting:
		#0: player_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player1Button/SpriteJogador1
		#1: player_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player2Button/SpriteJogador2
		#2: player_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player3Button/SpriteJogador3
		#3: player_sprite = $PlayersMarginContainer/PlayerLobby/VBoxContainer/HBoxContainer/Player4Button/SpriteJogador4
		#_: return
	#player_sprite.texture = load(sprite_path)
	#player_sprite.scale = Vector2(4.0,4.0)


func check_all_controls() -> void:
	var i = 0
	var not_used = 0
	var WASD = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/WASD
	var Arrows = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/Arrows
	var JKLI = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/JKLI
	var Controller = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/Controller
	while i < 4:
		match game.player_controls_setup[i]:
			0: not_used += 1
		i += 1
	if (not_used == 0):
		WASD.show()
		Arrows.show()
		JKLI.show()
		Controller.show()

func grab_focus() -> void:
	if (lobby_container.visible):
		#player_1_button.grab_focus()
		pass
	#if (sprites_container.visible):
		#$SpritesMarginContainer/SpritesContainer/VBoxContainer/Char1/Sprite1/Char1Sprite1Button.grab_focus()
	#if (controls_container.visible):
		#var WASD = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/WASD
		#var Arrows = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/Arrows
		#var JKLI = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/JKLI
		#var Controller = $ControlsMarginContainer/ControlsContainer/VBoxContainer/HBoxContainer/Controller
		#if(WASD.visible):
			#WASD.get_node('WASDButton').grab_focus()
		#elif(Arrows.visible):
			#Arrows.get_node('ArrowsButton').grab_focus()
		#elif(JKLI.visible):
			#JKLI.get_node('JKLIButton').grab_focus()
		#elif(Controller.visible):
			#Controller.get_node('ControllerButton').grab_focus()
	if (name_container.visible):
		$NameCenterContainer/VBoxContainer/CenterContainer2/NameLineEdit.grab_focus()

func incrementaPlayers():
	if (player_1_sprite.texture.resource_path != pressioneParaCriar):
		players_on_lobby = 1
		player_active[0] = true
	if (player_2_sprite.texture.resource_path != pressioneParaCriar):
		players_on_lobby = 2
		player_active[1] = true
	if (player_3_sprite.texture.resource_path != pressioneParaCriar):
		players_on_lobby = 3
		player_active[2] = true
	if (player_4_sprite.texture.resource_path != pressioneParaCriar):
		players_on_lobby = 4
		player_active[3] = true



func _on_start_button_pressed() -> void:
	game_start()


func activate_p1():
	# Select Name	
	player_selecting = 1
	name_menu()


func activate_p2():
	# Select Name
	player_selecting = 2
	name_menu()


func activate_p3():
	# Select Name
	player_selecting = 3
	name_menu()


func activate_p4():
	# Select Name
	player_selecting = 4
	name_menu()


#sprite_path = "res://Sprites/Chars/Char1-4-Icon.png",
#player_sprite_setup = "1-4",

func set_sprite_player(playerNum, spriteNum):
	var spriteStr = str(spriteNum)
	player_sprite_num[playerNum-1] = spriteNum
	game.player_sprite_setup[playerNum-1] = sprites[spriteStr].player_sprite_setup
	match playerNum:
		1: 
			player_1_sprite.texture = load(sprites[spriteStr].sprite_path)
			player_1_sprite.scale = Vector2(4.0,4.0)
		2: 
			player_2_sprite.texture = load(sprites[spriteStr].sprite_path)
			player_2_sprite.scale = Vector2(4.0,4.0)
		3: 
			player_3_sprite.texture = load(sprites[spriteStr].sprite_path)
			player_3_sprite.scale = Vector2(4.0,4.0)
		4: 
			player_4_sprite.texture = load(sprites[spriteStr].sprite_path)
			player_4_sprite.scale = Vector2(4.0,4.0)
		_: 
			return

func show_next_sprite(playerNum):
	if (playerNum <= 0):
		pass
	var spriteNumber = player_sprite_num[playerNum-1]
	spriteNumber += 1
	if (spriteNumber >= 16): 
		spriteNumber = 1
	player_sprite_num[playerNum-1] = spriteNumber
	set_sprite_player(playerNum, spriteNumber)

func show_last_sprite(playerNum):
	if (playerNum <= 0):
		pass
	var spriteNumber = player_sprite_num[playerNum-1]
	spriteNumber -= 1
	if (spriteNumber <= 0): 
		spriteNumber = 16
	player_sprite_num[playerNum-1] = spriteNumber
	set_sprite_player(playerNum, spriteNumber)


func back_to_menu():
	if (lobby_container.visible):
		fade_out(lobby_container)
		get_tree().change_scene_to_file("res://start_menu.tscn")


func _on_back_button_button_down() -> void:
	back_button.icon = load("res://Sprites/Ui/voltar-pressed.png")


func _on_back_button_button_up() -> void:
	back_button.icon = load("res://Sprites/Ui/voltar.png")
	back_to_menu()
	#if (sprites_container.visible):
		#fade_out(sprites_container)
		#lobby_menu()
	#if (controls_container.visible):
		#fade_out(controls_container)
		#select_sprite_menu()


func _on_ok_button_button_down() -> void:
	ok_button.icon = load("res://Sprites/Ui/confirmar-pressed.png")

func _on_ok_button_button_up() -> void:
	ok_button.icon = load("res://Sprites/Ui/confirmar.png")
	handle_confirm_name()

func handle_confirm_name():
	var nameLineEdit = name_container.get_node("VBoxContainer/CenterContainer2/NameLineEdit")
	var nameText = nameLineEdit.text.to_upper()
	if (nameText == ""):
		return
	if (name_filter(nameText) == false):
		nameLineEdit.text = ""
		nameLineEdit.placeholder_text = "Nome Inválido!"
		return (0)
	player_names[player_selecting-1] = nameText
	lobby_menu()
	set_sprite_player(player_selecting,1)
	incrementaPlayers()
	show_buttons()

func name_filter(nameText) -> bool:
	if (nameText.find(" ") != -1):
		return false
	if (nameText.find("CARALHO") != -1 || nameText.find("PORRA") != -1 || nameText.find("MERDA") != -1 || nameText.find("PUTA") != -1 || nameText.find("CRIOLO") != -1):
		return false
	if (nameText.find("NIGGER") != -1 || nameText.find("BITCH") != -1 || nameText.find("SHIT") != -1 || nameText.find("FUCK") != -1 || nameText.find("CUNT") != -1):
		return false
	if (nameText.find("VIADO") != -1 || nameText.find("PUTINHA") != -1 || nameText.find("CÚ") != -1 || nameText.find("PINTO") != -1 || nameText.find("BUCETA") != -1):
		return false
	return true


func _on_player_1_button_button_up() -> void:
	#player_1_button.icon = load("res://Sprites/Ui/Button-Player-Blank.png")
	pass
	#player_selecting = 0
	#if (game.player_number < 1):
		#game.player_number = 1
	#fade_out(lobby_container)
	#select_sprite_menu()


func _on_player_2_button_button_up() -> void:
	#player_2_button.icon = load("res://Sprites/Ui/Button-Player-Blank.png")
	pass
	#player_selecting = 1
	#if (game.player_number < 2):
		#game.player_number = 2
	#fade_out(lobby_container)
	#select_sprite_menu()


func _on_player_3_button_button_up() -> void:
	#player_3_button.icon = load("res://Sprites/Ui/Button-Player-Blank.png")
	pass
	#player_selecting = 2
	#if (game.player_number < 3):
		#game.player_number = 3
	#fade_out(lobby_container)
	#select_sprite_menu()


func _on_player_4_button_button_up() -> void:
	#player_4_button.icon = load("res://Sprites/Ui/Button-Player-Blank.png")
	pass
	#player_selecting = 3
	#if (game.player_number < 4):
		#game.player_number = 4
	#fade_out(lobby_container)
	#select_sprite_menu()


#func _on_char_1_sprite_1_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char1-1-Icon.png"
	#game.player_sprite_setup[player_selecting] = "1-1"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_1_sprite_2_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char1-2-Icon.png"
	#game.player_sprite_setup[player_selecting] = "1-2"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_1_sprite_3_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char1-3-Icon.png"
	#game.player_sprite_setup[player_selecting] = "1-3"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_1_sprite_4_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char1-4-Icon.png"
	#game.player_sprite_setup[player_selecting] = "1-4"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_2_sprite_1_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char2-1-Icon.png"
	#game.player_sprite_setup[player_selecting] = "2-1"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_2_sprite_2_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char2-2-Icon.png"
	#game.player_sprite_setup[player_selecting] = "2-2"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_2_sprite_3_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char2-3-Icon.png"
	#game.player_sprite_setup[player_selecting] = "2-3"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_2_sprite_4_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char2-4-Icon.png"
	#game.player_sprite_setup[player_selecting] = "2-4"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_3_sprite_1_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char3-1-Icon.png"
	#game.player_sprite_setup[player_selecting] = "3-1"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_3_sprite_2_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char3-2-Icon.png"
	#game.player_sprite_setup[player_selecting] = "3-2"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_3_sprite_3_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char3-3-Icon.png"
	#game.player_sprite_setup[player_selecting] = "3-3"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_3_sprite_4_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char3-4-Icon.png"
	#game.player_sprite_setup[player_selecting] = "3-4"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_4_sprite_1_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char4-1-Icon.png"
	#game.player_sprite_setup[player_selecting] = "4-1"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_4_sprite_2_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char4-2-Icon.png"
	#game.player_sprite_setup[player_selecting] = "4-2"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_4_sprite_3_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char4-3-Icon.png"
	#game.player_sprite_setup[player_selecting] = "4-3"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
#
#func _on_char_4_sprite_4_button_pressed() -> void:
	#var sprite_path = "res://Sprites/Chars/Char4-4-Icon.png"
	#game.player_sprite_setup[player_selecting] = "4-4"
	#update_sprite_lobby(sprite_path)
	#incrementaPlayers()
	#controls_menu()
#
	#
## Botões de Controles
#func _on_wasd_button_pressed() -> void:
	#game.player_controls_setup[player_selecting] = 1
	#player_selecting += 1
	#lobby_menu()
#
#func _on_arrows_button_pressed() -> void:
	#game.player_controls_setup[player_selecting] = 2
	#player_selecting += 1
	#lobby_menu()
#
#func _on_jkli_button_pressed() -> void:
	#game.player_controls_setup[player_selecting] = 3
	#player_selecting += 1
	#lobby_menu()
#
#func _on_controller_button_pressed() -> void:
	#game.player_controls_setup[player_selecting] = 4
	#player_selecting += 1
	#lobby_menu()
