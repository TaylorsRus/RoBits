## Types

### `Bin`

The object returned by `Bin.new()`

```luau
type Function = (...any) -> ...any
type Listener = (Signal, Function) -> ConnectionLike
type ConnectionLike = {
	Connected: boolean,
	Disconnect: (any) -> (),
} | RBXScriptConnection

type Cleanable = {
	Destroy: (any) -> ()?,
	CleanUp: (any) -> ()?,
	Clean: (any) -> ()?,
	Clear: (any) -> ()?,
}

type Item = Instance | Cleanable | ConnectionLike | Function | thread

export type Bin = {
	_bin: { any },

	Add: <T>(Bin, Item & T) -> T,
	Remove: <T>(Bin, Item & T) -> T,
	Clear: (Bin) -> (),
	Connect: (Bin, Signal, Function) -> ConnectionLike,
}
```

## Constructors

### `new`

The primary constructor for creating a `Bin` object

```luau
local Bin = require(...)

local bin = Bin.new()
```

## Methods

### `Add`

Add an item to your `bin`, to be cleaned up when `bin:Clear()` is called.
This function supports a wide array of instances, see the type for `Bin` to see what can and can't be cleaned up.

```luau
local Bin = require(...)

local bin = Bin.new()

local folder = Instance.new("Folder")
bin:Add(folder)

local thread = task.spawn(function() end)
bin:Add(thread)
```

### `Remove`

Remove an item previously added to your bin via `Add`, when the bin is cleared via `Clear`, this item will not be cleaned up.
Calling this method on an item which is not in the bin will do nothing.

```luau
local Bin = require(...)

local bin = Bin.new()

local folder = Instance.new("Folder")
folder.Parent = script

bin:Add(folder)
bin:Remove(folder)
bin:Clear()

print(folder.Parent) -- script
```

### `Clear`

Clear items previously added to your bin.

```luau
local Bin = require(...)

local bin = Bin.new()

local folder = Instance.new("Folder")
bin:Add(folder)

local thread = task.spawn(function() end)
bin:Add(thread)

bin:Clear()

print(folder.Parent) -- nil
print(coroutine.status(thread)) -- dead
```

### `Connect`

Shorthand for `Add(connection: ConnectionLike)`

```luau
local Bin = require(...)

local bin = Bin.new()

local function onScriptChanged()
end

bin:Connect(script.Changed, onScriptChanged)
```
