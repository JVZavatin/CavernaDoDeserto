extends "res://Resources/Powers/Power.gd"

func activate(player):
	player.movement_data.jump_velocity *= 1.5
	print("Super Pulo ativado para o jogador: ", player.name)

func deactivate(player):
	player.movement_data.jump_velocity /= 1.5
	print("Super Pulo desativado para o jogador: ", player.name)
