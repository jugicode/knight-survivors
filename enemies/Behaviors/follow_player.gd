extends Node

@export var speed = 1.0
#@onready var direction: AnimatedSprite2D = $AnimatedSprite2D

var direction: AnimatedSprite2D
var enemy: Enemy

func _ready():
	enemy = get_parent()
	direction = enemy.get_node("AnimatedSprite2D")
	

func _physics_process(delta):
	if GameManager.is_game_over: return
	
	#calcular direção
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position 
	var input_vector = difference.normalized()
	#input vector = vector2 que varia de -1 a 1 nos eixos
	
	#andar
	enemy.velocity = input_vector * speed *100.0
	enemy.move_and_slide()
	
	#mudar direção de movimento (girar sprite)
	if input_vector.x > 0:
		direction.flip_h = false
	elif input_vector.x < 0:
		direction.flip_h = true
