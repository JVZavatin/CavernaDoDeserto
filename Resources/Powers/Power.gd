extends Node2D
class_name Power

@export var nome: String
@export var icon: Texture  # Ícone do poder
@export var duration: float = 6.0  # Duração do efeito em segundos

func activate(_player):
	# Para ser sobrescrito nos poderes específicos
	pass

func deactivate(_player):
	# Para ser sobrescrito nos poderes específicos
	pass
