extends Area2D

@export var is_power: bool = false  # Define se este item é uma maçã ou um poder
@export var power_type: int = -1  # Identifica o tipo de poder (caso seja poder)
@export var apple_sprites: Array[Texture]  # Lista de sprites para alternar
@export var power_duration: float = 10.0  # Duração padrão do poder


@onready var sprite = $Sprite2D
@onready var timer = Timer.new()  # Cria o timer dinamicamente

var current_sprite_index: int = 0  # Rastreamento do índice atual da sprite

func _ready():	
	# Define a sprite inicial com base no tipo
	if is_power:
		if power_type >= 1 and power_type < apple_sprites.size():
			sprite.texture = apple_sprites[power_type]  # Usa o índice do tipo do poder
		else:
			print("Erro: power_type inválido ou sprite não configurada!")
			queue_free()  # Remove o coletável se o tipo for inválido
	else:
		if apple_sprites.size() > 0:
			sprite.texture = apple_sprites[0]  # Índice 0 para maçã normal


func _change_sprite():
	if is_power:
		if power_type >= 1 and power_type < apple_sprites.size():
			sprite.texture = apple_sprites[power_type]  # Usa o índice do tipo do poder
		else:
			print("Erro: power_type inválido ou sprite não configurada!")
			queue_free()  # Remove o coletável se o tipo for inválido
	else:
		if apple_sprites.size() > 0:
			sprite.texture = apple_sprites[0]  # Índice 0 para maçã normal


func _on_body_entered(body):
	if body.has_method("activate_power") and is_power:
		if body.active_power != null:
			return  # Não permite coletar outro poder
		body.activate_power(self)
	else:
		queue_free()
		#var apple_count = get_tree().get_nodes_in_group("Apples")

func activate(player):
	if is_power:
		player.activate_power(self)
	else:
		player.points_count += 1
	queue_free()

func activate_power(player):
	if power_type == -1:
		print("Erro: Coletável sem tipo de poder definido!")
		return
	player.activate_power(self)
	queue_free()
