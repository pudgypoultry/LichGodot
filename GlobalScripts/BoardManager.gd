extends Node

# Handles all logic of objects moving from zone to zone as well as setting up the board

@export var playerController : PlayerController
@export var playerUI : UIManager
@export var playerDeck : Deck

var boxes : Array[Box] = []
var cards : Array[Card] = []
var boxGroups : Array[BoxGroup] = []
var standardPlacementHeight = 0.151
var standardPickupHeight = 1
var globalID = 0

func _process(delta):
	if Input.is_action_just_pressed("testDraw"):
		DrawTopCardToTable()
		print("Cards ====> ", cards)
		print("Deck  ====> ", playerDeck.deck)
	if Input.is_action_just_pressed("testPut"):
		if len(cards) > 0:
			PutCardIntoDeck(0, cards[0])
			print("Cards ====> ", cards)
			print("Deck  ====> ", playerDeck.deck)


func CleanList(list):
	var nullsInList = []
	print(list)
	for i in range(len(list)):
		if list[i] == null:
			nullsInList.append(i)
	nullsInList.reverse()
	for item in nullsInList:
		list.remove_at(item)
	print(list)


func RemoveGlobalIDFromList(id : int, list : Array):
	var indexToRemove : int
	for i in range(len(list)):
		if list[i].globalID == id:
			indexToRemove = i
			break
	list.remove_at(indexToRemove)


"""=====================================================
General Management of Resources
====================================================="""

func AddInteractableToTable(newObject : Interactable):
	newObject.boardManager = self
	newObject.globalID = globalID
	globalID += 1


func AddCardToTable(newCard : Card):
	newCard.boardManager = self
	newCard.globalID = globalID
	globalID += 1
	cards.append(newCard)
	newCard.slotted.connect(HandleCardSlotted)
	newCard.playerController = playerController
	newCard.pickupHeightOffset = standardPickupHeight
	newCard.placeHeightOffset = standardPlacementHeight
	playerUI.SubscribeToInteractable(newCard)


func DrawTopCardToTable():
	var topCard = playerDeck.DrawFromTop()
	if topCard != null:
		# Instantiate copy of card
		var newCard = load(JSONAndLoadHandler.resourceLocationsDict["Card:" + topCard]).instantiate()
		get_tree().current_scene.add_child(newCard)
		# AddCardToTable(newCard)
		print(newCard.name)
		newCard.global_position = playerDeck.GetSpawnGlobalPosition()
		# Play animation of flipping from top of deck
		newCard.RevealNewCard(playerDeck.GetSpawnGlobalPosition().y)
		newCard.isOnDeck = true
		playerDeck.currentlyShowingCard = true
		newCard.OnDraw()
	else:
		print("No card to draw")


func PutCardIntoDeck(howFarDown : int, card : Card):
	playerDeck.InsertCardAtPosition(howFarDown, card.cardName)
	RemoveCardFromTable(card)


func RemoveCardFromTable(cardToRemove : Card):
	RemoveGlobalIDFromList(cardToRemove.globalID, cards)
	cardToRemove.queue_free()


func AddBoxToTable(newBox : Box):
	newBox.boardManager = self
	boxes.append(newBox)
	newBox.globalID = globalID
	globalID += 1
	newBox.card_slotted.connect(HandleNewCardInBox)
	newBox.card_unslotted.connect(HandleCardUnslotted)
	newBox.playerController = playerController
	playerUI.SubscribeToInteractable(newBox)
	newBox.boardManager = self


func RemoveBoxFromTable(boxToRemove : Box):
	boxes.erase(boxToRemove)
	boxToRemove.queue_free()


func AddBoxGroupToTable(newBoxGroup : BoxGroup):
	newBoxGroup.boardManager = self
	boxGroups.append(newBoxGroup)
	newBoxGroup.globalID = globalID
	globalID += 1
	newBoxGroup.playerController = playerController
	playerUI.SubscribeToInteractable(newBoxGroup)
	newBoxGroup.boardManager = self


func RemoveBoxGroupFromTable(groupToRemove : BoxGroup):
	boxGroups.erase(groupToRemove)
	groupToRemove.queue_free()


"""=====================================================
Signal Management
====================================================="""

func HandleCardSlotted(cardType, currentRank, newBox):
	print("A card with type ", cardType, " with rank ", currentRank, " was slotted into ", newBox.name)


func HandleNewCardInBox(slottedCard, newBox):
	print(slottedCard.name, " was slotted into ", newBox.name)


func HandleCardUnslotted(oldBox):
	print("A card was unslotted from ", oldBox.name)


"""=====================================================
Managing the start of the game
====================================================="""

func LoadBoard(rootNode, cardArray, boxArray, boxGroupArray):
	FindCards(rootNode, cardArray)
	FindBoxes(rootNode, boxArray)
	FindBoxGroups(rootNode, boxGroupArray)


func FindCards(node: Node, arrayToAddTo : Array) -> void:
	if node is Card:
		print("Adding ", node.name, " to array")
		AddCardToTable(node)
	for child in node.get_children():
		FindCards(child, arrayToAddTo)


func FindBoxes(node: Node, arrayToAddTo : Array) -> void:
	if node is Box:
		print("Adding ", node.name, " to array")
		AddBoxToTable(node)
	for child in node.get_children():
		FindBoxes(child, arrayToAddTo)


func FindBoxGroups(node : Node, arrayToAddTo : Array) -> void:
	if node is BoxGroup:
		print("Adding ", node.name, " to array")
		AddBoxGroupToTable(node)
	for child in node.get_children():
		FindBoxGroups(child, arrayToAddTo)
