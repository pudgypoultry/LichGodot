extends Node3D

class_name DeckVisual

var theDeck : Deck
var cardsInDeck : Array[MeshInstance3D]
var deckVisualCount : int = 15
var shuffleSpeed : float = 0.4
var tweenArray : Array[Tween]
var spawnPoint : Vector3
var originalSpawnPoint : Vector3


func _ready():
	for card in get_children():
		if card is MeshInstance3D:
			cardsInDeck.append(card)
			tweenArray.append(create_tween())
	for card in get_children():
		if card is Marker3D:
			spawnPoint = card.position
	MatchVisual(1.0)
	deckVisualCount = get_child_count() - 1


func Shuffle():
	var i = 0
	for card in cardsInDeck:
		var rotationDirection = -1 if randf() < 0.5 else 1
		var rotationSpeedOffset = shuffleSpeed * randf()
		print(rotationSpeedOffset)
		TweenTools.TweenRotation(card, tweenArray[i], Vector3(0, rotationDirection * 2*PI, 0), shuffleSpeed)
		i += 1


func MatchVisual(fractionOfDeckLeft : float):
	if fractionOfDeckLeft < 0 or fractionOfDeckLeft > 1:
		return
	var currentCount = int(deckVisualCount * fractionOfDeckLeft)
	ResetVisual()
	for i in range(deckVisualCount - currentCount - 1):
		cardsInDeck[i].visible = false
		spawnPoint = cardsInDeck[i].position
		print("Spawn Point Location: ", spawnPoint)


func ResetVisual():
	for i in range(deckVisualCount):
		cardsInDeck[i].visible = true
	spawnPoint = cardsInDeck[0].position


func EmptyDeck():
	for i in range(deckVisualCount):
		cardsInDeck[i].visible = false
