extends BoxGroup


func IsValidCombo(boxArray : Array[Box]):
	var currentCards : Array[Card] = []
	
	for box in slottedCards.keys():
		if slottedCards[box] != null:
			currentCards.append(slottedCards[box])
	var currentProduct = FindPrimeResult(currentCards)
	
	if currentProduct in validCombos:
		print("	->Found a valid combo!")
		return true
	else:
		return false


func HandleResult(currentProduct : int):
	slottedCards[boxes[0]].OnUse()
