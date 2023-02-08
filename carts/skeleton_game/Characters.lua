objects = {}

---------------------------------------------------------

GameObject = {}
function GameObject:New()
	local o = {
		position = Vector:New()
	}
	setmetatable(o, self)
	self.__index = self

	o.qtNode = nil -- the quadtree node this object is in (not used for every object, probably)

	return o
end

-- if outside of the quadtree node, remove and reinsert
function GameObject:CheckQTNodeBounds()
	if not self.qtNode then
		Log("trying to check qt node bounds for object that isn't in a quadtree node")
		return
	end

	if not self.qtNode.bounds:Contains(self.position.x, self.position.y) then
		local tree = self.qtNode.tree
		self.qtNode:Remove(self)
		tree:Insert(self)
	end
end

---------------------------------------------------------

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