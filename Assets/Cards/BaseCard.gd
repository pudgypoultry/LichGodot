extends Interactable

class_name Card

enum CardType {NONE, COMPONENT, SPELL, MINION, LOCATION, DEATH}

signal slotted(type : CardType, rank : int)
signal card_spawned(card : Card)

@export_category("Card Qualities")
@export var cardName : String
var cardDescription : String
var cardTags : Array
var baseRank : int
var cardType : CardType
var cardPrimeID : int
var currentRank : int
var currentBox : Box = null
var isSlotted : bool = false
var isOnDeck : bool = false
var addToBoard : bool = true
var lastLocation : Vector3
var cardFront : MeshInstance3D
static var resourceLocation = "res://Assets/Cards/BaseCard.tscn"
@onready var cardMesh : MeshInstance3D = self.find_child("CardFront")

@export_category("Debug")
@export var startsInPlay : bool = false


static func MakeCopy(newCardName : String) -> Card:
	var cardCopy = load(resourceLocation).instantiate()
	cardCopy.cardName = newCardName
	return cardCopy


func CopyThisCard() -> Card:
	return MakeCopy(self.cardName)


func _ready():
	if addToBoard:
		BoardManager.AddCardToTable(self)
		self.card_spawned.emit(self)
	var cardStats = JSONAndLoadHandler.GetCardInfo(self)
	cardDescription = cardStats["DESCRIPTION"]
	cardPrimeID = cardStats["PRIMEID"]
	cardTags = cardStats["TAGS"]


# Before I am deleted, I need to be unslotted if I am slotted
func _exit_tree():
	if currentBox != null:
		currentBox.UnslotCard(self)


func _process(delta):
	super(delta)
	if isSlotted:
		position = currentBox.slotPosition.global_position


func SlotMe(newBox : Box):
	currentBox = newBox
	isSlotted = true
	newBox.AcceptCard(self)
	slotted.emit(cardType, currentRank, newBox)
	TweenTools.TweenPosition(self, tweenPosition, newBox.slotPosition.global_position, pickupSpeed)


func UnslotMe(oldBox : Box):
	isSlotted = false
	currentBox = null
	oldBox.UnslotCard(self)


"""=====================================================
Interactable Movement Management
====================================================="""

func PickMeUp():
	if isOnDeck:
		isOnDeck = false
		BoardManager.playerDeck.currentlyShowingCard = false
	if currentBox != null:
		UnslotMe(currentBox)
	if currentlyOfferedAsReward:
		currentRewardSpawner.spawnPointFilled[currentRewardNumber] = false
		currentlyOfferedAsReward = false
		currentRewardSpawner = null
	print("Picking up")
	ManageState(State.PICKEDUP)
	print("Moving to: ", position + Vector3(0, pickupHeightOffset, 0))
	position.y += pickupHeightOffset
	print("Current Position: ", position)


func IsValidDrop():
	if currentlyAbove is Box:
		if currentlyAbove.IsValidCard(self):
			return true
	if currentlyAbove == null:
		return true
	return false


func DropMe():
	canDrag = true
	if isFaceUp:
		ManageState(State.SETFACEUP)
	else:
		ManageState(State.SETFACEDOWN)
	
	if IsValidDrop() && currentlyAbove == null:
		print("Dropping...")
		print("	at ", Vector3(position.x, placeHeightOffset, position.z))
		TweenTools.TweenPosition(self, tweenPosition, Vector3(position.x, placeHeightOffset, position.z), pickupSpeed)
	elif IsValidDrop() && currentlyAbove != null:
		print("Dropping into ", currentlyAbove.name, "...")
		SlotMe(currentlyAbove)
	else:
		TweenTools.TweenPosition(self, tweenPosition, lastKnownPosition, pickupSpeed)
	
	playerController.currentInteractable = null
	print("Currently Above: ", currentlyAbove)
	currentlyAbove = null


"""=====================================================
In-Place Animation
====================================================="""

func FlipCard(landingHeight : float):
	TweenTools.TweenPosition(self, tweenPosition, Vector3(self.position.x, 3, self.position.z), 0.2)
	TweenTools.TweenRotation(self, tweenRotation, self.rotation + Vector3(0, 0, PI), 0.2)
	await get_tree().create_timer(0.1).timeout
	TweenTools.TweenPosition(self, tweenPosition, Vector3(self.position.x, landingHeight, self.position.z), 0.2)


func RevealNewCard(landingHeight : float):
	TweenTools.TweenPosition(self, tweenPosition, Vector3(self.position.x, 3, self.position.z), 0.2)
	TweenTools.TweenRotation(self, tweenRotation, self.rotation + Vector3(0, 0, 2*PI), 0.2)
	await get_tree().create_timer(0.1).timeout
	TweenTools.TweenPosition(self, tweenPosition, Vector3(self.position.x, landingHeight, self.position.z), 0.2)


"""=====================================================
Game Event Hooks
====================================================="""

func OnDraw():
	print("OnDraw() is not implemented for ", name, "!")

func OnUse():
	print("OnUse() is not implemented for ", name, "!")

func OnAttack():
	print("OnAttack() is not implemented for ", name, "!")

func OnStartOfTurn():
	print("OnStartOfTurn() is not implemented for ", name, "!")

func OnEndOfTurn():
	print("OnEndOfTurn() is not implemented for ", name, "!")
