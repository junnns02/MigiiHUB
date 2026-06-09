-- // ========================================== \\ --
-- ||        MIGII-HUB SCRIPT - INDO HANGOUT       || --
-- ||       CREATOR BY : JUNNNS AKA MIGII HUB     || --
-- ||                   POWERED ©2026                      || --
-- \\ ========================================== // --

-- ==========================================
-- 0. DETEKSI NAMA GAME & SETUP FOLDER
-- ==========================================
local MarketplaceService = game:GetService("MarketplaceService")
local baseFolder = "MigiiHub"
local gameDisplayName = "Unknown Map" 

local function getGameNames()
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    local rawName = (success and info and info.Name) or game.Name
    gameDisplayName = string.gsub(rawName, "[<>]", "") 
    local safeName = string.gsub(rawName, '[^%w%p%s]', '') 
    safeName = string.gsub(safeName, '[<>:"/\\|?*]', '')
    safeName = string.gsub(safeName, '^%s*(.-)%s*$', '%1') 
    if safeName == "" then safeName = tostring(game.PlaceId) end
    return string.sub(safeName, 1, 30) 
end

local gameFolderName = getGameNames()
local fullFolderPath = baseFolder .. "/" .. gameFolderName

if isfolder and makefolder then 
    if not isfolder(baseFolder) then makefolder(baseFolder) end
    if not isfolder(fullFolderPath) then makefolder(fullFolderPath) end 
end

-- ==========================================
-- 0.5. [ MIGII HUB ] ANTI-CHEAT BYPASS
-- ==========================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and tostring(self) == "Rod" then
        if args[1] == "Cheating" then
            return -- Membuang deteksi client
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 1. LOAD UI LIBRARY & INJEKSI CUSTOM UI
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/migii02/MigiiHUB/refs/heads/main/UI/LibraryLite.lua"))()

Library._SectionMethods.AddDropdown = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local selected = config.Default or options[1] or ""
    
    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 30); container.LayoutOrder = self._elementOrder
    container.ClipsDescendants = true; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(1, 0, 0, 30); mainBtn.BackgroundTransparency = 1; mainBtn.Text = ""
    
    local label = Instance.new("TextLabel", mainBtn)
    label.Size = UDim2.new(1, -30, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1; label.Text = config.Text or "Dropdown"
    label.TextColor3 = Color3.fromRGB(220, 220, 240); label.Font = Enum.Font.GothamSemibold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", mainBtn)
    valLabel.Size = UDim2.new(0, 160, 1, 0); valLabel.Position = UDim2.new(1, -185, 0, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Text = selected; valLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 10; valLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local arrow = Instance.new("TextLabel", mainBtn)
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▼"; arrow.TextColor3 = Color3.fromRGB(200, 200, 200); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 10
    
    local searchBox = Instance.new("TextBox", container)
    searchBox.Size = UDim2.new(1, -10, 0, 25); searchBox.Position = UDim2.new(0, 5, 0, 32)
    searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35); searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderText = "🔍 Cari opsi..."; searchBox.Text = ""; searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 9
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
    
    local scrollFrame = Instance.new("ScrollingFrame", container)
    scrollFrame.Size = UDim2.new(1, -10, 1, -65); scrollFrame.Position = UDim2.new(0, 5, 0, 60)
    scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3; scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 255, 120)
    
    local list = Instance.new("UIListLayout", scrollFrame)
    list.SortOrder = Enum.SortOrder.LayoutOrder; list.Padding = UDim.new(0, 2)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)

    local isOpen = false; local TweenService = game:GetService("TweenService")
    
    local function toggle()
        isOpen = not isOpen
        local targetHeight = isOpen and 180 or 30
        TweenService:Create(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        arrow.Text = isOpen and "▲" or "▼"
        if not isOpen then searchBox.Text = "" end 
    end
    mainBtn.MouseButton1Click:Connect(toggle)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchBox.Text:lower()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then 
                child.Visible = child.Text:lower():find(filter) ~= nil 
            end
        end
    end)

    local function updateOptions(newOptions)
        for _, c in pairs(scrollFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        options = newOptions
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", scrollFrame)
            optBtn.Size = UDim2.new(1, -8, 0, 25); optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            optBtn.BackgroundTransparency = 0.5; optBtn.BorderSizePixel = 0; optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200); optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 10; optBtn.TextXAlignment = Enum.TextXAlignment.Left; optBtn.LayoutOrder = i
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
            
            optBtn.MouseButton1Click:Connect(function() 
                selected = opt; valLabel.Text = opt; toggle(); callback(opt) 
            end)
        end
    end
    
    updateOptions(options)
    return {Refresh = updateOptions}
end

Library._SectionMethods.AddLabel = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local container = Instance.new("Frame", self.Frame)
    container.Size = UDim2.new(1, 0, 0, 25); container.BackgroundTransparency = 1; container.LayoutOrder = self._elementOrder
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -16, 1, 0); label.Position = UDim2.new(0, 8, 0, 0); label.BackgroundTransparency = 1
    label.Text = config.Text or ""; label.TextColor3 = config.Color or Color3.fromRGB(255, 215, 0)
    label.Font = Enum.Font.GothamBold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left
    local api = {}
    function api:SetText(newText) label.Text = newText end; function api:SetColor(newColor) label.TextColor3 = newColor end
    return api
end

Library._SectionMethods.AddInput = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 30); container.LayoutOrder = self._elementOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.4, 0, 1, 0); label.Position = UDim2.new(0, 8, 0, 0); label.BackgroundTransparency = 1
    label.Text = config.Text or "Input"; label.TextColor3 = Color3.fromRGB(220, 220, 240); label.Font = Enum.Font.GothamSemibold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(0.6, -16, 1, 0); box.Position = UDim2.new(0.4, 8, 0, 0); box.BackgroundTransparency = 1
    box.Text = config.Default or ""; box.PlaceholderText = config.Placeholder or "Type here..."; box.TextColor3 = Color3.fromRGB(80, 255, 120)
    box.Font = Enum.Font.Gotham; box.TextSize = 10; box.TextXAlignment = Enum.TextXAlignment.Right; box.ClearTextOnFocus = false
    box.FocusLost:Connect(function(enterPressed) if config.Callback then config.Callback(box.Text, enterPressed) end end)
    local api = {}
    function api:GetText() return box.Text end; function api:SetText(txt) box.Text = txt end
    return api
end

Library._SectionMethods.AddSlider = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local min = config.Min or 0
    local max = config.Max or 100
    local def = config.Default or min
    local inc = config.Increment or 1
    local cb = config.Callback or function() end

    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 50); container.LayoutOrder = self._elementOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.5, 0, 0, 20); label.Position = UDim2.new(0, 8, 0, 5); label.BackgroundTransparency = 1
    label.Text = config.Text or "Slider"; label.TextColor3 = Color3.fromRGB(220, 220, 240); label.Font = Enum.Font.GothamSemibold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left

    local valBox = Instance.new("TextBox", container)
    valBox.Size = UDim2.new(0, 45, 0, 20); valBox.Position = UDim2.new(1, -70, 0, 5); valBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35); valBox.TextColor3 = Color3.fromRGB(80, 255, 120); valBox.Font = Enum.Font.GothamBold; valBox.TextSize = 10; valBox.Text = tostring(def)
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,4)

    local btnMinus = Instance.new("TextButton", container)
    btnMinus.Size = UDim2.new(0, 20, 0, 20); btnMinus.Position = UDim2.new(1, -95, 0, 5); btnMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 60); btnMinus.Text = "-"; btnMinus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0,4)

    local btnPlus = Instance.new("TextButton", container)
    btnPlus.Size = UDim2.new(0, 20, 0, 20); btnPlus.Position = UDim2.new(1, -20, 0, 5); btnPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 60); btnPlus.Text = "+"; btnPlus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0,4)

    local sliderBg = Instance.new("TextButton", container)
    sliderBg.Size = UDim2.new(1, -16, 0, 6); sliderBg.Position = UDim2.new(0, 8, 0, 35); sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30); sliderBg.Text = ""; sliderBg.AutoButtonColor = false; Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(80, 255, 120); Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

    local dragging = false
    local formatStr = (inc < 0.01) and "%.3f" or (inc < 0.1) and "%.2f" or (inc < 1) and "%.1f" or "%.0f"
    
    local function updateVal(val)
        val = math.clamp(math.round(val / inc) * inc, min, max)
        valBox.Text = string.format(formatStr, val)
        game:GetService("TweenService"):Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}):Play()
        cb(val)
    end

    local function updateFromInput(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = min + (pos * (max - min))
        updateVal(val)
    end

    sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateFromInput(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end end)

    btnMinus.MouseButton1Click:Connect(function() updateVal(tonumber(valBox.Text) - inc) end)
    btnPlus.MouseButton1Click:Connect(function() updateVal(tonumber(valBox.Text) + inc) end)
    valBox.FocusLost:Connect(function() local n = tonumber(valBox.Text); if n then updateVal(n) else updateVal(def) end end)

    updateVal(def)
    return {SetValue = updateVal}
end

-- ==========================================
-- 2. SETUP VARIABEL & SERVICE
-- ==========================================
getgenv().AutoFish = false
getgenv().AutoMining = false
getgenv().AutoSell = false
getgenv().SellMode = "Sell All" 
getgenv().AutoSellCrystal = false
getgenv().SellCrystalMode = "Sell All" 

getgenv().AutoQurban = false
getgenv().TargetQurban = "Sapi & Kambing"

getgenv().TargetAvatar = ""
getgenv().SelectedUniversalTool = ""
getgenv().TargetPlayerTP = "" 

getgenv().MigiiFC_Waypoints = getgenv().MigiiFC_Waypoints or {}
getgenv().MigiiFC_UndoStack = getgenv().MigiiFC_UndoStack or {}

-- WEBHOOK VARIABLES
getgenv().EnableWebhook = false
getgenv().WebhookURL = ""

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:WaitForChild("Terrain")

-- REMOTES
local IndexRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("Index")
local RodEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvent"):WaitForChild("Rod")
local MineEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvent"):WaitForChild("Pickaxe")
local SellFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("SellFish")
local SellCrystalFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("SellCrystal")
local ShopFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("RodShop")
local AuraShopFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):FindFirstChild("AuraShop")
local PickaxeShopFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("PickaxeShop")

-- ==========================================
-- 2.5. SISTEM DISCORD WEBHOOK REPORTER
-- ==========================================
local WhFile = fullFolderPath .. "/MigiiWebhook.json"
local whData = { URL = "", Enabled = false }

if isfile and isfile(WhFile) then
    pcall(function() whData = HttpService:JSONDecode(readfile(WhFile)) end)
end
getgenv().WebhookURL = whData.URL or ""
getgenv().EnableWebhook = whData.Enabled or false

local function saveWebhook()
    if writefile then
        pcall(function() writefile(WhFile, HttpService:JSONEncode({URL = getgenv().WebhookURL, Enabled = getgenv().EnableWebhook})) end)
    end
end

local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function SendToWebhook(itemNameRaw, itemCategory)
    if not getgenv().EnableWebhook or getgenv().WebhookURL == "" then return end
    if not requestFunc then return end
    
    task.spawn(function()
        local embedColor = 3447003
        local thumbUrl = nil 
        
        if itemCategory == "Mining" then 
            embedColor = 16711680 
        elseif itemCategory == "System" then
            embedColor = 65280
        end 
        
        pcall(function()
            local cleanName = itemNameRaw:lower():gsub("%s*%b()", "")
            if itemCategory == "Fishing" then
                local fishInfo = IndexRemote:InvokeServer("GetFishInfo", cleanName)
                if fishInfo and fishInfo.image then thumbUrl = fishInfo.image end
            elseif itemCategory == "Mining" then
                cleanName = cleanName:gsub("crystaldecor", "crystal"):gsub("dekor", "")
                local crysInfo = IndexRemote:InvokeServer("GetCrystalInfo", cleanName)
                if crysInfo and crysInfo.image then thumbUrl = crysInfo.image end
            end
        end)

        if thumbUrl and thumbUrl:match("rbxassetid://") then
            local assetId = thumbUrl:match("%d+")
            if assetId then
                thumbUrl = "https://assetgame.roproxy.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=" .. assetId
            end
        end
        
        local safeAvatar = "https://cdn.discordapp.com/attachments/1412787806262136957/1501853913538625566/file_00000000388c71fab67ac2c36cf64681.png"
        
        local embedData = {
            ["title"] = "🎉 Hasil " .. itemCategory .. " Baru!",
            ["color"] = embedColor,
            ["fields"] = {
                {["name"] = "👤 Player", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "📦 Item Didapat", ["value"] = itemNameRaw, ["inline"] = true}
            },
            ["footer"] = {["text"] = "MigiiHUB Logger | " .. os.date("%Y-%m-%d %H:%M:%S")}
        }
        
        if thumbUrl then
            embedData["thumbnail"] = {["url"] = thumbUrl}
        end
        
        local data = {
            ["username"] = "MIGII-HUB REPORT",
            ["avatar_url"] = safeAvatar,
            ["embeds"] = {embedData}
        }
        
        pcall(function()
            requestFunc({
                Url = getgenv().WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

local trackedItems = {}
local function onToolAdded(tool)
    if not tool:IsA("Tool") then return end
    if trackedItems[tool] then return end
    trackedItems[tool] = true
    
    local name = tool.Name:lower()
    if name:find("crystal") then
        SendToWebhook(tool.Name, "Mining")
    elseif not name:find("rod") and not name:find("pickaxe") and not name:find("torch") and not name:find("phone") then
        SendToWebhook(tool.Name, "Fishing")
    end
end

LocalPlayer.Backpack.ChildAdded:Connect(onToolAdded)
LocalPlayer.CharacterAdded:Connect(function(char) char.ChildAdded:Connect(onToolAdded) end)
if LocalPlayer.Character then LocalPlayer.Character.ChildAdded:Connect(onToolAdded) end

-- ==========================================
-- 3. PERSIAPAN DATA SHOP (DENGAN HARGA)
-- ==========================================
local function formatPrice(number)
    if not tonumber(number) then return "Rp. 0" end
    return "Rp. " .. tostring(number):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
end

local BaseRodList = {"basic rod", "coconut rod", "gopay rod", "vip rod", "party rod", "shark rod", "piranha rod", "thermo rod", "flowers rod", "trisula rod", "feather rod", "wave rod", "duck rod", "planet rod", "earth rod", "bat rod", "pumkin rod", "reindeer rod", "canny rod", "jinggle rod", "blue dragon rod", "pink dragon rod", "blue devotion rod", "pink devotion rod", "heart core rod", "lunar serpent rod", "infernal dragon rod", "zenith rod", "celestia rod", "volcano rod"}
local BaseAuraList = {"blackred love", "green glitch", "pink love", "autumn", "christmas", "gopay portal", "glints wave", "gopay exclusive", "sakura", "starlight", "blueada", "fortune lantern", "emperor’s gold", "pink heartastic", "blue heartastic", "blue heartfull", "pink heartfull", "moonveil", "radiance", "top 5 donate", "purple wings", "top 1 donate"}
local BasePickaxeList = {"Basic Pickaxe", "Vip Pickaxe", "Gold Pickaxe", "Ruby Pickaxe", "Frost Pickaxe", "Emerald Pickaxe", "Candy Pickaxe", "Forbidden Pickaxe", "Volcano Pickaxe", "Void Pickaxe", "Heart Pickaxe"}

local RodOptions = {}
for _, rodName in ipairs(BaseRodList) do table.insert(RodOptions, rodName) end

local AuraOptionsWithPrice = {}; local AuraRealNamesMap = {}
for _, auraName in ipairs(BaseAuraList) do
    pcall(function()
        local info = (AuraShopFunc and AuraShopFunc:InvokeServer("GetAuraInfo", auraName)) or ShopFunc:InvokeServer("GetAuraInfo", auraName) or IndexRemote:InvokeServer("GetAuraInfo", auraName)
        if info and info.price then
            local disp = auraName .. " - " .. formatPrice(info.price)
            table.insert(AuraOptionsWithPrice, disp); AuraRealNamesMap[disp] = auraName
        else table.insert(AuraOptionsWithPrice, auraName); AuraRealNamesMap[auraName] = auraName end
    end)
end

local PickaxeOptionsWithPrice = {}; local PickaxeRealNamesMap = {}
for _, pickName in ipairs(BasePickaxeList) do
    pcall(function()
        local info = (PickaxeShopFunc and PickaxeShopFunc:InvokeServer("GetPickaxeInfo", pickName)) or ShopFunc:InvokeServer("GetPickaxeInfo", pickName) or IndexRemote:InvokeServer("GetPickaxeInfo", pickName)
        if info and info.price then
            local disp = pickName .. " - " .. formatPrice(info.price)
            table.insert(PickaxeOptionsWithPrice, disp); PickaxeRealNamesMap[disp] = pickName
        else table.insert(PickaxeOptionsWithPrice, pickName); PickaxeRealNamesMap[pickName] = pickName end
    end)
end

getgenv().TargetRod = RodOptions[1]
getgenv().TargetAura = AuraRealNamesMap[AuraOptionsWithPrice[1]]
getgenv().TargetPickaxe = PickaxeRealNamesMap[PickaxeOptionsWithPrice[1]]

-- ==========================================
-- 4. FUNGSI MACRO: MINING, FISHING, SELL, QURBAN & TP
-- ==========================================

local function getNearestSafeCrystal()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = math.huge
    local OccupyRadius = 15 
    
    local PathCrystals = workspace:FindFirstChild("MapContent") and workspace.MapContent:FindFirstChild("Crystals")
    if not PathCrystals then return nil end
    
    for _, obj in pairs(PathCrystals:GetChildren()) do
        local name = string.lower(obj.Name)
        if not string.find(name, "decor") and not string.find(name, "dekor") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local crystalPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
            local myDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(crystalPos.X, 0, crystalPos.Z)).Magnitude
            
            local isOccupied = false
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local otherPos = player.Character.HumanoidRootPart.Position
                    local distToOther = (Vector3.new(otherPos.X, 0, otherPos.Z) - Vector3.new(crystalPos.X, 0, crystalPos.Z)).Magnitude
                    
                    if distToOther < OccupyRadius and distToOther < myDist then
                        isOccupied = true
                        break
                    end
                end
            end
            
            if not isOccupied then
                if myDist < minDist then
                    minDist = myDist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function walkToTarget(targetPos, myPos)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return false end
    
    local direction = (myPos - targetPos).Unit
    if direction.X ~= direction.X then direction = Vector3.new(1, 0, 0) end 
    local stopPos = targetPos + (direction * 4)
    stopPos = Vector3.new(stopPos.X, myPos.Y, stopPos.Z)

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4 
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(hrp.Position, stopPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        for i, waypoint in ipairs(waypoints) do
            if not getgenv().AutoMining then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            local timeout = tick() + 2 
            local dist = math.huge
            
            while getgenv().AutoMining and tick() < timeout and dist >= 4 do
                task.wait(0.05)
                if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                dist = (Vector3.new(char.HumanoidRootPart.Position.X, 0, char.HumanoidRootPart.Position.Z) - Vector3.new(waypoint.Position.X, 0, waypoint.Position.Z)).Magnitude
            end
        end
        return true
    else
        humanoid:MoveTo(stopPos)
        task.wait(1)
        return false
    end
end

local function startAutoMining()
    task.spawn(function()
        local AnimsFolder = ReplicatedStorage:WaitForChild("Stuffs"):WaitForChild("Anims"):WaitForChild("Mining")
        local HitAnimObj = AnimsFolder:WaitForChild("Mining Hit")
        
        while getgenv().AutoMining do
            local character = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if character and backpack and humanoid and humanoid.Health > 0 and hrp then
                local targetCrystal = getNearestSafeCrystal()
                
                if targetCrystal then
                    local crystalPos = targetCrystal:IsA("Model") and targetCrystal:GetPivot().Position or targetCrystal.Position
                    
                    walkToTarget(crystalPos, hrp.Position)
                    
                    if getgenv().AutoMining then
                        local realDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(crystalPos.X, 0, crystalPos.Z)).Magnitude
                        if realDist <= 6.5 then
                            
                            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(crystalPos.X, hrp.Position.Y, crystalPos.Z))
                            
                            local pickaxe = character:FindFirstChild("Vip Pickaxe") or backpack:FindFirstChild("Vip Pickaxe") or character:FindFirstChild("Basic Pickaxe") or backpack:FindFirstChild("Basic Pickaxe")
                            
                            if pickaxe then
                                local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator")
                                
                                if pickaxe.Parent ~= character then
                                    humanoid:EquipTool(pickaxe)
                                    task.wait(0.5) 
                                end
                                
                                for i = 1, 10 do
                                    if not getgenv().AutoMining or not targetCrystal.Parent then break end
                                    
                                    local currentDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(crystalPos.X, 0, crystalPos.Z)).Magnitude
                                    if currentDist > 9 then break end
                                    
                                    local hitAnimTrack = animator:LoadAnimation(HitAnimObj)
                                    hitAnimTrack:Play()
                                    
                                    task.wait(0.5) 
                                    pcall(function() MineEvent:FireServer("Hit", pickaxe) end)
                                    task.wait(1.5) 
                                end
                            else
                                task.wait(1) 
                            end
                        else
                            task.wait(0.5)
                        end
                    end
                else
                    task.wait(1) 
                end
            else
                task.wait(1) 
            end
        end
    end)
end

local function startAutoSellCrystal()
    task.spawn(function()
        while getgenv().AutoSellCrystal do 
            pcall(function() 
                SellCrystalFunc:InvokeServer("SellCrystal", getgenv().SellCrystalMode) 
            end) 
            task.wait(10) 
        end
    end)
end

local function startAutoFishSafe()
    task.spawn(function()
        local reelingConnection
        local isHolding = false
        
        while getgenv().AutoFish do
            local character = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            
            if not character or not playerGui then 
                task.wait(1)
            else
                local equippedRod = character:FindFirstChildOfClass("Tool")
                if not equippedRod and backpack then
                    local bestRod
                    for i = #BaseRodList, 1, -1 do 
                        if backpack:FindFirstChild(BaseRodList[i]) then 
                            bestRod = backpack:FindFirstChild(BaseRodList[i])
                            break 
                        end 
                    end
                    if not bestRod then bestRod = backpack:FindFirstChild("Basic Rod") end
                    
                    if bestRod then 
                        pcall(function() if humanoid then humanoid:EquipTool(bestRod) end end)
                        task.wait(1) 
                        equippedRod = character:FindFirstChild(bestRod.Name) 
                    end
                end
                
                if equippedRod then
                    pcall(function()
                        equippedRod:Activate()
                        task.wait(1)
                        
                        local reelingUI = playerGui:WaitForChild("Reeling", 5)
                        if reelingUI then
                            local mainFrame = reelingUI:WaitForChild("MainFrame", 5)
                            if mainFrame then
                                local frame = mainFrame:WaitForChild("Frame")
                                local whiteBar = frame:WaitForChild("WhiteBar")
                                local redBar = frame:WaitForChild("RedBar")
                                
                                local timeoutWait = 0
                                while not reelingUI.Enabled and getgenv().AutoFish and timeoutWait < 600 do 
                                    task.wait(0.1)
                                    timeoutWait = timeoutWait + 1
                                end
                                
                                if reelingUI.Enabled then
                                    reelingConnection = RunService.RenderStepped:Connect(function()
                                        if reelingUI.Enabled and whiteBar.Parent and redBar.Parent then
                                            local whiteCenter = whiteBar.AbsolutePosition.X + (whiteBar.AbsoluteSize.X / 2)
                                            local redCenter = redBar.AbsolutePosition.X + (redBar.AbsoluteSize.X / 2)
                                            
                                            if whiteCenter < redCenter - 3 then
                                                if not isHolding then
                                                    isHolding = true
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                                end
                                            elseif whiteCenter > redCenter + 3 then
                                                if isHolding then
                                                    isHolding = false
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                                end
                                            end
                                        else 
                                            if isHolding then
                                                isHolding = false
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                            end
                                            if reelingConnection then reelingConnection:Disconnect() end 
                                        end
                                    end)
                                    
                                    while reelingUI.Enabled and getgenv().AutoFish do task.wait(0.1) end
                                    
                                    if isHolding then
                                        isHolding = false
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                    end
                                    if reelingConnection then reelingConnection:Disconnect() end
                                else
                                    equippedRod:Activate()
                                end
                            end
                        end
                    end)
                    task.wait(2.5) 
                end
            end
        end
        
        if isHolding then
            isHolding = false
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
        if reelingConnection then reelingConnection:Disconnect() end
    end)
end

local function startAutoSell()
    task.spawn(function()
        while getgenv().AutoSell do pcall(function() SellFunc:InvokeServer("CheckFish", getgenv().SellMode); SellFunc:InvokeServer("SellFish", getgenv().SellMode) end); task.wait(10) end
    end)
end

local function startAutoQurban()
    task.spawn(function()
        while getgenv().AutoQurban do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hrp then
                local originalPos = hrp.CFrame
                local foundQurban = false
                
                for _, obj in ipairs(workspace:GetChildren()) do
                    if not getgenv().AutoQurban then break end
                    local name = obj.Name:lower()
                    
                    local isTarget = false
                    if getgenv().TargetQurban == "Sapi & Kambing" and (name == "qurban sapi" or name == "qurban kambing") then isTarget = true
                    elseif getgenv().TargetQurban == "Hanya Sapi" and name == "qurban sapi" then isTarget = true
                    elseif getgenv().TargetQurban == "Hanya Kambing" and name == "qurban kambing" then isTarget = true end
                    
                    if isTarget and obj:FindFirstChild("Body") then
                        local prompt = obj.Body:FindFirstChild("ProximityPrompt")
                        if prompt and prompt.Enabled then
                            foundQurban = true
                            
                            -- Teleport ke hewan
                            hrp.CFrame = obj.Body.CFrame * CFrame.new(0, 3, 0)
                            task.wait(0.5) 
                            
                            -- Pemicu Claim
                            pcall(function()
                                if fireproximityprompt then
                                    fireproximityprompt(prompt, 1, true)
                                else
                                    prompt.HoldDuration = 0
                                    prompt:InputHoldBegin()
                                    task.wait(0.1)
                                    prompt:InputHoldEnd()
                                end
                            end)
                            
                            task.wait(1.5) 
                        end
                    end
                end
                
                -- Teleport balik ke tempat asal
                if foundQurban and hrp then
                    hrp.CFrame = originalPos
                end
            end
            task.wait(2)
        end
    end)
end

local function teleportTo(Target)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        if typeof(Target) == "CFrame" then character.HumanoidRootPart.CFrame = Target
        elseif typeof(Target) == "Instance" and Target:IsA("BasePart") then character.HumanoidRootPart.CFrame = Target.CFrame * CFrame.new(0, 3, 0) end
    end
end

-- ==========================================
-- 5. FUNGSI AVATAR, HISTORY & WAYPOINT FILES
-- ==========================================
local HistoryFile = fullFolderPath .. "/MigiiAvaHistory.json"
local WpFile = fullFolderPath .. "/FC_Waypoints.json"
local UserIdCache = {}

local function getHistory()
    if isfile and isfile(HistoryFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(HistoryFile)) end)
        if success and type(data) == "table" and #data > 0 then return data end
    end return {"Belum ada history"}
end

local function addHistory(username)
    if not writefile then return getHistory() end 
    local history = getHistory(); if history[1] == "Belum ada history" then table.remove(history, 1) end
    for i, v in ipairs(history) do if v == username then table.remove(history, i); break end end
    table.insert(history, 1, username); if #history > 10 then table.remove(history, 11) end
    pcall(function() writefile(HistoryFile, HttpService:JSONEncode(history)) end); return history
end

local function removeHistory(username)
    if not writefile then return getHistory() end 
    local history = getHistory(); for i, v in ipairs(history) do if v == username then table.remove(history, i); break end end
    if #history == 0 then table.insert(history, "Belum ada history") end
    pcall(function() writefile(HistoryFile, HttpService:JSONEncode(history)) end); return history
end

local function getWpData()
    if isfile and isfile(WpFile) then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(WpFile)) end)
        if s and type(d) == "table" then return d end
    end return {}
end

local function saveWpPreset(name, wps)
    if not name or name == "" then return false end
    local data = getWpData()
    local formatted = {}
    for _, cf in ipairs(wps) do table.insert(formatted, {cf:GetComponents()}) end
    data[name] = formatted
    if writefile then pcall(function() writefile(WpFile, HttpService:JSONEncode(data)) end) end
    return true
end

local function getPresetNames()
    local list = {}
    for k, _ in pairs(getWpData()) do table.insert(list, k) end
    if #list == 0 then return {"Belum ada preset"} end
    return list
end

local function loadAvatar(username)
    if not username or username == "" then return false, "Username kosong!" end
    
    local userId = UserIdCache[username]
    if not userId then
        local success, result = pcall(function() return Players:GetUserIdFromNameAsync(username) end)
        if not success then return false, "User tidak ditemukan!" end
        userId = result
        UserIdCache[username] = userId 
    end

    local success2, humanoidDesc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
    if not success2 then return false, "Gagal ambil deskripsi avatar target!" end
    
    local RS = game:GetService("ReplicatedStorage")
    local bloxbiz = RS:FindFirstChild("BloxbizRemotes")
    
    if bloxbiz and bloxbiz:FindFirstChild("CatalogOnApplyOutfit") then
        task.spawn(function()
            local openEvent = bloxbiz:FindFirstChild("CatalogOpenedEvent")
            if openEvent then openEvent:FireServer() end
            task.wait(0.1)

            local outfitData = {
                SwimAnimation = humanoidDesc.SwimAnimation or 0, DepthScale = humanoidDesc.DepthScale or 1,
                RightLegColor = humanoidDesc.RightLegColor, MoodAnimation = humanoidDesc.MoodAnimation or 0,
                Face = humanoidDesc.Face or 0, JumpAnimation = humanoidDesc.JumpAnimation or 0,
                HeadColor = humanoidDesc.HeadColor, BodyTypeScale = humanoidDesc.BodyTypeScale or 1,
                ClimbAnimation = humanoidDesc.ClimbAnimation or 0, LeftArmColor = humanoidDesc.LeftArmColor,
                LeftLegColor = humanoidDesc.LeftLegColor, Pants = humanoidDesc.Pants or 0,
                RightArmColor = humanoidDesc.RightArmColor, WidthScale = humanoidDesc.WidthScale or 1,
                LeftArm = humanoidDesc.LeftArm or 0, IdleAnimation = humanoidDesc.IdleAnimation or 0,
                RightArm = humanoidDesc.RightArm or 0, GraphicTShirt = humanoidDesc.GraphicTShirt or 0,
                Head = humanoidDesc.Head or 0, Shirt = humanoidDesc.Shirt or 0, Torso = humanoidDesc.Torso or 0,
                RunAnimation = humanoidDesc.RunAnimation or 0, WalkAnimation = humanoidDesc.WalkAnimation or 0,
                FallAnimation = humanoidDesc.FallAnimation or 0, TorsoColor = humanoidDesc.TorsoColor,
                RightLeg = humanoidDesc.RightLeg or 0, HeadScale = humanoidDesc.HeadScale or 1,
                HeightScale = humanoidDesc.HeightScale or 1, ProportionScale = humanoidDesc.ProportionScale or 1,
                LeftLeg = humanoidDesc.LeftLeg or 0, 
                Accessories = {}
            }

            local addedIds = {}

            local function packClassicAcc(idString, accEnum)
                if type(idString) == "string" and idString ~= "" and idString ~= "0" then
                    for _, idStr in ipairs(idString:split(",")) do
                        local numId = tonumber(idStr)
                        if numId and not addedIds[numId] then
                            addedIds[numId] = true
                            table.insert(outfitData.Accessories, {
                                Rotation = Vector3.new(0,0,0),
                                AssetId = numId,
                                Position = Vector3.new(0,0,0),
                                Scale = Vector3.new(1,1,1),
                                IsLayered = false,
                                AccessoryType = accEnum
                            })
                        end
                    end
                end
            end

            packClassicAcc(humanoidDesc.HatAccessory, Enum.AccessoryType.Hat)
            packClassicAcc(humanoidDesc.HairAccessory, Enum.AccessoryType.Hair)
            packClassicAcc(humanoidDesc.FaceAccessory, Enum.AccessoryType.Face)
            packClassicAcc(humanoidDesc.NeckAccessory, Enum.AccessoryType.Neck)
            packClassicAcc(humanoidDesc.ShouldersAccessory, Enum.AccessoryType.Shoulder)
            packClassicAcc(humanoidDesc.FrontAccessory, Enum.AccessoryType.Front)
            packClassicAcc(humanoidDesc.BackAccessory, Enum.AccessoryType.Back)
            packClassicAcc(humanoidDesc.WaistAccessory, Enum.AccessoryType.Waist)

            local allAccs = humanoidDesc:GetAccessories(true)
            for _, acc in pairs(allAccs) do
                if not addedIds[acc.AssetId] then
                    addedIds[acc.AssetId] = true
                    local accData = {
                        Rotation = acc.Rotation or Vector3.new(0,0,0),
                        AssetId = acc.AssetId,
                        Position = acc.Position or Vector3.new(0,0,0),
                        Scale = acc.Scale or Vector3.new(1,1,1),
                        IsLayered = acc.IsLayered or false,
                        AccessoryType = acc.AccessoryType
                    }
                    if accData.IsLayered then
                        accData.Order = acc.Order or 1
                        accData.Puffiness = acc.Puffiness or 1
                    end
                    table.insert(outfitData.Accessories, accData)
                end
            end

            bloxbiz.CatalogOnApplyOutfit:FireServer(outfitData)
        end)
        return true, "Sukses Inject Full Outfit ke Server!"
    end
    
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if char and humanoid and humanoid.Health > 0 then
        local success3 = pcall(function() 
            if humanoid.ApplyDescriptionClientServer then humanoid:ApplyDescriptionClientServer(humanoidDesc) 
            else humanoid:ApplyDescription(humanoidDesc) end 
        end)
        if success3 then return true, "Sukses (Hanya Visual Lokal)" else return false, "Gagal apply lokal" end
    end

    return false, "Proses dibatalkan"
end

-- ==========================================
-- 6. UNIVERSAL TOOL STEALER
-- ==========================================
local function forceGiveTool(targetToolName)
    local myBackpack = LocalPlayer:FindFirstChild("Backpack")
    if not myBackpack then return false, "Backpack tidak ditemukan." end

    local sourceTool = nil
    local ownerName = ""
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild(targetToolName) then
                sourceTool = p.Backpack[targetToolName]; ownerName = p.Name; break
            elseif p.Character and p.Character:FindFirstChild(targetToolName) then
                sourceTool = p.Character[targetToolName]; ownerName = p.Name; break
            end
        end
    end

    if not sourceTool then return false, "Tidak ada " .. targetToolName .. " di server ini." end

    if myBackpack:FindFirstChild(targetToolName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(targetToolName)) then
        return false, "Kamu sudah punya barang ini di tas!"
    end

    local stolenTool = sourceTool:Clone()
    stolenTool.Parent = myBackpack

    return true, targetToolName .. " berhasil dicuri dari " .. ownerName .. " ke tasmu!"
end

-- ==========================================
-- X. SISTEM VISUAL & ESP HIGHLIGHT & NAME
-- ==========================================
getgenv().ESPPlayer = false
getgenv().ESPKambing = false
getgenv().ESPSapi = false

local function ApplyESP(target, nameText, color, isPlayer, playerObj)
    if not target then return end
    
    -- 1. Apply Highlight
    local hl = target:FindFirstChild("MigiiESP_HL")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "MigiiESP_HL"
        hl.Parent = target
    end
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.1

    -- 2. Tentukan target part untuk BillboardGui
    local bbTarget = nil
    if isPlayer then
        bbTarget = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
    else
        bbTarget = target:FindFirstChild("Body") or target:FindFirstChildWhichIsA("BasePart")
    end
    
    if bbTarget then
        local bb = bbTarget:FindFirstChild("MigiiESP_BB")
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "MigiiESP_BB"
            bb.Size = UDim2.new(0, 200, 0, 70) 
            bb.StudsOffset = Vector3.new(0, 4, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = bbTarget 
            bb.Parent = bbTarget

            local textYOffset = 0
            
            -- Jika target adalah Player, tambahkan foto profil (Thumbnail)
            if isPlayer and playerObj then
                local img = Instance.new("ImageLabel")
                img.Name = "PFP"
                img.Size = UDim2.new(0, 30, 0, 30)
                img.Position = UDim2.new(0.5, -15, 0, 0)
                img.BackgroundTransparency = 1
                
                -- Load Thumbnail aman menggunakan task.spawn biar ngga bikin ngelag
                task.spawn(function()
                    local success, thumb = pcall(function()
                        return Players:GetUserThumbnailAsync(playerObj.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                    end)
                    if success and img.Parent then img.Image = thumb end
                end)
                
                Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
                img.Parent = bb
                textYOffset = 32
            end

            local txt = Instance.new("TextLabel")
            txt.Name = "Text"
            txt.Size = UDim2.new(1, 0, 1, -textYOffset)
            txt.Position = UDim2.new(0, 0, 0, textYOffset)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = color
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 13
            txt.TextYAlignment = Enum.TextYAlignment.Top
            txt.Parent = bb
        end
        
        -- 3. Update Teks (Nama, Username, Jarak M secara Real-time)
        local txtLabel = bb:FindFirstChild("Text")
        if txtLabel then
            local distText = ""
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local targetPos = bbTarget:IsA("Model") and bbTarget:GetPivot().Position or bbTarget.Position
                local dist = math.floor((myChar.HumanoidRootPart.Position - targetPos).Magnitude)
                distText = "\n[" .. dist .. " M]"
            end
            
            if isPlayer and playerObj then
                txtLabel.Text = playerObj.DisplayName .. " (@" .. playerObj.Name .. ")" .. distText
            else
                txtLabel.Text = nameText .. distText
            end
        end
    end
end

local function RemoveESP(target)
    if not target then return end
    
    local hl = target:FindFirstChild("MigiiESP_HL")
    if hl then hl:Destroy() end
    
    for _, child in pairs(target:GetDescendants()) do
        if child.Name == "MigiiESP_BB" then
            child:Destroy()
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            -- Render ESP Player
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if getgenv().ESPPlayer then
                        ApplyESP(player.Character, player.Name, Color3.fromRGB(255, 255, 255), true, player)
                    else
                        RemoveESP(player.Character)
                    end
                end
            end
            
            -- Render ESP Qurban
            for _, obj in ipairs(workspace:GetChildren()) do
                local name = obj.Name:lower()
                
                if name == "qurban kambing" then
                    if getgenv().ESPKambing and obj:FindFirstChild("Body") and obj.Body:FindFirstChild("ProximityPrompt") then
                        ApplyESP(obj, "🐐 Qurban Kambing", Color3.fromRGB(150, 255, 150), false)
                    else
                        RemoveESP(obj)
                    end
                elseif name == "qurban sapi" then
                    if getgenv().ESPSapi and obj:FindFirstChild("Body") and obj.Body:FindFirstChild("ProximityPrompt") then
                        ApplyESP(obj, "🐄 Qurban Sapi", Color3.fromRGB(255, 200, 150), false)
                    else
                        RemoveESP(obj)
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- 7. MEMBANGUN UI MIGIIHUB UTAMA
-- ==========================================
Library.ShowMigiiLoader()
local LOGO_ID = "rbxthumb://type=Asset&id=132319281050903&w=150&h=150"
local Window = Library.new({Title = "MigiiHUB | " .. gameDisplayName, Size = UDim2.new(0, 480, 0, 320)})
Window:CreateToggleButton({ Icon = LOGO_ID })

local DashTab = Window:AddTab({ Name = "Dashboard", Icon = "📊" })
local FarmTab = Window:AddTab({ Name = "Main Farm", Icon = "⚔️" })
local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "👁️" })
local StealerTab = Window:AddTab({ Name = "Stealer", Icon = "🕵️" })
local ShopTab = Window:AddTab({ Name = "Shop Menu", Icon = "🛒" })
local TeleportTab = Window:AddTab({ Name = "Teleports", Icon = "🚀" })
local AvatarTab = Window:AddTab({ Name = "Avatar", Icon = "👕" })
local EmoteTab = Window:AddTab({ Name = "Emote", Icon = "🕺" })
local FreecamTab = Window:AddTab({ Name = "Freecam", Icon = "🎥" })

local StatSection = DashTab:AddSection({ Title = "Live Statistics" })
local CatchDash = StatSection:AddLabel({Text = "🏆 Total Tangkapan: Memuat...", Color = Color3.fromRGB(100, 200, 255)})
local CrystalDash = StatSection:AddLabel({Text = "💎 Total Kristal (Map): Memuat...", Color = Color3.fromRGB(80, 255, 120)})

local WebhookSection = DashTab:AddSection({ Title = "Discord Webhook Logger" })

local WhStatusLabel = WebhookSection:AddLabel({
    Text = "Status: " .. (getgenv().WebhookURL ~= "" and "✅ Webhook Tersimpan" or "❌ Webhook Kosong"), 
    Color = (getgenv().WebhookURL ~= "" and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80))
})

if getgenv().WebhookURL ~= "" then
    task.spawn(function()
        task.wait(1.5)
        Window:Toast({Title="Webhook Loaded", Message="Link Webhook berhasil dimuat dari file save!", Duration=3, Type="Info"})
    end)
end

WebhookSection:AddToggle({Text = "Kirim Log ke Discord", Default = getgenv().EnableWebhook, Callback = function(v) 
    getgenv().EnableWebhook = v; saveWebhook() 
end})

WebhookSection:AddInput({Text = "URL Webhook", Default = getgenv().WebhookURL, Placeholder = "Paste link webhook discord...", Callback = function(t) 
    getgenv().WebhookURL = t; 
    saveWebhook()
    if t ~= "" then
        WhStatusLabel:SetText("Status: ✅ Webhook Tersimpan")
        WhStatusLabel:SetColor(Color3.fromRGB(80, 255, 120))
    else
        WhStatusLabel:SetText("Status: ❌ Webhook Kosong")
        WhStatusLabel:SetColor(Color3.fromRGB(255, 80, 80))
    end
end})

WebhookSection:AddButton({Text = "🔔 Test Webhook", Callback = function()
    if getgenv().WebhookURL == "" then
        Window:Toast({Title="Error", Message="Isi URL Webhook dulu di atas!", Duration=2, Type="Error"})
        return
    end
    
    if not requestFunc then
        Window:Toast({Title="Error", Message="Executor kamu tidak support HTTP Request!", Duration=3, Type="Error"})
        return
    end
    
    local safeAvatar = "https://cdn.discordapp.com/attachments/1412787806262136957/1501853913538625566/file_00000000388c71fab67ac2c36cf64681.png"
    
    local data = {
        ["content"] = "✅ **Test Berhasil!** Webhook ini sudah terhubung dengan MigiiHUB.",
        ["username"] = "MIGII-HUB REPORT",
        ["avatar_url"] = safeAvatar
    }
    
    task.spawn(function()
        Window:Toast({Title="Webhook", Message="Mencoba kirim test report...", Duration=2, Type="Info"})
        local success, response = pcall(function()
            return requestFunc({
                Url = getgenv().WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
        
        if success and response and (response.StatusCode == 200 or response.StatusCode == 204) then
            Window:Toast({Title="Sukses", Message="Test Webhook berhasil masuk ke Discord!", Duration=3, Type="Success"})
        else
            Window:Toast({Title="Gagal", Message="Discord menolak link webhook ini. Coba buat ulang linknya.", Duration=4, Type="Error"})
        end
    end)
end})

-- [FARM TAB]
local MineSection = FarmTab:AddSection({ Title = "Mining & Crystal Settings" })
MineSection:AddToggle({Text = "Auto Mining Crystal 💎", Default = false, Callback = function(v) 
    getgenv().AutoMining = v
    if v then 
        Window:Toast({Title = "Auto Mine", Message = "Auto Mining Diaktifkan!", Duration = 2, Type = "Success"})
        startAutoMining() 
    else
        Window:Toast({Title = "Auto Mine", Message = "Auto Mining Dimatikan!", Duration = 2, Type = "Info"})
    end
end})
MineSection:AddDropdown({Text = "Target Jual Kristal", Options = {"Sell All", "All under 50 Kg", "All under 100 Kg", "All under 400 Kg", "All under 600 Kg"}, Default = "Sell All", Callback = function(v) 
    getgenv().SellCrystalMode = v 
    Window:Toast({Title = "Filter Kristal", Message = "Mode jual kristal: " .. v, Duration = 2, Type = "Info"})
end})
MineSection:AddToggle({Text = "▶ AUTO SELL CRYSTAL", Default = false, Callback = function(v) 
    getgenv().AutoSellCrystal = v
    if v then 
        Window:Toast({Title = "Auto Sell", Message = "Auto Jual Kristal Diaktifkan! 💎", Duration = 2, Type = "Success"})
        startAutoSellCrystal() 
    else
        Window:Toast({Title = "Auto Sell", Message = "Auto Jual Kristal Dimatikan!", Duration = 2, Type = "Info"})
    end
end})

local FishSection = FarmTab:AddSection({ Title = "Fishing Features" })
FishSection:AddToggle({Text = "Auto Catch (Safe Mode) 🎣", Default = false, Callback = function(v) 
    getgenv().AutoFish = v
    if v then 
        Window:Toast({Title = "Auto Catch", Message = "Auto Mancing Diaktifkan (100% Legit)!", Duration = 2, Type = "Success"})
        startAutoFishSafe() 
    else
        Window:Toast({Title = "Auto Catch", Message = "Auto Mancing Dimatikan!", Duration = 2, Type = "Info"})
    end
end})

local SellSection = FarmTab:AddSection({ Title = "Fish Selling Settings" })
SellSection:AddDropdown({Text = "Target Penjualan Ikan", Options = {"Sell All", "All under 50 Kg", "All under 100 Kg", "All under 400 Kg", "All under 600 Kg"}, Default = "Sell All", Callback = function(v) 
    getgenv().SellMode = v 
    Window:Toast({Title = "Filter Jual", Message = "Mode diubah ke: " .. v, Duration = 2, Type = "Info"})
end})
SellSection:AddToggle({Text = "▶ START AUTO SELL FISH", Default = false, Callback = function(v) 
    getgenv().AutoSell = v
    if v then 
        Window:Toast({Title = "Auto Sell", Message = "Auto Jual Ikan Diaktifkan! 💰", Duration = 2, Type = "Success"})
        startAutoSell() 
    else
        Window:Toast({Title = "Auto Sell", Message = "Auto Jual Ikan Dimatikan!", Duration = 2, Type = "Info"})
    end
end})

local EventSection = FarmTab:AddSection({ Title = "Special Event: Qurban 🐐" })
EventSection:AddDropdown({Text = "Pilih Target Qurban", Options = {"Sapi & Kambing", "Hanya Sapi", "Hanya Kambing"}, Default = "Sapi & Kambing", Callback = function(v) 
    getgenv().TargetQurban = v 
end})
EventSection:AddToggle({Text = "▶ AUTO CLAIM QURBAN", Default = false, Callback = function(v) 
    getgenv().AutoQurban = v
    if v then 
        Window:Toast({Title = "Auto Qurban", Message = "Auto Claim Diaktifkan! Akan otomatis claim & balik ke posisi awal.", Duration = 4, Type = "Success"})
        startAutoQurban() 
    else
        Window:Toast({Title = "Auto Qurban", Message = "Auto Claim Dimatikan!", Duration = 2, Type = "Info"})
    end
end})

-- [VISUAL TAB]
local ESPSection = VisualTab:AddSection({ Title = "ESP & Highlights" })

ESPSection:AddToggle({Text = "👁️ ESP Player (Foto & Info)", Default = false, Callback = function(v) 
    getgenv().ESPPlayer = v
    if not v then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                RemoveESP(player.Character)
            end
        end
    end
end})

ESPSection:AddToggle({Text = "🐐 ESP Qurban Kambing", Default = false, Callback = function(v) 
    getgenv().ESPKambing = v
    if not v then 
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:lower() == "qurban kambing" then RemoveESP(obj) end
        end
    end
end})

ESPSection:AddToggle({Text = "🐄 ESP Qurban Sapi", Default = false, Callback = function(v) 
    getgenv().ESPSapi = v
    if not v then 
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:lower() == "qurban sapi" then RemoveESP(obj) end
        end
    end
end})

-- [STEALER TAB]
local ToolSection = StealerTab:AddSection({ Title = "Universal Take Tool Stealer" })
local ToolDropdown = ToolSection:AddDropdown({Text = "Pilih Barang Target", Options = {"Scan tas orang dulu..."}, Callback = function(v) 
    getgenv().SelectedUniversalTool = v 
end})

ToolSection:AddButton({
    Text = "🎒 Scan inventory",
    Callback = function()
        local foundTools = {}
        local checkDict = {}
        -- Whitelist item gamepass/khusus yang boleh diculik
        local gamepassWhitelist = {"panci", "sapu", "sendal", "tali", "moneygun", "sign", "vip pickaxe"}
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local function checkFolder(folder)
                    if folder then
                        for _, obj in pairs(folder:GetChildren()) do
                            if obj:IsA("Tool") and not checkDict[obj.Name] then
                                local nameLower = string.lower(obj.Name)
                                
                                local isGamepass = false
                                for _, gp in ipairs(gamepassWhitelist) do
                                    if string.find(nameLower, gp) then
                                        isGamepass = true
                                        break
                                    end
                                end
                                
                                if isGamepass then
                                    checkDict[obj.Name] = true
                                    table.insert(foundTools, obj.Name)
                                end
                            end
                        end
                    end
                end
                checkFolder(p.Character)
                checkFolder(p:FindFirstChild("Backpack"))
            end
        end
        if #foundTools > 0 then
            ToolDropdown.Refresh(foundTools); getgenv().SelectedUniversalTool = foundTools[1]
            Window:Toast({ Title = "Mata-mata", Message = "Menemukan " .. #foundTools .. " item gamepass di tas player lain!", Duration = 3, Type = "Success" })
        else
            ToolDropdown.Refresh({"Tidak ada barang"})
            Window:Toast({ Title = "Kosong", Message = "Tas player lain kosong / cuma isi ikan.", Duration = 3, Type = "Error" })
        end
    end
})

ToolSection:AddButton({
    Text = "TAKE ITEM",
    Callback = function()
        if getgenv().SelectedUniversalTool == "" or getgenv().SelectedUniversalTool == "Scan tas orang dulu..." or getgenv().SelectedUniversalTool == "Tidak ada barang" then
            Window:Toast({ Title = "Gagal", Message = "Pilih barang yang mau diambil dulu!", Duration = 2, Type = "Error" })
            return
        end
        local success, msg = forceGiveTool(getgenv().SelectedUniversalTool)
        if success then Window:Toast({ Title = "Berhasil Dicuri!", Message = msg, Duration = 4, Type = "Success" })
        else Window:Toast({ Title = "Error", Message = msg, Duration = 4, Type = "Error" }) end
    end
})

-- [SHOP TAB]
local BuyRodSec = ShopTab:AddSection({ Title = "Buy Fishing Rods" })
BuyRodSec:AddDropdown({Text = "Select Rod", Options = RodOptions, Default = RodOptions[1], Callback = function(v) 
    getgenv().TargetRod = v 
end})
BuyRodSec:AddButton({Text = "💰 Beli Pancingan", Callback = function() 
    pcall(function() ShopFunc:InvokeServer("Buy", getgenv().TargetRod) end) 
    Window:Toast({Title = "Toko Pancing", Message = "Meminta server untuk membeli " .. getgenv().TargetRod .. "...", Duration = 3, Type = "Info"})
end})

local BuyPickaxeSec = ShopTab:AddSection({ Title = "Buy Pickaxes" })
BuyPickaxeSec:AddDropdown({Text = "Select Pickaxe", Options = PickaxeOptionsWithPrice, Default = PickaxeOptionsWithPrice[1], Callback = function(v) 
    getgenv().TargetPickaxe = PickaxeRealNamesMap[v] 
end})
BuyPickaxeSec:AddButton({Text = "🔨 Beli Pickaxe", Callback = function() 
    if PickaxeShopFunc then
        pcall(function() PickaxeShopFunc:InvokeServer("Buy", getgenv().TargetPickaxe) end)
        Window:Toast({Title = "Toko Pickaxe", Message = "Membeli " .. getgenv().TargetPickaxe .. "...", Duration = 3, Type = "Info"})
    else
        pcall(function() ShopFunc:InvokeServer("BuyPickaxe", getgenv().TargetPickaxe) end)
        Window:Toast({Title = "Toko Pickaxe", Message = "Mencoba membeli " .. getgenv().TargetPickaxe .. "...", Duration = 3, Type = "Info"})
    end
end})

local BuyAuraSec = ShopTab:AddSection({ Title = "Buy Auras" })
BuyAuraSec:AddDropdown({Text = "Select Aura", Options = AuraOptionsWithPrice, Default = AuraOptionsWithPrice[1], Callback = function(v) 
    getgenv().TargetAura = AuraRealNamesMap[v] 
end})
BuyAuraSec:AddButton({Text = "✨ Beli Aura", Callback = function() 
    if AuraShopFunc then
        pcall(function() AuraShopFunc:InvokeServer("Buy", getgenv().TargetAura) end)
        Window:Toast({Title = "Toko Aura", Message = "Membeli " .. getgenv().TargetAura .. "...", Duration = 3, Type = "Info"})
    else
        pcall(function() ShopFunc:InvokeServer("BuyAura", getgenv().TargetAura) end)
        Window:Toast({Title = "Toko Aura", Message = "Mencoba membeli " .. getgenv().TargetAura .. "...", Duration = 3, Type = "Info"})
    end
end})

-- [TELEPORT TAB]
local TPSection = TeleportTab:AddSection({ Title = "World Teleports" })

TPSection:AddButton({Text = "📍 Teleport to Sell Fish", Callback = function() 
    teleportTo(CFrame.new(206.535, 1.180, -442.576)) 
    Window:Toast({Title = "Teleportasi", Message = "Wush! Kamu dipindahkan ke Tempat Jual Ikan.", Duration = 2, Type = "Success"})
end})

TPSection:AddButton({Text = "📍 Teleport to Rod Shop", Callback = function() 
    teleportTo(CFrame.new(233.865, 3.725, -287.614)) 
    Window:Toast({Title = "Teleportasi", Message = "Wush! Kamu dipindahkan ke Rod Shop.", Duration = 2, Type = "Success"})
end})

local SpotSection = TeleportTab:AddSection({ Title = "Fishing Spots" })

local FishingSpots = {
    ["Spot 1"] = CFrame.new(-50.159, 4.725, -532.192),
    ["Spot 2"] = CFrame.new(183.588, 3.624, -482.841),
    ["Spot 3"] = CFrame.new(233.611, 0.627, 391.405),
    ["Spot 4"] = CFrame.new(-513.486, 1.669, 108.379),
    ["Spot 5"] = CFrame.new(-373.355, 112.565, -272.579),
    ["Spot 6"] = CFrame.new(-239.853, 170.578, 179.943),
    ["Spot 7"] = CFrame.new(-300.065, -10.133, -21.423)
}

local SpotOptions = {"Spot 1", "Spot 2", "Spot 3", "Spot 4", "Spot 5", "Spot 6", "Spot 7"}
getgenv().SelectedSpot = SpotOptions[1]

SpotSection:AddDropdown({Text = "Pilih Spot Mancing", Options = SpotOptions, Default = SpotOptions[1], Callback = function(v) 
    getgenv().SelectedSpot = v 
end})

SpotSection:AddButton({Text = "🎣 Teleport ke Spot", Callback = function() 
    if getgenv().SelectedSpot and FishingSpots[getgenv().SelectedSpot] then
        teleportTo(FishingSpots[getgenv().SelectedSpot])
        Window:Toast({Title = "Teleportasi", Message = "Berhasil teleport ke " .. getgenv().SelectedSpot .. "!", Duration = 2, Type = "Success"})
    else
        Window:Toast({Title = "Error", Message = "Spot tidak valid!", Duration = 2, Type = "Error"})
    end
end})

local PlayerTPSection = TeleportTab:AddSection({ Title = "Player Teleport & Spectate" })

local PlayerTPDropdown = PlayerTPSection:AddDropdown({Text = "Pilih Player", Options = {"Scan dulu..."}, Callback = function(v) 
    getgenv().TargetPlayerTP = v 
end})

PlayerTPSection:AddButton({Text = "🔍 Scan / Refresh Player", Callback = function()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do 
        if p.Name ~= LocalPlayer.Name then table.insert(list, p.Name) end 
    end
    if #list == 0 then table.insert(list, "Tidak ada player lain") end
    PlayerTPDropdown.Refresh(list)
    getgenv().TargetPlayerTP = list[1]
    Window:Toast({Title = "Scan Berhasil", Message = "Daftar player diperbarui!", Duration = 2, Type = "Success"})
end})

PlayerTPSection:AddButton({Text = "🚀 Teleport ke Player", Callback = function()
    local tName = getgenv().TargetPlayerTP
    if tName == "" or tName == "Scan dulu..." or tName == "Tidak ada player lain" then
        Window:Toast({Title = "Gagal", Message = "Pilih player yang valid!", Duration = 2, Type = "Error"})
        return
    end
    local tPlayer = Players:FindFirstChild(tName)
    if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
        teleportTo(tPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)) 
        Window:Toast({Title = "Teleport", Message = "Berhasil teleport ke " .. tName, Duration = 2, Type = "Success"})
    else
        Window:Toast({Title = "Gagal", Message = "Player tidak ditemukan atau mati!", Duration = 2, Type = "Error"})
    end
end})

PlayerTPSection:AddToggle({Text = "👁️ View Player (Spectate)", Default = false, Callback = function(v)
    local camera = workspace.CurrentCamera
    if v then
        local tName = getgenv().TargetPlayerTP
        local tPlayer = Players:FindFirstChild(tName)
        if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = tPlayer.Character.Humanoid
            Window:Toast({Title = "Spectate", Message = "Melihat kamera " .. tName, Duration = 2, Type = "Info"})
        else
            Window:Toast({Title = "Gagal", Message = "Player tidak bisa di-spectate!", Duration = 2, Type = "Error"})
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
            Window:Toast({Title = "Spectate", Message = "Kamera kembali normal.", Duration = 2, Type = "Info"})
        end
    end
end})

-- [AVATAR TAB]
local AvaSection = AvatarTab:AddSection({ Title = "Change Your Avatar" })

local AvaInputAPI = AvaSection:AddInput({Text = "Target Username", Placeholder = "Ketik username...", Callback = function(t) getgenv().TargetAvatar = t end})

local PlayerDropdown = AvaSection:AddDropdown({Text = "Pilih Player", Options = {"Scan dulu..."}, Callback = function(s) if s ~= "Scan dulu..." and s ~= "Kosong (Cuma kamu)" then getgenv().TargetAvatar = s; AvaInputAPI:SetText(s) end end})

AvaSection:AddButton({Text = "🔍 Scan Server", Callback = function() 
    local list = {}; 
    for _, p in pairs(Players:GetPlayers()) do if p.Name ~= LocalPlayer.Name then table.insert(list, p.Name) end end
    if #list == 0 then table.insert(list, "Kosong (Cuma kamu)") end
    PlayerDropdown.Refresh(list) 
    Window:Toast({Title = "Scan Avatar", Message = "Berhasil memuat nama " .. #list .. " pemain!", Duration = 2, Type = "Success"})
end})

local HistoryDropdown = AvaSection:AddDropdown({Text = "History", Options = getHistory(), Callback = function(s) if s ~= "Belum ada history" then getgenv().TargetAvatar = s; AvaInputAPI:SetText(s) end end})

AvaSection:AddButton({Text = "🗑️ Hapus History", Callback = function() 
    if getgenv().TargetAvatar ~= "" then
        local new = removeHistory(getgenv().TargetAvatar)
        HistoryDropdown.Refresh(new) 
        Window:Toast({Title = "History", Message = "History target berhasil dihapus!", Duration = 2, Type = "Info"})
    else
        Window:Toast({Title = "Gagal", Message = "Pilih username dari history dulu!", Duration = 2, Type = "Error"})
    end
end})

AvaSection:AddButton({Text = "✨ Load Avatar", Callback = function() 
    if getgenv().TargetAvatar == "" then Window:Toast({Title = "Gagal", Message = "Pilih username dulu!", Duration = 2, Type = "Error"}) return end
    Window:Toast({Title = "Memproses", Message = "Menyalin tampilan " .. getgenv().TargetAvatar .. "...", Duration = 3, Type = "Info"})
    local s, m = loadAvatar(getgenv().TargetAvatar)
    if s then Window:Toast({Title="Berhasil!", Message=m, Duration=3, Type="Success"}); HistoryDropdown.Refresh(addHistory(getgenv().TargetAvatar))
    else Window:Toast({Title="Gagal", Message=m, Duration=3, Type="Error"}) end
end})

AvaSection:AddButton({Text = "🧍 Balik ke Avatar Asli", Callback = function() 
    Window:Toast({Title = "Memproses", Message = "Mengembalikan avatar aslimu...", Duration = 3, Type = "Info"})
    local s, m = loadAvatar(LocalPlayer.Name)
    if s then 
        Window:Toast({Title="Berhasil!", Message="Karakter asli berhasil dimuat!", Duration=3, Type="Success"})
    else 
        Window:Toast({Title="Gagal", Message=m, Duration=3, Type="Error"}) 
    end
end})

AvaSection:AddButton({Text = "🔄 Refresh Karakter", Callback = function() 
    task.spawn(function()
        local success, err = pcall(function()
            local args = {"CommandUsed", "!ref"}
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 3):WaitForChild("RemoteFunction", 3):WaitForChild("AdminCommands", 3):InvokeServer(unpack(args))
        end)
        if success then
            Window:Toast({Title = "Refresh", Message = "Karakter sedang di-refresh!", Duration = 2, Type = "Info"})
        else
            Window:Toast({Title = "Gagal", Message = "Remote Refresh tidak ditemukan di map ini!", Duration = 2, Type = "Error"})
        end
    end)
end})

-- [EMOTE TAB]
local EmoteSection = EmoteTab:AddSection({ Title = "Emotes & Animations" })

EmoteSection:AddButton({
    Text = "🕺 Buka Menu Emote", 
    Callback = function() 
        Window:Toast({Title = "Memuat...", Message = "Mengunduh UI Emote...", Duration = 2, Type = "Info"})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/migii02/MigiiHUB/refs/heads/main/etc/Emote.lua"))()
            end)
            if success then
                Window:Toast({Title = "Berhasil", Message = "Menu Emote berhasil dieksekusi!", Duration = 3, Type = "Success"})
            else
                Window:Toast({Title = "Error", Message = "Gagal memuat script emote.", Duration = 3, Type = "Error"})
                warn("Emote Load Error: ", err)
            end
        end)
    end
})

-- LOOP UPDATE STATISTIK UI
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("NameTag") then
                for _, v in pairs(head.NameTag:GetDescendants()) do 
                    if v:IsA("TextLabel") and tonumber(v.Text) then 
                        CatchDash:SetText("🏆 Total Tangkapan: " .. v.Text .. " Ikan")
                        break 
                    end 
                end
            end
        end)
        
        pcall(function()
            local count = 0
            local PathCrystals = workspace:FindFirstChild("MapContent") and workspace.MapContent:FindFirstChild("Crystals")
            if PathCrystals then
                for _, obj in pairs(PathCrystals:GetChildren()) do
                    local name = string.lower(obj.Name)
                    if not string.find(name, "decor") and not string.find(name, "dekor") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        count = count + 1
                    end
                end
            end
            CrystalDash:SetText("💎 Total Kristal (Map): " .. count)
        end)
    end
end)

-- ==========================================
-- 8. SETUP FREECAM (OPTIMIZED)
-- ==========================================
do
    local Players_FC = game:GetService("Players")
    local Lighting_FC = game:GetService("Lighting")
    local player_FC = Players_FC.LocalPlayer
    local guiName_FC = "FreecamPro_Migii_V49_Optimized"

    if player_FC:WaitForChild("PlayerGui"):FindFirstChild(guiName_FC) then 
        player_FC.PlayerGui[guiName_FC]:Destroy() 
    end

    local RunService_FC = game:GetService("RunService")
    local UserInputService_FC = game:GetService("UserInputService")
    local TweenService_FC = game:GetService("TweenService")
    local camera_FC = workspace.CurrentCamera
    
    local isActive_FC, isCinematicMode_FC, isFollowChar_FC, isShakeActive_FC = false, false, false, false
    local isPlayingPath_FC, isLoopPath_FC, isLockAtTarget_FC = false, false, false

    local currentTween_FC = nil
    local baseMoveSpeed_FC, sensitivity_FC, zoomSpeed_FC, followSpeedMult_FC, wPathSpeed_FC = 0.55, 0.012, 1.5, 1.0, 2.0
    local shakeIntensity_FC = 0.05
    local currentFOV_FC, moveVector_FC, verticalVector_FC, lookVector_FC = 70, Vector3.new(), Vector3.new(), Vector2.new()
    local smoothedMoveVector_FC, smoothedVertical_FC = Vector3.new(), Vector3.new()
    local cameraRotX_FC, cameraRotY_FC, lastCharPos_FC = 0, 0, Vector3.new()
    local isZoomingIn_FC, isZoomingOut_FC = false, false

    local currentSpeedMultiplier_FC = 1.0
    local FAST_MULT_FC = 4.0
    local SLOW_MULT_FC = 0.2
    local uiVis_FC = true 

    local FCMain = FreecamTab:AddSection({ Title = "Freecam Main Controls" })
    
    FCMain:AddButton({Text = "🎥 Buka Freecam Ultra Pro", Callback = function() 
        if getgenv().ToggleMigiiFreecam then getgenv().ToggleMigiiFreecam(true) end 
    end})
    FCMain:AddButton({Text = "🛑 Matikan Freecam", Callback = function() 
        if getgenv().ToggleMigiiFreecam then getgenv().ToggleMigiiFreecam(false) end 
    end})
    FCMain:AddButton({Text = "📍 Buka/Tutup Panel Waypoint Manager", Callback = function() 
        if getgenv().MigiiFC_ToggleWpPanel then getgenv().MigiiFC_ToggleWpPanel() end 
    end})
    FCMain:AddToggle({Text = "👁️ Tampilkan Kontrol Layar Kanan (D-Pad)", Default = true, Callback = function(v) 
        if getgenv().MigiiFC_ToggleControls then getgenv().MigiiFC_ToggleControls(v) end 
    end})

    local FCModes = FreecamTab:AddSection({ Title = "Mode & Toggles" })
    FCModes:AddToggle({Text = "🎬 Mode Sinematik (Smooth)", Default = false, Callback = function(v) isCinematicMode_FC = v end})
    FCModes:AddToggle({Text = "🧍 Ikuti Pergerakan Karakter", Default = false, Callback = function(v) isFollowChar_FC = v end})
    FCModes:AddToggle({Text = "🎯 Kunci Pandangan ke Karakter", Default = false, Callback = function(v) isLockAtTarget_FC = v end})
    FCModes:AddToggle({Text = "🌋 Efek Gempa (Camera Shake)", Default = false, Callback = function(v) isShakeActive_FC = v end})

    local FCSpeeds = FreecamTab:AddSection({ Title = "Pengaturan Kecepatan" })
    local slSpeed = FCSpeeds:AddSlider({Text = "Kecepatan Gerak", Min = 0.05, Max = 5.0, Default = 0.55, Increment = 0.05, Callback = function(v) baseMoveSpeed_FC = v end})
    local slSens = FCSpeeds:AddSlider({Text = "Sensitivitas Layar", Min = 0.001, Max = 0.1, Default = 0.012, Increment = 0.001, Callback = function(v) sensitivity_FC = v end})
    local slZoom = FCSpeeds:AddSlider({Text = "Kecepatan Zoom (Z+/Z-)", Min = 0.1, Max = 10.0, Default = 1.5, Increment = 0.1, Callback = function(v) zoomSpeed_FC = v end})
    FCSpeeds:AddButton({Text = "🔄 Reset Kecepatan ke Default", Callback = function()
        slSpeed.SetValue(0.55); slSens.SetValue(0.012); slZoom.SetValue(1.5)
        Window:Toast({Title="Reset", Message="Kecepatan di-reset ke pengaturan awal!", Duration=2, Type="Info"})
    end})

    local FCVisual = FreecamTab:AddSection({ Title = "Visual Filters" })
    local function applyF_FC(n)
        local cc = Lighting_FC:FindFirstChild("FCP_CC") or Instance.new("ColorCorrectionEffect", Lighting_FC)
        cc.Name = "FCP_CC"; cc.Saturation, cc.Contrast = 0,0
        if n == "Cinematic" then cc.Contrast, cc.Saturation = 0.2, 0.2
        elseif n == "Noir" then cc.Saturation = -1
        elseif n == "Vibrant" then cc.Saturation = 0.5
        elseif n == "Default" then cc:Destroy() end
    end
    FCVisual:AddDropdown({Text = "Pilih Filter Layar", Options = {"Default", "Cinematic", "Vibrant", "Noir"}, Default = "Default", Callback = function(v) applyF_FC(v) Window:Toast({Title="Visual", Message="Filter diubah ke: "..v, Duration=2}) end})

    local FCWpPreset = FreecamTab:AddSection({ Title = "Waypoint Auto Presets" })
    FCWpPreset:AddButton({Text = "🌀 Generate Auto 360° Spin", Callback = function()
        if not player_FC.Character or not player_FC.Character:FindFirstChild("HumanoidRootPart") then return end
        local center = player_FC.Character.HumanoidRootPart.Position
        getgenv().MigiiFC_Waypoints = {}; getgenv().MigiiFC_UndoStack = {}
        for i = 1, 8 do
            local angle = math.rad((i-1) * 45)
            table.insert(getgenv().MigiiFC_Waypoints, CFrame.new(Vector3.new(center.X + math.cos(angle)*15, center.Y + 5, center.Z + math.sin(angle)*15), center))
        end
        if getgenv().MigiiFC_UpdateWpUI then getgenv().MigiiFC_UpdateWpUI() end
        Window:Toast({Title="Sukses", Message="Jalur 360 derajat siap di-play!", Duration=2, Type="Success"})
    end})

    FCWpPreset:AddButton({Text = "🚁 Generate Drone Shot (Naik)", Callback = function()
        if not player_FC.Character or not player_FC.Character:FindFirstChild("HumanoidRootPart") then return end
        local center = player_FC.Character.HumanoidRootPart.Position
        local look = player_FC.Character.HumanoidRootPart.CFrame.LookVector
        getgenv().MigiiFC_Waypoints = {
            CFrame.new(center + (look * 10) + Vector3.new(0, 3, 0), center),
            CFrame.new(center + (look * 5) + Vector3.new(0, 25, 0), center),
            CFrame.new(center + Vector3.new(0, 50, 0), center)
        }
        getgenv().MigiiFC_UndoStack = {}
        if getgenv().MigiiFC_UpdateWpUI then getgenv().MigiiFC_UpdateWpUI() end
        Window:Toast({Title="Sukses", Message="Jalur Drone terbang siap di-play!", Duration=2, Type="Success"})
    end})

    FCWpPreset:AddButton({Text = "🌪️ Generate Spiral Up", Callback = function()
        if not player_FC.Character or not player_FC.Character:FindFirstChild("HumanoidRootPart") then return end
        local center = player_FC.Character.HumanoidRootPart.Position
        getgenv().MigiiFC_Waypoints = {}; getgenv().MigiiFC_UndoStack = {}
        for i = 1, 12 do
            local angle = math.rad((i-1) * 30)
            table.insert(getgenv().MigiiFC_Waypoints, CFrame.new(Vector3.new(center.X + math.cos(angle)*15, center.Y + (i*3), center.Z + math.sin(angle)*15), center))
        end
        if getgenv().MigiiFC_UpdateWpUI then getgenv().MigiiFC_UpdateWpUI() end
        Window:Toast({Title="Sukses", Message="Jalur Spiral ke atas siap di-play!", Duration=2, Type="Success"})
    end})

    FCWpPreset:AddButton({Text = "✈️ Generate Flyby (Lewat Samping)", Callback = function()
        if not player_FC.Character or not player_FC.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player_FC.Character.HumanoidRootPart
        local center, look, right = hrp.Position, hrp.CFrame.LookVector, hrp.CFrame.RightVector
        getgenv().MigiiFC_Waypoints = {
            CFrame.new(center + (look * 30) + (right * 15) + Vector3.new(0,5,0), center),
            CFrame.new(center + (right * -10) + Vector3.new(0,5,0), center),
            CFrame.new(center - (look * 30) + (right * 15) + Vector3.new(0,5,0), center)
        }
        getgenv().MigiiFC_UndoStack = {}
        if getgenv().MigiiFC_UpdateWpUI then getgenv().MigiiFC_UpdateWpUI() end
        Window:Toast({Title="Sukses", Message="Jalur Melesat (Flyby) siap di-play!", Duration=2, Type="Success"})
    end})

    local FCSaveLoad = FreecamTab:AddSection({ Title = "Save / Load Custom Presets" })
    getgenv().MigiiFC_PresetName = ""
    getgenv().MigiiFC_SelectedPreset = "Belum ada preset"

    FCSaveLoad:AddInput({Text = "Nama Preset Baru", Placeholder = "Ketik nama jalur...", Callback = function(v) getgenv().MigiiFC_PresetName = v end})
    local WpDropdown = FCSaveLoad:AddDropdown({Text = "Daftar Preset", Options = getPresetNames(), Callback = function(v) getgenv().MigiiFC_SelectedPreset = v end})
    
    FCSaveLoad:AddButton({Text = "💾 Simpan Waypoint Saat Ini", Callback = function()
        if #getgenv().MigiiFC_Waypoints == 0 then Window:Toast({Title="Error", Message="Titik jalur masih kosong!", Duration=2, Type="Error"}) return end
        if getgenv().MigiiFC_PresetName == "" then Window:Toast({Title="Error", Message="Isi nama preset dulu di atas!", Duration=2, Type="Error"}) return end
        if saveWpPreset(getgenv().MigiiFC_PresetName, getgenv().MigiiFC_Waypoints) then
            WpDropdown.Refresh(getPresetNames())
            Window:Toast({Title="Sukses", Message="Preset " .. getgenv().MigiiFC_PresetName .. " tersimpan!", Duration=2, Type="Success"})
        end
    end})

    FCSaveLoad:AddButton({Text = "📂 Load Preset Terpilih", Callback = function()
        local d = getWpData()[getgenv().MigiiFC_SelectedPreset]
        if d then
            getgenv().MigiiFC_Waypoints = {}; getgenv().MigiiFC_UndoStack = {} 
            for _, comp in ipairs(d) do table.insert(getgenv().MigiiFC_Waypoints, CFrame.new(unpack(comp))) end
            if getgenv().MigiiFC_UpdateWpUI then getgenv().MigiiFC_UpdateWpUI() end
            Window:Toast({Title="Sukses", Message="Preset " .. getgenv().MigiiFC_SelectedPreset .. " dimuat!", Duration=2, Type="Success"})
        else
            Window:Toast({Title="Error", Message="Pilih preset yang valid!", Duration=2, Type="Error"})
        end
    end})

    local screenGui_FC = Instance.new("ScreenGui", player_FC.PlayerGui)
    screenGui_FC.Name = guiName_FC; screenGui_FC.ResetOnSpawn = false; screenGui_FC.IgnoreGuiInset = true
    screenGui_FC.DisplayOrder = 99999 

    local function makeDraggable_FC(guiObject)
        local dragging, dragInput, dragStart, startPos
        guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = guiObject.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        guiObject.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        UserInputService_FC.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local frameControls_FC = Instance.new("Frame", screenGui_FC)
    frameControls_FC.Size = UDim2.new(1, 0, 1, 0)
    frameControls_FC.BackgroundTransparency = 1
    frameControls_FC.Visible = false

    local wpPanel_FC = Instance.new("Frame", frameControls_FC)
    wpPanel_FC.Size = UDim2.new(0, 180, 0, 205); wpPanel_FC.Position = UDim2.new(0, 20, 0.5, -120)
    wpPanel_FC.BackgroundColor3 = Color3.fromRGB(15, 18, 22); wpPanel_FC.BackgroundTransparency = 0.1
    Instance.new("UICorner", wpPanel_FC).CornerRadius = UDim.new(0, 10)
    
    local wpStrk = Instance.new("UIStroke", wpPanel_FC)
    wpStrk.Color = Color3.fromRGB(100, 200, 255); wpStrk.Thickness = 2.5
    wpStrk.LineJoinMode = Enum.LineJoinMode.Round
    wpPanel_FC.Visible = false 
    makeDraggable_FC(wpPanel_FC)

    local wpTitleLabel = Instance.new("TextLabel", wpPanel_FC)
    wpTitleLabel.Size = UDim2.new(1, 0, 0, 30); wpTitleLabel.BackgroundTransparency = 1
    wpTitleLabel.Text = "📍 WAYPOINT MANAGER"; wpTitleLabel.TextColor3 = Color3.new(1, 0.8, 0.2); wpTitleLabel.Font = Enum.Font.GothamBold; wpTitleLabel.TextSize = 11

    local wpCountLabel = Instance.new("TextLabel", wpPanel_FC)
    wpCountLabel.Size = UDim2.new(1, 0, 0, 20); wpCountLabel.Position = UDim2.new(0,0,0,25); wpCountLabel.BackgroundTransparency = 1
    wpCountLabel.Text = "Titik Tersimpan: 0"; wpCountLabel.TextColor3 = Color3.new(1, 1, 1); wpCountLabel.Font = Enum.Font.Gotham; wpCountLabel.TextSize = 10

    local wpBtnAdd = Instance.new("TextButton", wpPanel_FC)
    wpBtnAdd.Size = UDim2.new(0.9, 0, 0, 25); wpBtnAdd.Position = UDim2.new(0.05, 0, 0, 50); wpBtnAdd.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
    wpBtnAdd.Text = "➕ Tambah Titik Kamera"; wpBtnAdd.TextColor3 = Color3.new(1,1,1); wpBtnAdd.Font = Enum.Font.GothamBold; wpBtnAdd.TextSize = 10
    Instance.new("UICorner", wpBtnAdd).CornerRadius = UDim.new(0,6)

    local wpGrid = Instance.new("Frame", wpPanel_FC)
    wpGrid.Size = UDim2.new(0.95, 0, 0, 60); wpGrid.Position = UDim2.new(0.025, 0, 0, 80); wpGrid.BackgroundTransparency = 1
    local wpUig = Instance.new("UIGridLayout", wpGrid); wpUig.CellSize = UDim2.new(0.31, 0, 0, 25); wpUig.CellPadding = UDim2.new(0.02, 0, 0.08, 0)

    local function makeWpBtn(txt, col)
        local b = Instance.new("TextButton", wpGrid); b.BackgroundColor3 = col; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 9
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
        return b
    end
    
    local wpBtnPlay = makeWpBtn("▶ Mulai", Color3.fromRGB(20, 120, 40))
    local wpBtnStop = makeWpBtn("🛑 Stop", Color3.fromRGB(180, 80, 20))
    local wpBtnLoop = makeWpBtn("🔁 Loop: OFF", Color3.fromRGB(40, 40, 50))
    local wpBtnUndo = makeWpBtn("↩ Undo", Color3.fromRGB(150, 100, 20))
    local wpBtnRedo = makeWpBtn("↪ Redo", Color3.fromRGB(20, 100, 150))
    local wpBtnClear = makeWpBtn("🗑️ Hapus", Color3.fromRGB(150, 20, 20))

    local wpSliderFrame = Instance.new("Frame", wpPanel_FC)
    wpSliderFrame.Size = UDim2.new(0.9, 0, 0, 40); wpSliderFrame.Position = UDim2.new(0.05, 0, 0, 150); wpSliderFrame.BackgroundTransparency = 1

    local wpSpdLabel = Instance.new("TextLabel", wpSliderFrame)
    wpSpdLabel.Size = UDim2.new(0.5, 0, 0, 15); wpSpdLabel.BackgroundTransparency = 1; wpSpdLabel.Text = "Speed Jalur:"; wpSpdLabel.TextColor3 = Color3.new(1,1,1); wpSpdLabel.Font = Enum.Font.Gotham; wpSpdLabel.TextSize = 10; wpSpdLabel.TextXAlignment = Enum.TextXAlignment.Left

    local wpSpdBox = Instance.new("TextBox", wpSliderFrame)
    wpSpdBox.Size = UDim2.new(0, 30, 0, 15); wpSpdBox.Position = UDim2.new(1, -50, 0, 0); wpSpdBox.BackgroundColor3 = Color3.fromRGB(25,25,35); wpSpdBox.TextColor3 = Color3.new(0.5, 1, 0.5); wpSpdBox.Font = Enum.Font.GothamBold; wpSpdBox.TextSize = 9; wpSpdBox.Text = tostring(wPathSpeed_FC)
    Instance.new("UICorner", wpSpdBox).CornerRadius = UDim.new(0,4)

    local wpBtnSpdMinus = Instance.new("TextButton", wpSliderFrame)
    wpBtnSpdMinus.Size = UDim2.new(0, 15, 0, 15); wpBtnSpdMinus.Position = UDim2.new(1, -70, 0, 0); wpBtnSpdMinus.BackgroundColor3 = Color3.fromRGB(40,40,50); wpBtnSpdMinus.Text = "-"; wpBtnSpdMinus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", wpBtnSpdMinus).CornerRadius = UDim.new(0,4)

    local wpBtnSpdPlus = Instance.new("TextButton", wpSliderFrame)
    wpBtnSpdPlus.Size = UDim2.new(0, 15, 0, 15); wpBtnSpdPlus.Position = UDim2.new(1, -15, 0, 0); wpBtnSpdPlus.BackgroundColor3 = Color3.fromRGB(40,40,50); wpBtnSpdPlus.Text = "+"; wpBtnSpdPlus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", wpBtnSpdPlus).CornerRadius = UDim.new(0,4)

    local wpSliderBg = Instance.new("TextButton", wpSliderFrame)
    wpSliderBg.Size = UDim2.new(1, 0, 0, 6); wpSliderBg.Position = UDim2.new(0, 0, 0, 25); wpSliderBg.BackgroundColor3 = Color3.fromRGB(20,20,30); wpSliderBg.Text = ""; wpSliderBg.AutoButtonColor = false
    Instance.new("UICorner", wpSliderBg).CornerRadius = UDim.new(1,0)

    local wpSliderFill = Instance.new("Frame", wpSliderBg)
    wpSliderFill.Size = UDim2.new((wPathSpeed_FC - 0.5) / (20 - 0.5), 0, 1, 0); wpSliderFill.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
    Instance.new("UICorner", wpSliderFill).CornerRadius = UDim.new(1,0)

    local wpDragging = false
    local function updateWpSpeed(val)
        val = math.clamp(math.round(val / 0.5) * 0.5, 0.5, 20); wPathSpeed_FC = val; wpSpdBox.Text = string.format("%.1f", val)
        game:GetService("TweenService"):Create(wpSliderFill, TweenInfo.new(0.1), {Size = UDim2.new((val - 0.5) / (20 - 0.5), 0, 1, 0)}):Play()
    end
    local function updateWpFromInput(input)
        local pos = math.clamp((input.Position.X - wpSliderBg.AbsolutePosition.X) / wpSliderBg.AbsoluteSize.X, 0, 1)
        updateWpSpeed(0.5 + (pos * (20 - 0.5)))
    end

    wpSliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then wpDragging = true; updateWpFromInput(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then wpDragging = false end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if wpDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateWpFromInput(input) end end)

    wpBtnSpdMinus.MouseButton1Click:Connect(function() updateWpSpeed(tonumber(wpSpdBox.Text) - 0.5) end)
    wpBtnSpdPlus.MouseButton1Click:Connect(function() updateWpSpeed(tonumber(wpSpdBox.Text) + 0.5) end)
    wpSpdBox.FocusLost:Connect(function() local n = tonumber(wpSpdBox.Text); if n then updateWpSpeed(n) else updateWpSpeed(wPathSpeed_FC) end end)

    getgenv().MigiiFC_UpdateWpUI = function()
        wpCountLabel.Text = "Titik Tersimpan: " .. #getgenv().MigiiFC_Waypoints
        wpBtnLoop.Text = isLoopPath_FC and "🔁 Loop: ON" or "🔁 Loop: OFF"
        wpBtnLoop.BackgroundColor3 = isLoopPath_FC and Color3.fromRGB(20, 100, 150) or Color3.fromRGB(40, 40, 50)
    end

    wpBtnAdd.MouseButton1Click:Connect(function() table.insert(getgenv().MigiiFC_Waypoints, camera_FC.CFrame); getgenv().MigiiFC_UndoStack = {}; getgenv().MigiiFC_UpdateWpUI(); Window:Toast({Title="Waypoint", Message="Titik ditambahkan!", Duration=1, Type="Success"}) end)
    wpBtnUndo.MouseButton1Click:Connect(function() if #getgenv().MigiiFC_Waypoints > 0 then local lastWp = table.remove(getgenv().MigiiFC_Waypoints); table.insert(getgenv().MigiiFC_UndoStack, lastWp); getgenv().MigiiFC_UpdateWpUI(); Window:Toast({Title="Waypoint", Message="Titik di-Undo", Duration=1, Type="Info"}) end end)
    wpBtnRedo.MouseButton1Click:Connect(function() if #getgenv().MigiiFC_UndoStack > 0 then local restoredWp = table.remove(getgenv().MigiiFC_UndoStack); table.insert(getgenv().MigiiFC_Waypoints, restoredWp); getgenv().MigiiFC_UpdateWpUI(); Window:Toast({Title="Waypoint", Message="Titik di-Redo", Duration=1, Type="Success"}) end end)
    wpBtnClear.MouseButton1Click:Connect(function() getgenv().MigiiFC_Waypoints = {}; getgenv().MigiiFC_UndoStack = {}; isPlayingPath_FC = false; if currentTween_FC then currentTween_FC:Cancel() end; getgenv().MigiiFC_UpdateWpUI(); Window:Toast({Title="Waypoint", Message="Semua titik dihapus!", Duration=2, Type="Error"}) end)
    wpBtnLoop.MouseButton1Click:Connect(function() isLoopPath_FC = not isLoopPath_FC; getgenv().MigiiFC_UpdateWpUI() end)

    local function setupMv_FC(btn, dir, isV)
        btn.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then if isV then verticalVector_FC = dir else moveVector_FC = dir end end end)
        btn.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then if isV then verticalVector_FC = Vector3.new() else moveVector_FC = Vector3.new() end end end)
    end
    local function createBtn_FC(t, p, s, pr) local b = Instance.new("TextButton", pr); b.Text = t; b.Position = p; b.Size = s; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 25; Instance.new("UICorner", b); return b end
    
    local dpad_FC = Instance.new("Frame", frameControls_FC)
    dpad_FC.Position = UDim2.new(0, 50, 1, -210); dpad_FC.Size = UDim2.new(0, 160, 0, 160); dpad_FC.BackgroundTransparency = 1
    
    setupMv_FC(createBtn_FC("▲", UDim2.new(0.33,0,0,0), UDim2.new(0.33,0,0.33,0), dpad_FC), Vector3.new(0,0,-1), false) 
    setupMv_FC(createBtn_FC("▼", UDim2.new(0.33,0,0.66,0), UDim2.new(0.33,0,0.33,0), dpad_FC), Vector3.new(0,0,1), false) 
    setupMv_FC(createBtn_FC("◀", UDim2.new(0,0,0.33,0), UDim2.new(0.33,0,0.33,0), dpad_FC), Vector3.new(-1,0,0), false) 
    setupMv_FC(createBtn_FC("▶", UDim2.new(0.66,0,0.33,0), UDim2.new(0.33,0,0.33,0), dpad_FC), Vector3.new(1,0,0), false) 

    local cyberPanel_FC = Instance.new("Frame", frameControls_FC)
    cyberPanel_FC.Size = UDim2.new(0, 130, 0, 150); cyberPanel_FC.Position = UDim2.new(1, -140, 0, 20)
    cyberPanel_FC.BackgroundColor3 = Color3.fromRGB(10, 12, 15); cyberPanel_FC.BackgroundTransparency = 0.2
    Instance.new("UICorner", cyberPanel_FC).CornerRadius = UDim.new(0, 15)
    
    local cbStrk = Instance.new("UIStroke", cyberPanel_FC)
    cbStrk.Thickness = 2.5
    cbStrk.Color = Color3.fromRGB(100, 200, 255)
    cbStrk.LineJoinMode = Enum.LineJoinMode.Round
    makeDraggable_FC(cyberPanel_FC)

    local gridFrame_FC = Instance.new("Frame", cyberPanel_FC)
    gridFrame_FC.Size = UDim2.new(0, 75, 0, 75); gridFrame_FC.AnchorPoint = Vector2.new(0.5, 0); gridFrame_FC.Position = UDim2.new(0.5, 0, 0, 10); gridFrame_FC.BackgroundTransparency = 1
    local uig_FC = Instance.new("UIGridLayout", gridFrame_FC); uig_FC.CellSize = UDim2.new(0, 35, 0, 35); uig_FC.CellPadding = UDim2.new(0, 5, 0, 5)

    local function makeMini_FC(icon, order)
        local b = Instance.new("TextButton", gridFrame_FC); b.LayoutOrder = order
        b.BackgroundColor3=Color3.fromRGB(25,25,30); b.Text=icon; b.TextColor3=Color3.new(1,1,1); b.TextSize=16; b.Font=Enum.Font.GothamBold
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        local mnStrk = Instance.new("UIStroke", b); mnStrk.Color = Color3.fromRGB(60,60,70); mnStrk.Thickness = 1.5
        return b
    end
    
    local btnUpY_FC = makeMini_FC("▲", 1) 
    local btnDownY_FC = makeMini_FC("▼", 2) 
    local btnZoomIn_FC = makeMini_FC("Z+", 3)
    local btnZoomOut_FC = makeMini_FC("Z-", 4)
    
    setupMv_FC(btnUpY_FC, Vector3.new(0, 1, 0), true)
    setupMv_FC(btnDownY_FC, Vector3.new(0, -1, 0), true)

    local btnFast_FC = Instance.new("TextButton", cyberPanel_FC)
    btnFast_FC.Size = UDim2.new(0, 54, 0, 25); btnFast_FC.AnchorPoint = Vector2.new(0.5, 0); btnFast_FC.Position = UDim2.new(0.28, 0, 0, 88)
    btnFast_FC.BackgroundColor3 = Color3.fromRGB(20, 30, 25); btnFast_FC.BackgroundTransparency = 0.3; btnFast_FC.Text = ""
    Instance.new("UICorner", btnFast_FC).CornerRadius = UDim.new(0, 6)
    local fsStrk = Instance.new("UIStroke", btnFast_FC); fsStrk.Color = Color3.fromRGB(50, 255, 100); fsStrk.Thickness = 1.5
    local lFast_FC = Instance.new("TextLabel", btnFast_FC); lFast_FC.Size=UDim2.new(1,0,1,0); lFast_FC.BackgroundTransparency=1; lFast_FC.Text="CEPAT"; lFast_FC.TextColor3=Color3.fromRGB(50,255,100); lFast_FC.Font=Enum.Font.GothamBold; lFast_FC.TextSize=9

    local btnSlow_FC = Instance.new("TextButton", cyberPanel_FC)
    btnSlow_FC.Size = UDim2.new(0, 54, 0, 25); btnSlow_FC.AnchorPoint = Vector2.new(0.5, 0); btnSlow_FC.Position = UDim2.new(0.72, 0, 0, 88)
    btnSlow_FC.BackgroundColor3 = Color3.fromRGB(30, 20, 20); btnSlow_FC.BackgroundTransparency = 0.3; btnSlow_FC.Text = ""
    Instance.new("UICorner", btnSlow_FC).CornerRadius = UDim.new(0, 6)
    local slStrk = Instance.new("UIStroke", btnSlow_FC); slStrk.Color = Color3.fromRGB(255, 100, 50); slStrk.Thickness = 1.5
    local lSlow_FC = Instance.new("TextLabel", btnSlow_FC); lSlow_FC.Size=UDim2.new(1,0,1,0); lSlow_FC.BackgroundTransparency=1; lSlow_FC.Text="PELAN"; lSlow_FC.TextColor3=Color3.fromRGB(255,100,50); lSlow_FC.Font=Enum.Font.GothamBold; lSlow_FC.TextSize=9

    local btnForceStop_FC = Instance.new("TextButton", cyberPanel_FC)
    btnForceStop_FC.Size = UDim2.new(0.85, 0, 0, 25); btnForceStop_FC.AnchorPoint = Vector2.new(0.5, 0); btnForceStop_FC.Position = UDim2.new(0.5, 0, 0, 118)
    btnForceStop_FC.BackgroundColor3 = Color3.fromRGB(150, 20, 20); btnForceStop_FC.Text = "🛑 MATIKAN FREECAM"
    btnForceStop_FC.TextColor3 = Color3.new(1,1,1); btnForceStop_FC.Font = Enum.Font.GothamBold; btnForceStop_FC.TextSize = 9
    Instance.new("UICorner", btnForceStop_FC).CornerRadius = UDim.new(0,6)

    local function toggleUIMigiiHUB(isVisible)
        for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if v:IsA("TextLabel") and v.Text:find("MigiiHUB |") then
                local sg = v:FindFirstAncestorOfClass("ScreenGui"); if sg then sg.Enabled = isVisible end
            end
        end
        for _, v in pairs(player_FC:FindFirstChild("PlayerGui"):GetDescendants()) do
            if v:IsA("TextLabel") and v.Text:find("MigiiHUB |") then
                local sg = v:FindFirstAncestorOfClass("ScreenGui"); if sg then sg.Enabled = isVisible end
            end
        end
    end

    local function restoreUIAfterPlay()
        if uiVis_FC then dpad_FC.Visible = true; cyberPanel_FC.Visible = true end
        pcall(function() toggleUIMigiiHUB(true) end)
    end

    wpBtnStop.MouseButton1Click:Connect(function() 
        isPlayingPath_FC = false; if currentTween_FC then currentTween_FC:Cancel() end
        Window:Toast({Title="Waypoint", Message="Jalur dihentikan", Duration=2, Type="Info"}) 
        restoreUIAfterPlay()
    end)

    UserInputService_FC.InputBegan:Connect(function(input, gameProcessed)
        if isPlayingPath_FC and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not gameProcessed then 
                wpPanel_FC.Visible = true 
            end
        end
    end)

    wpBtnPlay.MouseButton1Click:Connect(function()
        if #getgenv().MigiiFC_Waypoints < 2 or isPlayingPath_FC then Window:Toast({Title="Error", Message="Butuh minimal 2 titik!", Duration=2, Type="Error"}) return end
        isPlayingPath_FC = true
        
        dpad_FC.Visible = false
        cyberPanel_FC.Visible = false
        wpPanel_FC.Visible = false
        pcall(function() toggleUIMigiiHUB(false) end)

        Window:Toast({Title="Waypoint", Message="Memulai Animasi...", Duration=4, Type="Success"})
        task.spawn(function()
            repeat 
                for i, t in ipairs(getgenv().MigiiFC_Waypoints) do
                    if not isPlayingPath_FC then break end
                    local d = (camera_FC.CFrame.Position - t.Position).Magnitude
                    currentTween_FC = TweenService_FC:Create(camera_FC, TweenInfo.new(d/wPathSpeed_FC, Enum.EasingStyle.Sine), {CFrame = t})
                    currentTween_FC:Play(); currentTween_FC.Completed:Wait()
                end 
            until not isLoopPath_FC or not isPlayingPath_FC
            
            if isPlayingPath_FC then 
                isPlayingPath_FC = false
                Window:Toast({Title="Waypoint", Message="Animasi Selesai", Duration=2, Type="Success"})
                restoreUIAfterPlay()
            end
        end)
    end)

    getgenv().MigiiFC_ToggleWpPanel = function()
        wpPanel_FC.Visible = not wpPanel_FC.Visible
    end

    getgenv().ToggleMigiiFreecam = function(state)
        if state then
            isActive_FC = true; frameControls_FC.Visible = true; camera_FC.CameraType = Enum.CameraType.Scriptable
            
            local rx, ry, rz = camera_FC.CFrame:ToEulerAnglesYXZ()
            cameraRotX_FC, cameraRotY_FC = ry, rx

            Window:Toast({Title = "Freecam", Message = "Freecam Ultra Pro Aktif!", Duration = 2, Type = "Success"})
            pcall(function() toggleUIMigiiHUB(false) end)
        else
            isActive_FC = false; frameControls_FC.Visible = false; camera_FC.CameraType = Enum.CameraType.Custom; camera_FC.FieldOfView = 70; currentFOV_FC = 70
            wpPanel_FC.Visible = false 
            if Lighting_FC:FindFirstChild("FCP_CC") then Lighting_FC.FCP_CC:Destroy() end
            Window:Toast({Title = "Freecam", Message = "Freecam Dinonaktifkan!", Duration = 2, Type = "Info"})
            pcall(function() toggleUIMigiiHUB(true) end)
        end
    end

    btnForceStop_FC.MouseButton1Click:Connect(function()
        if getgenv().ToggleMigiiFreecam then getgenv().ToggleMigiiFreecam(false) end
    end)

    getgenv().MigiiFC_ResetCam = function()
        currentFOV_FC = 70; camera_FC.FieldOfView = 70; currentSpeedMultiplier_FC = 1.0
        if player_FC.Character and player_FC.Character:FindFirstChild("Head") then
            camera_FC.CFrame = player_FC.Character.Head.CFrame * CFrame.new(0, 2, 6)
            local rx, ry, rz = camera_FC.CFrame:ToEulerAnglesYXZ()
            cameraRotX_FC, cameraRotY_FC = ry, rx
        end
    end

    getgenv().MigiiFC_ToggleControls = function(state)
        uiVis_FC = state; cyberPanel_FC.Visible = state; dpad_FC.Visible = state
    end

    btnFast_FC.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then currentSpeedMultiplier_FC = FAST_MULT_FC; btnFast_FC.BackgroundColor3=Color3.fromRGB(0,100,50) end end)
    btnFast_FC.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then currentSpeedMultiplier_FC = 1.0; btnFast_FC.BackgroundColor3=Color3.fromRGB(20,30,25) end end)
    btnSlow_FC.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then currentSpeedMultiplier_FC = SLOW_MULT_FC; btnSlow_FC.BackgroundColor3=Color3.fromRGB(100,40,20) end end)
    btnSlow_FC.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then currentSpeedMultiplier_FC = 1.0; btnSlow_FC.BackgroundColor3=Color3.fromRGB(30,20,20) end end)
    btnZoomIn_FC.InputBegan:Connect(function() isZoomingIn_FC = true end); btnZoomIn_FC.InputEnded:Connect(function() isZoomingIn_FC = false end)
    btnZoomOut_FC.InputBegan:Connect(function() isZoomingOut_FC = true end); btnZoomOut_FC.InputEnded:Connect(function() isZoomingOut_FC = false end)

    UserInputService_FC.InputChanged:Connect(function(i, p) if isActive_FC and i.UserInputType == Enum.UserInputType.Touch and not p then lookVector_FC = Vector2.new(i.Delta.X * sensitivity_FC, i.Delta.Y * sensitivity_FC) end end)

    RunService_FC.RenderStepped:Connect(function(dt)
        if not isActive_FC or isPlayingPath_FC then return end
        local finalSpeed = baseMoveSpeed_FC * currentSpeedMultiplier_FC
        if isCinematicMode_FC then smoothedMoveVector_FC = smoothedMoveVector_FC:Lerp(moveVector_FC, 0.1); smoothedVertical_FC = smoothedVertical_FC:Lerp(verticalVector_FC, 0.1) else smoothedMoveVector_FC, smoothedVertical_FC = moveVector_FC, verticalVector_FC end
        if isLockAtTarget_FC and player_FC.Character and player_FC.Character:FindFirstChild("HumanoidRootPart") then
            camera_FC.CFrame = CFrame.new(camera_FC.CFrame.Position, player_FC.Character.HumanoidRootPart.Position); local rX, rY, rZ = camera_FC.CFrame:ToEulerAnglesYXZ(); cameraRotX_FC, cameraRotY_FC = rY, rX
        else cameraRotX_FC = cameraRotX_FC - lookVector_FC.X; cameraRotY_FC = math.clamp(cameraRotY_FC - lookVector_FC.Y, -1.4, 1.4) end
        local rot = CFrame.Angles(0, cameraRotX_FC, 0) * CFrame.Angles(cameraRotY_FC, 0, 0)
        local f = (isFollowChar_FC and player_FC.Character and player_FC.Character:FindFirstChild("HumanoidRootPart")) and ((player_FC.Character.HumanoidRootPart.Position - lastCharPos_FC) * followSpeedMult_FC) or Vector3.new()
        if player_FC.Character and player_FC.Character:FindFirstChild("HumanoidRootPart") then lastCharPos_FC = player_FC.Character.HumanoidRootPart.Position end
        camera_FC.CFrame = CFrame.new(camera_FC.CFrame.Position + f + (rot:VectorToWorldSpace(smoothedMoveVector_FC) + smoothedVertical_FC) * (finalSpeed * 60 * dt)) * rot * (isShakeActive_FC and CFrame.new(math.noise(tick()*5)*shakeIntensity_FC, math.noise(0, tick()*5)*shakeIntensity_FC, 0) or CFrame.new())
        lookVector_FC = lookVector_FC * 0.5
        if isZoomingIn_FC then currentFOV_FC = math.clamp(currentFOV_FC - zoomSpeed_FC, 10, 100) elseif isZoomingOut_FC then currentFOV_FC = math.clamp(currentFOV_FC + zoomSpeed_FC, 10, 100) end
        camera_FC.FieldOfView = currentFOV_FC
    end)
end
