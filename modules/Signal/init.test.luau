local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local Signal = require(script.Parent)

local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach

local test = JestGlobals.test
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local signal: Signal.Signal<...any> = nil

describe("Signal", function()
	beforeEach(function()
		signal = Signal.new()
	end)
	afterEach(function()
		local connection = signal:Connect(function() end)
		connection:Disconnect()
	end)

	test("Handler is invoked", function()
		local count = 0

		signal:Connect(function()
			count += 1
		end)
		signal:Fire()
		task.wait()

		expect(count).toBe(1)
	end)

	test("Wait returns fired arguments", function()
		local expected1, expected2 = 42, "test"
		task.spawn(function()
			task.wait(0.1)
			signal:Fire(expected1, expected2)
		end)

		local result1, result2 = signal:Wait()
		expect(result1).toBe(expected1)
		expect(result2).toBe(expected2)
	end)

	test("Wait yields until Fire is called", function()
		local fired = false
		task.spawn(function()
			task.wait(0.2)
			fired = true
			signal:Fire(99)
		end)
		local result = signal:Wait()

		expect(fired).toBe(true)
		expect(result).toBe(99)
	end)

	test("All handlers invoke", function()
		local count = 0

		signal:Connect(function()
			count += 1
		end)
		signal:Connect(function()
			count += 1
		end)
		signal:Fire()
		task.wait()

		expect(count).toBe(2)
	end)

	test("Handlers receive arguements in correct order", function()
		local a, b, c = nil, nil, nil

		signal:Connect(function(x, y, z)
			a, b, c = x, y, z
		end)
		signal:Fire("hello", 42, true)
		task.wait()

		expect(a).toBe("hello")
		expect(b).toBe(42)
		expect(c).toBe(true)
	end)

	test("Disconnected handlers aren't invoked", function()
		local received = false
		local connection = signal:Connect(function()
			received = true
		end)

		connection:Disconnect()

		signal:Fire()
		task.wait()

		expect(connection.Connected).toBe(false)
		expect(received).toBe(false)
	end)

	test("Disconnection of one handler doesn't disconnect others", function()
		local count = 0

		local connection1 = signal:Connect(function()
			count += 1
		end)
		signal:Connect(function()
			count += 1
		end)

		connection1:Disconnect()

		signal:Fire()
		task.wait()

		expect(count).toBe(1)
	end)

	test("Handler connected during Fire does not run immediately", function()
		local ranLater = false

		signal:Connect(function()
			signal:Connect(function()
				ranLater = true
			end)
		end)

		signal:Fire()
		task.wait()
		expect(ranLater).toBe(false)

		signal:Fire()
		task.wait()
		expect(ranLater).toBe(true)
	end)

	test("Handlers are called in LIFO order", function()
		local callOrder = {}

		signal:Connect(function()
			table.insert(callOrder, "first")
		end)

		signal:Connect(function()
			table.insert(callOrder, "second")
		end)

		signal:Fire()
		task.wait()

		expect(callOrder[1]).toBe("second")
		expect(callOrder[2]).toBe("first")
	end)

	test("Fire with no listeners does not error", function()
		expect(function()
			signal:Fire("any", "values", 123)
		end).never.toThrow()
	end)

	test("Disconnect is idempotent", function()
		local connection = signal:Connect(function() end)

		connection:Disconnect()
		expect(connection.Connected).toBe(false)

		connection:Disconnect()
		expect(connection.Connected).toBe(false)
	end)

	test("Once only calls callback once and disconnects", function()
		local callCount = 0

		signal:Once(function()
			callCount += 1
		end)

		task.defer(function()
			signal:Fire()
			signal:Fire()
			signal:Fire()
		end)
		task.wait()

		expect(callCount).toBe(1)
	end)
end)
