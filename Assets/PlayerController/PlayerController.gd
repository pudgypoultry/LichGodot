extends Node3D

class_name PlayerController

enum CurrentMouseFocus {BOARD, HUD, FREELOOK}

var camera_speed = .5
var camera_scroll_speed = 0.7
var camera_move_speed = .1
var mouse_delta = Vector2()
var move_forward = false
var move_back = false
var move_left = false
var move_right = false
var currentMousePosition : Vector3 = Vector3(0,0,0)
var currentInteractable : Interactable
var hasNewFocus : bool = false
var hasLeftCard : bool = false
var playerActionable : bool = true

@export var cam : Camera3D
@export var mouseRay : RayCast3D


func _ready():
	BoardManager.playerController = self


# What should happen every frame for player control
func _process(delta):
	# camera rotation and reset
	var leftRight = Input.get_axis("camLeft", "camRight")
	var upDown = Input.get_axis("camDown", "camUp")
	var pressingLeftMouseButton = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if leftRight != 0:
		translate_object_local(camera_move_speed * Vector3(leftRight,0,0))
	if upDown != 0:
		position += camera_move_speed * -upDown * Vector3(cam.transform.basis.z.x, 0, cam.transform.basis.z.z).normalized()
	
	if pressingLeftMouseButton && mouseRay.is_colliding():
		# print("Current Mouse Position: ", mouseRay.get_collision_point())
		currentMousePosition = mouseRay.get_collision_point()
	
	var mouseCollision = cam.project_position(get_viewport().get_mouse_position(), cam.global_transform.origin.z)
	mouseRay.look_at(mouseCollision)
	currentMousePosition = mouseRay.get_collision_point()
