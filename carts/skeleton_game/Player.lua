Player = Character:New()
function Player:New()
	local o = Character:New(config.playerMaxHp, 1, 1)
	setmetatable(o, self)
	self.__index = self

	return o
end

function Player:Move()
	-- if player is dead, don't move
	if self.hp <= 0 then return end

	-- flip sprite based on input
	if btn(0) then self.spriteFlip = true end
	if btn(1) then self.spriteFlip = false end

	-- set movement vector from button input, then normalize it
	local x = (btn(0) and -1 or 0) + (btn(1) and 1 or 0)
	local y = (btn(2) and -1 or 0) + (btn(3) and 1 or 0)
	local movementVector = Vector:New(x, y):Normalize((self.speed * config.gameSpeed))

	-- actually move
	self.position += movementVector
end

-------------------------------------------------

projectiles = {}

function UpdateWeapons()
	-- update positions
	for _, projectile in pairs(projectiles) do
		projectile.position = VectorSum(projectile.position, projectile.movementVector)
		-- if projectile is close to an enemy, hurt it
		for _, enemy in pairs(enemies) do
			if VectorMagnitude(VectorDifference(projectile.position, enemy.position)) < 4 then
				Hurt(enemy)
				del(projectiles, projectile)
				break
			end
		end
	end

	-- add new projectiles unless player is dead
	if player.hp <= 0 then return end

	--TODO: deleteme
	if #projectiles > 50 then
		del(projectiles, projectiles[1])
	end

	add(projectiles, {
		position = VectorSum(player.position, {x = 4, y = 4}), -- 4, 4 to center on player
		movementVector = VectorMultiply(VectorNormalized(VectorDifference((#enemies > 0 and rnd(enemies).position or {x = rnd(200) - 100, y = rnd(200) - 100}), player.position)), 1 * config.gameSpeed),
	})
end