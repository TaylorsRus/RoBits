type Type = "function" | "thread" | "table" | "Instance" | "RBXScriptConnection"

type Function = (...any) -> ...any
type Listener = (Signal, Function) -> ConnectionLike
type ConnectionLike = {
	Connected: boolean,
	Disconnect: (any) -> (),
} | RBXScriptConnection

-- type Cleanable = { Destroy: (any) -> () } & { CleanUp: (any) -> () } & { Clean: (any) -> () } & { Clear: (any) -> () }
type Cleanable = {
	Destroy: (any) -> ()?,
	CleanUp: (any) -> ()?,
	Clean: (any) -> ()?,
	Clear: (any) -> ()?,
}

type Item = Instance | Cleanable | ConnectionLike | Function | thread

type Signal = {
	Connect: Listener,
	Once: Listener,
}
export type Bin = {
	_bin: { any },

	Add: <T>(Bin, Item & T) -> T,
	Remove: <T>(Bin, Item & T) -> T,
	Clear: (Bin) -> (),
	Connect: (Bin, Signal, Function) -> ConnectionLike,
}

local CLEANUP_METHODS = {
	"Disconnect",
	"Destroy",
	"CleanUp",
	"Clean",
	"Clear",
}

local function cleanUpItem(item: Item)
	if typeof(item) == "Instance" then
		item:Destroy()
	elseif typeof(item) == "RBXScriptConnection" then
		item:Disconnect()
	elseif typeof(item) == "table" then
		local item = item :: Cleanable
		for _, cleanUpMethod in CLEANUP_METHODS do
			if item[cleanUpMethod] and typeof(item[cleanUpMethod]) == "function" then
				item[cleanUpMethod](item)
			end
		end
	elseif typeof(item) == "function" then
		task.spawn(item)
	elseif typeof(item) == "thread" then
		pcall(function()
			task.cancel(item)
		end)
	end
end

local function Add<T>(self: Bin, item: Item & T): T
	table.insert(self._bin, item)
	return item
end

local function Remove<T>(self: Bin, item: Item & T): T
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
		cleanUpItem(item)
	end
	table.clear(bin)
end

local function Connect<T>(self: Bin, signal: Signal, fn: Function): ConnectionLike
	return self:Add(signal:Connect(fn))
end

local function new(): Bin
	local self = {
		_bin = {},
		Add = Add,
		Remove = Remove,
		Clear = Clear,
		Connect = Connect,
	}

	return self :: any
end

return {
	new = new,
}
