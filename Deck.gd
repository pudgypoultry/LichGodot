extends Node

class_name Deck
@export var deckVisual : DeckVisual
@export var deck : Array[String]
var currentlyShowingCard : bool = false
var originalSize : int
var deckSize : int
var lastSize : int

func _ready():
	BoardManager.playerDeck = self
	deckSize = len(deck)
	lastSize = deckSize
	originalSize = deckSize


func _process(delta):
	if deckSize != lastSize:
		lastSize = deckSize
		deckVisual.MatchVisual(float(deckSize)/float(originalSize))

func GetSpawnPosition():
	return deckVisual.spawnPoint

func GetSpawnGlobalPosition():
	return deckVisual.spawnPoint + self.global_position


func CleanDeck():
	var nullsInList = []
	print(deck)
	for i in range(len(deck)):
		if deck[i] == null:
			nullsInList.append(i)
	nullsInList.reverse()
	for item in nullsInList:
		deck.remove_at(item)
	print(deck)


func DrawFromTop():
	if !currentlyShowingCard:
		if len(deck) == 0:
			return null
		return deck.pop_front()

func DrawFromBottom():
	if !currentlyShowingCard:
		return deck.pop_back()

func DrawFromPosition(pos : int):
	if !currentlyShowingCard:
		return deck.pop_at(pos)

func ShuffleDeck():
	deck.shuffle()
	deckVisual.Shuffle()

func LookAtTopX(howMany : int):
	var returnArray = []
	for i in range(howMany):
		returnArray.append(DrawFromTop())
	return returnArray

func LookAtBottomX(howMany : int):
	var returnArray = []
	for i in range(howMany):
		returnArray.append(DrawFromBottom())
	return returnArray


func PutCardOnTop(card : String):
	deck.insert(0, card)

func PutCardOnBottom(card : String):
	deck.append(card)

func InsertCardAtPosition(where : int, card : String):
	if len(deck) < where:
		PutCardOnBottom(card)
	else:
		deck.insert(where, card)


func RemoveCardAtPosition(where : int):
	deck.remove_at(where)

"""=====================================================
Counting and Finding
====================================================="""

func CountType(whatType : String):
	var count = 0
	for card in deck:
		if JSONAndLoadHandler.cardTagsDict[card].has(whatType):
			count += 1
	return count


func CountCopies(cardName : String):
	var count = 0
	for card in deck:
		if card == cardName:
			count += 1
	return count


func FirstInstance(whatCard : String):
	return deck.find(whatCard)


func FindFirstNonDeathCard():
	var i = 0
	for card in deck:
		if JSONAndLoadHandler.cardTagsDict[card].has("Death"):
			pass
		else:
			return i
		i += 1
	return -1
