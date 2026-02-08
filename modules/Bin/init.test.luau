local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local Bin = require(script.Parent)

local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach

local test = JestGlobals.test
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local function newCustomConnection()
	local self = { Connected = true }
	function self:Disconnect()
		self.Connected = false
	end
	return self
end

local function newCustomSignal()
	local self = {}
	function self:Connect(callback: (...any) -> ...any)
		return newCustomConnection()
	end
	function self:Once(callback: (...any) -> ...any)
		return newCustomConnection()
	end
	return self
end

local function newCustomObject()
	local self = {
		Destroyed = false,
		CleanedUp = false,
		Cleaned = false,
		Cleared = false,
	}
	function self:Destroy()
		self.Destroyed = true
	end
	function self:CleanUp()
		self.CleanedUp = true
	end
	function self:Clean()
		self.Cleaned = true
	end
	function self:Clear()
		self.Cleared = true
	end
	return self
end

describe("Bin", function()
	local bin: Bin.Bin = nil

	beforeEach(function()
		bin = Bin.new()
	end)
	afterEach(function()
		bin:Clear()
		bin = nil :: any
	end)

	test("Add and cleanup a Roblox Instance", function()
		local instance = Instance.new("Folder")
		instance.Parent = Workspace
		bin:Add(instance)
		bin:Clear()

		expect(instance.Parent).toBeNil()
	end)

	test("Add and cleanup a custom object with (a) cleanup method(s)", function()
		local object = newCustomObject()
		bin:Add(object)
		bin:Clear()

		expect(object.Destroyed).toBe(true)
		expect(object.Cleaned).toBe(true)
		expect(object.Cleared).toBe(true)
		expect(object.CleanedUp).toBe(true)
	end)

	test("Add and cleanup a RbxScriptConnection", function()
		local connection = newCustomConnection()
		bin:Add(connection)
		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Connect and cleanup a RbxScriptSignal", function()
		local connection = bin:Connect(RunService.Stepped, function() end)

		expect(connection.Connected).toBe(true)

		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Connect and cleanup a RbxScriptSignal using Once", function()
		local connection = bin:Once(RunService.Stepped, function() end)

		expect(connection.Connected).toBe(true)

		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Add and cleanup a custom connection object", function()
		local connection = newCustomConnection()
		bin:Add(connection)
		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Connect and cleanup a custom signal object", function()
		local connection = bin:Connect(newCustomSignal(), function() end)

		expect(connection.Connected).toBe(true)

		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Connect and cleanup a custom signal object using Once", function()
		local connection = bin:Once(newCustomSignal(), function() end)

		expect(connection.Connected).toBe(true)

		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Add and cleanup a thread", function()
		local thread = coroutine.create(function() end)
		bin:Add(thread)
		expect(coroutine.status(thread)).toBe("suspended")
		bin:Clear()
		expect(coroutine.status(thread)).toBe("dead")
	end)

	test("Add and cleanup a function", function()
		local value = false
		bin:Add(function()
			value = true
		end)
		bin:Clear()
		expect(value).toBe(true)
	end)
end)
