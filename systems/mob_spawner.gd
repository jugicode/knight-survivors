class_name MobSpawner
extends Node2D

@onready var path_follow: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0

@export var creatures: Array[PackedScene]
var frequencia: float = 60.0

func _process(delta):
	if GameManager.is_game_over: return
	
	# TEMPORIZADOR (cooldown)
	cooldown -= delta
	if cooldown > 0: return
	
	# FREQUENCIA (quantas criaturas por min):
	# 60 monstros/min = 1 por seg
	# 120 monstros/min = 2 por seg
	# intervalo (s) entre monstros = 60s/frequencia (quantidade monstros por min)
	var intervalo = 60.0/frequencia
	cooldown = intervalo
	
	
	# INSTANCIAR criatura aleatória
	# precisa: pegar criatura
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	
	
	# checar se ponto é válido
	# precisa: pegar ponto aleatório
	var point = get_point()
	
	# perguntar se esse ponto tem colisão
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new() 
	parameters.position = point
	var result: Array = world_state.intersect_point(parameters, 1)   # 1 = max_results
	if not result.is_empty(): return
	
	# precisa: instanciar cena 
	var creature = creature_scene.instantiate()
	
	
	# precisa: colocar na posição
	creature.global_position = point
	
	
	#definir parent
	get_parent().add_child(creature)
	

func get_point() -> Vector2:
	path_follow.progress_ratio = randf()
	return path_follow.global_position


