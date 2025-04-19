extends MarginContainer

class_name CardDisplay

enum WhereCardsComeFrom {TOP_OF_DECK, BOTTOM_OF_DECK, SPECIFIC}
enum WhereCardsGo {TOP_OF_DECK, BOTTOM_OF_DECK, SHUFFLE_INTO_DECK, PUT_INTO_PLAY, DESTROY}
@export var cardWindows : HBoxContainer
@export var baseWindow : PackedScene
var windowArray : Array
var actionOrder : Array
var currentSource : Node

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#await get_tree().create_timer(1).timeout
	#ActivateDisplay(self, 
		#["Death", "Fever", "Goblin"], 
		#[WhereCardsComeFrom.TOP_OF_DECK, WhereCardsComeFrom.BOTTOM_OF_DECK, WhereCardsComeFrom.TOP_OF_DECK]
	#)


func ActivateDisplay(whoAwokeMe : Node, cardArray : Array, whatActions : Array):
	currentSource = whoAwokeMe
	actionOrder = whatActions
	for cardName in cardArray:
		CreateWindow(cardName)


func CreateWindow(cardName : String):
	var newWindow = baseWindow.instantiate()
	cardWindows.add_child(newWindow)
	print("Adding " + cardName + " to window " + str(len(windowArray)))
	newWindow.SetImage(cardName, JSONAndLoadHandler.cardFaceLocationsDict[cardName])


func MakeChoice(whichWindow : UICardWindow):
	var action = actionOrder.pop_front()
	if action == WhereCardsGo.PUT_INTO_PLAY:
		var whatPosition = currentSource.position
		DealWithChoice(whichWindow, action, whatPosition)
	else:
		DealWithChoice(whichWindow, action)


func DealWithChoice(whichWindow : UICardWindow, whereToPutCard : WhereCardsGo, whatPosition : Vector3 = Vector3(0,0,0)):
	match whereToPutCard:
		WhereCardsGo.TOP_OF_DECK:
			HandleTopOfDeck(whichWindow, whichWindow.currentCardName)
		WhereCardsGo.BOTTOM_OF_DECK:
			HandleBottomOfDeck(whichWindow, whichWindow.currentCardName)
		WhereCardsGo.SHUFFLE_INTO_DECK:
			HandleShuffleIntoDeck(whichWindow, whichWindow.currentCardName)
		WhereCardsGo.PUT_INTO_PLAY:
			HandlePutIntoPlay(whichWindow, whichWindow.currentCardName, whatPosition)
		WhereCardsGo.TOP_OF_DECK:
			HandleTopOfDeck(whichWindow, whichWindow.currentCardName)
		WhereCardsGo.DESTROY:
			HandleDestroy(whichWindow, whichWindow.currentCardName)
	whichWindow.OnDestroy()


func HandleTopOfDeck(whichWindow : UICardWindow, cardName : String):
	BoardManager.playerDeck.PutCardOnTop(whichWindow.currentCardName)

func HandleBottomOfDeck(whichWindow : UICardWindow, cardName : String):
	BoardManager.playerDeck.PutCardOnBottom(whichWindow.currentCardName)

func HandleShuffleIntoDeck(whichWindow : UICardWindow, cardName : String):
	BoardManager.playerDeck.PutCardOnTop(whichWindow.currentCardName)
	BoardManager.playerDeck.ShuffleDeck()

func HandlePutIntoPlay(whichWindow : UICardWindow, cardName : String, whereToInstantiate : Vector3):
	var cardCopy = load(JSONAndLoadHandler.resourceLocationsDict["Card:" + cardName]).instantiate()
	get_tree().root.add_child(cardCopy)
	cardCopy.position = whereToInstantiate

func HandleDestroy(whichWindow : UICardWindow, cardName : String):
	pass


func OnWindowAdded(node: Node) -> void:
	if node is UICardWindow:
		windowArray.append(node)

func OnWindowSubtracted(node: Node) -> void:
	if node is UICardWindow:
		windowArray.erase(node)
