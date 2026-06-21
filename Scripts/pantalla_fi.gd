extends Control

#escenes_connexio
const ESCENA_JOC = "res://Scenes/escenari.tscn"
const ESCENA_MENU = "res://Scenes/MenuPrincipal.tscn"

@onready var contenidor = $Contenidor
@onready var label_temps = $TempsFinal
@onready var boto_tornar = $Contenidor/BotoTornar
@onready var boto_menu = $Contenidor/BotoMenu

#sprites_decoracio
@onready var pastanaga_anim = $Decoracio/Pastanaga
@onready var trevol = $Decoracio/Trevol
@onready var trevol2 = $Decoracio/Trevol2
@onready var flor = $Decoracio/Flor

#variables_particules
var llista_particules = []

func _ready() -> void:
	#llegir_temps_guardat_al_autoload
	label_temps.text = "Has aguantat: " + Globals.temps_final_text
	
	#preparar_animacio
	contenidor.modulate.a = 0.0
	contenidor.scale = Vector2(0.5, 0.5)
	contenidor.pivot_offset = contenidor.size / 2.0
	
	#animacio_entrada
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(contenidor, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(contenidor, "modulate:a", 1.0, 0.8)
	
	tween.chain().tween_callback(boto_tornar.grab_focus)
	
	boto_tornar.mouse_entered.connect(_on_hover.bind(boto_tornar))
	boto_tornar.mouse_exited.connect(_on_sortir_hover.bind(boto_tornar))
	boto_menu.mouse_entered.connect(_on_hover.bind(boto_menu))
	boto_menu.mouse_exited.connect(_on_sortir_hover.bind(boto_menu))
	
	boto_tornar.pressed.connect(_on_boto_tornar_pressed)
	boto_menu.pressed.connect(_on_boto_menu_pressed)
	
	#iniciar_decoracio_fons
	animar_pastanaga()
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
			element.position.y = randf_range(0, alcada)

#animacio_pastanaga
func animar_pastanaga() -> void:
	var amplada = get_viewport_rect().size.x
	var alcada_terra = 550.0 
	
	#posicio_inicial
	pastanaga_anim.position = Vector2(-150, alcada_terra) 
	
	#bucle_infinit
	var tween_decoracio = create_tween().set_loops()
	
	#moure_dreta
	tween_decoracio.tween_property(pastanaga_anim, "position:x", amplada + 150, 4.0)
	
	#reiniciar_esquerra
	tween_decoracio.tween_property(pastanaga_anim, "position:x", -150, 0.0)

#clonar_i_repartir_floretes
func generar_floretes() -> void:
	var amplada = get_viewport_rect().size.x
	var alcada = get_viewport_rect().size.y
	
	var llista_originals = [trevol, trevol2, flor]
	var llista_probabilitats = [trevol, trevol2, flor, flor]
	
	#afegir_originals
	llista_particules.append_array(llista_originals)
	
	#crear_15_clons_nous
	for i in range(15):
		var base_escollida = llista_probabilitats.pick_random()
		var clon = base_escollida.duplicate()
		$Decoracio.add_child(clon)
		llista_particules.append(clon)
		
	#repartir_totes_per_la_pantalla
	for element in llista_particules:
		#mida
		var mida = randf_range(0.6, 1.2)
		element.scale = Vector2(mida, mida)
		
		#repartides_per_tota_la_pantalla
		element.position.x = randf_range(0, amplada)
		element.position.y = randf_range(0, alcada)
		
		#velocitat_vent_suau
		var velocitat_vent = randf_range(10.0, 35.0)
		element.set_meta("velocitat", velocitat_vent)

#tornar_a_jugar
func _on_boto_tornar_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_JOC)

#tornar_al_menu
func _on_boto_menu_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)

#animacions_botons
func _on_hover(boto: Button) -> void:
	boto.pivot_offset = boto.size / 2.0 
	var tween = create_tween()
	tween.tween_property(boto, "scale", Vector2(1.2, 1.2), 0.1)

func _on_sortir_hover(boto: Button) -> void:
	var tween = create_tween()
	tween.tween_property(boto, "scale", Vector2(1.0, 1.0), 0.1)
