extends Position2D

export(float) var GRAVEDAD = 5000
export(float) var VEL_MOVIMIENTO = 4000
export(float) var VEL_SALTO = 5000
var puede_disparar = true
var esta_en_agua = false
enum estados {idle, cuerpo_tierra, sumergido, apuntando_diagarr, apuntando_diagab, apuntando_arr, corriendo, apuntando_ab}
var estado_actual = idle
export(PackedScene) var bala_comun
export(Vector2) var spawnB_izq
export(Vector2) var spawnB_izqAR
export(Vector2) var spawnB_izqAB
export(Vector2) var spawnB_arr

var velocidad = Vector2()
var puede_saltar = false


func _ready():
	spawnB_izq = $cuerpo_j1/spawnBala.position

func _physics_process(delta):
	
	velocidad.y += GRAVEDAD * delta
	
	if Input.is_action_pressed("ui_left") && estado_actual != cuerpo_tierra && estado_actual != sumergido:
		velocidad.x = -VEL_MOVIMIENTO
		
		$cuerpo_j1/Spr_j1.flip_h = false
		if Input.is_action_pressed("ui_up") && puede_saltar && !esta_en_agua:
			if estado_actual != apuntando_diagarr:
				$animacion_j1.play("j1_diagar")
				$cuerpo_j1/spawnBala.position = spawnB_izqAR
				estado_actual = apuntando_diagarr
		elif Input.is_action_pressed("ui_down") && puede_saltar && !esta_en_agua:
			if estado_actual != apuntando_diagab:
				$animacion_j1.play("j1_diagab")
				$cuerpo_j1/spawnBala.position = spawnB_izqAB
				estado_actual = apuntando_diagab
		elif estado_actual != corriendo && puede_saltar:
			if !esta_en_agua:
				$animacion_j1.play("j_corriendo")
			else:
				$animacion_j1.play("j1_watermove")
			estado_actual = corriendo
			$cuerpo_j1/spawnBala.position = spawnB_izq
		elif estado_actual != corriendo && !puede_saltar:
			$cuerpo_j1/spawnBala.position = spawnB_izq
	elif Input.is_action_pressed("ui_right") && estado_actual != cuerpo_tierra && estado_actual != sumergido:
		velocidad.x = VEL_MOVIMIENTO
		$cuerpo_j1/Spr_j1.flip_h = true
		if Input.is_action_pressed("ui_up") && puede_saltar && !esta_en_agua:
			if estado_actual != apuntando_diagarr:
				$animacion_j1.play("j1_diagar")
				$cuerpo_j1/spawnBala.position = Vector2(spawnB_izqAR.x * -1, spawnB_izqAR.y)
				estado_actual = apuntando_diagarr
		elif Input.is_action_pressed("ui_down") && puede_saltar && !esta_en_agua:
			if estado_actual != apuntando_diagab:
				$animacion_j1.play("j1_diagab")
				$cuerpo_j1/spawnBala.position = Vector2(spawnB_izqAB.x * -1, spawnB_izqAB.y)
				estado_actual = apuntando_diagab
		elif estado_actual != corriendo && puede_saltar:
			if !esta_en_agua:
				$animacion_j1.play("j_corriendo")
			else:
				$animacion_j1.play("j1_watermove")
			estado_actual = corriendo
			$cuerpo_j1/spawnBala.position = Vector2(spawnB_izq.x * -1, spawnB_izq.y)
		elif estado_actual != corriendo && !puede_saltar:
			$cuerpo_j1/spawnBala.position = Vector2(spawnB_izq.x * -1, spawnB_izq.y)
	elif Input.is_action_pressed("ui_up") && estado_actual != cuerpo_tierra && estado_actual != sumergido:
		if puede_saltar && !esta_en_agua:
			$animacion_j1.play("j1_haciaarriba")
			$cuerpo_j1/spawnBala.position = spawnB_arr
			estado_actual = apuntando_arr
		elif !puede_saltar && !esta_en_agua:
			 $cuerpo_j1/spawnBala.position = spawnB_arr
		velocidad.x = 0
	elif Input.is_action_pressed("ui_down"):
		if puede_saltar:
			if !esta_en_agua:
				$animacion_j1.play("j1_cuerpotierra")
				estado_actual = cuerpo_tierra
			else:
				$animacion_j1.play("j1_waterunder")
		else:
			$cuerpo_j1/spawnBala.position = Vector2(spawnB_arr.x, spawnB_arr.y * -1)
			estado_actual = apuntando_ab
		velocidad.x = 0
	else:
		velocidad.x = 0
		if puede_saltar:
			estado_actual = idle
			if !esta_en_agua:
				$animacion_j1.play("j_idle")
				if estado_actual == cuerpo_tierra:
					$cuerpo_j1.global_position -= Vector2(0, 35)
			else:
				$animacion_j1.play("j1_water")
		
	

	if Input.is_action_pressed("tecla_z") && puede_saltar && estado_actual != sumergido:
		if estado_actual != cuerpo_tierra:
			velocidad.y = -VEL_SALTO
			$animacion_j1.play("j1_salto")
		else:
			$cuerpo_j1.global_position += Vector2(0, 1)
			estado_actual = idle
			$animacion_j1.play("j_idle")
		
		
	
	if Input.is_action_just_pressed("tecla_x") && puede_disparar:
		var newBala = bala_comun.instance()
		newBala.global_position = $cuerpo_j1/spawnBala.global_position
		get_tree().get_nodes_in_group("main")[0].add_child(newBala)
		puede_disparar = false
		$cuerpo_j1/tmr_cooldown.start()
		if estado_actual == apuntando_arr:
			newBala.velocidad.y = -newBala.potencia
		elif estado_actual == idle || estado_actual == corriendo || estado_actual == cuerpo_tierra:
			if $cuerpo_j1/Spr_j1.flip_h:
				newBala.velocidad.x = newBala.potencia
			else:
				newBala.velocidad.x = -newBala.potencia
		
		elif estado_actual == apuntando_diagarr:
			if $cuerpo_j1/Spr_j1.flip_h:
				newBala.velocidad = Vector2(newBala.potencia, -newBala.potencia)
			else:
				newBala.velocidad = Vector2(-newBala.potencia, -newBala.potencia)
		elif estado_actual == apuntando_diagab:
			if $cuerpo_j1/Spr_j1.flip_h:
				newBala.velocidad = Vector2(newBala.potencia, newBala.potencia)
			else:
				newBala.velocidad = Vector2(-newBala.potencia, newBala.potencia)
		elif estado_actual == apuntando_ab && !puede_saltar:
			newBala.velocidad.y = newBala.potencia
		puede_saltar = false
		
	if Input.is_action_just_released("ui_down"):
		estado_actual = idle
		
	var movimiento = velocidad * delta
	
	$cuerpo_j1.move_and_slide(movimiento)
	
	if($cuerpo_j1.get_slide_collision($cuerpo_j1.get_slide_count()-1) != null):
		var obj_colisionado = ($cuerpo_j1.get_slide_collision($cuerpo_j1.get_slide_count()-1).collider)
		if(obj_colisionado.is_in_group("suelo")):
			if puede_saltar == false:
				$animacion_j1.stop()
				puede_saltar = true
				if(obj_colisionado.is_in_group("agua")):
					esta_en_agua = true
				else:
					esta_en_agua = false
	elif puede_saltar:
		puede_saltar = false

func _on_tmr_cooldown_timeout():
	puede_disparar = true
