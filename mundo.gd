extends Node2D

@export var playerNumber : int = 1
@export var laps: int = 3
@export var apple_scene: PackedScene
@export var power_scenes: Array = [
	preload("res://Resources/Powers/Invulnerability.gd"),
	preload("res://Resources/Powers/Projectile.gd"),
	preload("res://Resources/Powers/SuperJump.gd"),
	preload("res://Resources/Powers/Rain.gd"),
]

@onready var mundo = $HBoxContainer/SubViewportContainer/SubViewport/Mundo
@onready var tile_map = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/TileMap
@onready var apples = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Apples
@onready var hazards = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Hazards
@onready var canvasLevelComplete = $HBoxContainer/SubViewportContainer/SubViewport/CanvasLevelComplete
@onready var finishLine = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/FinishLine

@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player1
	},
	"2": {
		viewport= $HBoxContainer/SubViewportContainer2/SubViewport,
		camera= $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player2
	},
	"3": {
		viewport= $HBoxContainer/SubViewportContainer3/SubViewport,
		camera= $HBoxContainer/SubViewportContainer3/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player3
	},
	"4": {
		viewport= $HBoxContainer/SubViewportContainer4/SubViewport,
		camera= $HBoxContainer/SubViewportContainer4/SubViewport/Camera2D,
		player= $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player4
	}
}

#func _ready():
	#var num = 1
	#RenderingServer.set_default_clear_color(Color.BLACK)
	#var mapbounds = _get_map_bounds(tile_map)
	#var screenWidth = get_viewport_rect()
	#screenWidth.size.y = mapbounds.size.y
	#
	#var new_map
	#var new_hazards
	#var new_apples
	#
	##Sequência de geração de voltas
	#var height: float = mapbounds.size.y
	#for i in range(laps):
		#new_map = tile_map.duplicate()
		#new_hazards = hazards.duplicate()
		#new_apples = apples.duplicate()
		#mundo.add_child(new_map)
		#mundo.add_child(new_hazards)
		#mundo.add_child(new_apples)
		#new_map.position = tile_map.position - Vector2(0, height * (i+1))
		#new_hazards.position = hazards.position - Vector2(0, height * (i+1))
		#new_apples.position = apples.position - Vector2(0, height * (i+1))
	#
	#finishLine.position = finishLine.position - Vector2(0, height * (laps))
	#
	##Montar o bloco a cima do fim do percuso
	#new_map = tile_map.duplicate()
	#new_hazards = hazards.duplicate()
	#mundo.add_child(new_map)
	#mundo.add_child(new_hazards)
	#new_map.position = tile_map.position - Vector2(0, height * (laps+1))
	#new_hazards.position = hazards.position - Vector2(0, height * (laps+1))
	##Posicionar a linha de chegada no fim do percurso
	#
	#players["2"].viewport.world_2d = players["1"].viewport.world_2d
	#players["3"].viewport.world_2d = players["1"].viewport.world_2d
	#players["4"].viewport.world_2d = players["1"].viewport.world_2d
	#
	##Preparando players
	#for node in players.values():
		#var remote_transform = RemoteTransform2D.new()
		#remote_transform.remote_path = node.camera.get_path()
		#node.player.add_child(remote_transform)
		#init_camera_limits(node.camera, mapbounds)
		#set_viewport_size(node.viewport, screenWidth, playerNumber)
		#set_animated_sprite(node.player, num)
		#if num >= playerNumber:
			#break
		#num += 1
		#
	#Events.level_completed.connect(show_level_completed)
	
func _ready():
	var num = 1
	RenderingServer.set_default_clear_color(Color.BLACK)
	var mapbounds = _get_map_bounds(tile_map)
	var screenWidth = get_viewport_rect()
	screenWidth.size.y = mapbounds.size.y
	
	var height: float = mapbounds.size.y
	for i in range(laps):
		# Duplicação do cenário
		var new_map = tile_map.duplicate()
		var new_hazards = hazards.duplicate()
		var new_apples = apples.duplicate()
		mundo.add_child(new_map)
		mundo.add_child(new_hazards)
		mundo.add_child(new_apples)
		new_map.position = tile_map.position - Vector2(0, height * (i + 1))
		new_hazards.position = hazards.position - Vector2(0, height * (i + 1))
		new_apples.position = apples.position - Vector2(0, height * (i + 1))
		# Extrair as posições dos filhos de `new_apples` (verifique se `new_apples` tem filhos configurados)
		var positions = []
		
		print(apples)
		for child in apples.get_children():
			positions.append(child.global_position + new_apples.position)
		# Distribuir coletáveis nas posições extraídas
		setup_collectibles(new_apples, positions)
	
	# Ajusta a posição da linha de chegada
	finishLine.position = finishLine.position - Vector2(0, height * laps)
	
	# Bloco acima do percurso final
	var new_map = tile_map.duplicate()
	var new_hazards = hazards.duplicate()
	mundo.add_child(new_map)
	mundo.add_child(new_hazards)
	new_map.position = tile_map.position - Vector2(0, height * (laps + 1))
	new_hazards.position = hazards.position - Vector2(0, height * (laps + 1))
	
	# Compartilhamento de viewport entre os jogadores
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	players["3"].viewport.world_2d = players["1"].viewport.world_2d
	players["4"].viewport.world_2d = players["1"].viewport.world_2d
	
	# Preparando jogadores
	for node in players.values():
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
		init_camera_limits(node.camera, mapbounds)
		set_viewport_size(node.viewport, screenWidth, playerNumber)
		set_animated_sprite(node.player, num)
		if num >= playerNumber:
			break
		num += 1
	
	Events.level_completed.connect(show_level_completed)



func _get_map_bounds(tilemap: TileMap) -> Rect2:
	var map_rect: Rect2 = tilemap.get_used_rect()
	var cell_width: float = tilemap.tile_set.tile_size.x * tilemap.scale.x

	var pos := Vector2(cell_width * map_rect.position.x, cell_width * map_rect.position.y)
	var size:= Vector2(cell_width * map_rect.size.x, cell_width * map_rect.size.y)

	return Rect2(pos, size)

func init_camera_limits(camera: Camera2D, map_bounds: Rect2) -> void:
	# inject into player's camera
	camera.set_limit(Side.SIDE_LEFT, int(map_bounds.position.x))
	camera.set_limit(Side.SIDE_RIGHT, int(map_bounds.size.x + map_bounds.position.x))
	camera.set_limit(Side.SIDE_TOP, int(-1*(map_bounds.size.y*laps) +map_bounds.position.y))
	camera.set_limit(Side.SIDE_BOTTOM, int(map_bounds.size.y*laps + map_bounds.position.y))

func set_viewport_size(subviewport: SubViewport, map_bounds: Rect2, num:int) -> void:
	subviewport.size.x = int((map_bounds.size.x/num))
	subviewport.size.y = int(map_bounds.size.y)


func set_animated_sprite(player: CharacterBody2D, num:int) -> void:
	var _animated_spriteP1 = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player1/AnimatedSprite2DP1
	var _animated_spriteP2 = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player2/AnimatedSprite2DP2
	var _animated_spriteP3 = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player3/AnimatedSprite2DP3
	var _animated_spriteP4 = $HBoxContainer/SubViewportContainer/SubViewport/Mundo/Player4/AnimatedSprite2DP4

	if num == 1:
		player.show()
		player.set_collision_layer_value(2, 1)
		player.animated_sprite_2d = _animated_spriteP1
	if num == 2:
		player.show()
		player.set_collision_layer_value(2, 1)
		player.animated_sprite_2d = _animated_spriteP2
	if num == 3:
		player.show()
		player.set_collision_layer_value(2, 1)
		player.animated_sprite_2d = _animated_spriteP3
	if num == 4:
		player.show()
		player.set_collision_layer_value(2, 1)
		player.animated_sprite_2d = _animated_spriteP4

func show_level_completed():
	print("show_level_completed")
	canvasLevelComplete.show()
	
func setup_collectibles(parent: Node2D, positions: Array[Vector2]):
	for position in positions:
		# Adiciona uma chance de 50% para não gerar o coletável
		if randi() % 2 != 0:  # 50% de chance de "falhar"
			print("Coletável não gerado na posição: ", position)
			continue  # Não gera nada nesta posição
		
		# Decide aleatoriamente entre maçã ou poder
		var random_choice = randi() % 2
		if random_choice == 0:
			# Instancia uma maçã
			var apple = apple_scene.instantiate()
			apple.position = position
			parent.add_child(apple)
		else:
			# Instancia um poder aleatório
			var power_index = randi() % power_scenes.size()
			var power = power_scenes[power_index].instantiate()
			power.position = position
			parent.add_child(power)
