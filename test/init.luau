local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Jest = require(ReplicatedStorage.DevPackages.Jest)

local processServiceExists, ProcessService = pcall(function()
	return game:GetService("ProcessService")
end)

local status, result = Jest.runCLI(Modules, {
	verbose = false,
	ci = false,
}, { Modules }):awaitStatus()

local numFailedTestSuites = result.results.numFailedTestSuites
local numFailedTests = result.results.numFailedTests
local allSucceeded = numFailedTestSuites == 0 and numFailedTests == 0

if status == "Rejected" then
	print(result)
elseif status == "Resolved" and allSucceeded and processServiceExists then
	ProcessService:ExitAsync(0)
end

if processServiceExists then
	ProcessService:ExitAsync(1)
end

return nil
