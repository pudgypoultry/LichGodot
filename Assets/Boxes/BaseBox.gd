extends Interactable

class_name Box

signal card_slotted(box : Box, card : Card)
signal card_unslotted(box : Box)
signal card_consumed(box : Box, card : Card)

@export_category("Game Rules")
@export var boxName : String
@export var boxDescription : String
var validTags : Array

@export_category("Plugging In Nodes")
@export var currentCard : Card = null
@export var slotPosition : Node3D
@export var rayToUI : RayCast3D
var hasCard : bool = false
var currentGroup : BoxGroup = null
var canBeManipulated : bool = true


func _ready():
	BoardManager.AddBoxToTable(self)
	placeHeightOffset = position.y


# Check if the card that we are attempting to slot is a valid one based on tag
func IsValidCard(cardToPlace : Card):
	var isValid = false
	
	for tag in cardToPlace.cardTags:
		if tag in validTags:
			isValid = true
			break
	
	if isValid && canBeManipulated:
		print_debug(cardToPlace.name, " is a valid card, allowed to dock")
		return true
	else:
		print(name, " rejected ", cardToPlace.cardName)
		print("	Here are its tags: ", cardToPlace.cardTags)
		#TODO FIX
		print("	Here my valid tags: ", cardToPlace.cardTags)
		return false


# If the card is valid, accept it, otherwise reject it
func AcceptCard(cardToPlace : Card):
	if IsValidCard(cardToPlace):
		canBeManipulated = false
		currentCard = cardToPlace
		print("Slotting ", currentCard.name, " into box...")
		currentGroup.NewCardSlotted(self)
		hasCard = true
		card_slotted.emit(self, cardToPlace)
		return true
	else:
		return false


func UnslotCard(cardToUnslot : Card):
	canBeManipulated = true
	currentGroup.CardUnslotted(self)
	currentCard = null
	card_unslotted.emit(self)


func ConsumeCard():
	if currentCard != null:
		card_consumed.emit(self, currentCard)
		currentCard.queue_free()
		currentCard = null


func PickMeUp():
	currentGroup.PickMeUp()


func DropMe():
	currentGroup.DropMe()
