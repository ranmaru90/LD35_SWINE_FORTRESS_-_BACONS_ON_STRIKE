
extends Area2D

const SQUARE = 0
const TRIANGLE = 1

export var current_shape = SQUARE

onready var fortress = get_parent().get_parent()
onready var fortress_body = get_parent()
onready var swine_sprite = get_node("swine_sprite")
onready var swine_saliva = swine_sprite.get_node("saliva_particles")
onready var water_gun = get_node("swine_attack").get_node("water_gun")
onready var swine_animation = get_node("swine_morph_animation")
onready var swine_move_animation = get_node("swine_move_animation")

var is_selected = false
var has_water = false
var has_food = false

# PUBLIC #

# call from swine_animation node
func set_shape(shape):
	current_shape = shape


# PRIVATE #

func _ready():
	swine_animation.set_speed(1)
	swine_move_animation.set_speed(1)	
	swine_move_animation.play("moving")
	
	if current_shape == SQUARE:
		swine_animation.play("to_square")
	elif current_shape == TRIANGLE:
		swine_animation.play("to_triangle")
	
	if has_water or has_food:
		swine_animation.play("to_square")
		swine_saliva.set_emitting(true)
	else:
		swine_animation.play("to_triangle")
		swine_saliva.set_emitting(false)


func _on_swine_mouse_enter():	
	swine_sprite.set_modulate(Color(1.0, 0.54, 0.77))
	is_selected = true


func _on_swine_mouse_exit():
	swine_sprite.set_modulate(Color(1.0, 1.0, 1.0))
	is_selected = false


func _on_swine_input_event( viewport, event, shape_idx ):
	if is_selected:		
		if event.type == InputEvent.MOUSE_BUTTON:
			swine_animation.set_speed(1)
			if current_shape == SQUARE:
				swine_animation.play("to_triangle")
				has_water = false
				swine_saliva.set_emitting(false)
				water_gun.set_emitting(true)


func _on_mouth_area_area_enter( area ):	
	if area.get_name() == "water_tray" and not has_water:
		has_water = true
		swine_saliva.set_emitting(true)
		swine_animation.play("to_square")
		fortress_body.set_applied_force((fortress_body.get_pos() - get_pos()).normalized() * -1000)


func _on_swine_area_enter( area ):
	if area.get_name() == "water_tray" or area.get_name() == "fenced":
		fortress.stopped = true
		fortress_body.set_linear_velocity((fortress_body.get_pos() - get_pos()).normalized() * - 5)
		fortress_body.set_applied_force((fortress_body.get_pos() - get_pos()).normalized() * -1000)


func _on_swine_area_exit( area ):
	fortress.stopped = false


func _on_swine_attack_body_enter( body ):
	if water_gun.is_emitting():
		print("attack_shape")