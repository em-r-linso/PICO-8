config = {
	rngSeed = rnd(100),
	spawnDelay = 0.2,
	animDelay = 0.2,
	retargetDelay = 1,
	numberOfAnimOffsets = 5,
	objectSize = 5,
	mapEdgeSpawnBuffer = -20, -- 20 is good; negative can be for testing
	maxEnemies = 100,
	enemyTargetFuzz = 50,
	enemySpeedUpDistance = 40, -- at this distance from target, enemies will start to speed up
	enemySpeedUpFactor = 0.03, -- enemies gain this speed for each pixel farther from the target (after enemySpeedUpDistance)
	gameSpeed = 1.3, -- used as a multiplier for all speeds (player and enemy)
	floorTileVariations = 10,
	extraLikelihoodForStandardFloorTile = 50,
	hpBarHeight = 3,
	enemyBounceBack = 50,
	playerMaxHp = 9999, -- set to 9999 for testing
	hurtFrames = 2,
	quadTreeSize = 1000,
	quadTreeCapacity = 4,
	quadTreeMaxNodes = 1000
}

function _update()

	-- player
	player:Move()
	-- UpdateWeapons()

	-- enemies
	Enemy:Spawn()
	Enemy:SetTargetAll()
	Enemy:MoveAll()

	-- rendering
	-- SortByY()
	AnimateSprites()

	LagAlert()
end

function LagAlert()
	if stat(7) < 30 then
		Log("LOW FPS: " .. stat(7))
	end
end

--TODO: move to a separate file
function Log(message)
	printh(RealTime() .. " " .. message)
end
function RealTime()
	local hoursMinutesSeconds = {stat(93), stat(94), stat(95)}
	for i = 1, #hoursMinutesSeconds do
		if hoursMinutesSeconds[i] < 10 then
			hoursMinutesSeconds[i] = "0" .. hoursMinutesSeconds[i]
		end
	end
	return hoursMinutesSeconds[1] .. ":" .. hoursMinutesSeconds[2] .. ":" .. hoursMinutesSeconds[3]
end

--------------------------------