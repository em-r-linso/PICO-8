GameObject = {}
function GameObject:New()
	local o = {
		position = Vector:New()
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

Character = GameObject:New()
function Character:New(maxHp, speed, sprite)
	local o = GameObject:New()
	setmetatable(o, self)
	self.__index = self

	o.maxHp = maxHp
	o.hp = maxHp
	o.speed = speed
	o.sprite = sprite
	o.spriteFlip = false
	o.animOffset = flr(rnd(config.numberOfAnimOffsets))

	return o
end

function Character:Hurt(damage)
    -- take damage (1 by default)
	self.hp = self.hp - (damage or 1)

    -- set the hurt sprite
	local spriteIndex = (flr(self.sprite / 5) * 5)
	self.sprite = spriteIndex + 3
	self.hurtFrames = config.hurtFrames
	if self.hp <= 0 then
		self.sprite = spriteIndex + 4
	end
end