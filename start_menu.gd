extends CanvasLayer

@export var music_playing = true

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

@onready var MainMenuContainer = $MainMenu
@onready var ConfigMenuContainer = $Configs
@onready var SplashScreenContainer = $SplashScreen
@onready var LeaderboardContainer = $Leaderboard
@onready var LeaderboardScrollContainer = $Leaderboard/Layout/ScrollContainer
@onready var LeaderboardList = $Leaderboard/Layout/ScrollContainer/List

@onready var buttonIniciar = %StartGameButton
@onready var buttonStartFromSplash = $SplashScreen/VBoxContainer/CenterContainer3/StartFromSplashButton
@onready var buttonConfigs = $MainMenu/Center/Options/ConfigButton
@onready var buttonLeaderboad = $MainMenu/Center/Options/LeaderboardButton
@onready var buttonQuit = $MainMenu/Center/Options/QuitButton
@onready var buttonMute = $MainMenu/Music/ButtonMute
@onready var button3 = $Configs/Options/CenterContainer2/AspectRatioContainer/HBoxContainer/Btn3Container/Button3
@onready var button5 = $Configs/Options/CenterContainer2/AspectRatioContainer/HBoxContainer/Btn5Container/Button5
@onready var button10 = $Configs/Options/CenterContainer2/AspectRatioContainer/HBoxContainer/Btn10Container/Button10

@onready var player_lobby_scene = load("res://player_lobby.tscn")
@onready var player_lobby

var laps = 3


func _ready():
	player_lobby = player_lobby_scene.instantiate()
	if music_playing:
		background_music.play()
	splash_screen()

func _process(_delta):
	if (is_instance_valid(MainMenuContainer) && MainMenuContainer.visible):
		if Input.is_action_just_pressed("pause"):
			main_menu()
		if Input.is_action_just_pressed("back"):
			main_menu()
	if (is_instance_valid(ConfigMenuContainer) && ConfigMenuContainer.visible):
		if Input.is_action_just_pressed("pause"):
			main_menu()
		if Input.is_action_just_pressed("back"):
			main_menu()
	if (is_instance_valid(LeaderboardContainer) && LeaderboardContainer.visible):
		if Input.is_action_just_pressed("pause"):
			main_menu()
		if Input.is_action_just_pressed("back"):
			main_menu()



# Main Menu
func config_menu():
	MainMenuContainer.hide()
	SplashScreenContainer.hide()
	LeaderboardContainer.hide()
	ConfigMenuContainer.show()
	button3.grab_focus()
	fade_in(ConfigMenuContainer)

func main_menu():
	ConfigMenuContainer.hide()
	SplashScreenContainer.hide()
	LeaderboardContainer.hide()
	MainMenuContainer.show()
	buttonIniciar.grab_focus()
	fade_in(MainMenuContainer)

func splash_screen():
	ConfigMenuContainer.hide()
	MainMenuContainer.hide()
	LeaderboardContainer.hide()
	SplashScreenContainer.show()
	buttonStartFromSplash.grab_focus()
	fade_in(SplashScreenContainer)

func leaderboard():
	ConfigMenuContainer.hide()
	MainMenuContainer.hide()
	SplashScreenContainer.hide()
	load_leaderboard()
	LeaderboardContainer.show()
	LeaderboardScrollContainer.grab_focus()
	fade_in(LeaderboardContainer)

func menu_to_player_lobby():
	MainMenuContainer.hide()
	SplashScreenContainer.hide()
	ConfigMenuContainer.hide()
	LeaderboardContainer.hide()
	player_lobby.laps = laps
	add_child(player_lobby)

func load_leaderboard():
	var baseEntry = get_node(str(LeaderboardList.get_path())+"/Entry1")
	
	# Pega até 50 entradas do SaveManager
	var entries := SaveManager.get_top(50)

	# Loop sobre as entradas retornadas
	for i in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[i]

		var nome: String = str(entry.get("name", ""))
		var pontos: int = int(entry.get("points", ""))
		var sprite_name: String = str(entry.get("sprite", ""))
		
		var newEntry = baseEntry.duplicate()
		baseEntry.add_sibling(newEntry)
		
		get_node(str(newEntry.get_path())+"/HBoxContainer/PositionContainer/Position").text = str(i+1)
		if (sprite_name != ""):
			get_node(str(newEntry.get_path())+"/HBoxContainer/IconContainer/PlayerIcon").texture = load(sprite_name)
		get_node(str(newEntry.get_path())+"/HBoxContainer/NameContainer/Name").text = nome
		get_node(str(newEntry.get_path())+"/HBoxContainer/PointsContainer/Points").text = str(pontos)
		
		newEntry.show()

func fade_out(obj):
	obj.modulate.a = 1.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 0.0, 1.0)
	
func fade_in(obj):
	obj.modulate.a = 0.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 1.0, 1.0)

# Configs
func _on_button_3_pressed() -> void:
	button3.icon = load("res://Sprites/Ui/small-3-pressed.png")
	button5.icon = load("res://Sprites/Ui/small-5.png")
	button10.icon = load("res://Sprites/Ui/small-10.png")
	laps = 3

func _on_button_5_pressed() -> void:
	button3.icon = load("res://Sprites/Ui/small-3.png")
	button5.icon = load("res://Sprites/Ui/small-5-pressed.png")
	button10.icon = load("res://Sprites/Ui/small-10.png")
	laps = 5

func _on_button_10_pressed() -> void:
	button3.icon = load("res://Sprites/Ui/small-3.png")
	button5.icon = load("res://Sprites/Ui/small-5.png")
	button10.icon = load("res://Sprites/Ui/small-10-pressed.png")
	laps = 10


# Start Button
func _on_start_game_button_button_down() -> void:
	#buttonIniciar.icon = load("res://Sprites/Ui/iniciar-pressed.png")
	pass

func _on_start_game_button_button_up() -> void:
	#buttonIniciar.icon = load("res://Sprites/Ui/iniciar.png")
	menu_to_player_lobby()


# Configs Button
func _on_config_button_button_down() -> void:
	#buttonConfigs.icon = load("res://Sprites/Ui/configs-pressed.png")
	pass

func _on_config_button_button_up() -> void:
	#buttonConfigs.icon = load("res://Sprites/Ui/configs.png")
	config_menu()


# Sair Button
func _on_quit_button_button_down() -> void:
	#buttonQuit.icon = load("res://Sprites/Ui/sair-pressed.png")
	pass
	

func _on_quit_button_button_up() -> void:
	#buttonQuit.icon = load("res://Sprites/Ui/sair.png")
	get_tree().quit()

func _on_button_mute_pressed() -> void:
	if background_music.playing:
		background_music.stop()
		music_playing = false
		buttonMute.icon = load("res://Sprites/Ui/mute.png")
	else:
		background_music.play()
		music_playing = true
		buttonMute.icon = load("res://Sprites/Ui/unmute.png")


func _on_start_from_splash_button_button_down() -> void:
	buttonStartFromSplash.icon = load("res://Sprites/Ui/iniciar-pressed.png")

func _on_start_from_splash_button_button_up() -> void:
	buttonStartFromSplash.icon = load("res://Sprites/Ui/iniciar.png")
	main_menu()


func _on_leaderboard_button_button_up() -> void:
	leaderboard()
