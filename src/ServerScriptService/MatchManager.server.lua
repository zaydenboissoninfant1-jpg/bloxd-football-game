local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local footballConfig = require(ReplicatedStorage:WaitForChild("FootballConfig"))

local function makeBall()
    local workspace = game:GetService("Workspace")
    local existingBall = workspace:FindFirstChild("FootballBall")
    if existingBall then
        return existingBall
    end

    local ball = Instance.new("Part")
    ball.Name = "FootballBall"
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(2, 2, 2)
    ball.Material = Enum.Material.SmoothPlastic
    ball.Color = Color3.fromRGB(255, 255, 255)
    ball.Position = Vector3.new(0, 4, 0)
    ball.CanCollide = true
    ball.Parent = workspace

    local customProperties = PhysicalProperties.new(1, 0.5, 0.5)
    ball.CustomPhysicalProperties = customProperties

    local ballTrail = Instance.new("Trail")
    ballTrail.Color = Color3.fromRGB(255, 255, 255)
    ballTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 1),
    })
    ballTrail.Lifetime = 0.3
    ballTrail.Parent = ball

    return ball
end

local function makeGoal(position, size, name)
    local workspace = game:GetService("Workspace")
    local goal = workspace:FindFirstChild(name)
    if goal then
        return goal
    end

    local goalPart = Instance.new("Part")
    goalPart.Name = name
    goalPart.Size = size
    goalPart.Position = position
    goalPart.Anchored = true
    goalPart.CanCollide = false
    goalPart.Transparency = 0.7
    goalPart.Material = Enum.Material.SmoothPlastic
    goalPart.Color = Color3.fromRGB(255, 255, 255)
    goalPart.Parent = workspace

    return goalPart
end

local function setupField()
    local workspace = game:GetService("Workspace")

    if not workspace:FindFirstChild("FootballField") then
        local field = Instance.new("Part")
        field.Name = "FootballField"
        field.Size = Vector3.new(200, 2, 120)
        field.Position = Vector3.new(0, 0, 0)
        field.Anchored = true
        field.Material = Enum.Material.Grass
        field.Color = Color3.fromRGB(30, 130, 70)
        field.Parent = workspace
    end

    local leftGoal = makeGoal(Vector3.new(-100, 5, 0), Vector3.new(3, 12, 30), "LeftGoal")
    local rightGoal = makeGoal(Vector3.new(100, 5, 0), Vector3.new(3, 12, 30), "RightGoal")

    local centerMark = Instance.new("Part")
    centerMark.Name = "CenterMark"
    centerMark.Size = Vector3.new(2, 0.5, 2)
    centerMark.Position = Vector3.new(0, 1, 0)
    centerMark.Shape = Enum.PartType.Cylinder
    centerMark.Color = Color3.fromRGB(255, 255, 255)
    centerMark.Anchored = true
    centerMark.Material = Enum.Material.SmoothPlastic
    centerMark.Parent = workspace

    local leftSpawn = Instance.new("SpawnLocation")
    leftSpawn.Name = "BlueTeamSpawn"
    leftSpawn.Size = Vector3.new(12, 1, 12)
    leftSpawn.Position = Vector3.new(-40, 4, 0)
    leftSpawn.Anchored = true
    leftSpawn.Neutral = false
    leftSpawn.Color = footballConfig.Teams[1].PrimaryColor
    leftSpawn.Parent = workspace

    local rightSpawn = Instance.new("SpawnLocation")
    rightSpawn.Name = "RedTeamSpawn"
    rightSpawn.Size = Vector3.new(12, 1, 12)
    rightSpawn.Position = Vector3.new(40, 4, 0)
    rightSpawn.Anchored = true
    rightSpawn.Neutral = false
    rightSpawn.Color = footballConfig.Teams[2].PrimaryColor
    rightSpawn.Parent = workspace
end

makeBall()
setupField()

print("Ball and field initialized.")
