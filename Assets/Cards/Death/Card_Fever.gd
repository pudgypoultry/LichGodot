extends Card

# Specific qualities about the Death card will go here
func OnDraw():
	BoardManager.playerDeck.PutCardOnTop("Fever")
	BoardManager.playerDeck.ShuffleDeck()
	BoardManager.playerDeck.PutCardOnBottom("Fatigue")
	print("Gonna hurl")
