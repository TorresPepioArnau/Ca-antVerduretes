extends Control

#escena_joc
const ESCENA_JOC = "res://Scenes/escenari.tscn"

@onready var contenidor = $Contenidor
@onready var boto_jugar = $Contenidor/BotoJugar
@onready var boto_sortir = $Contenidor/BotoSortir

#sprites_decoracio
@onready var conillet_anim = $Decoracio/Conillet
@onready var pastanaga_anim = $Decoracio/Pastanaga
@onready var trevol = $Decoracio/Trevol
@onready var trevol2 = $Decoracio/Trevol2
@onready var flor = $Decoracio/Flor

#variables_particules
var llista_particules = []

func _ready() -> void:
	#preparar_animacio
	contenidor.modulate.a = 0.0
	contenidor.scale = Vector2(0.5, 0.5)
	
	#centrar_pivots
	contenidor.pivot_offset = contenidor.size / 2.0
	
	#animacio_entrada
	var tween_entrada = create_tween()
	tween_entrada.set_parallel(true)
	tween_entrada.tween_property(contenidor, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween_entrada.tween_property(contenidor, "modulate:a", 1.0, 0.8)
	
	#focus
	tween_entrada.chain().tween_callback(boto_jugar.grab_focus)
	
	#connectar_hover
	boto_jugar.mouse_entered.connect(_on_hover.bind(boto_jugar))
	boto_jugar.mouse_exited.connect(_on_sortir_hover.bind(boto_jugar))
	boto_sortir.mouse_entered.connect(_on_hover.bind(boto_sortir))
	boto_sortir.mouse_exited.connect(_on_sortir_hover.bind(boto_sortir))

	#iniciar_fons
	animar_decoracio()
	generar_floretes()

func _process(delta: float) -> void:
	var amplada = get_viewport_rect().size.x
	var alcada = get_viewport_rect().size.y
	
	#moure_particules_constantment
	for element in llista_particules:
		var velocitat = element.get_meta("velocitat")
		element.position.x -= velocitat * delta
		
		#reiniciar_a_la_dreta_quan_surten
		if element.position.x < -100:
			element.position.x = amplada + 100
			#reaparicio_per_tota_la_pantalla
			element.position.y = randf_range(0, alcada)

#animacio_sprites_fons
func animar_decoracio() -> void:
	var amplada = get_viewport_rect().size.x
	var alcada_terra = 630.0 
	
	#girar_conillet
	conillet_anim.flip_h = true
	pastanaga_anim.flip_h = true
	
	#posicions_inicials
	conillet_anim.position = Vector2(-50, alcada_terra)
	pastanaga_anim.position = Vector2(-350, alcada_terra) 
	
	#bucle_infinit
	var tween_decoracio = create_tween().set_loops()
	
	#moure_dreta
	tween_decoracio.tween_property(conillet_anim, "position:x", amplada + 350, 4.0)
	tween_decoracio.parallel().tween_property(pastanaga_anim, "position:x", amplada + 50, 4.0)
	
	#reiniciar_esquerra
	tween_decoracio.tween_property(conillet_anim, "position:x", -50, 0.0)
	tween_decoracio.parallel().tween_property(pastanaga_anim, "position:x", -350, 0.0)

#clonar_i_repartir
func generar_floretes() -> void:
	var amplada = get_viewport_rect().size.x
	var alcada = get_viewport_rect().size.y
	
	var llista_originals = [trevol, trevol2, flor]
	#llista_trampejada_per_tenir_tantes_flors_com_trevols
	var llista_probabilitats = [trevol, trevol2, flor, flor]
	
	#afegir_originals
	llista_particules.append_array(llista_originals)
	
	#crear_nomes_15_clons_nous
	for i in range(15):
		var base_escollida = llista_probabilitats.pick_random()
		var clon = base_escollida.duplicate()
		$Decoracio.add_child(clon)
		llista_particules.append(clon)
		
	#repartir_totes_per_la_pantalla
	for element in llista_particules:
		#mida_molt_mes_petita
		var mida = randf_range(0.6, 1.2)
		element.scale = Vector2(mida, mida)
		
		#repartides_per_TOTA_la_pantalla (eix Y de 0 al final)
		element.position.x = randf_range(0, amplada)
		element.position.y = randf_range(0, alcada)
		
		#velocitat_vent_una_mica_mes_suau
		var velocitat_vent = randf_range(10.0, 35.0)
		element.set_meta("velocitat", velocitat_vent)

#jugar
func _on_boto_jugar_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_JOC)

#sortir
func _on_boto_sortir_pressed() -> void:
	get_tree().quit()

#hover_entrar
func _on_hover(boto: Button) -> void:
	boto.pivot_offset = boto.size / 2.0 
	var tween = create_tween()
	tween.tween_property(boto, "scale", Vector2(1.2, 1.2), 0.1)

#hover_sortir
func _on_sortir_hover(boto: Button) -> void:
	var tween = create_tween()
	tween.tween_property(boto, "scale", Vector2(1.0, 1.0), 0.1)
