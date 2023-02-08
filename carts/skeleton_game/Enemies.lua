enemies = {}
numberOfSpawns = 0
numberOfRetargets = 0

Enemy = Character:New()
function Enemy:New(maxHp, speed, sprite)
	local o = Character:New(maxHp, speed, sprite)
	setmetatable(o, self)
	self.__index = self

	o.target = Vector:New()

	return o
end

function Enemy:MoveAll()
	for _, enemy in pairs(enemies) do
		enemy:Move()
	end
end

function Enemy:Spawn()
	-- don't spawn if there are already too many
	if #enemies >= config.maxEnemies then
		return
	end

	--TODO: rework wonky timer
	if t() > numberOfSpawns * config.spawnDelay then
		numberOfSpawns += 1
		if rnd(10) > 5 then
			spawnX = rnd(127)
			spawnY = rnd(10) > 5 and -config.mapEdgeSpawnBuffer or 127+config.mapEdgeSpawnBuffer
		else
			spawnX = rnd(10) > 5 and -config.mapEdgeSpawnBuffer or 127+config.mapEdgeSpawnBuffer
			spawnY = rnd(127)
		end
		local newEnemy = Skeleton:New()
		newEnemy.position = Vector:New(spawnX + player.position.x - 64, spawnY + player.position.y - 64)
		add(objects, newEnemy)
		add(enemies, newEnemy)
		qt:Insert(newEnemy)
	end
end

function Enemy:Move()
	-- if dead, don't move
	if self.hp <= 0 then return end

	-- if touching player, hurt them (and bounce back)
	local vectorToPlayer = player.position - self.position
	local distanceToPlayer = #vectorToPlayer
	if distanceToPlayer < config.objectSize then
		player:Hurt()
		self.target = self.position + (vectorToPlayer:Normalize() * -config.enemyBounceBack)
	end
	local vectorToTarget = self.target - self.position
	local distanceToTarget = #vectorToTarget
	
	-- don't move if too close to target (you're already there, dummy!)
	if distanceToTarget < config.objectSize then
		return
	end

	-- speed up if too far away
	local speed = self.speed * config.gameSpeed
	if distanceToTarget > config.enemySpeedUpDistance then
		speed += config.enemySpeedUpFactor * (distanceToTarget - config.enemySpeedUpDistance)
	end

	-- calculate new position and move
	local newPosition = self.position + (vectorToTarget:Normalize() * speed)
	self.position = newPosition

	-- look where you're going
	self.spriteFlip = vectorToTarget.x < 0

	-- check if you've exited your current quadtree node
	self:CheckQTNodeBounds() -- this will remove and reinsert the object if necessary
end

function Enemy:SetTargetAll()
	if t() > numberOfRetargets * config.retargetDelay then
		numberOfRetargets += 1
		for _, enemy in pairs(enemies) do
			if (numberOfRetargets % config.numberOfAnimOffsets == enemy.animOffset) then -- share distribution with animation, good enough
				local fuzz = config.enemyTargetFuzz
				local halfFuzz = fuzz/2
				local fuzzVector = {x = rnd(fuzz) - halfFuzz, y = rnd(fuzz) - halfFuzz}
				enemy.target = player.position + fuzzVector
			end
		end
	end
end

------------------------------------------------------

Skeleton = Enemy:New()
function Skeleton:New()
	local o = Enemy:New(10, 0.5, 6)
	setmetatable(o, self)
	self.__index = self
	return o
end

Goblin = Enemy:New()
function Goblin:New()
	local o = Enemy:New(5, 1.5, 11)
	setmetatable(o, self)
	self.__index = self
	return o
end