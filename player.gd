extends CharacterBody2D

# Configs
@export var movement_data : PlayerMovementData
@export var controls : Resource = null
@export var animated_sprite_2d : AnimatedSprite2D = null
@export var power_icons: Array[Texture]  # Array com as texturas dos ícones dos poderes
@export var power_icon_offset: Vector2 = Vector2(-8, -16) # Offsets para posicionar o ícone de poder
@export var stunned_icon: Texture  # textura de atordoado
@export var arrow_scene: PackedScene  # Referência para o projétil
@export var rain_scene: PackedScene  # Referência para o projétil
@export var points_count = 0
@export var current_lap = 1


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invulnerable: bool = false
var can_shoot: bool = false
var is_slowed = false

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var air_jump = false
@onready var starting_position = global_position
@onready var input_enabled = true
@onready var stun_force = 200
@onready var stun_seconds = 4
@onready var slow_factor = 2
@onready var active_power = null
@onready var power_icon = Sprite2D.new()  # Ícone de poder
@onready var power_timer = $PowerTimer #Timer do poder
@onready var projectile_timer = $ProjectileTimer

@onready var sfx_jump: AudioStreamPlayer = $sfx_jump
@onready var sfx_coin: AudioStreamPlayer = $sfx_coin
@onready var sfx_hurt: AudioStreamPlayer = $sfx_hurt
@onready var sfx_finish: AudioStreamPlayer = $sfx_finish



func _ready():
	add_child(power_icon)
	power_icon.visible = false
	power_timer.one_shot = true
	projectile_timer.one_shot = false
	#projectile_timer.connect("timeout", Callable(self, "shoot_projectile"))
	Events.connect("apply_rain_effect", Callable(self, "_on_rain_effect_applied"))
	Events.connect("remove_rain_effect", Callable(self, "_on_rain_effect_removed"))

func _physics_process(delta):
	if (input_enabled):
		var input_axis = Input.get_axis(controls.move_left, controls.move_right)
		handle_jump()	
		handle_acceleration(input_axis, delta)
		apply_friction(input_axis, delta)
		apply_air_resistance(input_axis, delta)
		update_animations(input_axis)
	
	## Rotina
	apply_gravity(delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	# Checar condições do pulo de coyote
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func _on_mundo_ready():
	pass

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_jump():
	if is_on_floor(): air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed(controls.jump):
			velocity.y = movement_data.jump_velocity
			sfx_jump.play()
	elif not is_on_floor():
		if Input.is_action_just_released(controls.jump) and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed(controls.jump) and air_jump:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false
			sfx_jump.play()

func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		if not is_slowed:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.accelleration * delta)
		else:
			velocity.x = move_toward(velocity.x/slow_factor, (movement_data.speed*input_axis)/slow_factor, (movement_data.accelleration*delta)/slow_factor)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis):
	animated_sprite_2d.show()
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("running")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(_area):
	if is_invulnerable:
		return  # Ignora os perigos enquanto está invulnerável
	apply_random_force_in_cone(stun_force)
	disable_input_for_seconds(stun_seconds)
	sfx_hurt.play()
	# Exibe o ícone de atordoado
	show_stunned_icon()
	# Cria um temporizador para remover o ícone após o tempo de atordoamento
	var timer = Timer.new()
	timer.wait_time = stun_seconds
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_hide_stunned_icon"))
	add_child(timer)
	timer.start()

func show_stunned_icon():
	if stunned_icon:
		power_icon.texture = stunned_icon  # Define o ícone de atordoamento
		power_icon.position = power_icon_offset  # Aplica o offset
		power_icon.scale = Vector2(0.4, 0.4)  # Define o tamanho do ícone (ajuste conforme necessário)
		power_icon.visible = true  # Torna o ícone visível

func _hide_stunned_icon():
	if power_icon.texture == stunned_icon:
		power_icon.visible = false  # Oculta o ícone somente se for o de atordoamento


func _on_collectible_area_entered(collectible):
	if collectible.has_method("activate"):  # Verifica se é um poder
		activate_power(collectible)
	elif collectible.has_method("shoot"):  # Verifica se é um poder
		pass
	else:
		collectible.queue_free()  # Remove o objeto do cenário
		print("Pontos: ", points_count)
	Events.update_laps.emit()

func _on_finish_line_detector_area_entered(_area):
	self.get_owner().set_winner(get_player_number())
	Events.level_completed.emit()
	disabled_state()
	sfx_finish.play()


func disabled_state():
	set_invulnerable(true)
	input_enabled = false

func enabled_state():
	deactivate_power()
	set_invulnerable(false)
	input_enabled = true


func _on_lap_line_detector_area_entered(_area: Area2D) -> void:
	Events.update_laps.emit()


func get_player_number() -> int:
	for i in range(1, 5):  # Assumindo um máximo de 4 jogadores
		if name == "Player" + str(i):
			return i
	return -1  # Retorna -1 caso o jogador não seja identificado


func apply_random_force_in_cone(force_magnitude: float):
	# Define o ângulo central (em radianos) e a amplitude do cone
	var cone_angle_center = -PI / 2 # 90 graus para cima 
	var cone_angle_range = deg_to_rad(90) / 2 # 25 graus para cada lado
	# Gera um ângulo aleatório dentro do cone
	var random_angle = cone_angle_center + randf_range(-cone_angle_range, cone_angle_range)
	# Calcula o vetor da direção usando o ângulo
	var force_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
	# Aplica a força multiplicando pela magnitude desejada
	var force_vector = force_direction * force_magnitude
	
	velocity += force_vector


func disable_input_for_seconds(seconds: float):
	if not input_enabled:
		return
	else:
		input_enabled = false
	
	# Cria um Timer para reativar os inputs após segundos
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_enable_input"))
	add_child(timer)
	timer.start()

func _enable_input() -> void:
	input_enabled = true

# --------------------------------------
# - Poderes
func activate_power(power_node):
	if power_node.is_power:
		if active_power != null:
			print("Um poder já está ativo. Coletável ignorado.")
			return  # Evita ativar outro poder enquanto um já está ativo
		print("Ativando poder do tipo: ", power_node.power_type)
		active_power = power_node.power_type
		
		match active_power:
			1:
				print("Ativando invulnerabilidade")
				set_invulnerable(true)
			2:
				print("Ativando habilidade de disparar projéteis")
				can_shoot = true
				projectile_timer.start(1.0)
			3:
				print("Ativando super pulo")
				movement_data.jump_velocity *= 1.5
			4:
				print("Ativando chuva")
				activate_rain()
		
		# Atualiza o ícone do poder
		update_power_icon(power_node.power_type)
		
		# Configura o PowerTimer para desativar o poder após 5 segundos
		if not power_timer.is_stopped():
			power_timer.stop()  # Garante que o timer não está ativo
		power_timer.start(10.0)
	else:
		# Caso não seja um poder (ex: maçã)
		points_count += 1
		print("Pontos coletados: ", points_count)
	# Remove o objeto do cenário
	power_node.queue_free()
	# Som de coletando moeda
	sfx_coin.play()


func deactivate_power():
	# Certifica-se de que o poder ativo está sendo desativado
	if active_power == null:
		print("Nenhum poder ativo para desativar.")
		return

	print("Desativando poder do tipo: ", active_power)

	match active_power:
		1: set_invulnerable(false)  # Desativa invulnerabilidade
		2: 
			can_shoot = false
			projectile_timer.stop()  # Para o disparo automático
		3: movement_data.jump_velocity /= 1.5  # Restaura o pulo original
		4: Events.remove_rain_effect.emit()  # Remove o efeito de chuva

	# Remove o ícone do poder
	update_power_icon(-1)
	active_power = null
	

func set_invulnerable(state: bool):
	is_invulnerable = state
	
	if is_invulnerable:
		# Exemplo: Tornar o jogador semi-transparente para indicar invulnerabilidade
		if animated_sprite_2d:
			animated_sprite_2d.modulate = Color(1, 1, 1, 0.5)
	else:
		# Voltar à aparência normal
		if animated_sprite_2d:
			animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func update_power_icon(power_type: int):
	if power_type >= 0 and power_type < power_icons.size():
		power_icon.texture = power_icons[power_type]  # Define o ícone com base no tipo do poder
		power_icon.position = power_icon_offset  # Aplica o offset
		power_icon.scale = Vector2(0.4, 0.4)  # Reduz o tamanho para 50% (ajuste conforme necessário)
		power_icon.visible = true  # Exibe o ícone
	else:
		power_icon.visible = false  # Oculta o ícone quando não há poder ativo

func activate_rain():
	Events.apply_rain_effect.emit()
	remove_rain_effect()
func deactivate_rain():
	Events.remove_rain_effect.emit()

func _on_rain_effect_applied():
	if not is_slowed:
		is_slowed = true
		#movement_data.speed *= 0.5  # Reduz a velocidade pela metade
		#movement_data.accelleration *= 0.5  # Reduz a aceleração pela metade
		# Opcional: Adicione efeitos visuais para o jogador
		if animated_sprite_2d:
			animated_sprite_2d.modulate = Color(0.5, 0.5, 1, 1)  # Muda para um tom azulado

func _on_rain_effect_removed():
	if is_slowed:
		is_slowed = false
		#movement_data.speed *= 2  # Restaura a velocidade original
		#movement_data.accelleration *= 2  # Restaura a aceleração original
		# Opcional: Restaure os efeitos visuais
		if animated_sprite_2d:
			animated_sprite_2d.modulate = Color(1, 1, 1, 1)
			
func remove_rain_effect():
	is_slowed = false
	#movement_data.speed *= 2  # Restaura a velocidade original
	#movement_data.accelleration *= 2  # Restaura a aceleração original
	# Opcional: Restaure os efeitos visuais
	if animated_sprite_2d:
		animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func shoot_projectile():
	if not can_shoot:
		return  # Não dispara se o jogador não puder atirar ou se não houver cena da flecha

	# Instancia a flecha
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.shooter_instance = self  # Define o jogador como o atirador da flecha
	
	# Adiciona a flecha à cena
	get_parent().add_child(arrow)
	
	# Define a direção com base no jogador
	var direction = Vector2(1, 0)  # Direção para a direita
	if animated_sprite_2d.flip_h:
		direction = Vector2(-1, 0)  # Direção para a esquerda
	arrow.shoot(global_position, direction, self)

func get_points_count() -> int:
	return points_count

func add_points(number):
	points_count += number

func get_current_lap() -> int:
	return current_lap

func set_current_lap(lap):
	current_lap = lap
