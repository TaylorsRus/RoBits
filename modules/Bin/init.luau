type Item = Instance | RBXScriptConnection | thread | ((...any) -> ...any)

export type Bin = {
	_bin: { Item },

	Add: (Bin, Item) -> Item,
	Remove: (Bin, Item) -> Item,
	Clear: (Bin) -> (),
}
local function Add(self: Bin, item: Item)
	table.insert(self._bin, item)
	return item
end

local function Remove(self: Bin, item: Item)
	local bin = self._bin
	local index = table.find(bin, item)
	if not index then
		error("Attempted to remove item from bin that was not in bin.")
	end

	table.remove(bin, index)
	return item
end

local function Clear(self: Bin)
	local bin = self._bin

	for _, item in bin do
		if typeof(item) == "Instance" then
			item:Destroy()
		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()
		elseif typeof(item) == "function" then
			task.spawn(item)
		elseif typeof(item) == "thread" then
			pcall(function()
				task.cancel(item)
			end)
		end
	end
	table.clear(bin)
end

local function new(): Bin
	local self: Bin = {
		_bin = {},
		Add = Add,
		Remove = Remove,
		Clear = Clear,
	}

	return self
end

return {
	new = new,
}
