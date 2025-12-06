extends "res://Resources/Powers/Power.gd"

func activate(player):
	player.can_shoot = true  # Adiciona a capacidade de atirar
	print("Projetil ativado para o jogador: ", player.name)

func deactivate(player):
	player.can_shoot = false
	print("Projetil ativado para o jogador: ", player.name)
