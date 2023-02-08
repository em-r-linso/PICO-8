QuadTree = {}
function QuadTree:New(size, capacity, maxNodes)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.size = size
	o.capacity = capacity
	o.maxNodes = maxNodes

	-- create the top level node
	o.nodes = {}
	local halfSize = size / 2
	local rootNode = QTNode:New(nil, Bounds:New(-halfSize, -halfSize, size, size))
	rootNode.tree = o
	add(o.nodes, rootNode)
	
	return o
end

function QuadTree:Draw()

	for i = 1, #self.nodes do
		local node = self.nodes[i]
		if #node.nodes == 0 then
			rect(node.bounds.x, node.bounds.y, node.bounds.x + node.bounds.w, node.bounds.y +  node.bounds.h, 8)
		end
	end
end

function QuadTree:Insert(object)
	self.nodes[1]:Insert(object) -- insert the object into the top level node
end

--------------------------------------------------------------------

QTNode = {}
function QTNode:New(parent, bounds)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.parent = parent or nil
	o.bounds = bounds
	o.tree = nil
	o.objects = {}
	o.nodes = {}
	
	if parent != nil then
		o.depth = parent.depth + 1	-- depth increases by 1 for each level
		o.tree = parent.tree		-- this points to the tree that this node belongs to
	else
		o.depth = 0 -- if this is the top level node, depth is 0
	end

	if o.tree != nil then
		add(o.tree.nodes, o) -- add this node to the tree's list of nodes
	end

	return o
end

function QTNode:Insert(object)
	-- if this node has no children, add the object to this node
	if #self.nodes == 0 then
		add(self.objects, object)
		object.qtNode = self -- so the object can report when it leaves the node

		-- if this node has reached capacity, split it
		if #self.objects > self.tree.capacity then
			self:Split()
		end

	-- if this node has children, insert the object into the correct child node
	else
		for node in all(self.nodes) do
			if node.bounds:Contains(object.position.x, object.position.y) then
				node:Insert(object) -- recursive call which allows us to bore down to the correct child node
				break
			end
		end
	end
end

function QTNode:Remove(object)
	-- if this node has children, there shouldn't be any objects in it to begin with
	if #self.nodes > 0 then
		Log("attempting to remove object from node that has children")
	end

	-- remove the object from this node
	del(self.objects, object)

	-- we might want to unsplit this node's parent
	if self.parent == nil then return end -- this is the top level node, so we can't split	
	local numObjects = 0
	for node in all(self.parent.nodes) do
		if #node.nodes > 0 then return end -- child nodes would be orphaned, so we can't split
		numObjects += #node.objects
		if numObjects >= self.tree.capacity then return end -- there are too many objects, so we can't split
	end
	self.parent:Unsplit() -- we can unsplit this node's parent
end

function QTNode:Split()
	-- reject if too many nodes
	if #self.tree.nodes >= self.tree.maxNodes then
		Log("exceeded max nodes")
		return
	end

	local x = self.bounds.x
	local y = self.bounds.y
	local w = self.bounds.w
	local h = self.bounds.h
	local halfW = w / 2
	local halfH = h / 2

	-- create the 4 child nodes
	self.nodes = {}
	add(self.nodes, QTNode:New(self, Bounds:New(x, y, halfW, halfH)))
	add(self.nodes, QTNode:New(self, Bounds:New(x + halfW, y, halfW, halfH)))
	add(self.nodes, QTNode:New(self, Bounds:New(x, y + halfH, halfW, halfH)))
	add(self.nodes, QTNode:New(self, Bounds:New(x + halfW, y + halfH, halfW, halfH)))

	-- move the objects from this node to the child nodes
	for object in all(self.objects) do
		for node in all(self.nodes) do
			if node.bounds:Contains(object.position.x, object.position.y) then
				-- add(node.objects, object)
				node:Insert(object)
				break
			end
		end
	end

	-- clear the objects from this node (because they have been moved to the child nodes)
	self.objects = {}
end

function QTNode:Unsplit()
	-- keep track of the objects that will need reinsertion
	local objectsToReinsert = {}
	for node in all(self.nodes) do
		for object in all(node.objects) do
			add(objectsToReinsert, object)
		end
	end

	-- delete the child nodes
	for i = 1, #self.nodes do
		del(self.tree.nodes, self.nodes[i])
		self.nodes[i] = nil
	end
	self.nodes = {}

	-- reinsert the objects
	for object in all(objectsToReinsert) do
		self:Insert(object)
	end
end

--------------------------------------------------------------------

Bounds = {}
function Bounds:New(x, y, w, h)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.x = x
	o.y = y
	o.w = w
	o.h = h

	return o
end

function Bounds:ToString()
	return "Bounds: " .. self.x .. ", " .. self.y .. ", " .. self.w .. ", " .. self.h
end

function Bounds:Contains(x, y)
	return (x >= self.x) and (x <= self.x + self.w) and (y >= self.y) and (y <= self.y + self.h)
end