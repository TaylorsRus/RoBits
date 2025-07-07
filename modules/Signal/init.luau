type Listener<T...> = {
	Next: Listener<T...>?,
	Callback: (T...) -> (),
}

type Callback<T...> = (T...) -> ()

export type Signal<T...> = {
	_head: Listener<T...>?,

	Connect: (Signal<T...>, Callback: Callback<T...>) -> Connection<T...>,
	Once: (Signal<T...>, Callback: Callback<T...>) -> Connection<T...>,
	Fire: (Signal<T...>, T...) -> (),
	Wait: (Signal<T...>) -> T...,
}

export type Connection<T...> = {
	_signal: Signal<T...>,
	_listener: Listener<T...>,

	Connected: boolean,
	Disconnect: (Connection<T...>) -> (),
}

local function Disconnect<T...>(self: Connection<T...>)
	if not self.Connected then
		return
	end

	self.Connected = false

	local head = self._signal._head
	local listener = self._listener

	if head == listener then
		self._signal._head = listener.Next
	else
		local currentListener = head
		while currentListener do
			if currentListener.Next == listener then
				currentListener.Next = listener.Next
				break
			end
			currentListener = currentListener.Next
		end
	end

	self._signal = nil :: any
	self._listener = nil :: any
end

local function Connect<T...>(self: Signal<T...>, callback: (T...) -> ()): Connection<T...>
	local listener: Listener<T...> = {
		Next = self._head,
		Callback = callback,
	}
	self._head = listener

	local connection: Connection<T...> = {
		_signal = self,
		_listener = listener,
		Connected = true,
		Disconnect = Disconnect,
	}
	return connection
end

local function Once<T...>(self: Signal<T...>, callback: Callback<T...>): Connection<T...>
	local connection: Connection<T...> = nil

	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)

	return connection
end

local function Wait<T...>(self: Signal<T...>): T...
	local thread = coroutine.running()

	self:Once(function(...)
		coroutine.resume(thread, ...)
	end)

	return coroutine.yield()
end

local function Fire<T...>(self: Signal<T...>, ...: T...)
	local listener = self._head
	while listener do
		task.spawn(listener.Callback, ...)
		listener = listener.Next
	end
end

local function new<T...>(): Signal<T...>
	local self: Signal<T...> = {
		_head = nil,
		Connect = Connect,
		Once = Once,
		Fire = Fire,
		Wait = Wait,
	}
	return self
end

return {
	new = new,
}
