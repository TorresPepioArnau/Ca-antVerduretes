extends Area2D

var level: int = 1
var vida: int = 1
var speed: int = 100
var damage: int = 5
var knock_amount: int = 100
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player") 

func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			vida = 1
			speed = 100
			damage = 5
			knock_amount = 100
			attack_size = 1.0

func _physics_process(delta: float) -> void:
	position += angle*speed*delta

func enemy_hit(charge = 1):
	vida -= charge
	if vida <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
