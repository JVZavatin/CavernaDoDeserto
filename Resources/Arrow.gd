extends Area2D

@export var arrow_speed: float = 200  # Velocidade da flecha
@export var stun_duration: float = 5.0  # Duração do atordoamento
@export var shooter_instance: Node2D = null  # Referência ao jogador que disparou a flecha

@onready var direction: Vector2 = Vector2()  # Direção da flecha
@onready var sfx_shoot: AudioStreamPlayer = $sfx_shoot

var shooter: Node2D = null  # Jogador que disparou a flecha

func _ready():
	# Configuração inicial da flecha
	$Sprite2D.flip_h = direction.x < 0  # Gira a sprite se necessário
	set_physics_process(true)  # Habilita processamento físico

func _physics_process(delta):
	# Move a flecha constantemente na direção definida
	position += direction * arrow_speed * delta

func _on_body_entered(body):
	if body == shooter_instance:
		return  # Ignora o jogador que disparou
	if body.has_method("disable_input_for_seconds"):
		body._on_hazard_detector_area_entered(null)
		print("Jogador atordoado:", body.name)
		queue_free()  # Destroi a flecha após o impacto

func shoot(origin: Vector2, directionVector: Vector2, shooterNode: Node2D):
	#Posição Inicial
	global_position = origin
	#Direção da flecha
	self.direction = directionVector
	if (directionVector == Vector2(-1, 0)): 
		$Sprite2D.flip_h = true
	#Atirador
	shooter_instance = shooterNode
	sfx_shoot.play()
