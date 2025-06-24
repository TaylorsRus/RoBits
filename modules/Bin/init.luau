type Item = Instance | RBXScriptConnection | thread | ((...any) -> ...any)

export type Bin = {
	Add: (Bin, Item) -> Item,
	Remove: (Bin, Item) -> Item,
	Clear: (Bin) -> (),
}
type BinInternal = Bin & {
	_bin: { Item },
}

local function Add(self: BinInternal, item: Item)
	table.insert(self._bin, item)
	return item
end

local function Remove(self: BinInternal, item: Item)
	local bin = self._bin
	local index = table.find(bin, item)
	if not index then
		error("Attempted to remove item from bin that was not in bin.")
	end

	table.remove(bin, index)
	return item
end

local function Clear(self: BinInternal)
	for _, item in self._bin do
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
end

local function new(): Bin
	local self = {
		_bin = {},
		Add = Add,
		Remove = Remove,
		Clear = Clear,
	}

	return (self :: any) :: Bin
end

return {
	new = new,
}
