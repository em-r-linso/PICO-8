function _init()
	Log("------------")
	Log("GAME STARTED")
	Log("------------")

	config.animDelay /= config.numberOfAnimOffsets -- divide by number of animation offsets to get the actual delay between animations
	config.retargetDelay /= config.numberOfAnimOffsets -- same as above

	player = Player:New()
	add(objects, player)
end