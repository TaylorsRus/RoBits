# Signal

Signal is a module for replicating the behavior of a BindableEvent, and likewise, RBXScriptConnection/Signal, but without the same performance implications.

This module uses the same logic as GoodSignal, which blends performance with usability.

It is implemented in pure Luau.

## Types

### `Signal`

The object returned by `Signal.new()`

```luau
export type Signal<T...> = {
	_head: Listener<T...>?,

	Connect: (Signal<T...>, Callback: Callback<T...>) -> Connection<T...>,
	Once: (Signal<T...>, Callback: Callback<T...>) -> Connection<T...>,
	Fire: (Signal<T...>, T...) -> (),
	Wait: (Signal<T...>) -> T...,
}
```

### `Connection`

The object returned by `Connect`, and by proxy, `Once`

```luau
export type Connection<T...> = {
	_signal: Signal<T...>,
	_listener: Listener<T...>,

	Connected: boolean,
	Disconnect: (Connection<T...>) -> (),
}
```

## Constructors

### `new`

The primary constructor for creating a `Signal` object

```luau
local Signal = require(...)

local signal = Signal.new()
```

## Methods

### `Fire`

Tells your `signal` to invoke all the functions associated with it via `Connect`.

This method can be called inside of an event handler.

This method never allocates memory, unless you yield in the event handler.

```luau
local Signal = require(...)

local signal = Signal.new()

signal:Connect(function(argument)
    print(`Callback invoked with argument of '{argument}'`)
end)

signal:Fire("Firing a signal!") --> "Callback invoked with argument of 'Firing a signal!'"
```

### `Connect`

Associates a callback to your signal, also known as an event handler.

This method returns a `Connection` object, with a `Connected` boolean, and a `Disconnect` method.

You can use this method within another event handler.

```luau
local Signal = require(...)

local signal = Signal.new()

local connection = signal:Connect(function(argument)
    print("Callback was invoked")
end)

print(connection.Connected) --> true
signal:Fire() --> "Callback was invoked"

connection:Disconnect()

print(connection.Connected) --> false
signal:Fire() --> nothing
```

### `Once`

Identical to `Connect`, but disconnects its own connection immediately after the first invocation.

This method internally uses `Connect`.

```luau
local Signal = require(...)

local signal = Signal.new()

local connection = signal:Once(function()
    print("This will only print once")
end)

print(connection.Connected) --> true
signal:Fire() --> "This will only print once"
print(connection.Connected) --> false
signal:Fire() --> nothing
```

### `Wait`

Pauses the current thread until your `signal` receives an invocation.

This method internally uses `Once`.

```luau
local Signal = require(...)

local signal = Signal.new()

local startTime = os.clock()
task.delay(3, function()
    signal:Fire()
end)

signal:Wait()
print(os.clock() - startTime) --> Greater than 3 seconds
```
