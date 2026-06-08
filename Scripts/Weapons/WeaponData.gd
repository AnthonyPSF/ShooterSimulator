class_name WeaponData
extends Resource

@export var weapon_name: String = "Assault Rifle"
@export var fire_rate: float = 0.1 # Tiempo entre disparos en segundos
@export var muzzle_velocity: float = 800.0 # m/s

@export var magazine_size: int = 30
@export var max_reserve: int = 90
@export var reload_time: float = 2.0

# Array de Vector2: X = Yaw (horizontal), Y = Pitch (vertical) en grados.
# Representa el salto exacto que dará la cámara en cada disparo consecutivo.
@export var recoil_pattern: Array[Vector2] = []
