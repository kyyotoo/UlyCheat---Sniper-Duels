--[[
  🔐 SYSTÈME DE CODE - STYLE NEXUS VBL
  ✨ Menu sombre draggable + particules violet/rose glow
  🔗 Intégration Junkie Key System API
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ==================== CONFIGURATION ====================
local CONFIG = {
    API_BASE = "https://api.junkie-development.de",
    API_KEY = "6adb46b3-6251-415d-9668-80a8dff2603a",
    GET_LINK_URL = "https://junkie-development.de/get-key/ulycheat"
}

-- Activer HttpService
pcall(function()
    HttpService.HttpEnabled = true
end)

-- ==================== FONCTION DE VÉRIFICATION JUNKIE ====================
local function verifyKeyWithJunkie(userKey)
    -- Méthode 1: POST avec JSON body
    local methods = {
        -- Essai 1: /api/v1/keys/verify avec POST
        function()
            local success, response = pcall(function()
                return HttpService:PostAsync(
                    CONFIG.API_BASE .. "/api/v1/keys/verify",
                    HttpService:JSONEncode({
                        apikey = CONFIG.API_KEY,
                        key = userKey
                    }),
                    Enum.HttpContentType.ApplicationJson,
                    false
                )
            end)
            
            if success then
                local parseSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response)
                end)
                
                if parseSuccess and (data.valid or data.success) then
                    return true
                end
            end
            return false
        end,
        
        -- Essai 2: GET avec query parameters
        function()
            local success, response = pcall(function()
                local url = string.format(
                    "%s/api/v1/keys/verify?apikey=%s&key=%s",
                    CONFIG.API_BASE,
                    HttpService:UrlEncode(CONFIG.API_KEY),
                    HttpService:UrlEncode(userKey)
                )
                return HttpService:GetAsync(url)
            end)
            
            if success then
                local parseSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response)
                end)
                
                if parseSuccess and (data.valid or data.success) then
                    return true
                end
            end
            return false
        end,
        
        -- Essai 3: RequestAsync avec Authorization header
        function()
            local success, response = pcall(function()
                return HttpService:RequestAsync({
                    Url = CONFIG.API_BASE .. "/api/v1/keys/verify",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Authorization"] = "Bearer " .. CONFIG.API_KEY
                    },
                    Body = HttpService:JSONEncode({
                        key = userKey
                    })
                })
            end)
            
            if success and response.Success and response.StatusCode == 200 then
                local parseSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)
                
                if parseSuccess and (data.valid or data.success) then
                    return true
                end
            end
            return false
        end,
        
        -- Essai 4: /api/v1/verify (endpoint alternatif)
        function()
            local success, response = pcall(function()
                return HttpService:PostAsync(
                    CONFIG.API_BASE .. "/api/v1/verify",
                    HttpService:JSONEncode({
                        apikey = CONFIG.API_KEY,
                        key = userKey
                    }),
                    Enum.HttpContentType.ApplicationJson,
                    false
                )
            end)
            
            if success then
                local parseSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response)
                end)
                
                if parseSuccess and (data.valid or data.success) then
                    return true
                end
            end
            return false
        end
    }
    
    -- Essayer chaque méthode
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result then
            return true
        end
        task.wait(0.2) -- Petit délai entre les tentatives
    end
    
    return false
end

-- ==================== CRÉATION DU GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UlyCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Overlay noir semi-transparent
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.3
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 100
Overlay.Parent = ScreenGui

-- Effet de flou
local Blur = Instance.new("BlurEffect")
Blur.Size = 12
Blur.Parent = game:GetService("Lighting")

-- Frame principale (PLUS SOMBRE)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Plus sombre
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 101
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- ==================== PARTICULES VIOLET/ROSE GLOW ====================
local function createParticle()
    local particle = Instance.new("Frame")
    local size = math.random(4, 10)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random(0, 100) / 100, 0, 0, -20)
    
    -- Couleurs violet/rose aléatoires
    local colors = {
        Color3.fromRGB(147, 51, 234), -- Violet
        Color3.fromRGB(168, 85, 247), -- Violet clair
        Color3.fromRGB(217, 70, 239), -- Rose violet
        Color3.fromRGB(236, 72, 153), -- Rose
        Color3.fromRGB(219, 39, 119), -- Rose foncé
    }
    
    particle.BackgroundColor3 = colors[math.random(1, #colors)]
    particle.BackgroundTransparency = math.random(20, 50) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 99
    particle.Parent = MainFrame
    
    -- Effet GLOW (UIStroke)
    local glow = Instance.new("UIStroke")
    glow.Color = particle.BackgroundColor3
    glow.Thickness = 0
    glow.Transparency = 0.3
    glow.Parent = particle
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local fallDuration = math.random(4, 7)
    local sway = math.random(-40, 40)
    
    -- Animation de chute
    TweenService:Create(particle, TweenInfo.new(fallDuration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(particle.Position.X.Scale, sway, 1, 20),
        BackgroundTransparency = 0.9
    }):Play()
    
    -- Animation du glow (pulse)
    spawn(function()
        while particle.Parent do
            TweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Thickness = size / 2
            }):Play()
            task.wait(0.8)
            TweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Thickness = 0
            }):Play()
            task.wait(0.8)
        end
    end)
    
    -- Rotation légère
    spawn(function()
        while particle.Parent do
            particle.Rotation = particle.Rotation + math.random(-3, 3)
            task.wait(0.1)
        end
    end)
    
    -- Suppression automatique
    task.delay(fallDuration + 0.5, function()
        if particle.Parent then
            particle:Destroy()
        end
    end)
end

-- Générateur de particules continu
spawn(function()
    while MainFrame.Parent do
        createParticle()
        task.wait(math.random(8, 20) / 100) -- Plus de particules
    end
end)

-- ==================== SYSTÈME DE DRAG (DÉPLAÇABLE) ====================
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

-- Barre de titre (PLUS SOMBRE)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12) -- Plus sombre
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 102
TitleBar.Parent = MainFrame

-- Active le drag sur la barre de titre
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 1, -20)
TitleFix.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 102
TitleFix.Parent = TitleBar

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 30, 0, 30)
TitleIcon.Position = UDim2.new(0, 18, 0, 13)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🛡️"
TitleIcon.TextSize = 20
TitleIcon.ZIndex = 103
TitleIcon.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 0, 55)
Title.Position = UDim2.new(0, 55, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "UlyCheat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 103
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -50, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 22
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 103
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- Contenu principal
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -70, 1, -120)
Content.Position = UDim2.new(0, 35, 0, 75)
Content.BackgroundTransparency = 1
Content.ZIndex = 102
Content.Parent = MainFrame

-- Titre "Nexus VBL Key System" avec glow violet
local SystemTitle = Instance.new("TextLabel")
SystemTitle.Size = UDim2.new(1, 0, 0, 32)
SystemTitle.Position = UDim2.new(0, 0, 0, 20)
SystemTitle.BackgroundTransparency = 1
SystemTitle.Text = "UlyCheat Key System"
SystemTitle.TextColor3 = Color3.fromRGB(217, 70, 239) -- Rose violet
SystemTitle.TextSize = 21
SystemTitle.Font = Enum.Font.GothamBold
SystemTitle.ZIndex = 103
SystemTitle.Parent = Content

-- Glow sur le titre
local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(147, 51, 234)
TitleStroke.Thickness = 2
TitleStroke.Transparency = 0.5
TitleStroke.Parent = SystemTitle

-- Sous-titre
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 22)
Subtitle.Position = UDim2.new(0, 0, 0, 52)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Key Verification Required"
Subtitle.TextColor3 = Color3.fromRGB(140, 150, 165)
Subtitle.TextSize = 13
Subtitle.Font = Enum.Font.Gotham
Subtitle.ZIndex = 103
Subtitle.Parent = Content

-- Conteneur de l'input (PLUS SOMBRE)
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(1, 0, 0, 48)
InputContainer.Position = UDim2.new(0, 0, 0, 100)
InputContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Plus sombre
InputContainer.BorderSizePixel = 0
InputContainer.ZIndex = 103
InputContainer.Parent = Content

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 10)
InputCorner.Parent = InputContainer

local KeyIcon = Instance.new("ImageLabel")
KeyIcon.Size = UDim2.new(0, 22, 0, 22)
KeyIcon.Position = UDim2.new(0, 16, 0.5, -11)
KeyIcon.BackgroundTransparency = 1
KeyIcon.Image = "rbxassetid://6031625888"
KeyIcon.ImageColor3 = Color3.fromRGB(147, 51, 234) -- Violet
KeyIcon.ZIndex = 104
KeyIcon.Parent = InputContainer

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -55, 1, 0)
InputBox.Position = UDim2.new(0, 48, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.Text = ""
InputBox.PlaceholderText = "Enter your verification key"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(90, 100, 120)
InputBox.TextSize = 14
InputBox.Font = Enum.Font.Gotham
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.TextEditable = true
InputBox.ZIndex = 104
InputBox.Parent = InputContainer

-- Conteneur des boutons
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 0, 48)
ButtonContainer.Position = UDim2.new(0, 0, 0, 163)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ZIndex = 103
ButtonContainer.Parent = Content

-- Bouton "Get Link" (Violet)
local GetLinkButton = Instance.new("TextButton")
GetLinkButton.Size = UDim2.new(0.48, 0, 1, 0)
GetLinkButton.Position = UDim2.new(0, 0, 0, 0)
GetLinkButton.BackgroundColor3 = Color3.fromRGB(147, 51, 234) -- Violet
GetLinkButton.Text = ""
GetLinkButton.BorderSizePixel = 0
GetLinkButton.ZIndex = 104
GetLinkButton.Parent = ButtonContainer

local GetLinkCorner = Instance.new("UICorner")
GetLinkCorner.CornerRadius = UDim.new(0, 10)
GetLinkCorner.Parent = GetLinkButton

local LinkXIcon = Instance.new("TextLabel")
LinkXIcon.Size = UDim2.new(0, 22, 0, 22)
LinkXIcon.Position = UDim2.new(0, 18, 0.5, -11)
LinkXIcon.BackgroundTransparency = 1
LinkXIcon.Text = "🔗"
LinkXIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
LinkXIcon.TextSize = 16
LinkXIcon.Font = Enum.Font.GothamBold
LinkXIcon.ZIndex = 105
LinkXIcon.Parent = GetLinkButton

local GetLinkText = Instance.new("TextLabel")
GetLinkText.Size = UDim2.new(1, -50, 1, 0)
GetLinkText.Position = UDim2.new(0, 45, 0, 0)
GetLinkText.BackgroundTransparency = 1
GetLinkText.Text = "Get Key"
GetLinkText.TextColor3 = Color3.fromRGB(255, 255, 255)
GetLinkText.TextSize = 15
GetLinkText.Font = Enum.Font.GothamMedium
GetLinkText.ZIndex = 105
GetLinkText.Parent = GetLinkButton

-- Bouton "Verify Key" (Rose)
local VerifyButton = Instance.new("TextButton")
VerifyButton.Size = UDim2.new(0.48, 0, 1, 0)
VerifyButton.Position = UDim2.new(0.52, 0, 0, 0)
VerifyButton.BackgroundColor3 = Color3.fromRGB(219, 39, 119) -- Rose
VerifyButton.Text = ""
VerifyButton.BorderSizePixel = 0
VerifyButton.ZIndex = 104
VerifyButton.Parent = ButtonContainer

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 10)
VerifyCorner.Parent = VerifyButton

local CheckIcon = Instance.new("TextLabel")
CheckIcon.Size = UDim2.new(0, 22, 0, 22)
CheckIcon.Position = UDim2.new(0, 18, 0.5, -11)
CheckIcon.BackgroundTransparency = 1
CheckIcon.Text = "✓"
CheckIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckIcon.TextSize = 18
CheckIcon.Font = Enum.Font.GothamBold
CheckIcon.ZIndex = 105
CheckIcon.Parent = VerifyButton

local VerifyText = Instance.new("TextLabel")
VerifyText.Size = UDim2.new(1, -50, 1, 0)
VerifyText.Position = UDim2.new(0, 45, 0, 0)
VerifyText.BackgroundTransparency = 1
VerifyText.Text = "Verify Key"
VerifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyText.TextSize = 15
VerifyText.Font = Enum.Font.GothamMedium
VerifyText.ZIndex = 105
VerifyText.Parent = VerifyButton

-- ==================== NOTIFICATION ====================
local function createNotification(message, icon)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 0, 0, 65)
    Notif.Position = UDim2.new(1, -20, 1, -85)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Notif.BorderSizePixel = 0
    Notif.ZIndex = 200
    Notif.ClipsDescendants = true
    Notif.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 14)
    NotifCorner.Parent = Notif
    
    local NotifIcon = Instance.new("TextLabel")
    NotifIcon.Size = UDim2.new(0, 45, 0, 45)
    NotifIcon.Position = UDim2.new(0, 12, 0.5, -22)
    NotifIcon.BackgroundTransparency = 1
    NotifIcon.Text = icon or "⏳"
    NotifIcon.TextSize = 26
    NotifIcon.ZIndex = 201
    NotifIcon.Parent = Notif
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -65, 1, 0)
    NotifText.Position = UDim2.new(0, 60, 0, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = message
    NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifText.TextSize = 13
    NotifText.Font = Enum.Font.GothamMedium
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextWrapped = true
    NotifText.ZIndex = 201
    NotifText.Parent = Notif
    
    TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 290, 0, 65),
        Position = UDim2.new(1, -310, 1, -85)
    }):Play()
    
    if icon == "⏳" then
        spawn(function()
            while Notif.Parent do
                for i = 0, 360, 10 do
                    if not Notif.Parent then break end
                    NotifIcon.Rotation = i
                    task.wait(0.02)
                end
            end
        end)
    end
    
    task.delay(3, function()
        if Notif.Parent then
            TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 65),
                Position = UDim2.new(1, -20, 1, -85)
            }):Play()
            task.wait(0.4)
            Notif:Destroy()
        end
    end)
    
    return Notif
end

-- ==================== VALIDATION ====================
local function validateCode()
    local enteredCode = InputBox.Text
    
    if enteredCode == "" then
        createNotification("Please enter a key", "⚠️")
        return
    end
    
    -- Désactiver les boutons pendant la vérification
    VerifyButton.Active = false
    InputBox.TextEditable = false
    
    local verifyNotif = createNotification("Verifying key with Junkie...", "⏳")
    
    -- Vérification avec l'API Junkie
    local isValid = verifyKeyWithJunkie(enteredCode)
    
    if verifyNotif and verifyNotif.Parent then
        verifyNotif:Destroy()
    end
    
    if isValid then
        createNotification("Key verified successfully!", "✅")
        
        task.wait(1)
        
        local fetchNotif = createNotification("Loading script...", "⏳")
        
        task.wait(2)
        
        TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 0}):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 180
        }):Play()
        
        task.wait(0.6)
        
        if fetchNotif and fetchNotif.Parent then
            fetchNotif:Destroy()
        end
        
        Blur:Destroy()
        ScreenGui:Destroy()
        
        loadMainScript()
    else
        createNotification("Invalid key! Try again", "❌")
        
        local originalPos = MainFrame.Position
        for i = 1, 3 do
            MainFrame.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 10, originalPos.Y.Scale, originalPos.Y.Offset)
            task.wait(0.05)
            MainFrame.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 10, originalPos.Y.Scale, originalPos.Y.Offset)
            task.wait(0.05)
        end
        MainFrame.Position = originalPos
        
        TweenService:Create(InputContainer, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        }):Play()
        
        task.wait(0.3)
        
        TweenService:Create(InputContainer, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        }):Play()
        
        InputBox.Text = ""
        
        -- Réactiver les boutons
        VerifyButton.Active = true
        InputBox.TextEditable = true
    end
end

-- ==================== EVENTS ====================
VerifyButton.MouseButton1Click:Connect(validateCode)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateCode()
    end
end)

GetLinkButton.MouseButton1Click:Connect(function()
    createNotification("Link copied to clipboard!", "📋")
    if setclipboard then
        setclipboard(CONFIG.GET_LINK_URL)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.4)
    Blur:Destroy()
    ScreenGui:Destroy()
end)

GetLinkButton.MouseEnter:Connect(function()
    TweenService:Create(GetLinkButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(168, 85, 247),
        Size = UDim2.new(0.48, 0, 1, 2)
    }):Play()
end)

GetLinkButton.MouseLeave:Connect(function()
    TweenService:Create(GetLinkButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(147, 51, 234),
        Size = UDim2.new(0.48, 0, 1, 0)
    }):Play()
end)

VerifyButton.MouseEnter:Connect(function()
    TweenService:Create(VerifyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(236, 72, 153),
        Size = UDim2.new(0.48, 0, 1, 2)
    }):Play()
end)

VerifyButton.MouseLeave:Connect(function()
    TweenService:Create(VerifyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(219, 39, 119),
        Size = UDim2.new(0.48, 0, 1, 0)
    }):Play()
end)

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 38, 38),
        Rotation = 90
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        Rotation = 0
    }):Play()
end)

-- ==================== ANIMATION D'ENTRÉE ====================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Rotation = -180
Overlay.BackgroundTransparency = 1

TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 600, 0, 380),
    Position = UDim2.new(0.5, -300, 0.5, -190),
    Rotation = 0
}):Play()

task.wait(0.8)
InputBox:CaptureFocus()

-- ==================== FONCTION DE CHARGEMENT ====================
function loadMainScript()
    print("✅ UlyCheat loaded successfully!")
    print("🔐 Key verified via Junkie Key System")
    
    -- 👇 COLLE TON SCRIPT ICI
    
    
    
    -- 👆 Fin de ton script
end
