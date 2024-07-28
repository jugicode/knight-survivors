class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3

@export_category("Sword")
@export var swordDamage: int =  2 

@export_category("Life")
#copiados do script enemy.gd
@export var health: int  = 100
@export var death_prefab: PackedScene
@export var max_health: int = 100

@export_category("Ritual")
#dano, frquencia, intervalo, prefab
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction: Sprite2D = $Sprite2D
@onready var swordArea: Area2D = $SwordArea
@onready var hitbox: Area2D = $hitbox
@onready var health_bar: ProgressBar = $health_bar

var is_running: bool = false
var is_attacking: bool = false #por padrão
var attack_cooldown: float = 0.0
var input_vector: Vector2 = Vector2(0, 0)
var hitbox_cooldown: float = 0.0

var ritual_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready():
	GameManager.player = self 
	meat_collected.connect(func(value: int): 
		GameManager.meat_counter += 1)

#temporizador do ataque
func _process(delta):
	# mandando posição do player para o Autoload
	GameManager.player_position = position
	
	# obter input_vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play('Idle')
			
	# atualizar is_running
	var movimento = is_running
	is_running = not input_vector.is_zero_approx()
	
	#tocar animação
	if not is_attacking:
		if movimento != is_running:
			if is_running:
				animation_player.play("Run")
			else:
				animation_player.play('Idle')
			
	#mudar direção de movimento
	if not is_attacking:
		if input_vector.x > 0:
			direction.flip_h = false
		elif input_vector.x < 0:
			direction.flip_h = true
			
	#processar dano
	update_hitbox_detection(delta)
	
	#ritual
	update_ritual(delta)
	
	#atualizar health bar
	health_bar.max_value = max_health
	health_bar.value = health


func _physics_process(delta: float):	
	# modificar velocidade
	var velocity2 = input_vector * speed * 100.0
	velocity = lerp(velocity, velocity2, 0.15)
	if is_attacking:
		velocity2 *= 0.25
	move_and_slide()
	
	#sistema de ataque
	if Input.is_action_just_pressed("attack"):
		attack()

func attack():
	
	if is_attacking:
		return
	
	animation_player.play("attack_side-1")
	attack_cooldown = 0.6
	is_attacking = true
	
	#aplicar dano nos inimigos
	##deal_damage_to_enemies() <<< fiz pelo animation

func deal_damage_to_enemies():
	#acessar todos os inimigos
	#chamar função "damage" com variável "swordDamage" como parâmetro 
	
	var bodies = swordArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if direction.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			print("Dot: ", dot_product)
			if dot_product >= 0.3:
				enemy.damage(swordDamage)
		
	#var enemies = get_tree().get_nodes_in_group("enemies")
	##print("Enemies: ", enemies.size())
	#for enemy in enemies:
		#enemy.damage(swordDamage)

func update_hitbox_detection(delta: float):
	#temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown >0: return # se o cooldown estiver em mais que 0, ignora o código abaixo. Caso contrário, processa
	
	#frequência (x por seg)
	hitbox_cooldown = 0.5
	
	#detectar inimigos
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 2
			damage(damage_amount)

#copiados do script enemy.gd
func damage(amount: int):
	if health <= 0: return #se o personagem estiver morto, não processa o resto do código
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health)
	
	#piscar player
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#processar morte
	if health <= 0:
		die()

func die():
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object) #registra na cena para ser processado
	
	print("Player morreu.")
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print ("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)
	return health
	

func update_ritual(delta: float):
	#atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	#resetar temporizador
	ritual_cooldown = ritual_interval
	
	#criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage #puxando variável do outro script 
	add_child(ritual) #isso faz o ritual andar junto do player
	
