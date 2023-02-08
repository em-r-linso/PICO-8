function CreateQuadTree(bounds)
	-- Log("CreateQuadTree()")

	local quadTree = {
		bounds = bounds,
		objects = {},
		nodes = {}
	}

	-- Log("    Bounds: " .. bounds.x .. ", " .. bounds.y .. ", " .. bounds.w .. ", " .. bounds.h)

	return quadTree
end

function SplitNode(tree)
	-- Log("SplitNode()")

	local x = tree.bounds.x
	local y = tree.bounds.y
	local w = tree.bounds.w / 2
	local h = tree.bounds.h / 2

	tree.nodes[1] = CreateQuadTree({x = x + w,	y = y,		w = w,	h = h})
	tree.nodes[2] = CreateQuadTree({x = x,		y = y,		w = w,	h = h})
	tree.nodes[3] = CreateQuadTree({x = x,		y = y + h,	w = w,	h = h})
	tree.nodes[4] = CreateQuadTree({x = x + w,	y = y + h,	w = w,	h = h})
end

function InsertObject(tree, object)
	-- Log("Object being inserted @ " .. object.position.x .. ", " .. object.position.y)

	-- check child nodes to see which one the object fits in
	local index = 0
	for i = 1, #tree.nodes do
		local node = tree.nodes[i]
		if object.position.x >= node.bounds.x and object.position.x < node.bounds.x + node.bounds.w and object.position.y >= node.bounds.y and object.position.y < node.bounds.y + node.bounds.h then
			index = i
			-- Log("    Best fit: node " .. index)
			break
		end
	end

	-- if the object fits in a child node, insert it there
	if index > 0 then
		-- Log("    Inserting object into node " .. index)
		InsertObject(tree.nodes[index], object)

	-- otherwise, insert it into the current node
	else
		-- Log("    No best fit, inserting object into this node")
		add(tree.objects, object)

		-- Log("    Object count: " .. #tree.objects)
		-- Log("    Child node count: " .. #tree.nodes)

		-- if the current node has too many objects and no children, split it
		if #tree.objects > 4 and #tree.nodes == 0 then
			-- Log("    Splitting node")
			SplitNode(tree)
		
			-- redistribute objects (remove and reinsert)
			for i = #tree.objects, 1, -1 do
				-- Log("    Reinserting object " .. i)
				local o = tree.objects[i]
				del(tree.objects, o)
				InsertObject(tree, o)
			end
		end
	end
end

local function RetrieveObjects(tree, objects, bounds)
	-- Log("RetrieveObjects()")

	if #tree.nodes == 0 then
		for i = 1, #tree.objects do
			add(objects, tree.objects[i])
		end
		return
	end

	for i = 1, #tree.nodes do
		local node = tree.nodes[i]
		if bounds.x < node.bounds.x + node.bounds.w and bounds.x + bounds.w > node.bounds.x and bounds.y < node.bounds.y + node.bounds.h and bounds.y + bounds.h > node.bounds.y then
			RetrieveObjects(node, objects, bounds)
		end
	end
end

-- Initialize the quadtree with a large initial bounds
-- tree = CreateQuadTree({x = -10000, y = -10000, w = 20000, h = 20000})
tree = CreateQuadTree({x = -6400, y = -6400, w = 12800, h = 12800})
reinsertionQueue = {}

-- -- Add objects to the quadtree
-- for i = 1, #enemies do
-- 	InsertObject(tree, enemies[i].position)
-- end
-- 
-- for i = 1, #projectiles do
-- 	InsertObject(tree, projectiles[i].position)
-- end
-- 
-- -- Get the list of objects within a certain bounds
-- objects = {}
-- RetrieveObjects(tree, objects, {x = 0, y = 0, w = 10000, h = 10000})

-- -- Perform collision checks on objects within the bounds
-- for i = 1, #objects do
-- 	for j = i + 1, #objects do
-- 		local obj1 = objects[i]
-- 		local obj2 = objects[j]
-- 		local distance = #(obj1 - obj2)
-- 		if distance <= obj1.radius + obj2.radius then
-- 			-- Handle collision
-- 		end
-- 	end
-- end