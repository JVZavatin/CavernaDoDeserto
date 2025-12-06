extends Node2D

@export var player_number : int = 1
@export var apple_scene: PackedScene
@export var power_scenes: Array = [
	preload("res://Resources/Powers/Invulnerability.gd"),
	preload("res://Resources/Powers/Projectile.gd"),
	preload("res://Resources/Powers/SuperJump.gd"),
	preload("res://Resources/Powers/Rain.gd"),
]
@export var player_sprite_setup: Array = [0,0,0,0]
@export var player_names: Array = [""]
@export var player_controls_setup: Array = [0,0,0,0]
@export var player_race_points: Array = [0,0,0,0]

@export var laps: int = 3 # Min 3
@onready var race_lap_nodes: Array = []

@onready var mundo = $HBoxContainer/SubViewportContainer/SubViewport/Mundo
#@onready var tile_map = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/TileMapCavernaDoDeserto
#@onready var apples = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/TileMapCavernaDoDeserto/Apples
#@onready var hazards = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/TileMapCavernaDoDeserto/Hazards
#@onready var lap_line = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/TileMapCavernaDoDeserto/LapLine1
@onready var canvasScoreboard = $HBoxContainer/CanvasScoreBoard
@onready var canvasScoreboardOptions = $HBoxContainer/CanvasScoreBoard/Options
@onready var finishLine = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/FinishLine
@onready var pauseMenuCanvas = $HBoxContainer/CanvasPauseMenu
@onready var TransitionCanvas = $HBoxContainer/CanvasRaceTransition

@onready var ScoreboardTimer = $HBoxContainer/CanvasScoreBoard/ScoreboardTimer
@onready var TransitionTimer = $HBoxContainer/CanvasRaceTransition/TransitionTimer

@onready var player_controls_options: Array = [
	preload("res://Resources/controls_1.tres"), #preload("res://Resources/WASD_controls.tres")
	preload("res://Resources/controls_2.tres"), #preload("res://Resources/Arrows_controls.tres")
	preload("res://Resources/controls_3.tres"), #preload("res://Resources/JKLI_controls.tres")
	preload("res://Resources/controls_4.tres") #preload("res://Resources/Controller_controls.tres")
]

@onready var race_finish_points = [90,60,30,10]
@export var player_finished_race: Array = [false,false,false,false]
@export var players_finished = 0

var collectibles_chance = 2 # 1 é 100% 4 é 25%
var isPaused = false
var tilesetHeight: float = 0
var mapbounds
var screenWidth

@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player1,
		ui = $"HBoxContainer/SubViewportContainer/SubViewport/Ui-P1",
		apples_ui = $"HBoxContainer/SubViewportContainer/SubViewport/Ui-P1/ApplesUI",
		laps_ui = $"HBoxContainer/SubViewportContainer/SubViewport/Ui-P1/LapsUi",
		player_icon_ui = $"HBoxContainer/SubViewportContainer/SubViewport/Ui-P1/PlayerUiIcon",
		player_name_ui = $"HBoxContainer/SubViewportContainer/SubViewport/Ui-P1/PlayerNameUi"
	},
	"2": {
		viewport= $HBoxContainer/SubViewportContainer2/SubViewport,
		camera= $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player2,
		ui = $"HBoxContainer/SubViewportContainer2/SubViewport/Ui-P2",
		player_icon_ui = $"HBoxContainer/SubViewportContainer2/SubViewport/Ui-P2/PlayerUiIcon",
		player_name_ui = $"HBoxContainer/SubViewportContainer2/SubViewport/Ui-P2/PlayerNameUi",
		apples_ui = $"HBoxContainer/SubViewportContainer2/SubViewport/Ui-P2/ApplesUI",
		laps_ui = $"HBoxContainer/SubViewportContainer2/SubViewport/Ui-P2/LapsUi"
	},
	"3": {
		viewport= $HBoxContainer/SubViewportContainer3/SubViewport,
		camera= $HBoxContainer/SubViewportContainer3/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player3,
		ui = $"HBoxContainer/SubViewportContainer3/SubViewport/Ui-P3",
		player_icon_ui = $"HBoxContainer/SubViewportContainer3/SubViewport/Ui-P3/PlayerUiIcon",
		player_name_ui = $"HBoxContainer/SubViewportContainer3/SubViewport/Ui-P3/PlayerNameUi",
		apples_ui = $"HBoxContainer/SubViewportContainer3/SubViewport/Ui-P3/ApplesUI",
		laps_ui = $"HBoxContainer/SubViewportContainer3/SubViewport/Ui-P3/LapsUi"
	},
	"4": {
		viewport= $HBoxContainer/SubViewportContainer4/SubViewport,
		camera= $HBoxContainer/SubViewportContainer4/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player4,
		ui = $"HBoxContainer/SubViewportContainer4/SubViewport/Ui-P4",
		player_icon_ui = $"HBoxContainer/SubViewportContainer4/SubViewport/Ui-P4/PlayerUiIcon",
		player_name_ui = $"HBoxContainer/SubViewportContainer4/SubViewport/Ui-P4/PlayerNameUi",
		apples_ui = $"HBoxContainer/SubViewportContainer4/SubViewport/Ui-P4/ApplesUI",
		laps_ui = $"HBoxContainer/SubViewportContainer4/SubViewport/Ui-P4/LapsUi"
	}
}

@onready var podium := {
	"1": {
		node = $HBoxContainer/CanvasScoreBoard/Podium/Place1
	},
	"2": {
		node = $HBoxContainer/CanvasScoreBoard/Podium/Place2
	},
	"3": {
		node = $HBoxContainer/CanvasScoreBoard/Podium/Place3
	},
	"4": {
		node = $HBoxContainer/CanvasScoreBoard/Podium/Place4
	}
}

@export var race_order: Array = ["Deserto","Selva","Catacumbas","Cidade"]
@export var current_race: String

@onready var races := {
	"Deserto": {
		tile_map = "res://TileMapCavernaDoDeserto.tscn",
		player_position_x = 208.0,
		player_position_y = 472.0
	},
	"Selva": {
		tile_map = "res://TileMapJungleCave.tscn",
		player_position_x = 56.0,
		player_position_y = 882.0
	},
	"Catacumbas": {
		tile_map = "res://TileMapTower.tscn",
		player_position_x = 160.0,
		player_position_y = 882.0
	},
	"Cidade": {
		tile_map = "res://TileMapCity.tscn",
		player_position_x = 160.0,
		player_position_y = 882.0
	}
}

func _ready():	
	load_race_map()
	
	# Compartilhamento de viewport entre os jogadores
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	players["3"].viewport.world_2d = players["1"].viewport.world_2d
	players["4"].viewport.world_2d = players["1"].viewport.world_2d
	
	# Preparando jogadores
	var num = 1
	for node in players.values():
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
		init_camera_limits(node.camera, mapbounds)
		set_viewport_size(node.viewport, screenWidth, player_number)
		set_animated_sprite(node.player, player_sprite_setup[num-1])
		node.ui.show()
		set_ui_icon(node,player_sprite_setup[num-1])
		set_ui_name(node,player_names[num-1])
		set_player_controls(node.player,player_controls_setup[num-1])
		set_player_positions(node.player,num)
		if num >= player_number:
			break
		num += 1
	
	mundo.show()
	pauseMenuCanvas.hide()
	hide_scoreboard()
	Events.level_completed.connect(show_scoreboard)
	Events.update_laps.connect(calculate_laps)
	ScoreboardTimer.timeout.connect(show_scoreboard_options)


func _process(_delta):
	if (is_instance_valid(TransitionTimer) && !TransitionTimer.is_stopped()):
		if Input.is_anything_pressed():
			get_viewport().set_input_as_handled()
	if (is_instance_valid(pauseMenuCanvas) && is_instance_valid(canvasScoreboard) && !canvasScoreboard.visible):
		if Input.is_action_just_pressed("pause"):
			handle_pause_menu()
	if (is_instance_valid(canvasScoreboard) && canvasScoreboard.visible):
		handle_scoreboard_inputs()

func handle_scoreboard_inputs():
	if(canvasScoreboardOptions.visible):
		if Input.is_anything_pressed():
			if (race_order.is_empty()):
				handle_back_to_menu()
			else:
				handle_next_race()


func load_race_map():
	# Mostra tela de transição de 3 segundos
	TransitionCanvas.show()
	TransitionCanvas.start_transition()
	
	# Pega a próxima corrida do Array de ordem de corrida
	current_race = race_order.pop_front()
	var tileMap = load(str(races[current_race].tile_map)).instantiate()
	
	mundo.add_child(tileMap,true)
	race_lap_nodes.push_back(tileMap)
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	mapbounds = _get_map_bounds(get_node(str(tileMap.get_path())+"/Surface"))
	screenWidth = get_viewport_rect()
	screenWidth.size.y = mapbounds.size.y
	tilesetHeight = mapbounds.size.y
	
	var newMap = tileMap.duplicate()	
	# Sistema de Voltas
	for i in range(laps):
		# Duplicação do cenário
		newMap = tileMap.duplicate()
		tileMap.add_sibling(newMap,true)
		newMap.position = tileMap.position - Vector2(0, tilesetHeight * (i + 1))
		race_lap_nodes.push_back(newMap)
	# Inicia os coletáveis aleatórios
	var apple_nodes = get_tree().get_nodes_in_group("Apples")
	for collectible in apple_nodes:
		if collectible is Node2D:
			setup_collectibles(collectible)
	# Ajusta a posição da linha de chegada
	finishLine.position.y = (-8) - (tilesetHeight * laps)
	
	# Bloco acima do percurso final por estética
	newMap = tileMap.duplicate()
	tileMap.add_sibling(newMap)
	newMap.position = tileMap.position - Vector2(0, tilesetHeight * (laps + 1))
	race_lap_nodes.push_back(newMap)

func unload_race_map():
	for lap in race_lap_nodes:
		get_node(str(lap.get_path())).queue_free()
	race_lap_nodes = []
	player_finished_race = [false,false,false,false]
	players_finished = 0

func reset_player_positions():
	# Preparando jogadores
	var num = 1
	for node in players.values():
		set_animated_sprite(node.player, player_sprite_setup[num-1])
		node.ui.show()
		init_camera_limits(node.camera, mapbounds)
		set_viewport_size(node.viewport, screenWidth, player_number)
		set_player_positions(node.player,num)
		node.player.enabled_state()
		if num >= player_number:
			break
		num += 1

func handle_next_race():
	hide_scoreboard()
	unload_race_map()
	load_race_map()
	reset_player_positions()
	calculate_laps()

func atualizar_ui():
	# Percorre o dicionário
	for key in players.keys():
		# Pega as referências do dicionário
		var player = players[key].player
		var applesUi = players[key].apples_ui
		var lapsUi = players[key].laps_ui
		if player != null:
			# Busca as informações com a função getter do jogador 
			applesUi.text = str(player.get_points_count())
			lapsUi.text = str(player.get_current_lap())
		# Percorre todos os jogadores
		if int(key) >= player_number:
			break


func calculate_laps():
	for key in players.keys():
		var player = players[key].player
		if player != null and player.has_method("set_current_lap"):
			var lap = 0
			if (tilesetHeight != 0):
				lap = abs((player.position.y+2)/tilesetHeight) # +2 é margem de erro da hitbox
			lap = ceil(lap)
			player.set_current_lap(lap)
		if int(key) >= player_number:
			break
	atualizar_ui()


func set_player_controls(player,controlOption) -> void:
	player.controls = player_controls_options[controlOption-1]

func set_player_positions(player,playerNum):
	# Posições iniciais baseadas na corrida atual
	player.position.x = races[current_race].player_position_x + ((playerNum)*15)
	player.position.y = races[current_race].player_position_y
	# Jogadores são posicionados no cenário acima de Y 0
	player.position.y -= tilesetHeight

func _get_map_bounds(tilemap) -> Rect2:
	var map_rect: Rect2 = tilemap.get_used_rect()
	var cell_width: float = tilemap.tile_set.tile_size.x * tilemap.scale.x

	var pos := Vector2(cell_width * map_rect.position.x, cell_width * map_rect.position.y)
	var size:= Vector2(cell_width * map_rect.size.x, cell_width * map_rect.size.y)
	
	return Rect2(pos, size)

func init_camera_limits(camera: Camera2D, map_bounds: Rect2) -> void:
	# inject into player's cameraa
	camera.offset.y = -45
	camera.set_limit(Side.SIDE_LEFT, 0)
	camera.set_limit(Side.SIDE_RIGHT, int(map_bounds.size.x + map_bounds.position.x))
	camera.set_limit(Side.SIDE_TOP, int(-1*(map_bounds.size.y*(laps+1)) +map_bounds.position.y))
	camera.set_limit(Side.SIDE_BOTTOM, int(map_bounds.size.y*laps + map_bounds.position.y))

func set_viewport_size(subviewport: SubViewport, _map_bounds: Rect2, num:int) -> void:
	#subviewport.size.x = int((map_bounds.size.x/num))
	#subviewport.size.y = int(map_bounds.size.y)
	subviewport.size.x = int((345/num))
	subviewport.size.y = int(180)


func set_animated_sprite(player, numSprite) -> void:
	var _animated_spriteP = player.get_node("AnimatedSprite2DP"+numSprite)
	
	player.show()
	player.set_collision_layer_value(2, 1)
	player.animated_sprite_2d = _animated_spriteP
	_animated_spriteP.visible = true

func set_ui_icon(node, numSprite) -> void:
	var path = "res://Sprites/Chars/Char"+numSprite+"-Icon.png"
	node.player_icon_ui.texture = load(path)
	
func set_ui_name(node, playerName) -> void:
	node.player_name_ui.text = playerName

func setup_collectibles(parent: Node2D):
	for collectible in parent.get_children():
		if collectible is Node2D:
			# Chance de 50% para manter ou remover o coletável
			if randi() % collectibles_chance != 0:
				collectible.queue_free()  # Remove o coletável
				continue
			
			# Decide aleatoriamente se será um poder ou uma maçã
			var random_choice = randi() % 2
			if random_choice == 0:
				collectible.set("is_power", false)  # Configurado como maçã
				collectible.set("power_type", -1)  # Não é um poder
				print("Coletável configurado como maçã:", collectible)
			else:
				collectible.set("is_power", true)  # Configurado como poder
				if collectible.has_method("get") and collectible.get("apple_sprites") != null:
					var power_index = randi() % collectible.get("apple_sprites").size()
					collectible.set("power_type", power_index)
				else:
					print("Erro: apple_sprites não encontrado ou inválido no coletável:", collectible)
					collectible.queue_free()
					continue

			# Chama a função `_change_sprite` para ajustar a textura
			if collectible.has_method("_change_sprite"):
				collectible.call("_change_sprite")  # Chama a função diretamente
			else:
				print("O coletável não possui a função _change_sprite:", collectible)

func hide_scoreboard():
	canvasScoreboard.hide()

func show_scoreboard(): # Podium
	if (players_finished < player_number):
		atualizar_ui()
		return 0
		
	hide_game_ui()
	get_node(str(canvasScoreboard.get_path())+"/BlackBackground").show()
	var playerPodiumOrder:Array = calculate_podium()
	var auxNum = 1
	
	for key in playerPodiumOrder:
		var nodePlace = podium[str(auxNum)].node
		var sprite = get_node(str(nodePlace.get_path())+"/Sprite")
		var applesLabel = get_node(str(nodePlace.get_path())+"/ApplesLabel")
		var playerNameUi = get_node(str(nodePlace.get_path())+"/PlayerNameUi")
		sprite.texture = load("res://Sprites/Chars/Char"+player_sprite_setup[key-1]+"-Podium.png")
		applesLabel.text = str(player_race_points[key-1])
		applesLabel.position.x += 10
		playerNameUi.text = player_names[key-1]
		#playerNameUi.position.x += 10
		nodePlace.show()
		if (race_order.is_empty()):
			SaveManager.submit_score(str(player_names[key-1]), player_race_points[key-1],"res://Sprites/Chars/Char"+player_sprite_setup[key-1]+"-Icon.png")
			get_node(str(canvasScoreboardOptions.get_path())+"/VBoxContainer/NextButton").hide()
			get_node(str(canvasScoreboardOptions.get_path())+"/VBoxContainer/BackButton").show()
		else:
			get_node(str(canvasScoreboardOptions.get_path())+"/VBoxContainer/BackButton").hide()
			get_node(str(canvasScoreboardOptions.get_path())+"/VBoxContainer/NextButton").show()
		auxNum += 1
	
	canvasScoreboardOptions.hide()
	ScoreboardTimer.start()
	canvasScoreboard.show()
	
func show_scoreboard_options(): # Podium
	fade_in(canvasScoreboardOptions)
	canvasScoreboardOptions.show()
	get_node(str(canvasScoreboardOptions.get_path())+"/VBoxContainer/NextButton").grab_focus()

func calculate_podium() -> Array:
	var podiumPositions: Array = [1,2,3,4]
	var playerPodiumOrder: Array = []
	var availablePlayers: Array = [1,2,3,4]
	var mostPointsValue
	var mostPointsPlayer
	
	for pos in podiumPositions:
		mostPointsPlayer = 0
		mostPointsValue = 0
		for key in availablePlayers:
			if int(key) > player_number:
				break
			var player = players[str(key)].player
			if player != null and player.has_method("get_points_count"):
				var points = player.get_points_count()
				player_race_points[int(key)-1] = points
				if (mostPointsValue < points):
					mostPointsValue = points
					mostPointsPlayer = int(key)
					availablePlayers.pop_at(int(key)-1)
		playerPodiumOrder.push_front(mostPointsPlayer)
		if pos >= player_number:
			break
	return playerPodiumOrder

func set_winner(player_num: int):
	var player = players[str(player_num)].player
	if player != null and player.has_method("get_points_count"):
		if (players_finished > 3 || players_finished < 0):
			player.add_points(race_finish_points[players_finished])
			player_finished_race[player_num-1] = true
			players_finished = 1
		if (!player_finished_race[player_num-1] && players_finished < 4 && players_finished >= 0):
			player.add_points(race_finish_points[players_finished])
			player_finished_race[player_num-1] = true
			players_finished += 1

func handle_back_to_menu():
	get_tree().change_scene_to_file("res://start_menu.tscn")

func handle_pause_menu():
	if isPaused:
		pauseMenuCanvas.hide()
		Engine.time_scale = 1
	else:
		pauseMenuCanvas.show()
		
		Engine.time_scale = 0
	isPaused = !isPaused


func hide_game_ui():
	for key in players.keys():
		players[key].ui.hide()
		if int(key) >= player_number:
			break
	pass

func fade_out(obj):
	obj.modulate.a = 1.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 0.0, 1.0)
	
func fade_in(obj):
	obj.modulate.a = 0.0
	var animation_tween = create_tween()
	animation_tween.tween_property(obj, "modulate:a", 1.0, 1.0)


func _on_next_button_button_up() -> void:
	pass # Replace with function body.


func _on_back_button_button_up() -> void:
	handle_back_to_menu()
