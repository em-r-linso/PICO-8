function _init()
	Log("------------")
	Log("GAME STARTED")
	Log("------------")

	config.animDelay /= config.numberOfAnimOffsets -- divide by number of animation offsets to get the actual delay between animations
	config.retargetDelay /= config.numberOfAnimOffsets -- same as above

    qt = QuadTree:New(config.quadTreeSize, config.quadTreeCapacity, config.quadTreeMaxNodes)

	player = Player:New()
	add(objects, player)
end