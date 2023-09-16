local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local isRunning = false
local UseRage = false
local UseRapture = false
local sliderValue = 20
local ggdebounce = false
local focusedBall, displayBall = nil, nil
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ballsFolder = workspace:WaitForChild("Balls")
local parryButtonPress = replicatedStorage.Remotes.ParryButtonPress
local abilityButtonPress = replicatedStorage.Remotes.AbilityButtonPress
local BASE_THRESHOLD = 0.15
local VELOCITY_SCALING_FACTOR_FAST = 0.050
local VELOCITY_SCALING_FACTOR_SLOW = 0.1
local responses = {
    "lol what",
    "??",
    "wdym",
    "bru what",
    "mad cuz bad",
    "skill issue",
    "cry"
}
local gameEndResponses = {
    "ggs",
    "gg :3",
    "good game",
    "ggs yall",
    "wp",
    "ggs man"
}
local keywords = {
    "auto parry",
    "auto",
    "cheating",
    "hacking"
}

local function isValidBall(ball)
    return ball and ball.Parent and (ball:GetAttribute("realBall") or ball:GetAttribute("target"))
end

local function chooseNewFocusedBall()
    local balls = ballsFolder:GetChildren()
    for _, ball in ipairs(balls) do
        if ball:GetAttribute("realBall") ~= nil and ball:GetAttribute("realBall") == true then
            focusedBall = ball
            print(focusedBall.Name)
            break
        elseif ball:GetAttribute("target") ~= nil then
            focusedBall = ball
            print(focusedBall.Name)
            break
        end
    end
    
    if focusedBall == nil then
        print("Debug: Could not find a ball that's the realBall or has a target.")
    end
    return focusedBall
end


local function getDynamicThreshold(ballVelocityMagnitude)
    if ballVelocityMagnitude > 60 then
        return math.max(0.20, BASE_THRESHOLD - (ballVelocityMagnitude * VELOCITY_SCALING_FACTOR_FAST))
    else
        return math.min(0.01, BASE_THRESHOLD + (ballVelocityMagnitude * VELOCITY_SCALING_FACTOR_SLOW))
    end
end

local function timeUntilImpact(ballVelocity, distanceToPlayer, playerVelocity)
    local directionToPlayer = (character.HumanoidRootPart.Position - focusedBall.Position).Unit
    local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer) - playerVelocity:Dot(directionToPlayer)
    
    if velocityTowardsPlayer <= 0 then
        return math.huge
    end
    
    return (distanceToPlayer - sliderValue) / velocityTowardsPlayer
end

local function isWalkSpeedZero()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return true
    end
    return false
end


local function checkBallDistance()
    if not character or not character:FindFirstChild("Highlight") then return end

    local charPos = character.HumanoidRootPart.Position
    local charVel = character.HumanoidRootPart.Velocity

    if focusedBall and not focusedBall.Parent then
        print("Focused ball lost parent. Choosing a new focused ball.")
        chooseNewFocusedBall()
    end
    if not focusedBall then 
        print("No focused ball.")
        chooseNewFocusedBall()
    end

    local ball = focusedBall

    if ball.zoomies.VectorVelocity == nil or (ball.zoomies.VectorVelocity.x == -0 or ball.zoomies.VectorVelocity.x == 0 or ball.zoomies.VectorVelocity.y == -0 or ball.zoomies.VectorVelocity.y == 0 or ball.zoomies.VectorVelocity.z == -0 or ball.zoomies.VectorVelocity.z == 0) then
        return 
    end

    local distanceToPlayer = (ball.Position - charPos).Magnitude
    local ballVelocityTowardsPlayer = ball.Velocity:Dot((charPos - ball.Position).Unit)
    
    if distanceToPlayer < 10 then
        parryButtonPress:Fire()
    end

    if timeUntilImpact(ball.Velocity, distanceToPlayer, charVel) < getDynamicThreshold(ballVelocityTowardsPlayer) then
        if character.Abilities["Raging Deflection"].Enabled and UseRage then
            abilityButtonPress:Fire()
            if not character:FindFirstChildOfClass("Humanoid").Walkspeed == 0 then
                parryButtonPress:Fire()
            end
        elseif character.Abilities["Rapture"].Enabled and UseRapture then
            abilityButtonPress:Fire()
            if not character:FindFirstChildOfClass("Humanoid").Walkspeed == 0 then
                parryButtonPress:Fire()
            end
        else
            parryButtonPress:Fire()
        end
    end
end


localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

if character then
    print("Character found.")
else
    print("Character not found.")
    return
end


local function autoParryCoroutine()
    while isRunning do
        checkBallDistance()
        task.wait()
    end
end

local function startAutoParry()
    print("Script successfully ran.")
    
    chooseNewFocusedBall()
    
    isRunning = true
    local co = coroutine.create(autoParryCoroutine)
    coroutine.resume(co)
end

local function stopAutoParry()
    isRunning = false
end


local Window = Rayfield:CreateWindow({
    Name = "Blade Ball",
    LoadingTitle = "Inferno Scripts",
    LoadingSubtitle = "by InfernoKarl",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = "Inferno Scripts",
       FileName = "Inferno Scripts"
    },
    Discord = {
       Enabled = true,
       Invite = "hNX8VxcjMF",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Inferno Scripts",
       Subtitle = "Key System",
       Note = "Join the discord (discord.gg/hNX8VxcjMF)",
       FileName = "InfernoKey",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = "Hello"
    }
 })
 
 local AutoParry = Window:CreateTab("Auto Parry", 13014537525)
 
 local AutoParrySection = AutoParry:CreateSection("Auto Parry")
 
 local AutoParryToggle = AutoParry:CreateToggle({
     Name = "Auto Parry",
     CurrentValue = false,
     Flag = "AutoParryFlag",
     Callback = function(Value)
         if Value then
             startAutoParry()
         else
             stopAutoParry()
         end
     end,
 })

 local AutoRagingDeflect = AutoParry:CreateToggle({
     Name = "Auto Rage Parry (MUST EQUIP RAGING DEFLECT)",
     CurrentValue = false,
     Flag = "AutoRagingDeflectFlag",
     Callback = function(Value)
         UseRage = Value
     end,
 })

 local AutoRapture = AutoParry:CreateToggle({
     Name = "Auto Rapture (MUST EQUIP RAPTURE)",
     CurrentValue = false,
     Flag = "AutoRaptureFlag",
     Callback = function(Value)
         UseRapture = Value
     end,
 })
 local CloseFighting = AutoParry:CreateSection("Close Fighting")
 
 local SpamParry = AutoParry:CreateKeybind({
    Name = "Spam Parry (Hold)",
    CurrentKeybind = "C",
    HoldToInteract = true,
    Flag = "ToggleParrySpam", 
    Callback = function(Keybind)
        parryButtonPress:Fire()
    end,
 })
 
 local Configuration = AutoParry:CreateSection("Configuration")
 
 local DistanceSlider = AutoParry:CreateSlider({
    Name = "Distance Configuration",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Distance",
    CurrentValue = 20,
    Flag = "DistanceSlider",
    Callback = function(Value)
        sliderValue = Value
    end,
 })
 
 local ToggleParryOn = AutoParry:CreateKeybind({
    Name = "Toggle Parry (Bind)",
    CurrentKeybind = "One",
    HoldToInteract = false,
    Flag = "ToggleParryOn", 
    Callback = function(Keybind)
        AutoParryToggle:Set(not AutoParryToggle.CurrentValue)
 
    end
 })

local AutoGGToggle = AutoParry:CreateToggle({
    Name = "Auto GG",
    CurrentValue = false,
    Flag = "AutoGGFlage",
    Callback = function(Value)
        return
    end
})

local AutoResponseToggle = AutoParry:CreateToggle({
    Name = "Auto Response",
    CurrentValue = false,
    Flag = "AutoResponseFlage",
    Callback = function(Value)
        return
    end
})

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 0.7,
        Image = 10010348543,
    })
end

local ToggleParryOffPlus = AutoParry:CreateKeybind({
   Name = "+ 10 range",
   CurrentKeybind = "X",
   HoldToInteract = false,
   Flag = "ToggleParryOffPlus",
   Callback = function()
        if sliderValue < 200 then
            sliderValue = sliderValue + 10
            DistanceSlider:Set(sliderValue)
            notify("Range Increased", "New Range: " .. sliderValue)
        end
   end,
})

local ToggleParryOffMinus = AutoParry:CreateKeybind({
   Name = "- 10 range",
   CurrentKeybind = "Z",
   HoldToInteract = false,
   Flag = "ToggleParryOffMinus",
   Callback = function()
        if sliderValue > 0 then
            sliderValue = sliderValue - 10
            DistanceSlider:Set(sliderValue)
            notify("Range Decreased", "New Range: " .. sliderValue)
        end
   end,
})

localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

workspace:FindFirstChild("Balls").ChildAdded:Connect(function(child)
    chooseNewFocusedBall()
end)

workspace:FindFirstChild("Alive").ChildRemoved:Connect(function()
    if #(workspace.Alive:GetChildren()) <= 1 and AutoGGToggle.CurrentValue and not ggdebounce then
        ggdebounce = true
        local randomResponse = math.random(1, #gameEndResponses)
        wait(math.random(2,3.5))
        replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(gameEndResponses[randomResponse],"All")
        task.wait(math.random(1.5,3.3))
        ggdebounce = false
    end
end)

players.PlayerChatted:Connect(function(PlayerChatType,Player,Message)
    for _,v in pairs(keywords) do
        if (string.find(Message, v)) and Player ~= localPlayer and AutoResponseToggle.CurrentValue and not responsedebounce then
            responsedebounce = true
            local choice = math.random(1, #responses)
            replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(responses[choice],"All")
            task.wait(2,5)
            responsedebounce = false
        end
    end
end)
