class_name RecoilSystem
extends Node

var target_recoil: Vector2 = Vector2.ZERO
var recoil_speed: float = 20.0

var total_recoil_accumulated: Vector2 = Vector2.ZERO
var recovery_speed: float = 12.0
var recovering: bool = false
var time_since_last_shot: float = 0.0

func add_recoil(pitch_rad: float, yaw_rad: float):
	var step = Vector2(yaw_rad, pitch_rad)
	target_recoil += step
	total_recoil_accumulated += step
	time_since_last_shot = 0.0
	recovering = false

func _process(delta: float):
	time_since_last_shot += delta
	var player = get_player()
	if not player or not player.has_method("apply_recoil"):
		return
		
	# 1. Aplicar la patada de recoil activa
	if target_recoil.length_squared() > 0.000001:
		var recoil_step = target_recoil * recoil_speed * delta
		if recoil_step.length() > target_recoil.length():
			recoil_step = target_recoil
			
		target_recoil -= recoil_step
		player.apply_recoil(recoil_step.y, recoil_step.x)
	else:
		# Si ya terminamos de patear y pasó un tiempo, empezamos a recuperar
		if time_since_last_shot > 0.15: # Ligeramente mayor al fire_rate típico
			recovering = true
			
	# 2. Recuperar la cámara a su postura original
	if recovering and total_recoil_accumulated.length_squared() > 0.000001:
		var recovery_step = total_recoil_accumulated * recovery_speed * delta
		if recovery_step.length() > total_recoil_accumulated.length():
			recovery_step = total_recoil_accumulated
			
		total_recoil_accumulated -= recovery_step
		
		# Se aplica en negativo para deshacer el salto previo de la cámara
		player.apply_recoil(-recovery_step.y, -recovery_step.x)
		
		if total_recoil_accumulated.length_squared() < 0.000001:
			total_recoil_accumulated = Vector2.ZERO
			recovering = false

func get_player() -> CharacterBody3D:
	var curr = get_parent()
	while curr:
		if curr is CharacterBody3D:
			return curr
		curr = curr.get_parent()
	return null
