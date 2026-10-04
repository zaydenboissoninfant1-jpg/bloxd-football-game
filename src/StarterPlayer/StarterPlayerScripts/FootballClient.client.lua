local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("FootballRemotes")
local setTeamRemote = remotes:WaitForChild("SetTeam")
local teamListRemote = remotes:WaitForChild("TeamList")
local rosterRemote = remotes:WaitForChild("RosterInfo")

local cachedTeams = {}
local cachedRosterData = {}

local function createTextLabel(parent, size, position, text, textColor)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = parent
    return label
end

local function createButton(parent, size, position, text, callback)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Text = text
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

local function showTeamMenu()
    local existing = playerGui:FindFirstChild("FootballTeamMenu")
    if existing then
        existing:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FootballTeamMenu"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.38, 0, 0.74, 0)
    frame.Position = UDim2.new(0.31, 0, 0.13, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = createTextLabel(frame, UDim2.new(1, -20, 0, 45), UDim2.new(0, 10, 0, 15), "Choose Your Team", Color3.fromRGB(255, 255, 255))
    title.TextSize = 28

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -20, 0.78, -50)
    list.Position = UDim2.new(0, 10, 0, 75)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 7
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.Parent = frame

    local buttons = {}

    local function renderTeams()
        for _, button in ipairs(buttons) do
            button:Destroy()
        end
        buttons = {}

        local itemY = 0

        local freeAgentButton = createButton(list, UDim2.new(1, -10, 0, 44), UDim2.new(0, 5, 0, itemY), "Free Agent", function()
            setTeamRemote:FireServer("Free Agent")
            gui:Destroy()
        end)
        freeAgentButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        table.insert(buttons, freeAgentButton)
        itemY += 52

        for _, teamData in ipairs(cachedTeams) do
            local button = createButton(list, UDim2.new(1, -10, 0, 44), UDim2.new(0, 5, 0, itemY), teamData.Name, function()
                setTeamRemote:FireServer(teamData.Name)
                gui:Destroy()
            end)
            button.BackgroundColor3 = teamData.PrimaryColor
            table.insert(buttons, button)
            itemY += 52
        end

        list.CanvasSize = UDim2.new(0, 0, 0, itemY)
    end

    local closeButton = createButton(frame, UDim2.new(0, 120, 0, 36), UDim2.new(1, -130, 0, 15), "Close", function()
        gui:Destroy()
    end)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    renderTeams()
    return gui
end

local function createStatusPanel()
    local gui = playerGui:FindFirstChild("FootballStatusPanel")
    if gui then
        gui:Destroy()
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "FootballStatusPanel"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 310, 0, 120)
    panel.Position = UDim2.new(0.02, 0, 0.8, 0)
    panel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    panel.BorderSizePixel = 0
    panel.Parent = gui

    local title = createTextLabel(panel, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), "Football Club", Color3.fromRGB(255, 255, 255))
    title.TextSize = 18

    local teamLabel = createTextLabel(panel, UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 42), player:GetAttribute("FootballTeam") or "Free Agent", Color3.fromRGB(255, 255, 255))
    teamLabel.TextSize = 22

    local rosterLabel = createTextLabel(panel, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 80), "Roster: None", Color3.fromRGB(180, 180, 180))
    rosterLabel.TextSize = 14

    local function refreshRosterText()
        local teamName = player:GetAttribute("FootballTeam") or "Free Agent"
        teamLabel.Text = teamName

        local rosterText = "Roster: "
        local currentRoster = cachedRosterData[teamName] or {}

        if #currentRoster > 0 then
            local names = {}
            for _, member in ipairs(currentRoster) do
                table.insert(names, member.Name)
            end
            rosterText = rosterText .. table.concat(names, ", ")
        else
            rosterText = rosterText .. "No players"
        end

        rosterLabel.Text = rosterText
    end

    rosterRemote.OnClientEvent:Connect(function(rosterData)
        cachedRosterData = rosterData
        refreshRosterText()
    end)

    teamListRemote.OnClientEvent:Connect(function(teams)
        cachedTeams = teams
    end)

    refreshRosterText()
    return gui
end

teamListRemote.OnClientEvent:Connect(function(teams)
    cachedTeams = teams
end)

rosterRemote.OnClientEvent:Connect(function(rosterData)
    cachedRosterData = rosterData
end)

createStatusPanel()

local buttonGui = playerGui:FindFirstChild("TeamButtonGui")
if buttonGui then
    buttonGui:Destroy()
end

buttonGui = Instance.new("ScreenGui")
buttonGui.Name = "TeamButtonGui"
buttonGui.Parent = playerGui

local teamButton = Instance.new("TextButton")
teamButton.Size = UDim2.new(0, 170, 0, 42)
teamButton.Position = UDim2.new(0.82, 0, 0.02, 0)
teamButton.BackgroundColor3 = Color3.fromRGB(18, 32, 62)
teamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teamButton.Font = Enum.Font.GothamBold
teamButton.TextSize = 18
teamButton.Text = "Choose Team"
teamButton.Parent = buttonGui
teamButton.MouseButton1Click:Connect(function()
    showTeamMenu()
end)

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0, 220, 0, 24)
keyLabel.Position = UDim2.new(0.8, 0, 0.07, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Press T to open the team menu"
keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 15
keyLabel.Parent = buttonGui

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.T then
        showTeamMenu()
    end
end)

print("Football client system loaded.")
