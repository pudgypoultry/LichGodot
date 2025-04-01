extends BoxGroup


func HandleResult(currentProduct : int):
	# make it a switch case
	# Death Only
	if currentProduct == 37:
		print("BoxGroup is empty, but button has been pressed!")
		BeginExecution(cooldownArray[0], resultArray[0])
		return
	# Death + Earth
	if currentProduct == 74:
		print("Beginning execution of product 3")
		BeginExecution(cooldownArray[1], resultArray[1])
		return
	
	print("No valid combo was found")
	return
