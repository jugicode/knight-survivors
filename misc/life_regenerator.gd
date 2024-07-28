extends Node2D

@export var regeneration_amount: int = 10

#@onready var area2d: Area2D = $Area2D

func _ready(): #função que vem quando o Node está pronto
		$Area2D.body_entered.connect(entered_body)
		
		
	
func entered_body(body: Node2D):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amount)
		player.meat_collected.emit(regeneration_amount)  # <<<<<<
		queue_free()
