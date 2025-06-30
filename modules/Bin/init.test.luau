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

	test("Add and cleanup an RbxScriptConnection", function()
		local connection = RunService.Stepped:Connect(function() end)
		bin:Add(connection)
		bin:Clear()

		expect(connection.Connected).toBe(false)
	end)

	test("Add and cleanup a Roblox thread", function()
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
