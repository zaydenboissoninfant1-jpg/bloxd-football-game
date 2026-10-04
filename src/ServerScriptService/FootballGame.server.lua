local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")
local TextChatService = game:GetService("TextChatService")

local FootballConfig = require(ReplicatedStorage:WaitForChild("FootballConfig"))

local remoteFolder = ReplicatedStorage:FindFirstChild("FootballRemotes") or Instance.new("Folder")
remoteFolder.Name = "FootballRemotes"
remoteFolder.Parent = ReplicatedStorage

local setTeamRemote = remoteFolder:FindFirstChild("SetTeam") or Instance.new("RemoteEvent")
setTeamRemote.Name = "SetTeam"
setTeamRemote.Parent = remoteFolder

local teamListRemote = remoteFolder:FindFirstChild("TeamList") or Instance.new("RemoteEvent")
teamListRemote.Name = "TeamList"
teamListRemote.Parent = remoteFolder

local rosterRemote = remoteFolder:FindFirstChild("RosterInfo") or Instance.new("RemoteEvent")
rosterRemote.Name = "RosterInfo"
rosterRemote.Parent = remoteFolder

local teamByName = {}
local playersByTeam = {}

local function ensureTeamsExist()
    for _, teamData in ipairs(FootballConfig.Teams) do
        local teamName = teamData.Name
        if not teamByName[teamName] then
            local teamPart = Instance.new("Team")
            teamPart.Name = teamName
            teamPart.Parent = TeamsService
            teamByName[teamName] = teamPart
            playersByTeam[teamName] = {}
        end
    end
end

local function getTeamForPlayer(player)
    local teamName = player:GetAttribute("FootballTeam")
    if typeof(teamName) == "string" and teamName ~= "" then
        return teamName
    end
    return FootballConfig.FREE_AGENT_NAME
end

local function setPlayerAttribute(player, teamName)
    player:SetAttribute("FootballTeam", teamName)
    player:SetAttribute("IsFreeAgent", teamName == FootballConfig.FREE_AGENT_NAME)
end

local function removePlayerFromRoster(teamName, player)
    local roster = playersByTeam[teamName]
    if roster then
        for index, rosterPlayer in ipairs(roster) do
            if rosterPlayer == player then
                table.remove(roster, index)
                break
            end
        end
    end
end

local function addPlayerToRoster(teamName, player)
    if not playersByTeam[teamName] then
        playersByTeam[teamName] = {}
    end

    removePlayerFromRoster(teamName, player)
    table.insert(playersByTeam[teamName], player)
end

local function getRosterForTeam(teamName)
    if not playersByTeam[teamName] then
        return {}
    end
    return playersByTeam[teamName]
end

local function updateRosterForAllClients()
    rosterRemote:FireAllClients(playersByTeam)
end

local function createTeamBillboard(character, teamName, teamColor)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end

    local oldTag = humanoidRootPart:FindFirstChild("FootballTeamTag")
    if oldTag then
        oldTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FootballTeamTag"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = teamName
    label.TextColor3 = teamColor
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
end

local function applyOwnerHeadNumber(player)
    if player.Name ~= FootballConfig.OWNER_NAME then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local head = character:FindFirstChild("Head")
    if not head then
        return
    end

    local oldTag = head:FindFirstChild("OwnerNumberTag")
    if oldTag then
        oldTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "OwnerNumberTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 90, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
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

local function applyChatTag(player)
    if player.Name ~= FootballConfig.OWNER_NAME then
        return
    end

    if TextChatService and TextChatService.OnIncomingMessage then
        local originalOnIncomingMessage = TextChatService.OnIncomingMessage
        TextChatService.OnIncomingMessage = function(message)
            if message and message.Sender == player then
                message.Text = "[BLOXD_IO_YT_ZAY] " .. message.Text
            end
            return originalOnIncomingMessage and originalOnIncomingMessage(message) or message
        end
    end
end

local function applyTeamKit(player, teamName)
    local character = player.Character
    if not character then
        return
    end

    local targetTeam = nil
    for _, teamData in ipairs(FootballConfig.Teams) do
        if teamData.Name == teamName then
            targetTeam = teamData
            break
        end
    end

    if not targetTeam then
        return
    end

    local existingPartNames = {
        "FootballKitShirt",
        "FootballKitShorts",
        "FootballKitLeftSock",
        "FootballKitRightSock",
    }

    for _, partName in ipairs(existingPartNames) do
        local part = character:FindFirstChild(partName)
        if part then
            part:Destroy()
        end
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
        shirt.CFrame = torso.CFrame * CFrame.new(0, 0.15, 0.2)

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
        shorts.CFrame = torso.CFrame * CFrame.new(0, -1.2, 0.15)

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

            local leftSockWeld = Instance.new("WeldConstraint")
            leftSockWeld.Part0 = leftLeg
            leftSockWeld.Part1 = leftSock
            leftSockWeld.Parent = character
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

            local rightSockWeld = Instance.new("WeldConstraint")
            rightSockWeld.Part0 = rightLeg
            rightSockWeld.Part1 = rightSock
            rightSockWeld.Parent = character
            rightSock.CFrame = rightLeg.CFrame * CFrame.new(0, 0.2, 0.2)
        end
    end

    createTeamBillboard(character, teamName, targetTeam.PrimaryColor)
    applyOwnerHeadNumber(player)
end

local function updatePlayerTeam(player, targetTeam)
    local oldTeam = getTeamForPlayer(player)
    if oldTeam ~= FootballConfig.FREE_AGENT_NAME then
        removePlayerFromRoster(oldTeam, player)
    end

    if targetTeam ~= FootballConfig.FREE_AGENT_NAME then
        addPlayerToRoster(targetTeam, player)
    end

    setPlayerAttribute(player, targetTeam)

    if player.Character then
        applyTeamKit(player, targetTeam)
    end

    updateRosterForAllClients()
    teamListRemote:FireClient(player, FootballConfig.Teams)
end

local function setupPlayer(player)
    setPlayerAttribute(player, FootballConfig.FREE_AGENT_NAME)

    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        local selectedTeam = getTeamForPlayer(player)
        if selectedTeam == FootballConfig.FREE_AGENT_NAME then
            createTeamBillboard(character, "Free Agent", Color3.fromRGB(190, 190, 190))
        else
            applyTeamKit(player, selectedTeam)
        end

        if player.Name == FootballConfig.OWNER_NAME then
            applyOwnerHeadNumber(player)
            applyChatTag(player)
        end
    end)

    if player.Character then
        local selectedTeam = getTeamForPlayer(player)
        if selectedTeam == FootballConfig.FREE_AGENT_NAME then
            createTeamBillboard(player.Character, "Free Agent", Color3.fromRGB(190, 190, 190))
        else
            applyTeamKit(player, selectedTeam)
        end
    end

    if player.Name == FootballConfig.OWNER_NAME then
        applyChatTag(player)
    end

    teamListRemote:FireClient(player, FootballConfig.Teams)
    rosterRemote:FireClient(player, playersByTeam)
end

setTeamRemote.OnServerEvent:Connect(function(player, teamName)
    local valid = teamName == FootballConfig.FREE_AGENT_NAME
    if not valid then
        for _, teamData in ipairs(FootballConfig.Teams) do
            if teamData.Name == teamName then
                valid = true
                break
            end
        end
    end

    if not valid then
        return
    end

    updatePlayerTeam(player, teamName)
end)

Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

ensureTeamsExist()
print("Football game server started successfully.")
