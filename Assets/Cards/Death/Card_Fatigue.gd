extends Card

# Specific qualities about the Death card will go here
func OnDraw():
	var cardToMill = BoardManager.playerDeck.FindFirstNonDeathCard()
	BoardManager.playerDeck.RemoveCardAtPosition(cardToMill)
	BoardManager.playerDeck.PutCardOnTop("Delirium")
	print("I'm so tired")
