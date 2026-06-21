extends CharacterBody2D

# Variables
@export var movement_speed: int = 20
@export var vida: int = 10
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var so_mort: AudioStreamPlayer2D = $so_mort

func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()

	if direction.x > 0.1:
		sprite.flip_h = true
	elif  direction.x < -0.1:
		sprite.flip_h = false

func _on_hurt_box_hurt(damage: Variant) -> void:
	vida -= damage
	if vida <= 0:
		so_mort.play()
		hide() 
		await so_mort.finished 
		queue_free()

func rebre_dany(quantitat: int) -> void:
	_on_hurt_box_hurt(quantitat)
