Vector = {}
function Vector:New(x, y)
	local o = {
		x = x or 0,
		y = y or 0
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Vector:__add(vector)
	return Vector:New(self.x + vector.x, self.y + vector.y)
end

function Vector:__sub(vector)
	return Vector:New(self.x - vector.x, self.y - vector.y)
end

function Vector:__mul(scalar)
	return Vector:New(self.x * scalar, self.y * scalar)
end

function Vector:__div(scalar)
	return Vector:New(self.x / scalar, self.y / scalar)
end

function Vector:__unm()
	return Vector:New(-self.x, -self.y)
end

function Vector:__eq(vector)
	return self.x == vector.x and self.y == vector.y
end

function Vector:__len()
	local x = self.x * self.x
	local y = self.y * self.y
	local sum = x + y

	-- if x or y or their sum is negative, then we have an overflow
	-- in this case, the length is really big, so we return a big number
	-- 999 can also be used as a flag for despawning things that are far away
	if (x < 0 or y < 0 or x + y < 0) then
		return 999
	end

	return sqrt(sum)
end

function Vector:ToString()
	return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vector:Normalize(scale)
	local length = #self
	if length == 0 then return self end
	return Vector:New(self.x / length, self.y / length) * (scale or 1) -- if scale is omitted, then we get a unit vector
end