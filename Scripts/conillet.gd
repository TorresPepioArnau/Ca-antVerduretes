extends CharacterBody2D

#fsm
enum Estats { IDLE, MOVE, ATTACK, HURT }
var estat_actual : Estats = Estats.IDLE

@export var velocitat : float = 350.0
@onready var sprite = $Sprite2D
@onready var area_atac = $AreaAtac
@onready var colisio_atac = $AreaAtac/CollisionShape2D
@onready var efecte_area = $EfecteArea
@onready var timer_cooldown = $TimerCooldown
@onready var barraVida = $%BarraVida
@onready var tempsPartida = $HUD/HUD/TempsPartida
@export var vida_maxima : int = 50

#HP del conillet
var vida_actual : int

#Temps de joc
var time = 0

#Attacks
var flowerSpear = preload("res://Scenes/Attacks/flowerSpear.tscn")

#AttackNodes
@onready var flowerSpearTimer = get_node("%FlowerSpearTimer")
@onready var flowerSpearAttackTimer = get_node("%FlowerSpearAttackTimer")

#FlowerSpear
var flowerspear_amno = 0
var flowerspear_baseamno = 1
var flowerspear_attackspeed = 1.5
var flowerspear_level = 1

#Enemy related
var enemy_close = []

#cooldown
var pot_atacar : bool = true

func _ready() -> void:
	vida_actual = vida_maxima
	
	efecte_area.visible = false 
	efecte_area.modulate.a = 0.0
	
	#connectar_timer
	timer_cooldown.timeout.connect(permetre_atac)
	
	attack()
	_on_hurt_box_hurt(0)


func _physics_process(_delta: float) -> void:
	var direccio_pantalla = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#saltar
	if Input.is_action_just_pressed("ui_accept") and pot_atacar and (estat_actual == Estats.IDLE or estat_actual == Estats.MOVE):
		iniciar_atac()
	
	match estat_actual:
		Estats.IDLE:
			estat_idle(direccio_pantalla)
		Estats.MOVE:
			estat_move(direccio_pantalla)
		Estats.ATTACK:
			pass 
		Estats.HURT:
			estat_hurt()

	move_and_slide()

func iniciar_atac() -> void:
	estat_actual = Estats.ATTACK
	pot_atacar = false
	
	velocity = Vector2.ZERO 
	sprite.position.y = 0.0 
	
	var tween = create_tween()
	var alcada_salt = 80.0 
	var temps_salt = 0.25 
	
	#pujar
	tween.tween_property(sprite, "position:y", -alcada_salt, temps_salt).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#baixar
	tween.tween_property(sprite, "position:y", 0.0, temps_salt).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#aterrar
	tween.tween_callback(_on_aterratge)

#estats

func estat_idle(direccio: Vector2) -> void:
	velocity = Vector2.ZERO
	#moure
	if direccio != Vector2.ZERO:
		estat_actual = Estats.MOVE
	#animacio

func estat_move(direccio: Vector2) -> void:
	if direccio == Vector2.ZERO:
		estat_actual = Estats.IDLE
		return
		
	#isometric
	var direccio_isometrica = Vector2.ZERO
	direccio_isometrica.x = direccio.x - direccio.y
	direccio_isometrica.y = (direccio.x + direccio.y) * 0.5
	
	#velocitat
	velocity = direccio_isometrica.normalized() * velocitat
	
	#direccio
	if direccio.x < 0:
		sprite.flip_h = false
	elif direccio.x > 0:
		sprite.flip_h = true

func estat_hurt() -> void:
	#impuls
	pass

#rebre_dany
func rebre_dany(quantitat: int) -> void:
	if estat_actual != Estats.HURT:
		estat_actual = Estats.HURT
		vida_actual -= quantitat
		print("Ui! M'han fet dany. Vida restant: ", vida_actual)
		
		if vida_actual <= 0:
			print("El conillet ha estat derrotat!")
			#gameover
		else:
			#viu
			estat_actual = Estats.IDLE

func _on_aterratge() -> void:
	#efecte
	efecte_area.visible = true 
	efecte_area.modulate.a = 1.0 
	
	#mal
	colisio_atac.disabled = false
	var cossos_dins = area_atac.get_overlapping_bodies()
	for verdura in cossos_dins:
		if verdura.is_in_group("enemics") and verdura.has_method("rebre_dany"):
			verdura.rebre_dany(25)
	
	#aturar_mal
	colisio_atac.disabled = true
			
	#fade
	var fade_tween = create_tween()
	fade_tween.tween_property(efecte_area, "modulate:a", 0.0, 0.3) 
	fade_tween.tween_callback(func(): efecte_area.visible = false)
	
	#idle
	estat_actual = Estats.IDLE
	
	#timer
	timer_cooldown.start()

#semafor
func permetre_atac() -> void:
	pot_atacar = true


func _on_hurt_box_hurt(damage: Variant) -> void:
	vida_actual -= damage
	print(vida_actual)
	barraVida.max_value = vida_maxima
	barraVida.value = vida_actual

func attack() -> void:
	if flowerspear_level > 0:
		flowerSpearTimer.wait_time = flowerspear_attackspeed
		if flowerSpearTimer.is_stopped():
			flowerSpearTimer.start()


func _on_flower_spear_timer_timeout() -> void:
	flowerspear_amno += flowerspear_baseamno
	flowerSpearAttackTimer.start()

func _on_flower_spear_attack_timer_timeout() -> void:
	if flowerspear_amno > 0:
		var flowerspear_attack = flowerSpear.instantiate()
		flowerspear_attack.position = position
		flowerspear_attack.target = get_random_target()
		flowerspear_attack.level = flowerspear_level
		add_child(flowerspear_attack)
		flowerspear_amno -= 1
		if flowerspear_amno > 0:
			flowerSpearAttackTimer.start()
		else:
			flowerSpearAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)

func change_time(argtime =0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str (0,get_m)
	if get_s < 10:
		get_s = str (0,get_s)
	tempsPartida.text = str (get_m,":",get_s)
			
