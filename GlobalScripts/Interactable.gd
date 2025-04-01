extends Node3D

class_name Interactable

enum DropPositions {BOARD, CARD, BOX}
enum State {SETFACEUP, SETFACEDOWN, PICKEDUP}

signal gainedFocus(newInteractable : Interactable)
signal lostFocus

@export_category("Placement Rules")
@export var mainCheckRay : RayCast3D
@export var pickupHeightOffset : float
@export var placeHeightOffset : float 
@export var pickupSpeed : float = 0.4

@export_category("Plugging in Nodes")
@export var playerController : PlayerController
var boardManager : BoardManager

@export_category("Debug")
@export var debug : bool = false

var canDrag : bool = false
var isDragging : bool = false
var isFaceUp : bool = true
var lastKnownPosition : Vector3
var currentState = State.SETFACEUP
var tweenPickup : Tween
var tweenPosition : Tween
var tweenRotation : Tween
var tweenScale : Tween
var currentlyAbove : Interactable = null
var currentlyOfferedAsReward = false
var currentRewardSpawner : RewardSpawner
var currentRewardNumber : int
var globalID : int

func _process(delta):
	if isDragging:
		pass
		# move item toward mouse position
	if Input.is_action_just_pressed("mouseInteract") && (currentState == State.SETFACEUP || currentState == State.SETFACEDOWN) && canDrag && playerController.currentInteractable == self:
		PickMeUp()
		await get_tree().create_timer(pickupSpeed + 0.1).timeout
	if Input.is_action_pressed("mouseInteract") && currentState == State.PICKEDUP:
		MoveMe()
	if !Input.is_action_pressed("mouseInteract") && currentState == State.PICKEDUP:
		DropMe()


func ManageState(newState : State):
	match newState:
		State.PICKEDUP:
			currentState = State.PICKEDUP
			lastKnownPosition = position
			isDragging = true
			canDrag = false
		State.SETFACEUP:
			currentState = State.SETFACEUP
			isDragging = false
		State.SETFACEDOWN:
			currentState = State.SETFACEDOWN
			isDragging = false


"""=====================================================
All Interactables Need To Define Click & Drag Rules
====================================================="""

func PickMeUp():
	print("PickMeUp() not implemented for ", name, "!")


func MoveMe():
	TweenTools.TweenPosition(self, tweenPosition, Vector3(playerController.currentMousePosition.x, position.y, playerController.currentMousePosition.z), 0.1)
	if mainCheckRay.is_colliding():
		currentlyAbove = mainCheckRay.get_collider().get_parent()
	else:
		currentlyAbove = null


func DropMe():
	print("DropMe() not implemented for ", name, "!")


func IsValidDrop():
	print("IsValidDrop() not implemented for ", name, "!")


"""=====================================================
Mouse Position Management
====================================================="""

func MouseEntered():
	if debug:
		print("Mouse entered ", name, "'s collider")
	if !Input.is_action_pressed("mouseInteract"):
		playerController.currentInteractable = self
		playerController.hasNewFocus = true
		canDrag = true
		self.gainedFocus.emit(self)


func MouseExited():
	if !isDragging:
		if debug:
			print("Mouse exited ", name, "'s collider")
		canDrag = false
	if !Input.is_action_pressed("mouseInteract"):
		playerController.hasLeftCard = true
		self.lostFocus.emit()
