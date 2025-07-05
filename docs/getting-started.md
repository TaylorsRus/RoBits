# Getting Started

These utility modules can be fetched via [Wally](https://wally.run), a package manager for Roblox.

## Wally Configuration

Once you have Wally installed, run `wally init` on your project directory. From there, you can add the utility modules you want to use under the `dependency` sections of the wally manifest (`wally.toml` by default].
Find below an example of a wally manifest, with the Bin utility added.

```toml
[package]
name = "name/project"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Bin = "taylorsrus/bin@1.0.0"
```

Once you've setup the wally configuration, you can run `wally install`, and these modules will be downloaded to your `./Packages` folder.

## Rojo Configuration

You're not done yet though. If you haven't already got Rojo setup on your project, you'll need to tell it where `Packages` maps to in terms of Roblox services.
The below example shows a very primitive and simple example of this.

```json
{
  "name": "roblox-util-example-project",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Packages": {
        "$path": "Packages"
      }
    }
  }
}
```

Check the docs for [Rojo](https://rojo.space/) and [Wally](https://github.com/UpliftGames/wally) for more on installation of these tools.

## Example Usage

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Bin = require(Packages.Bin)

local bin = Bin.new()

local folder = Instance.new("Folder")
bin:Add(folder)

local thread = task.spawn(function() end)
bin:Add(thread)

task.delay(5, function()
    bin:Clear()
end)
```

## Future Tooling Support

Support for [pesde](https://pesde.dev/) is currently planned, but not supported as of writing this.
