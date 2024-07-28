extends Node

@export var mob_spawner: MobSpawner
@export var initial_frequency: float = 60.0
@export var spawn_increase_frequency: float = 30.0
@export var wave_duration: float = 10.0
@export var break_intensity: float = 0.5

var time: float = 0.0


func _process(delta):
	if GameManager.is_game_over: return
	
	time += delta
	#linha verde (linear)
	var spawn_rate = initial_frequency + spawn_increase_frequency * (time/60.0)
	
	#linha rosa (onda)
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	#curva -> 2x Pi = TAU
	spawn_rate += wave_factor
	
	#aplicar dificuldade
	mob_spawner.frequencia = spawn_rate
