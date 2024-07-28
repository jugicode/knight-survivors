class_name Enemy
extends Node2D

@export_category("Life-death")
@export var health: int  = 10
@export var death_prefab: PackedScene

@onready var damage_digit_marker = $DamageMarker
var damage_digit_prefab: PackedScene

@export_category("Drops")
@export var drop_chance: float = 0.1 #chance do inimigo dropar algo
@export var drop_items: Array[PackedScene]
@export var drop_chance_2: Array[float]

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int):
	health -= amount
	print("Inimigo recebeu dano de ", amount, ". A vida total é de ", health)
	
	#piscar inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# criar damage_digit

	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	#processar morte
	if health <= 0:
		die()

func die():
	#SKULL
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object) #registra na cena para ser processado
	
	#DROP MOB
	if randf() <= drop_chance:
		drop()
	
	#incrementar contador
	GameManager.monsters_defeated_counter += 1
	
	#deletar node
	queue_free()

func drop():
	var dropping = get_drop().instantiate()
	dropping.position = position
	get_parent().add_child(dropping)

func get_drop() -> PackedScene:
	#listas com 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	#chance máxima
	var max_chance: float = 0
	for drop_chance in drop_chance_2:
		max_chance += drop_chance
	
	#jogar dado
	var random_value = randf() * max_chance
	
	#iterar itens (roleta)
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance  = drop_chance_2[i] if i < drop_chance_2.size() else 1
		if random_value <- drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
	
