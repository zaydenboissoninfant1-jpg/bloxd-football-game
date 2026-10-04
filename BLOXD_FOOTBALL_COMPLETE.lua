-- COMPLETE BLOXD.IO FOOTBALL GAME - COPY & PASTE INTO ServerScriptService
-- Includes: Teams, Free Agent, Kits, Owner Tag, Ball, Goals, Scoreboard, Match Timer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")
local StarterPlayer = game:GetService("StarterPlayer")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")

local OWNER_NAME = "BLOXD_IO_YT_ZAY"
local FREE_AGENT = "Free Agent"
local MATCH_LENGTH = 600

local Teams = {
	{ Name = "PSG", PrimaryColor = Color3.fromRGB(35, 68, 175), Kit = { Shirt = Color3.fromRGB(35, 68, 175), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(35, 68, 175), Leggings = Color3.fromRGB(18, 28, 80) } },
	{ Name = "Barcelona", PrimaryColor = Color3.fromRGB(0, 102, 255), Kit = { Shirt = Color3.fromRGB(0, 102, 255), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(0, 102, 255), Leggings = Color3.fromRGB(15, 15, 15) } },
	{ Name = "Real Madrid", PrimaryColor = Color3.fromRGB(255, 255, 255), Kit = { Shirt = Color3.fromRGB(255, 255, 255), Shorts = Color3.fromRGB(0, 0, 0), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(255, 255, 255), Leggings = Color3.fromRGB(25, 25, 25) } },
	{ Name = "Al Nassr", PrimaryColor = Color3.fromRGB(255, 160, 0), Kit = { Shirt = Color3.fromRGB(255, 160, 0), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(255, 160, 0), Leggings = Color3.fromRGB(90, 55, 0) } },
	{ Name = "Al Hilala", PrimaryColor = Color3.fromRGB(0, 153, 76), Kit = { Shirt = Color3.fromRGB(0, 153, 76), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(0, 153, 76), Leggings = Color3.fromRGB(8, 70, 35) } },
	{ Name = "Manchester City", PrimaryColor = Color3.fromRGB(67, 122, 255), Kit = { Shirt = Color3.fromRGB(67, 122, 255), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(67, 122, 255), Leggings = Color3.fromRGB(25, 25, 50) } },
	{ Name = "Bayern Munich", PrimaryColor = Color3.fromRGB(212, 16, 26), Kit = { Shirt = Color3.fromRGB(212, 16, 26), Shorts = Color3.fromRGB(255, 206, 0), Socks = Color3.fromRGB(255, 206, 0), Armor = Color3.fromRGB(212, 16, 26), Leggings = Color3.fromRGB(80, 20, 15) } },
	{ Name = "Liverpool", PrimaryColor = Color3.fromRGB(196, 17, 53), Kit = { Shirt = Color3.fromRGB(196, 17, 53), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(196, 17, 53), Leggings = Color3.fromRGB(65, 10, 25) } },
	{ Name = "Juventus", PrimaryColor = Color3.fromRGB(255, 255, 255), Kit = { Shirt = Color3.fromRGB(255, 255, 255), Shorts = Color3.fromRGB(188, 188, 188), Socks = Color3.fromRGB(188, 188, 188), Armor = Color3.fromRGB(255, 255, 255), Leggings = Color3.fromRGB(60, 60, 60) } },
	{ Name = "Inter Milan", PrimaryColor = Color3.fromRGB(255, 0, 0), Kit = { Shirt = Color3.fromRGB(255, 0, 0), Shorts = Color3.fromRGB(255, 255, 255), Socks = Color3.fromRGB(255, 255, 255), Armor = Color3.fromRGB(255, 0, 0), Leggings = Color3.fromRGB(75, 0, 0) } },
}

local teamByName = {}
local teamRoster = {}
local matchScore = {}
local matchTimer = MATCH_LENGTH
local matchActive = true

local remotesFolder = ReplicatedStorage:FindFirstChild("FootballRemotes") or Instance.new("Folder")
romotesFolder.Name = "FootballRemotes"
remotesFolder.Parent = ReplicatedStorage

local SetTeamRemote = remotesFolder:FindFirstChild("SetTeam") or Instance.new("RemoteEvent")
SetTeamRemote.Name = "SetTeam"
SetTeamRemote.Parent = remotesFolder

local TeamListRemote = remotesFolder:FindFirstChild("TeamList") or Instance.new("RemoteEvent")
TeamListRemote.Name = "TeamList"
TeamListRemote.Parent = remotesFolder

local RosterRemote = remotesFolder:FindFirstChild("RosterInfo") or Instance.new("RemoteEvent")
RosterRemote.Name = "RosterInfo"
RosterRemote.Parent = remotesFolder

local ScoreRemote = remotesFolder:FindFirstChild("ScoreUpdate") or Instance.new("RemoteEvent")
ScoreRemote.Name = "ScoreUpdate"
ScoreRemote.Parent = remotesFolder

local TimerRemote = remotesFolder:FindFirstChild("TimerUpdate") or Instance.new("RemoteEvent")
TimerRemote.Name = "TimerUpdate"
TimerRemote.Parent = remotesFolder

local function ensureTeams()
	for _, teamData in ipairs(Teams) do
		if not teamByName[teamData.Name] then
			local teamPart = Instance.new("Team")
			teamPart.Name = teamData.Name
			teamPart.Parent = TeamsService
			teamByName[teamData.Name] = teamPart
			teamRoster[teamData.Name] = {}
			matchScore[teamData.Name] = 0
		end
	end
end

local function getPlayerTeam(player)
	local value = player:GetAttribute("FootballTeam")
	if typeof(value) == "string" and value ~= "" then
		return value
	end
	return FREE_AGENT
end

local function setPlayerTeam(player, teamName)
	player:SetAttribute("FootballTeam", teamName)
	player:SetAttribute("IsFreeAgent", teamName == FREE_AGENT)
end

local function removePlayerFromTeam(teamName, player)
	local roster = teamRoster[teamName]
	if not roster then return end
	for i, p in ipairs(roster) do
		if p == player then
			table.remove(roster, i)
			break
		end
	end
end

local function addPlayerToTeam(teamName, player)
	if not teamRoster[teamName] then teamRoster[teamName] = {} end
	removePlayerFromTeam(teamName, player)
	table.insert(teamRoster[teamName], player)
end

local function broadcastRoster()
	RosterRemote:FireAllClients(teamRoster)
end

local function createTeamTag(character, teamName, teamColor)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local oldTag = hrp:FindFirstChild("FootballTeamTag")
	if oldTag then oldTag:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FootballTeamTag"
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 200, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = teamName
	label.TextColor3 = teamColor
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
end

local function createOwnerNumberTag(character)
	local head = character:FindFirstChild("Head")
	if not head then return end

	local oldTag = head:FindFirstChild("OwnerNumberTag")
	if oldTag then oldTag:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OwnerNumberTag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 110, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "1"
	label.TextColor3 = Color3.fromRGB(255, 200, 0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = billboard
end

local function applyKitToCharacter(player, character, teamName)
	if teamName == FREE_AGENT then return end

	local targetTeam = nil
	for _, teamData in ipairs(Teams) do
		if teamData.Name == teamName then
			targetTeam = teamData
			break
		end
	end

	if not targetTeam then return end

	local bodyColors = character:FindFirstChild("BodyColors")
	if bodyColors then
		bodyColors.HeadColor3 = targetTeam.Kit.Shirt
		bodyColors.TorsoColor3 = targetTeam.Kit.Shirt
		bodyColors.LeftArmColor3 = targetTeam.Kit.Shirt
		bodyColors.RightArmColor3 = targetTeam.Kit.Shirt
		bodyColors.LeftLegColor3 = targetTeam.Kit.Shorts
		bodyColors.RightLegColor3 = targetTeam.Kit.Shorts
	end

	local partNames = { "FootballKitShirt", "FootballKitShorts", "FootballKitLeftSock", "FootballKitRightSock" }
	for _, partName in ipairs(partNames) do
		local part = character:FindFirstChild(partName)
		if part then part:Destroy() end
	end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if torso then
		local shirt = Instance.new("Part")
		shirt.Name = "FootballKitShirt"
		shirt.Size = Vector3.new(2.1, 1.8, 0.4)
		shirt.Color = targetTeam.Kit.Shirt
		shirt.Material = Enum.Material.SmoothPlastic
		shirt.Anchored = false
		shirt.CanCollide = false
		shirt.Parent = character

		local shirtWeld = Instance.new("WeldConstraint")
		shirtWeld.Part0 = torso
		shirtWeld.Part1 = shirt
		shirtWeld.Parent = character
		shirt.CFrame = torso.CFrame * CFrame.new(0, 0.2, 0.2)

		local shorts = Instance.new("Part")
		shorts.Name = "FootballKitShorts"
		shorts.Size = Vector3.new(2.1, 0.8, 0.6)
		shorts.Color = targetTeam.Kit.Shorts
		shorts.Material = Enum.Material.SmoothPlastic
		shorts.Anchored = false
		shorts.CanCollide = false
		shorts.Parent = character

		local shortsWeld = Instance.new("WeldConstraint")
		shortsWeld.Part0 = torso
		shortsWeld.Part1 = shorts
		shortsWeld.Parent = character
		shorts.CFrame = torso.CFrame * CFrame.new(0, -1.1, 0.15)

		local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
		local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")

		if leftLeg then
			local leftSock = Instance.new("Part")
			leftSock.Name = "FootballKitLeftSock"
			leftSock.Size = Vector3.new(0.7, 1.1, 0.4)
			leftSock.Color = targetTeam.Kit.Socks
			leftSock.Material = Enum.Material.SmoothPlastic
			leftSock.Anchored = false
			leftSock.CanCollide = false
			leftSock.Parent = character

			local leftWeld = Instance.new("WeldConstraint")
			leftWeld.Part0 = leftLeg
			leftWeld.Part1 = leftSock
			leftWeld.Parent = character
			leftSock.CFrame = leftLeg.CFrame * CFrame.new(0, 0.2, 0.2)
		end

		if rightLeg then
			local rightSock = Instance.new("Part")
			rightSock.Name = "FootballKitRightSock"
			rightSock.Size = Vector3.new(0.7, 1.1, 0.4)
			rightSock.Color = targetTeam.Kit.Socks
			rightSock.Material = Enum.Material.SmoothPlastic
			rightSock.Anchored = false
			rightSock.CanCollide = false
			rightSock.Parent = character

			local rightWeld = Instance.new("WeldConstraint")
			rightWeld.Part0 = rightLeg
			rightWeld.Part1 = rightSock
			rightWeld.Parent = character
			rightSock.CFrame = rightLeg.CFrame * CFrame.new(0, 0.2, 0.2)
		end
	end

	createteamTag(character, teamName, targetTeam.PrimaryColor)
end

local function setupPlayer(player)
	setPlayerTeam(player, FREE_AGENT)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		local currentTeam = getPlayerTeam(player)
		if currentTeam == FREE_AGENT then
			createTeamTag(character, FREE_AGENT, Color3.fromRGB(200, 200, 200))
		else
			applyKitToCharacter(player, character, currentTeam)
		end

		if player.Name == OWNER_NAME then
			createOwnerNumberTag(character)
		end
	end)

	if player.Character then
		local currentTeam = getPlayerTeam(player)
		if currentTeam == FREE_AGENT then
			createTeamTag(player.Character, FREE_AGENT, Color3.fromRGB(200, 200, 200))
		else
			applyKitToCharacter(player, player.Character, currentTeam)
		end
	end

	if player.Name == OWNER_NAME and player.Character then
		createOwnerNumberTag(player.Character)
	end

	TeamListRemote:FireClient(player, Teams)
	RosterRemote:FireClient(player, teamRoster)
	ScoreRemote:FireClient(player, matchScore)
	TimerRemote:FireClient(player, matchTimer)
end

local function validTeam(teamName)
	if teamName == FREE_AGENT then return true end
	for _, teamData in ipairs(Teams) do
		if teamData.Name == teamName then return true end
	end
	return false
end

SetTeamRemote.OnServerEvent:Connect(function(player, teamName)
	if not validTeam(teamName) then return end

	local oldTeam = getPlayerTeam(player)
	if oldTeam ~= FREE_AGENT then
		removePlayerFromTeam(oldTeam, player)
	end

	if teamName == FREE_AGENT then
		setPlayerTeam(player, FREE_AGENT)
	else
		addPlayerToTeam(teamName, player)
		setPlayerTeam(player, teamName)
	end

	if player.Character then
		local currentTeam = getPlayerTeam(player)
		if currentTeam == FREE_AGENT then
			createTeamTag(player.Character, FREE_AGENT, Color3.fromRGB(200, 200, 200))
		else
			applyKitToCharacter(player, player.Character, currentTeam)
		end
	end

	broadcastRoster()
	TeamListRemote:FireClient(player, Teams)
end)

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

ensureTeams()

local originalOnIncomingMessage = TextChatService.OnIncomingMessage
TextChatService.OnIncomingMessage = function(message)
	if message and message.Sender and message.Sender.Name == OWNER_NAME then
		message.Text = "[BLOXD_IO_YT_ZAY] " .. message.Text
	end

	if originalOnIncomingMessage then
		return originalOnIncomingMessage(message)
	end

	return message
end

-- CREATE FOOTBALL FIELD
local field = Workspace:FindFirstChild("FootballField")
if not field then
	field = Instance.new("Part")
	field.Name = "FootballField"
	field.Size = Vector3.new(300, 1, 180)
	field.Position = Vector3.new(0, 0, 0)
	field.Anchored = true
	field.Material = Enum.Material.Grass
	field.Color = Color3.fromRGB(30, 130, 70)
	field.CanCollide = true
	field.Parent = Workspace
end

-- CREATE FOOTBALL BALL
local ball = Workspace:FindFirstChild("FootballBall")
if not ball then
	ball = Instance.new("Part")
	ball.Name = "FootballBall"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(2, 2, 2)
	ball.Material = Enum.Material.SmoothPlastic
	ball.Color = Color3.fromRGB(255, 255, 255)
	ball.Position = Vector3.new(0, 5, 0)
	ball.CanCollide = true
	ball.TopSurface = Enum.SurfaceType.Smooth
	ball.BottomSurface = Enum.SurfaceType.Smooth
	ball.Parent = Workspace

	local ballPhysics = PhysicalProperties.new(0.5, 0.3, 0.5)
	ball.CustomPhysicalProperties = ballPhysics
end

-- CREATE GOALS
local leftGoal = Workspace:FindFirstChild("LeftGoal")
if not leftGoal then
	leftGoal = Instance.new("Part")
	leftGoal.Name = "LeftGoal"
	leftGoal.Size = Vector3.new(2, 15, 40)
	leftGoal.Position = Vector3.new(-150, 7, 0)
	leftGoal.Anchored = true
	leftGoal.CanCollide = true
	leftGoal.Transparency = 0.5
	leftGoal.Material = Enum.Material.SmoothPlastic
	leftGoal.Color = Color3.fromRGB(255, 255, 255)
	leftGoal.Parent = Workspace
end

local rightGoal = Workspace:FindFirstChild("RightGoal")
if not rightGoal then
	rightGoal = Instance.new("Part")
	rightGoal.Name = "RightGoal"
	rightGoal.Size = Vector3.new(2, 15, 40)
	rightGoal.Position = Vector3.new(150, 7, 0)
	rightGoal.Anchored = true
	rightGoal.CanCollide = true
	rightGoal.Transparency = 0.5
	rightGoal.Material = Enum.Material.SmoothPlastic
	rightGoal.Color = Color3.fromRGB(255, 255, 255)
	rightGoal.Parent = Workspace
end

-- GOAL ZONES
local leftGoalZone = Workspace:FindFirstChild("LeftGoalZone")
if not leftGoalZone then
	leftGoalZone = Instance.new("Part")
	leftGoalZone.Name = "LeftGoalZone"
	leftGoalZone.Size = Vector3.new(1, 15, 40)
	leftGoalZone.Position = Vector3.new(-151, 7, 0)
	leftGoalZone.Anchored = true
	leftGoalZone.CanCollide = false
	leftGoalZone.Transparency = 1
	leftGoalZone.Parent = Workspace

	leftGoalZone.Touched:Connect(function(hit)
		if hit.Name == "FootballBall" then
			if matchActive then
				matchScore[Teams[2].Name] = (matchScore[Teams[2].Name] or 0) + 1
				ScoreRemote:FireAllClients(matchScore)
				ball.Position = Vector3.new(0, 5, 0)
				ball.AssemblyLinearVelocity = Vector3.zero
				ball.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end)
end

local rightGoalZone = Workspace:FindFirstChild("RightGoalZone")
if not rightGoalZone then
	rightGoalZone = Instance.new("Part")
	rightGoalZone.Name = "RightGoalZone"
	rightGoalZone.Size = Vector3.new(1, 15, 40)
	rightGoalZone.Position = Vector3.new(151, 7, 0)
	rightGoalZone.Anchored = true
	rightGoalZone.CanCollide = false
	rightGoalZone.Transparency = 1
	rightGoalZone.Parent = Workspace

	rightGoalZone.Touched:Connect(function(hit)
		if hit.Name == "FootballBall" then
			if matchActive then
				matchScore[Teams[1].Name] = (matchScore[Teams[1].Name] or 0) + 1
				ScoreRemote:FireAllClients(matchScore)
				ball.Position = Vector3.new(0, 5, 0)
				ball.AssemblyLinearVelocity = Vector3.zero
				ball.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end)
end

-- TEAM SPAWNS
local blueSpawn = Workspace:FindFirstChild("BlueTeamSpawn")
if not blueSpawn then
	blueSpawn = Instance.new("SpawnLocation")
	blueSpawn.Name = "BlueTeamSpawn"
	blueSpawn.Size = Vector3.new(15, 1, 15)
	blueSpawn.Position = Vector3.new(-80, 4, -30)
	blueSpawn.Anchored = true
	blueSpawn.Material = Enum.Material.Neon
	blueSpawn.Color = Teams[1].PrimaryColor
	blueSpawn.CanCollide = true
	blueSpawn.Parent = Workspace
end

local redSpawn = Workspace:FindFirstChild("RedTeamSpawn")
if not redSpawn then
	redSpawn = Instance.new("SpawnLocation")
	redSpawn.Name = "RedTeamSpawn"
	redSpawn.Size = Vector3.new(15, 1, 15)
	redSpawn.Position = Vector3.new(80, 4, 30)
	redSpawn.Anchored = true
	redSpawn.Material = Enum.Material.Neon
	redSpawn.Color = Teams[2].PrimaryColor
	redSpawn.CanCollide = true
	redSpawn.Parent = Workspace
end

-- MATCH TIMER
coroutine.wrap(function()
	while matchActive do
		task.wait(1)
		matchTimer = matchTimer - 1
		TimerRemote:FireAllClients(matchTimer)

		if matchTimer <= 0 then
			matchActive = false
			break
		end
	end
end)()

-- CLIENT UI SCRIPT
local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
if not starterScripts then
	starterScripts = Instance.new("Folder")
	starterScripts.Name = "StarterPlayerScripts"
	starterScripts.Parent = StarterPlayer
end

local clientScript = starterScripts:FindFirstChild("BloxdFootballUI")
if clientScript then clientScript:Destroy() end

local clientCode = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remoteFolder = ReplicatedStorage:WaitForChild("FootballRemotes")
local SetTeamRemote = remoteFolder:WaitForChild("SetTeam")
local TeamListRemote = remoteFolder:WaitForChild("TeamList")
local RosterRemote = remoteFolder:WaitForChild("RosterInfo")
local ScoreRemote = remoteFolder:WaitForChild("ScoreUpdate")
local TimerRemote = remoteFolder:WaitForChild("TimerUpdate")

local cachedTeams = {}
local cachedRoster = {}
local cachedScore = {}
local cachedTimer = 600

local function makeText(parent, size, position, text, color)
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = parent
	return label
end

local function makeButton(parent, size, position, text, callback, buttonColor)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = buttonColor or Color3.fromRGB(30, 30, 30)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	button.MouseButton1Click:Connect(callback)
	return button
end

local function openTeamMenu()
	local existing = playerGui:FindFirstChild("FootballTeamMenu")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "FootballTeamMenu"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.38, 0, 0.76, 0)
	frame.Position = UDim2.new(0.31, 0, 0.12, 0)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local title = makeText(frame, UDim2.new(1, -20, 0, 45), UDim2.new(0, 10, 0, 15), "Choose Your Team", Color3.fromRGB(255, 255, 255))
	title.TextSize = 28

	local scroller = Instance.new("ScrollingFrame")
	scroller.Size = UDim2.new(1, -20, 0.8, -50)
	scroller.Position = UDim2.new(0, 10, 0, 75)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 7
	scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroller.Parent = frame

	local buttons = {}

	local function render()
		for _, oldButton in ipairs(buttons) do
			oldButton:Destroy()
		end
		buttons = {}

		local y = 0

		local freeButton = makeButton(scroller, UDim2.new(1, -10, 0, 44), UDim2.new(0, 5, 0, y), "Free Agent", function()
			SetTeamRemote:FireServer("Free Agent")
			gui:Destroy()
		end, Color3.fromRGB(90, 90, 90))
		table.insert(buttons, freeButton)
		y = y + 52

		for _, teamData in ipairs(cachedTeams) do
			local teamButton = makeButton(scroller, UDim2.new(1, -10, 0, 44), UDim2.new(0, 5, 0, y), teamData.Name, function()
				SetTeamRemote:FireServer(teamData.Name)
				gui:Destroy()
			end, teamData.PrimaryColor)
			table.insert(buttons, teamButton)
			y = y + 52
		end

		scroller.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	local closeButton = makeButton(frame, UDim2.new(0, 120, 0, 36), UDim2.new(1, -130, 0, 15), "Close", function()
		gui:Destroy()
	end, Color3.fromRGB(60, 60, 60))

	render()
end

local function createStatusPanel()
	local existing = playerGui:FindFirstChild("FootballStatusPanel")
	if existing then existing:Destroy() end

	local panelGui = Instance.new("ScreenGui")
	panelGui.Name = "FootballStatusPanel"
	panelGui.ResetOnSpawn = false
	panelGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 340, 0, 140)
	panel.Position = UDim2.new(0.02, 0, 0.8, 0)
	panel.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
	panel.BorderSizePixel = 0
	panel.Parent = panelGui

	local title = makeText(panel, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), "Football Club", Color3.fromRGB(255, 255, 255))
	title.TextSize = 18

	local teamLabel = makeText(panel, UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 42), player:GetAttribute("FootballTeam") or "Free Agent", Color3.fromRGB(255, 255, 255))
	teamLabel.TextSize = 22

	local rosterLabel = makeText(panel, UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 82), "Roster: None", Color3.fromRGB(180, 180, 180))
	rosterLabel.TextSize = 14

	local scoreLabel = makeText(panel, UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 112), "Score: 0-0", Color3.fromRGB(255, 255, 0))
	scoreLabel.TextSize = 12

	local function refresh()
		local currentTeam = player:GetAttribute("FootballTeam") or "Free Agent"
		teamLabel.Text = currentTeam

		local rosterText = "Roster: "
		local list = cachedRoster[currentTeam] or {}

		if #list > 0 then
			local names = {}
			for _, member in ipairs(list) do
				table.insert(names, member.Name)
			end
			rosterText = rosterText .. table.concat(names, ", ")
		else
			rosterText = rosterText .. "No players"
		end

		rosterLabel.Text = rosterText

		local score1 = cachedScore["PSG"] or 0
		local score2 = cachedScore["Barcelona"] or 0
		scoreLabel.Text = "Score: " .. score1 .. " - " .. score2
	end

	RosterRemote.OnClientEvent:Connect(function(rosterData)
		cachedRoster = rosterData
		refresh()
	end)

	TeamListRemote.OnClientEvent:Connect(function(teamData)
		cachedTeams = teamData
	end)

	ScoreRemote.OnClientEvent:Connect(function(scoreData)
		cachedScore = scoreData
		refresh()
	end)

	refresh()
end

local function createTeamButton()
	local existing = playerGui:FindFirstChild("TeamButtonGui")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "TeamButtonGui"
	gui.Parent = playerGui

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 170, 0, 42)
	button.Position = UDim2.new(0.82, 0, 0.02, 0)
	button.BackgroundColor3 = Color3.fromRGB(20, 35, 60)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Text = "Choose Team"
	button.Parent = gui
	button.MouseButton1Click:Connect(function()
		openTeamMenu()
	end)

	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(0, 220, 0, 24)
	hint.Position = UDim2.new(0.8, 0, 0.07, 0)
	hint.BackgroundTransparency = 1
	hint.Text = "Press T to open | Click ball to kick"
	hint.TextColor3 = Color3.fromRGB(255, 255, 255)
	hint.TextSize = 13
	hint.Font = Enum.Font.Gotham
	hint.Parent = gui

	local timerLabel = makeText(gui, UDim2.new(0, 150, 0, 30), UDim2.new(0.82, 0, 0.15, 0), "Time: 10:00", Color3.fromRGB(255, 100, 100))
	timerLabel.TextSize = 20

	TimerRemote.OnClientEvent:Connect(function(timeLeft)
		local mins = math.floor(timeLeft / 60)
		local secs = timeLeft % 60
		timerLabel.Text = "Time: " .. string.format("%d:%02d", mins, secs)
	end)
end

RosterRemote.OnClientEvent:Connect(function(rosterData)
	cachedRoster = rosterData
end)

TeamListRemote.OnClientEvent:Connect(function(teamData)
	cachedTeams = teamData
end)

ScoreRemote.OnClientEvent:Connect(function(scoreData)
	cachedScore = scoreData
end)

createeStatusPanel()
createTeamButton()

local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	local ball = workspace:FindFirstChild("FootballBall")
	if ball then
		local distance = (ball.Position - player.Character.HumanoidRootPart.Position).Magnitude
		if distance < 20 then
			local kickForce = (player.Character.HumanoidRootPart.Position - ball.Position).Unit * 100
			ball.AssemblyLinearVelocity = kickForce
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		openTeamMenu()
	end
end)
]]

local localScript = Instance.new("LocalScript")
localScript.Name = "BloxdFootballUI"
localScript.Source = clientCode
localScript.Parent = starterScripts

print("BLOXD FOOTBALL GAME FULLY LOADED - Ball, Goals, Teams, Scoreboard READY")
