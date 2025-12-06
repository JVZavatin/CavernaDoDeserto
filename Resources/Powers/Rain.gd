extends "res://Resources/Powers/Power.gd"
class_name Rain

@export var activated_by: int

func activate(player):
	Events.apply_rain_effect.emit()  # Evento para desacelerar todos os oponentes
	print("Chuva ativada para o jogador: ", player.name)

func deactivate(player):
	Events.remove_rain_effect.emit()  # Remove o efeito
	print("Chuva desativada para o jogador: ", player.name)
