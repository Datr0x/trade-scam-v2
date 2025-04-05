local Config = {
    Key = Enum.KeyCode.F,
    Time = 0.5
}

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Versuche, TradingCmds zu laden
local success, TradingCmds = pcall(function()
    return require(ReplicatedStorage.Library.Client.TradingCmds)
end)

if not success or not TradingCmds then
    warn("❌ TradingCmds konnte nicht geladen werden!")
    return
end

local Freezer = {}
local originalGetState = TradingCmds.GetState

-- Sicherstellen, dass originalGetState existiert
if not originalGetState then
    warn("❌ TradingCmds.GetState existiert nicht!")
    return
end

TradingCmds.GetState = hookfunction(originalGetState, function(...)
    local state = originalGetState(...)
    if state and state._items then
        for userId, data in pairs(state._items) do
            if Freezer[userId] then
                data["2"] = Freezer[userId]
            end
        end
    end
    return state
end)

local function FreezeTargetItems()
    local state = originalGetState()
    if state and state._items then
        for userId, data in pairs(state._items) do
            if data["2"] then
                Freezer[userId] = data["2"]
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Config.Key and not gpe then
        if next(Freezer) then
            Freezer = {}
            print("❄️ Trade zurückgesetzt")
        else
            task.wait(Config.Time)
            FreezeTargetItems()
            print("🧊 Trade eingefroren")
        end
    end
end)

local state = TradingCmds.GetState()
if state and state._items then
    for i, v in pairs(state._items) do
        for j, k in pairs(v) do
            for a, o in pairs(k) do
                print(a, o)
            end
        end
    end
end
