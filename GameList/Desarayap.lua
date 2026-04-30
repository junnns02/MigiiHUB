-- ==========================================
-- 0. DETEKSI NAMA GAME & SETUP FOLDER
-- ==========================================
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- LOGIKA ANTI AFK (DENGAN KONTROL TOGGLE)
-- ==========================================
getgenv().AntiAFK = true -- Default nya True (aktif)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local baseFolder = "MigiiHub"
local gameDisplayName = "Desa Rayap" 

local function getGameNames()
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    local rawName = (success and info and info.Name) or game.Name
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
    valLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    local arrow = Instance.new("TextLabel", mainBtn)
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▼"; arrow.TextColor3 = Color3.fromRGB(200, 200, 200); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 10
    
    local dropFrame = Instance.new("ScrollingFrame", container)
    dropFrame.Size = UDim2.new(1, 0, 1, -30); dropFrame.Position = UDim2.new(0, 0, 0, 30); dropFrame.BackgroundTransparency = 1
    dropFrame.ScrollBarThickness = 4; dropFrame.BorderSizePixel = 0
    dropFrame.CanvasSize = UDim2.new(0, 0, 0, 0); dropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local list = Instance.new("UIListLayout", dropFrame); list.SortOrder = Enum.SortOrder.LayoutOrder

    local searchBox = Instance.new("TextBox", dropFrame)
    searchBox.Size = UDim2.new(1, -10, 0, 25); searchBox.Position = UDim2.new(0, 5, 0, 0)
    searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35); searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderText = "🔍 Cari nama..."; searchBox.Text = ""; searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 9
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
    searchBox.LayoutOrder = -1

    local isOpen = false
    local function toggle()
        isOpen = not isOpen
        local targetHeight = isOpen and (30 + 30 + (math.min(#options, 6) * 25)) or 30 
        if targetHeight > 200 then targetHeight = 200 end
        TweenService:Create(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        arrow.Text = isOpen and "▲" or "▼"
        if not isOpen then searchBox.Text = "" end
    end
    mainBtn.MouseButton1Click:Connect(toggle)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchBox.Text:lower()
        for _, child in pairs(dropFrame:GetChildren()) do
            if child:IsA("TextButton") then child.Visible = child.Text:lower():find(filter) ~= nil end
        end
    end)

    local function updateOptions(newOptions)
        for _, c in pairs(dropFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        options = newOptions
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropFrame)
            optBtn.Size = UDim2.new(1, 0, 0, 25); optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            optBtn.BackgroundTransparency = 0.5; optBtn.BorderSizePixel = 0; optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200); optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 10; optBtn.TextXAlignment = Enum.TextXAlignment.Left; optBtn.LayoutOrder = i
            optBtn.MouseButton1Click:Connect(function() selected = opt; valLabel.Text = opt; toggle(); callback(opt) end)
        end
    end
    updateOptions(options); return {Refresh = updateOptions}
end

Library._SectionMethods.AddMultiDropdown = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local selected = config.Default or {}
    
    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 30); container.LayoutOrder = self._elementOrder
    container.ClipsDescendants = true; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(1, 0, 0, 30); mainBtn.BackgroundTransparency = 1; mainBtn.Text = ""
    
    local label = Instance.new("TextLabel", mainBtn)
    label.Size = UDim2.new(1, -30, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1; label.Text = config.Text or "Multi Dropdown"
    label.TextColor3 = Color3.fromRGB(220, 220, 240); label.Font = Enum.Font.GothamSemibold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", mainBtn)
    valLabel.Size = UDim2.new(0, 160, 1, 0); valLabel.Position = UDim2.new(1, -185, 0, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Text = "Pilih..."
    valLabel.TextColor3 = Color3.fromRGB(80, 255, 120); valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 9
    valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    local arrow = Instance.new("TextLabel", mainBtn)
    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▼"; arrow.TextColor3 = Color3.fromRGB(200, 200, 200); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 10
    
    local dropFrame = Instance.new("ScrollingFrame", container)
    dropFrame.Size = UDim2.new(1, 0, 1, -30); dropFrame.Position = UDim2.new(0, 0, 0, 30); dropFrame.BackgroundTransparency = 1
    dropFrame.ScrollBarThickness = 4; dropFrame.BorderSizePixel = 0
    dropFrame.CanvasSize = UDim2.new(0, 0, 0, 0); dropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local list = Instance.new("UIListLayout", dropFrame); list.SortOrder = Enum.SortOrder.LayoutOrder

    local isOpen = false
    local function toggle()
        isOpen = not isOpen
        local targetHeight = isOpen and (30 + (math.min(#options, 6) * 25)) or 30 
        if targetHeight > 200 then targetHeight = 200 end
        TweenService:Create(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        arrow.Text = isOpen and "▲" or "▼"
    end
    mainBtn.MouseButton1Click:Connect(toggle)

    local function updateLabel()
        if #selected == 0 then valLabel.Text = "Pilih..." else valLabel.Text = table.concat(selected, ", ") end
        callback(selected)
    end
    
    local function updateOptions(newOptions)
        for _, c in pairs(dropFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        options = newOptions
        
        local newSelected = {}
        for _, s in ipairs(selected) do
            if table.find(options, s) then table.insert(newSelected, s) end
        end
        selected = newSelected
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropFrame)
            optBtn.Size = UDim2.new(1, 0, 0, 25); optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            optBtn.BackgroundTransparency = 0.5; optBtn.BorderSizePixel = 0; optBtn.Text = "  " .. opt
            optBtn.TextColor3 = table.find(selected, opt) and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(200, 200, 200)
            optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 10; optBtn.TextXAlignment = Enum.TextXAlignment.Left; optBtn.LayoutOrder = i
            
            optBtn.MouseButton1Click:Connect(function()
                local idx = table.find(selected, opt)
                if idx then
                    table.remove(selected, idx)
                    optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                else
                    table.insert(selected, opt)
                    optBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
                end
                updateLabel()
            end)
        end
        updateLabel()
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

Library._SectionMethods.AddParagraph = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local container = Instance.new("Frame", self.Frame)
    container.Size = UDim2.new(1, 0, 0, 120) 
    container.BackgroundTransparency = 1; container.LayoutOrder = self._elementOrder
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -16, 1, 0); label.Position = UDim2.new(0, 8, 0, 0); label.BackgroundTransparency = 1
    label.Text = config.Text or ""; label.TextColor3 = config.Color or Color3.fromRGB(80, 255, 120)
    label.Font = Enum.Font.GothamBold; label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left; label.TextYAlignment = Enum.TextYAlignment.Top
    local api = {}
    function api:SetText(newText) label.Text = newText end
    return api
end

Library._SectionMethods.AddButton = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 30); container.LayoutOrder = self._elementOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = config.Text or "Button"
    if config.Color then btn.TextColor3 = config.Color else btn.TextColor3 = Color3.fromRGB(220, 220, 240) end
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 11
    btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
end

Library._SectionMethods.AddToggle = function(self, config)
    self._elementOrder = self._elementOrder + 1
    local state = config.Default or false
    local callback = config.Callback or function() end

    local container = Instance.new("Frame", self.Frame)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 48); container.BackgroundTransparency = 0.3
    container.Size = UDim2.new(1, 0, 0, 30); container.LayoutOrder = self._elementOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -40, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1; label.Text = config.Text or "Toggle"
    label.TextColor3 = Color3.fromRGB(220, 220, 240); label.Font = Enum.Font.GothamSemibold; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left

    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 30, 0, 16); switchBg.Position = UDim2.new(1, -38, 0.5, -8)
    switchBg.BackgroundColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local TweenService = game:GetService("TweenService")
    
    local api = {}
    function api:SetValue(newState)
        state = newState
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(60, 60, 70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        callback(state)
    end
    
    btn.MouseButton1Click:Connect(function() api:SetValue(not state) end)
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
-- 2. SETUP CUSTOM UI NOTIFICATION (DETACHED)
-- ==========================================
local function MigiiNotify(title, text, duration)
    task.spawn(function()
        local GUI_Target = CoreGui:FindFirstChild("RobloxGui") or CoreGui
        local NotifContainer = GUI_Target:FindFirstChild("MigiiNotifContainer")
        
        if not NotifContainer then
            NotifContainer = Instance.new("ScreenGui")
            NotifContainer.Name = "MigiiNotifContainer"
            NotifContainer.Parent = GUI_Target
            
            local ContainerFrame = Instance.new("Frame")
            ContainerFrame.Name = "Container"
            ContainerFrame.Size = UDim2.new(0, 250, 1, -20)
            ContainerFrame.Position = UDim2.new(1, -20, 0, 10)
            ContainerFrame.AnchorPoint = Vector2.new(1, 0)
            ContainerFrame.BackgroundTransparency = 1
            ContainerFrame.Parent = NotifContainer
            
            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            UIListLayout.Padding = UDim.new(0, 10)
            UIListLayout.Parent = ContainerFrame
        end
        
        duration = duration or 3
        local container = NotifContainer.Container
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        frame.BackgroundTransparency = 0.1
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local glow = Instance.new("UIStroke")
        glow.Color = Color3.fromRGB(80, 255, 120)
        glow.Thickness = 1
        glow.Parent = frame
        
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -20, 0, 20)
        titleLbl.Position = UDim2.new(0, 10, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = frame
        
        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -20, 0, 30)
        msgLbl.Position = UDim2.new(0, 10, 0, 25)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = text
        msgLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextSize = 12
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped = true
        msgLbl.Parent = frame
        
        frame.Parent = container
        
        frame.Position = UDim2.new(1, 300, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        
        task.wait(duration)
        
        local fade = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        TweenService:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(msgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {Transparency = 1}):Play()
        fade:Play()
        fade.Completed:Wait()
        frame:Destroy()
    end)
end

-- ==========================================
-- 3. SETUP VARIABEL, JSON WEBHOOK & DASHBOARD
-- ==========================================
getgenv().NextTargetReady = false
getgenv().FarmStats = {} 
getgenv().WebhookMessageIDs = {} 

local SettingsFile = fullFolderPath .. "/MigiiSettings.json"
getgenv().WebhookURL = ""
getgenv().UseWebhook = false

local function SaveSettings()
    if writefile then
        pcall(function() 
            local data = { URL = getgenv().WebhookURL, Toggle = getgenv().UseWebhook }
            writefile(SettingsFile, HttpService:JSONEncode(data)) 
        end)
    end
end

if isfile and isfile(SettingsFile) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(SettingsFile))
        if data then
            getgenv().WebhookURL = data.URL or ""
            getgenv().UseWebhook = data.Toggle or false
        end
    end)
end

local function getMoneyNum()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local moneyObj = stats:FindFirstChild("Uang") or stats:FindFirstChild("Money") or stats:FindFirstChild("Cash") or stats:FindFirstChild("Coin") or stats:FindFirstChild("Coins")
        if moneyObj then return tonumber(moneyObj.Value) or 0 end
    end
    return 0
end

local function SendToWebhook(itemName, weightStr)
    if not getgenv().UseWebhook or getgenv().WebhookURL == "" then return end
    task.spawn(function()
        local url = getgenv().WebhookURL
        local count = getgenv().FarmStats[itemName] or 1
        local money = getMoneyNum()
        local timeStr = os.date("%H:%M:%S")
        
        local data = {
            ["username"] = "MIGII-HUB REPORT",
            ["avatar_url"] = "https://tr.rbxcdn.com/132319281050903/150/150/Image/Png",
            ["embeds"] = {{
                ["title"] = "🚜 Farm Update: " .. tostring(itemName),
                ["description"] = "**Item Terakhir:** " .. tostring(itemName) .. "\n**Berat / Jumlah:** " .. tostring(weightStr) .. "\n**Total Dikumpulkan:** " .. tostring(count) .. "\n\n**👤 Player Info**\n**Nama:** " .. LocalPlayer.DisplayName .. "\n**Username:** @" .. LocalPlayer.Name .. "\n**💰 Uang:** Rp " .. tostring(money),
                ["color"] = 16766720, 
                ["footer"] = {["text"] = "Map: Desa Rayap | Jam: " .. timeStr}
            }}
        }
        
        local req = syn and syn.request or http and http.request or request or http_request
        if not req then return end
        
        local messageId = getgenv().WebhookMessageIDs[itemName]
        if messageId then
            local editUrl = url .. "/messages/" .. messageId
            pcall(function() req({Url = editUrl, Method = "PATCH", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end)
        else
            local postUrl = url .. "?wait=true"
            local s, r = pcall(function() return req({Url = postUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end)
            if s and r and r.Body then
                local s2, decoded = pcall(function() return HttpService:JSONDecode(r.Body) end)
                if s2 and decoded and decoded.id then getgenv().WebhookMessageIDs[itemName] = decoded.id end
            end
        end
    end)
end

local function TestWebhook()
    task.spawn(function()
        if getgenv().WebhookURL == "" then MigiiNotify("Webhook", "URL masih kosong!", 3) return end
        local data = {
            ["username"] = "MIGII-HUB REPORT",
            ["avatar_url"] = "https://tr.rbxcdn.com/132319281050903/150/150/Image/Png",
            ["content"] = "✅ **Test Webhook Berhasil!** MigiiHub sukses terkoneksi ke channel ini."
        }
        local req = syn and syn.request or http and http.request or request or http_request
        if req then
            local s, r = pcall(function() return req({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end)
            if s then MigiiNotify("Webhook", "Test berhasil dikirim ke Discord!", 3) else MigiiNotify("Webhook", "Gagal mengirim test!", 3) end
        else
            MigiiNotify("Webhook", "Executor tidak support HTTP Request", 3)
        end
    end)
end

-- ==========================================
-- 3.5. INTEGRASI SMART FARM (KEBUN CONFIG)
-- ==========================================
local KebunConfig = nil

task.spawn(function()
    local success, result = pcall(function()
        local module = ReplicatedStorage:WaitForChild("Kebun", 5):WaitForChild("KebunConfig", 5)
        return require(module)
    end)
    if success and type(result) == "table" then
        KebunConfig = result
    end
end)

local function CanPlantSeed(seedName)
    if not KebunConfig then return true, 0 end
    local currentLevel = 0
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Level") then
        currentLevel = tonumber(stats.Level.Value) or 0
    end
    for _, plant in ipairs(KebunConfig.Plants) do
        if plant.name == seedName then
            return currentLevel >= plant.minLevel, plant.minLevel
        end
    end
    return true, 0
end

local function CalculateProfit(cropName, amount)
    if not KebunConfig then return "???" end
    local sellPrice = KebunConfig.GetSellPrice(cropName)
    if sellPrice then
        return tostring(sellPrice * amount)
    end
    return "???"
end

-- Listener Tas dengan ANTI-DOUBLE NOTIF (MigiiProcessed)
LocalPlayer:WaitForChild("Backpack").ChildAdded:Connect(function(item)
    if item:GetAttribute("MigiiProcessed") then return end 
    
    if (getgenv().AutoFarmBesi or getgenv().AutoFarmBelut) and item:IsA("Tool") then
        local weight = item:GetAttribute("WeightKg")
        if weight then
            item:SetAttribute("MigiiProcessed", true)
            local formattedWeight = string.format("%.2f", weight) .. " kg"
            
            local cleanName = item.Name
            local matchName = string.match(cleanName, "^(.-)%s*x%d+$")
            if matchName then cleanName = matchName end
            
            getgenv().FarmStats[cleanName] = (getgenv().FarmStats[cleanName] or 0) + 1 
            SendToWebhook(cleanName, formattedWeight)
            MigiiNotify("Farm Sukses", cleanName .. " (" .. formattedWeight .. ")", 2)
            getgenv().NextTargetReady = true
        elseif item.Name == "Belut" or item:GetAttribute("Belut") then
            item:SetAttribute("MigiiProcessed", true)
            getgenv().FarmStats["Belut"] = (getgenv().FarmStats["Belut"] or 0) + 1
            SendToWebhook("Belut", "1 Ekor")
            MigiiNotify("Farm Sukses", "Berhasil menangkap Belut!", 2)
            getgenv().NextTargetReady = true
        end
    end
end)

local TargetList = {
    "Auto Semua (Terdekat)", "Antena", "Besi Balok", "Besi Hitam", "Besi Panjang", "Cermin Cembung", 
    "Gerbang", "Jemuran", "Kursi", "Lampu Jalan", "Meja", "Mobil Biru", 
    "Mobil Merah", "Motor Supra", "Pagar", "Pagar Karat", "Pagar Putih", 
    "Pager", "Pager Besi", "Pipa Besi", "Pipa Kolam", "Pipa Panjang", 
    "Rak Besi", "Rell Kereta", "Sign Jalan", "Stop Sign", "Tiang Bengkel", 
    "TiangListrik", "Tong Sampah", "Trafo PLN", "Velg Supra", "cerca", "vedet"
}

local RodShopData = {
    ["Pancingan Kayu (50.000)"] = {"Pancingan Kayu", 50000},
    ["Wortel Rod (100.000)"] = {"Wortel Rod", 100000},
    ["Rod Galatama (300.000)"] = {"Rod Galatama", 300000},
    ["Blood Rod (700.000)"] = {"Blood Rod", 700000},
    ["Musica Rod (3.000.000)"] = {"Musica Rod", 3000000},
    ["Zeus Rod (7.000.000)"] = {"Zeus Rod", 7000000}
}
local RodList = {"Pancingan Kayu (50.000)", "Wortel Rod (100.000)", "Rod Galatama (300.000)", "Blood Rod (700.000)", "Musica Rod (3.000.000)", "Zeus Rod (7.000.000)"}

local SawShopData = {
    ["Hacksaw (50.000)"] = {"Hacksaw", 50000},
    ["Amok Saw (300.000)"] = {"Amok Saw", 300000},
    ["Pinky ChainSaw (800.000)"] = {"Pinky ChainSaw", 800000},
    ["Flare Jigsaw (1.000.000)"] = {"Flare Jigsaw", 1000000},
    ["Frost Saw (3.000.000)"] = {"Frost Saw", 3000000},
    ["Sharky Saw (7.000.000)"] = {"Sharky Saw", 7000000}
}
local SawList = {"Hacksaw (50.000)", "Amok Saw (300.000)", "Pinky ChainSaw (800.000)", "Flare Jigsaw (1.000.000)", "Frost Saw (3.000.000)", "Sharky Saw (7.000.000)"}

local SeedList = {"Bibit Padi", "Bibit Jagung", "Bibit Wortel", "Bibit Tomat", "Bibit Terong", "Bibit Sawit", "Bibit Kelapa", "Bibit Pisang"}
local CropList = {"Padi", "Jagung", "Wortel", "Tomat", "Terong", "Sawit", "Kelapa", "Pisang"}

local KolamCoords = {
    ["Kolam galatama"] = CFrame.new(-192.7, 5.5, 116.5, -0.37, 0, -0.93, 0, 1, 0, 0.93, 0, -0.37),
    ["empang pak ahmad"] = CFrame.new(-112.82, 5.22, -93.91),
    ["kolam ikan lele"] = CFrame.new(-188.88, 5.38, 34.32),
    ["kolam ikan mujaer"] = CFrame.new(-72.15, 6.90, 92.72)
}
local KolamList = {"Kolam galatama", "empang pak ahmad", "kolam ikan lele", "kolam ikan mujaer"}

local LahanList = {}
pcall(function()
    local areaFolder = workspace:FindFirstChild("AreaTanamFolder")
    if areaFolder then
        for _, plot in pairs(areaFolder:GetChildren()) do table.insert(LahanList, plot.Name) end
    end
end)

local TokoList = {"Jual Ikan", "Toko Pancing", "Toko Gergaji", "Jual Besi", "Toko Bibit", "Toko Hasil Tani"}

getgenv().SelectedTarget = TargetList[1]
getgenv().AutoFarmBesi = false
getgenv().AutoFarmBelut = false
getgenv().AutoSellBesi = false
getgenv().AutoSellBelut = false
getgenv().AutoSellIkan = false
getgenv().ESP_Cooldown = false

getgenv().AutoCast = false
getgenv().AutoWinMinigame = false
getgenv().AutoWinSmartBypass = false
getgenv().CastPower = 50 
getgenv().MinigameDelay = 3 
getgenv().SelectedKolam = KolamList[1]
getgenv().SelectedToko = TokoList[1]
getgenv().RodNameBuy = "Pancingan Kayu"
getgenv().RodPriceBuy = 50000
getgenv().SawNameBuy = "Hacksaw"
getgenv().SawPriceBuy = 50000

getgenv().AutoPlantSingle = false
getgenv().AutoPlantMulti = false
getgenv().AutoHarvestSekitar = false
getgenv().AutoHarvestTP = false
getgenv().AutoBuyBibit = false
getgenv().AutoSellTani = false
getgenv().BuyBibitAmount = 50
getgenv().SellTaniAmount = 50
getgenv().SeedName = SeedList[1]
getgenv().BuySeedName = SeedList[1]
getgenv().SellCropName = CropList[1]
getgenv().SelectedLahan = LahanList[1]

getgenv().AutoReturn = false
local lastDeathCFrame = nil
local lastEquippedToolName = nil
getgenv().TargetAvatar = ""
getgenv().TargetPlayerTP = ""

getgenv().ScannedSeeds = {}
getgenv().SelectedMultiSeeds = {}
getgenv().PlantPattern = "Kotak (Grid)"
getgenv().PlantSpacing = 3
getgenv().MaxPlantLimit = 40 

-- ==========================================
-- 4. LOGIKA TELEPORT & AUTO RETURN
-- ==========================================
local function teleportTo(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if typeof(target) == "Vector3" then
            hrp.CFrame = CFrame.new(target) * (hrp.CFrame - hrp.CFrame.Position)
        elseif typeof(target) == "CFrame" then
            hrp.CFrame = target
        end
    end
end

local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not hrp then return end
    task.spawn(function()
        task.wait(1.5) 
        if getgenv().AutoReturn and lastDeathCFrame then 
            char:PivotTo(lastDeathCFrame)
            if lastEquippedToolName then 
                local backpack = LocalPlayer:WaitForChild("Backpack", 5)
                if backpack then 
                    local toolToEquip = backpack:WaitForChild(lastEquippedToolName, 3)
                    if toolToEquip then humanoid:EquipTool(toolToEquip) end 
                end 
            end 
        end
    end)
    humanoid.Died:Connect(function() 
        if getgenv().AutoReturn then 
            lastDeathCFrame = hrp.CFrame
            local tool = char:FindFirstChildOfClass("Tool")
            lastEquippedToolName = tool and tool.Name or nil 
        end 
    end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

-- ==========================================
-- 5. LOGIKA FUNGSI AVATAR & HIDE STREAMER
-- ==========================================
local HistoryFile = fullFolderPath .. "/MigiiAvaHistory.json"
local UserIdCache = {}

local function getHistory()
    if isfile and isfile(HistoryFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(HistoryFile)) end)
        if success and type(data) == "table" and #data > 0 then return data end
    end 
    return {"Belum ada history"}
end

local function addHistory(name)
    if not writefile then return getHistory() end
    local history = getHistory()
    if history[1] == "Belum ada history" then table.remove(history, 1) end
    for i, v in ipairs(history) do if v == name then table.remove(history, i); break end end
    table.insert(history, 1, name)
    if #history > 10 then table.remove(history, 11) end
    pcall(function() writefile(HistoryFile, HttpService:JSONEncode(history)) end)
    return history
end

local function removeHistory(name)
    if not writefile then return getHistory() end
    local history = getHistory()
    for i, v in ipairs(history) do if v == name then table.remove(history, i); break end end
    if #history == 0 then table.insert(history, "Belum ada history") end
    pcall(function() writefile(HistoryFile, HttpService:JSONEncode(history)) end)
    return history
end

local function loadAvatar(targetName)
    if not targetName or targetName == "" then return false, "Username kosong!" end
    local userId = UserIdCache[targetName]
    if not userId then
        local success, result = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
        if not success then return false, "User tidak ditemukan!" end
        userId = result
        UserIdCache[targetName] = userId 
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
                LeftLeg = humanoidDesc.LeftLeg or 0, Accessories = {}
            }
            local addedIds = {}
            local function packClassicAcc(idString, accEnum)
                if type(idString) == "string" and idString ~= "" and idString ~= "0" then
                    for _, idStr in ipairs(idString:split(",")) do
                        local numId = tonumber(idStr)
                        if numId and not addedIds[numId] then
                            addedIds[numId] = true
                            table.insert(outfitData.Accessories, { Rotation = Vector3.new(0,0,0), AssetId = numId, Position = Vector3.new(0,0,0), Scale = Vector3.new(1,1,1), IsLayered = false, AccessoryType = accEnum })
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
                    local accData = { Rotation = acc.Rotation or Vector3.new(0,0,0), AssetId = acc.AssetId, Position = acc.Position or Vector3.new(0,0,0), Scale = acc.Scale or Vector3.new(1,1,1), IsLayered = acc.IsLayered or false, AccessoryType = acc.AccessoryType }
                    if accData.IsLayered then accData.Order = acc.Order or 1; accData.Puffiness = acc.Puffiness or 1 end
                    table.insert(outfitData.Accessories, accData)
                end
            end
            bloxbiz.CatalogOnApplyOutfit:FireServer(outfitData)
        end)
        return true, "Sukses Inject Full Outfit ke Server!"
    end
    return false, "Fitur Bloxbiz tidak ditemukan di map ini."
end

-- ==========================================
-- 6. LOGIKA STREAMER MODE (HIDE) & TITLE RGB
-- ==========================================
getgenv().fakeNickname = "MigiiHUB"
getgenv().fakeLevel = "Lv. 100"
getgenv().isHideActive = false
getgenv().RGBTitleActive = false

local function getRealLevel()
    local s, r = pcall(function() return tostring(LocalPlayer.leaderstats.Level.Value) end)
    return s and r or "0"
end

local function UpdateRGBTitle()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    if getgenv().RGBTitleActive and getgenv().isHideActive then
        if not head:FindFirstChild("MigiiRGBTitle") then
            local bgui = Instance.new("BillboardGui")
            bgui.Name = "MigiiRGBTitle"
            bgui.Size = UDim2.new(0, 200, 0, 50)
            bgui.StudsOffset = Vector3.new(0, 4.5, 0) 
            bgui.AlwaysOnTop = true
            bgui.Parent = head
            
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = "[MIGII-HUB]"
            txt.Font = Enum.Font.GothamBlack
            txt.TextSize = 20
            txt.TextStrokeTransparency = 0
            txt.Parent = bgui
            
            task.spawn(function()
                local hue = 0
                while bgui.Parent and getgenv().RGBTitleActive do
                    hue = hue + 0.02
                    if hue > 1 then hue = 0 end
                    txt.TextColor3 = Color3.fromHSV(hue, 1, 1)
                    task.wait(0.05)
                end
                if bgui and bgui.Parent then bgui:Destroy() end
            end)
        end
    else
        if head:FindFirstChild("MigiiRGBTitle") then head.MigiiRGBTitle:Destroy() end
    end
end

local function ApplyFakeUI()
    local realName = LocalPlayer.DisplayName
    local realUsername = LocalPlayer.Name
    local realLevelVal = getRealLevel()
    local char = LocalPlayer.Character
    
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.DisplayName = getgenv().fakeNickname end
    UpdateRGBTitle()
    
    local function applyText(gui)
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if not gui:FindFirstAncestor("MigiiNotifContainer") and not gui:FindFirstAncestor("MigiiHUB") then
                local txt = gui.Text
                local changed = false
                
                if string.find(txt, realName, 1, true) and realName ~= "" then
                    txt = string.gsub(txt, realName, getgenv().fakeNickname)
                    changed = true
                elseif string.find(txt, realUsername, 1, true) and realUsername ~= "" then
                    txt = string.gsub(txt, realUsername, getgenv().fakeNickname)
                    changed = true
                end
                
                if getgenv().fakeLevel ~= "" then
                    local newText = string.gsub(txt, "[Ll][Ee][Vv][Ee][Ll]%s*:?%s*%d+", getgenv().fakeLevel)
                    newText = string.gsub(newText, "[Ll][Vv]%.?%s*%d+", getgenv().fakeLevel)
                    if newText ~= txt then txt = newText; changed = true end
                    
                    if txt == realLevelVal then txt = string.match(getgenv().fakeLevel, "%d+"); changed = true end
                end
                if changed then gui.Text = txt end
            end
        end
    end
    if char then for _, gui in ipairs(char:GetDescendants()) do applyText(gui) end end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then for _, gui in ipairs(pGui:GetDescendants()) do applyText(gui) end end
end

local function RestoreOriginalUI()
    local realName = LocalPlayer.DisplayName
    local realLevelVal = getRealLevel()
    local char = LocalPlayer.Character
    
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.DisplayName = realName end
    UpdateRGBTitle()
    
    local function revertText(gui)
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if not gui:FindFirstAncestor("MigiiNotifContainer") and not gui:FindFirstAncestor("MigiiHUB") then
                local txt = gui.Text
                local changed = false
                if getgenv().fakeNickname ~= "" and string.find(txt, getgenv().fakeNickname, 1, true) then
                    txt = string.gsub(txt, getgenv().fakeNickname, realName)
                    changed = true
                end
                if getgenv().fakeLevel ~= "" then
                    local newText = string.gsub(txt, getgenv().fakeLevel, "Level : " .. realLevelVal)
                    if newText ~= txt then txt = newText; changed = true end
                end
                if changed then gui.Text = txt end
            end
        end
    end
    if char then for _, gui in ipairs(char:GetDescendants()) do revertText(gui) end end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then for _, gui in ipairs(pGui:GetDescendants()) do revertText(gui) end end
end

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().isHideActive then ApplyFakeUI() end
    end
end)

-- ==========================================
-- 7. LOGIKA MANCING & SMART AUTO PLANT
-- ==========================================
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.1) do
        if getgenv().AutoWinMinigame then
            local minigameUI = PlayerGui:FindFirstChild("MiniGameGUI")
            if minigameUI then
                task.wait(getgenv().MinigameDelay) 
                while PlayerGui:FindFirstChild("MiniGameGUI") and getgenv().AutoWinMinigame do
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("MiniGame") then pcall(function() remotes.MiniGame:FireServer(true) end) end
                    task.wait(0.15 + (math.random(1, 5) / 100)) 
                end
                task.wait(1.5)
            end
        end
    end
end)

-- ==========================================
-- [FITUR BARU] AUTO MANCING FULL (CAST + SMART BYPASS)
-- ==========================================
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    while task.wait(0.5) do
        if getgenv().AutoWinSmartBypass then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            
            -- 1. Panggil otak minigame aslinya & Pastikan AutoMode NYALA
            local success, MiniGameHandler = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Modules_C", 3):WaitForChild("MiniGameHandler", 3))
            end)
            
            if success and type(MiniGameHandler) == "table" then
                if not MiniGameHandler.AutoMode then
                    MiniGameHandler.ToggleAuto()
                end
            end

            -- 2. Pastikan lagi megang pancingan
            if tool and (string.find(string.lower(tool.Name), "rod") or string.find(string.lower(tool.Name), "pancingan")) then
                
                -- 3. Cek kalau UI Minigame belum muncul, kita lempar kail
                if not PlayerGui:FindFirstChild("MiniGameGUI") then
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("CastEvent") then
                        -- Lempar kail sesuai Cast Power
                        pcall(function() 
                            remotes.CastEvent:FireServer(true)
                            task.wait(1)
                            remotes.CastEvent:FireServer(false, getgenv().CastPower) 
                        end)
                        
                        -- Tunggu sampai UI minigame muncul (maksimal 15 detik nunggu ikan)
                        local waitTime = 0
                        while getgenv().AutoWinSmartBypass and waitTime < 15 do 
                            if PlayerGui:FindFirstChild("MiniGameGUI") then break end
                            task.wait(0.5)
                            waitTime = waitTime + 0.5 
                        end
                        
                        -- 4. Pas UI minigame muncul, biarin script bypass yang kerja otomatis
                        while PlayerGui:FindFirstChild("MiniGameGUI") and getgenv().AutoWinSmartBypass do 
                            task.wait(0.5) 
                        end
                        
                        -- Jeda dikit sebelum otomatis lempar kail lagi (biar natural)
                        task.wait(2.5)
                    end
                end
            end
        else
            -- Kalau tombol dimatiin, matiin juga AutoMode bawaan gamenya
            local success, MiniGameHandler = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Modules_C", 3):WaitForChild("MiniGameHandler", 3))
            end)
            if success and type(MiniGameHandler) == "table" then
                if MiniGameHandler.AutoMode then
                    MiniGameHandler.ToggleAuto()
                end
            end
        end
    end
end)

-- =================

task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.5) do
        if getgenv().AutoCast then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and (string.find(string.lower(tool.Name), "rod") or string.find(string.lower(tool.Name), "pancingan")) then
                if not PlayerGui:FindFirstChild("MiniGameGUI") then
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("CastEvent") then
                        pcall(function() remotes.CastEvent:FireServer(true); task.wait(1); remotes.CastEvent:FireServer(false, getgenv().CastPower) end)
                        local waitTime = 0
                        while getgenv().AutoCast and waitTime < 15 do if PlayerGui:FindFirstChild("MiniGameGUI") then break end; task.wait(0.5); waitTime = waitTime + 0.5 end
                        while PlayerGui:FindFirstChild("MiniGameGUI") and getgenv().AutoCast do task.wait(0.5) end
                        task.wait(2.5)
                    end
                end
            end
        end
    end
end)

local function countMyPlants()
    local count = 0
    local myUserId = tostring(LocalPlayer.UserId)
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            if string.find(obj.Name, myUserId) then
                count = count + 1
            end
        end
    end
    return count
end

local function getNearestPlot()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    local areaFolder = workspace:FindFirstChild("AreaTanamFolder")
    if areaFolder then
        for _, plot in pairs(areaFolder:GetChildren()) do
            if plot:IsA("BasePart") then
                local dist = (hrp.Position - plot.Position).Magnitude
                if dist < minDist then minDist = dist; nearest = plot end
            end
        end
    end
    if nearest and minDist <= 30 then return nearest end
    return nil
end

local function generatePatternPoints(plot, pattern, spacing, count)
    local points = {}
    local center = plot.Position + Vector3.new(0, plot.Size.Y/2, 0)
    local halfX = (plot.Size.X / 2) - 1.5 
    local halfZ = (plot.Size.Z / 2) - 1.5

    if pattern == "Menumpuk (Tengah)" then
        for i = 1, count do table.insert(points, center) end
    elseif pattern == "Kotak (Grid)" then
        local side = math.ceil(math.sqrt(count))
        local startX = -((side - 1) * spacing) / 2
        local startZ = -((side - 1) * spacing) / 2
        local n = 0
        for x = 0, side - 1 do
            for z = 0, side - 1 do
                if n >= count then break end
                local offsetX = math.clamp(startX + (x * spacing), -halfX, halfX)
                local offsetZ = math.clamp(startZ + (z * spacing), -halfZ, halfZ)
                local worldPoint = (plot.CFrame * CFrame.new(offsetX, plot.Size.Y/2, offsetZ)).Position
                table.insert(points, worldPoint)
                n = n + 1
            end
        end
    elseif pattern == "Lingkaran" then
        local radius = math.min(halfX, halfZ) - 1
        if radius < 1 then radius = 1 end
        for i = 1, count do
            local angle = (i / count) * math.pi * 2
            local offsetX = math.cos(angle) * radius
            local offsetZ = math.sin(angle) * radius
            local worldPoint = (plot.CFrame * CFrame.new(offsetX, plot.Size.Y/2, offsetZ)).Position
            table.insert(points, worldPoint)
        end
    end
    return points
end

local function getSeedTool(seedName)
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool and string.find(string.lower(tool.Name), string.lower(seedName)) then return tool end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(seedName)) then return t end
        end
    end
    return nil
end

local lastPlotNotify = 0
local lastMaxNotify = 0

local function executePlanting(mode)
    local targetPlot = getNearestPlot()
    if not targetPlot then 
        if tick() - lastPlotNotify > 5 then
            MigiiNotify("Tanam Gagal", "Berdirilah di dalam kotak lahanmu!", 3)
            lastPlotNotify = tick()
        end
        return
    end

    local currentPlants = countMyPlants()
    local limit = getgenv().MaxPlantLimit

    if currentPlants >= limit then
        if tick() - lastMaxNotify > 10 then
            MigiiNotify("Batas Tanam", "Standby... nunggu lahan kosong (" .. currentPlants .. "/" .. limit .. ")", 2)
            lastMaxNotify = tick()
        end
        return
    end

    local spotsNeeded = limit - currentPlants
    local points = generatePatternPoints(targetPlot, getgenv().PlantPattern, getgenv().PlantSpacing, spotsNeeded)
    local plantRemotes = ReplicatedStorage:FindFirstChild("PlantRemotes")
    if not plantRemotes or not plantRemotes:FindFirstChild("PlantSeed") then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    
    local syncCount = currentPlants

    if mode == "Single" then
        local seedName = getgenv().SeedName
        
        -- CEK LEVEL DULU SEBELUM EQUIP TOOL
        local isAllowed, reqLevel = CanPlantSeed(seedName)
        if not isAllowed then
            MigiiNotify("Level Kurang!", "Bibit " .. seedName .. " butuh Level " .. reqLevel, 3)
            getgenv().AutoPlantSingle = false 
            return
        end

        for i, point in ipairs(points) do
            if not getgenv().AutoPlantSingle then break end
            if syncCount >= limit then break end 
            
            local tool = getSeedTool(seedName)
            if not tool then MigiiNotify("Habis", seedName .. " tidak ditemukan di tas!", 2) break end
            
            local currentTool = char:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool ~= tool then
                hum:EquipTool(tool)
                task.wait(0.5) 
            end
            
            pcall(function() plantRemotes.PlantSeed:FireServer(seedName, point) end)
            syncCount = syncCount + 1 
            task.wait(0.8) 
        end
        
    elseif mode == "Multi" then
        local scanned = getgenv().SelectedMultiSeeds
        if #scanned == 0 then
            if tick() - lastMaxNotify > 5 then
                MigiiNotify("Multi Seed", "Pilih minimal 1 bibit di Dropdown!", 2)
                lastMaxNotify = tick()
            end
            getgenv().AutoPlantMulti = false
            return
        end
        
        local seedIndex = 1
        for i, point in ipairs(points) do
            if not getgenv().AutoPlantMulti then break end
            if syncCount >= limit then break end 
            
            local seedName = scanned[seedIndex]
            
            -- Pengecekan Level Smart Farm
            local isAllowed, reqLevel = CanPlantSeed(seedName)
            local skipCount = 0
            while not isAllowed and skipCount < #scanned do
                MigiiNotify("Skip", seedName .. " butuh Lv " .. reqLevel, 2)
                seedIndex = seedIndex + 1
                if seedIndex > #scanned then seedIndex = 1 end
                seedName = scanned[seedIndex]
                isAllowed, reqLevel = CanPlantSeed(seedName)
                skipCount = skipCount + 1
            end
            
            if not isAllowed then 
                MigiiNotify("Gagal", "Semua bibit di tas butuh level yang lebih tinggi!", 3)
                getgenv().AutoPlantMulti = false
                break
            end

            local tool = getSeedTool(seedName)
            local attempts = 0
            while not tool and attempts < #scanned do
                seedIndex = seedIndex + 1
                if seedIndex > #scanned then seedIndex = 1 end
                seedName = scanned[seedIndex]
                tool = getSeedTool(seedName)
                attempts = attempts + 1
            end
            
            if not tool then MigiiNotify("Habis", "Semua bibit yang dipilih habis!", 2) break end
            
            local currentTool = char:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool ~= tool then
                hum:EquipTool(tool)
                task.wait(0.5) 
            end
            
            pcall(function() plantRemotes.PlantSeed:FireServer(seedName, point) end)
            syncCount = syncCount + 1 
            task.wait(0.8) 
            
            seedIndex = seedIndex + 1
            if seedIndex > #scanned then seedIndex = 1 end
        end
    end
end

local plantLoopActive = false
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoPlantSingle and not plantLoopActive then
            plantLoopActive = true
            executePlanting("Single")
            plantLoopActive = false
        elseif getgenv().AutoPlantMulti and not plantLoopActive then
            plantLoopActive = true
            executePlanting("Multi")
            plantLoopActive = false
        end
    end
end)

-- AUTO HARVEST STRICT (Hanya Milik Sendiri dari UserId)
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoHarvestSekitar then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local myUserId = tostring(LocalPlayer.UserId)
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not getgenv().AutoHarvestSekitar then break end
                    if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" and obj.Enabled then
                        if string.find(obj:GetFullName(), myUserId) then
                            local part = obj.Parent
                            if part and (part:IsA("BasePart") or part:IsA("Attachment")) then
                                local targetPos = part:IsA("Attachment") and part.WorldPosition or part.Position
                                if (hrp.Position - targetPos).Magnitude <= 15 then
                                    if fireproximityprompt then fireproximityprompt(obj, 1, true) else obj.HoldDuration = 0; obj:InputHoldBegin(); task.wait(0.1); obj:InputHoldEnd() end
                                    task.wait(0.3) 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoHarvestTP then
            local myUserId = tostring(LocalPlayer.UserId)
            for _, obj in pairs(workspace:GetDescendants()) do
                if not getgenv().AutoHarvestTP then break end
                if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" and obj.Enabled then
                    if string.find(obj:GetFullName(), myUserId) then
                        local part = obj.Parent
                        if part and (part:IsA("BasePart") or part:IsA("Attachment")) then
                            local targetPos = part:IsA("Attachment") and part.WorldPosition or part.Position
                            teleportTo(targetPos + Vector3.new(0, 3, 0))
                            task.wait(0.3)
                            if fireproximityprompt then fireproximityprompt(obj, 1, true) else obj.HoldDuration = 0; obj:InputHoldBegin(); task.wait(0.1); obj:InputHoldEnd() end
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if getgenv().AutoBuyBibit then
            local remotes = ReplicatedStorage:FindFirstChild("ProgressRemotes")
            if remotes and remotes:FindFirstChild("BuyBibit") then pcall(function() remotes.BuyBibit:FireServer(getgenv().BuySeedName, getgenv().BuyBibitAmount) end) end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if getgenv().AutoSellTani then
            local remotes = ReplicatedStorage:FindFirstChild("ProgressRemotes")
            if remotes and remotes:FindFirstChild("OnJual") then pcall(function() remotes.OnJual:FireServer(getgenv().SellCropName, getgenv().SellTaniAmount) end) end
        end
    end
end)

-- ==========================================
-- 8. LOGIKA ESP & AUTO SELL DENGAN KALKULATOR PROFIT
-- ==========================================
getgenv().ESP_Plant = false

local function getPlantESPName(prompt)
    local model = prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Parent
    if model and model:IsA("Model") then
        local crop = string.match(model.Name, "^([^_]+)_planted")
        if crop then return crop end
    end
    return "Tanaman"
end

local function getRealObjectName(obj)
    if obj.Name == "BelutPrompt" then return "Belut" end
    local possibleNames = {obj.ObjectText, obj.Parent and obj.Parent.Name, obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name}
    for _, target in ipairs(TargetList) do
        if target ~= "Auto Semua (Terdekat)" then
            for _, nameVariant in ipairs(possibleNames) do
                if type(nameVariant) == "string" and string.find(string.lower(nameVariant), string.lower(target)) then return target end
            end
        end
    end
    if obj.ObjectText and obj.ObjectText ~= "" then return obj.ObjectText end
    if obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name ~= "Workspace" then return obj.Parent.Parent.Name end
    return "Barang Farm"
end

local function FormatWaktu(seconds)
    if seconds <= 0 then return "0s" end
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    if m > 0 then
        return string.format("%dm %ds", m, s)
    else
        return string.format("%ds", s)
    end
end

-- Cache manual sudah dikurangi 1 fase agar akurat (Total Fase - 1)
local PlantTimerCache = {
    ["Padi"] = 60,
    ["Jagung"] = 120,
    ["Tomat"] = 240,
    ["Terong"] = 360,
    ["Sawit"] = 600,
    ["Kelapa"] = 600,
    ["Pisang"] = 600
}

task.spawn(function()
    local myUserId = tostring(LocalPlayer.UserId)
    local MyPlantTimers = {} 
    
    while task.wait(1) do
        local currentTime = tick()

        -- Bersihkan memori dari tanaman yang sudah dipanen / dicabut
        -- Kalau posisi tersebut tidak terdeteksi selama lebih dari 5 detik, hapus dari memori
        for key, data in pairs(MyPlantTimers) do
            if currentTime - data.LastSeen > 5 then
                MyPlantTimers[key] = nil
            end
        end

        -- 1. LOGIKA ESP BARANG / BELUT / COOLDOWN
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and (obj.Name == "GatherPrompt" or obj.Name == "BelutPrompt") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local realName = getRealObjectName(obj)
                    local espName = "MigiiESP_Custom"
                    local existingEsp = part:FindFirstChild(espName)
                    
                    if getgenv().ESP_Cooldown then
                        local color = obj.Enabled and "rgb(80,255,120)" or "rgb(255,100,150)"
                        local statusText = "Ready"
                        local defaultRespawnUI = part:FindFirstChild("RespawnCountdown")
                        if defaultRespawnUI then 
                            defaultRespawnUI.Enabled = false 
                            local txtLbl = defaultRespawnUI:FindFirstChildOfClass("TextLabel")
                            if txtLbl and txtLbl.Text ~= "" then statusText = txtLbl.Text else statusText = "Cooldown" end
                        elseif not obj.Enabled then
                            statusText = "Cooldown"
                        end
                        
                        local richTextString = string.format([[<font size="24" face="GothamBlack" color="%s">%s</font>
<font size="12" face="GothamBold" color="%s">[%s]</font>]], color, realName, color, statusText)

                        if not existingEsp then
                            local bgui = Instance.new("BillboardGui", part); bgui.Name = espName; bgui.Size = UDim2.new(0, 300, 0, 70); bgui.StudsOffset = Vector3.new(0, 4, 0); bgui.AlwaysOnTop = true; bgui.MaxDistance = 99999
                            local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.RichText = true; txt.TextStrokeTransparency = 0
                            txt.Text = richTextString
                        else
                            local txt = existingEsp:FindFirstChildOfClass("TextLabel")
                            if txt then txt.Text = richTextString end
                        end
                    else
                        if existingEsp then existingEsp:Destroy() end
                        local defaultRespawnUI = part:FindFirstChild("RespawnCountdown")
                        if defaultRespawnUI then defaultRespawnUI.Enabled = true end
                    end
                end
            end
        end

        -- 2. LOGIKA KHUSUS ESP TANAMAN (TRACKING KORDINAT POSISI)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and string.find(obj.Name, myUserId) and string.find(obj.Name, "_planted") then
                local cropName = string.match(obj.Name, "^([^_]+)_planted") or "Tanaman"
                local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart") 
                
                if part then
                    -- Gunakan kordinat X dan Z yang dibulatkan sebagai ID Timer
                    local posKey = tostring(math.round(part.Position.X)) .. "_" .. tostring(math.round(part.Position.Z))
                    
                    if not MyPlantTimers[posKey] then
                        local totalDurasi = PlantTimerCache[cropName] or 60
                        
                        -- Tarik data dinamis dari KebunConfig kalau ada
                        if KebunConfig and KebunConfig.Plants then
                            for _, pData in ipairs(KebunConfig.Plants) do
                                if pData.crop == cropName then
                                    -- Kurangi 1 karena fase terakhir adalah status siap panen
                                    totalDurasi = pData.faseTimer * (pData.totalFase - 1)
                                    break
                                end
                            end
                        end
                        
                        MyPlantTimers[posKey] = {
                            SpawnTime = tick(),
                            Durasi = totalDurasi,
                            LastSeen = currentTime
                        }
                    else
                        -- Update waktu LastSeen agar tidak dihapus oleh pembersih memori di atas
                        MyPlantTimers[posKey].LastSeen = currentTime
                    end
                    
                    local espName = "MigiiESP_Plant"
                    local existingEsp = part:FindFirstChild(espName)
                    
                    if getgenv().ESP_Plant then
                        local harvestPrompt = obj:FindFirstChild("HarvestPrompt", true)
                        local isReady = harvestPrompt and harvestPrompt.Enabled
                        
                        local elapsed = currentTime - MyPlantTimers[posKey].SpawnTime
                        local remaining = math.ceil(MyPlantTimers[posKey].Durasi - elapsed)
                        
                        -- EDIT WARNA DISINI
                        local nameColor = ""
                        local statusColor = ""
                        local statusText = ""
                        
                        -- Kalau timer habis atau prompt panen muncul, ubah ke hijau
                        if isReady or remaining <= 0 then
                            nameColor = "rgb(80,255,120)" -- Hijau Siap Panen
                            statusColor = "rgb(80,255,120)" -- Hijau Siap Panen
                            statusText = "Siap Panen"
                        else
                            nameColor = "rgb(255,105,180)" -- Pink Terang untuk Nama saat Tumbuh
                            statusColor = "rgb(255,255,255)" -- Putih untuk teks status "Tumbuh"
                            statusText = "Tumbuh (" .. FormatWaktu(remaining) .. ")"
                        end
                        
                        -- Gunakan nameColor untuk Nama, statusColor untuk Status
                        local richTextString = string.format([[<font size="24" face="GothamBlack" color="%s">%s</font>
<font size="12" face="GothamBold" color="%s">[%s]</font>]], nameColor, cropName, statusColor, statusText)

                        if not existingEsp then
                            local bgui = Instance.new("BillboardGui", part); bgui.Name = espName; bgui.Size = UDim2.new(0, 300, 0, 70); bgui.StudsOffset = Vector3.new(0, 5, 0); bgui.AlwaysOnTop = true; bgui.MaxDistance = 99999
                            local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.RichText = true; txt.TextStrokeTransparency = 0
                            txt.Text = richTextString
                        else
                            local txt = existingEsp:FindFirstChildOfClass("TextLabel")
                            if txt then txt.Text = richTextString end
                        end
                    else
                        if existingEsp then existingEsp:Destroy() end
                    end
                end
            end
        end
    end
end)

local function sellBesi()
    local jualEvent = ReplicatedStorage:FindFirstChild("JualBesiEvent")
    if jualEvent then 
        local bfr = getMoneyNum()
        pcall(function() jualEvent:FireServer("semua") end) 
        task.wait(0.5)
        local profit = getMoneyNum() - bfr
        if profit > 0 then MigiiNotify("Auto Sell Besi", "Sukses menjual besi!\nProfit: Rp " .. tostring(profit), 3) end
    end
end
local function sellBelut()
    local jualBelutEvent = ReplicatedStorage:FindFirstChild("JualBelutEvent")
    if jualBelutEvent then 
        local bfr = getMoneyNum()
        pcall(function() jualBelutEvent:FireServer("semua") end) 
        task.wait(0.5)
        local profit = getMoneyNum() - bfr
        if profit > 0 then MigiiNotify("Auto Sell Belut", "Sukses menjual belut!\nProfit: Rp " .. tostring(profit), 3) end
    end
end
local function sellIkan()
    local jualIkanEvent = ReplicatedStorage:FindFirstChild("JualIkanRemote")
    if jualIkanEvent then 
        local bfr = getMoneyNum()
        pcall(function() jualIkanEvent:FireServer("All") end) 
        task.wait(0.5)
        local profit = getMoneyNum() - bfr
        if profit > 0 then MigiiNotify("Auto Sell Ikan", "Sukses menjual ikan!\nProfit: Rp " .. tostring(profit), 3) end
    end
end

task.spawn(function()
    while task.wait(10) do 
        if getgenv().AutoSellBesi then sellBesi() end
        if getgenv().AutoSellBelut then sellBelut() end
        if getgenv().AutoSellIkan then sellIkan() end
    end
end)


local function startFarmBesi()
    task.spawn(function()
        while getgenv().AutoFarmBesi do
            task.wait(0.01)
            local targetName = getgenv().SelectedTarget
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not hrp or not humanoid then continue end

            local validTargets = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Name == "GatherPrompt" and obj.Enabled then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        local realName = getRealObjectName(obj) 
                        if targetName == "Auto Semua (Terdekat)" or realName == targetName then
                            table.insert(validTargets, {prompt = obj, part = part, dist = (hrp.Position - part.Position).Magnitude})
                        end
                    end
                end
            end
            
            if #validTargets > 0 then
                table.sort(validTargets, function(a, b) return a.dist < b.dist end)
                local bestTarget = validTargets[1]
                
                getgenv().NextTargetReady = false 
                teleportTo(bestTarget.part.Position + Vector3.new(0, 2, 0))
                task.wait(0.1) 
                
                local currentTool = char:FindFirstChildOfClass("Tool")
                if not (currentTool and (string.find(string.lower(currentTool.Name), "saw") or string.find(string.lower(currentTool.Name), "gergaji"))) then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "saw") or string.find(string.lower(tool.Name), "gergaji")) then
                                humanoid:EquipTool(tool)
                                task.wait(0.1)
                                break
                            end
                        end
                    end
                end
                
                if fireproximityprompt then fireproximityprompt(bestTarget.prompt, 1, true) else bestTarget.prompt:InputHoldBegin() end
                
                local timeout = 0
                while bestTarget.prompt and bestTarget.prompt.Enabled and getgenv().AutoFarmBesi and not getgenv().NextTargetReady and timeout < 300 do
                    task.wait(0.01) 
                    timeout = timeout + 1
                end
                if not fireproximityprompt then pcall(function() bestTarget.prompt:InputHoldEnd() end) end
            else 
                task.wait(0.5) 
            end
        end
    end)
end

local function startFarmBelut()
    task.spawn(function()
        while getgenv().AutoFarmBelut do
            task.wait(0.01)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local validTargets = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Name == "BelutPrompt" and obj.Enabled then
                    if string.find(string.lower(obj:GetFullName()), "jual") or string.find(string.lower(obj:GetFullName()), "npc") then continue end
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then table.insert(validTargets, {prompt = obj, part = part, dist = (hrp.Position - part.Position).Magnitude}) end
                end
            end
            
            if #validTargets > 0 then
                table.sort(validTargets, function(a, b) return a.dist < b.dist end)
                local bestTarget = validTargets[1]
                
                getgenv().NextTargetReady = false
                teleportTo(bestTarget.part.Position + Vector3.new(0, 2, 0))
                task.wait(0.1)
                
                if fireproximityprompt then fireproximityprompt(bestTarget.prompt, 1, true) else bestTarget.prompt:InputHoldBegin() end
                
                local timeout = 0
                while bestTarget.prompt and bestTarget.prompt.Enabled and getgenv().AutoFarmBelut and not getgenv().NextTargetReady and timeout < 300 do
                    task.wait(0.01); timeout = timeout + 1
                end
                if not fireproximityprompt then pcall(function() bestTarget.prompt:InputHoldEnd() end) end
            else 
                task.wait(0.5) 
            end
        end
    end)
end

-- ==========================================
-- 9. MEMBANGUN UI MIGIIHUB
-- ==========================================
Library.ShowMigiiLoader()
local LOGO_ID = "rbxthumb://type=Asset&id=132319281050903&w=150&h=150"
local Window = Library.new({Title = "MigiiHUB | " .. gameDisplayName, Size = UDim2.new(0, 480, 0, 320)})
Window:CreateToggleButton({ Icon = LOGO_ID })

local StatsTab = Window:AddTab({ Name = "Dashboard", Icon = "📊" })
local FarmTab = Window:AddTab({ Name = "Main Farm", Icon = "⛏️" })
local TaniTab = Window:AddTab({ Name = "Pertanian", Icon = "🌾" })
local FishTab = Window:AddTab({ Name = "Fishing", Icon = "🎣" })
local MiscTab = Window:AddTab({ Name = "ESP & Etc Fitur", Icon = "🎒" })
local TPTab = Window:AddTab({ Name = "Teleport", Icon = "🚀" })
local SellTab = Window:AddTab({ Name = "Shop & Sell", Icon = "💰" })
local VisualTab = Window:AddTab({ Name = "Hide", Icon = "👁️" })
local AvatarTab = Window:AddTab({ Name = "Avatar", Icon = "👤" })

-- [ DASHBOARD ]
local TrackingSection = StatsTab:AddSection({ Title = "Live Farm Tracker" })
local StatsDisplay = TrackingSection:AddParagraph({Text = "Menunggu proses farm dimulai..."})

task.spawn(function()
    while task.wait(1) do
        local displayString = ""
        local hasItem = false
        for item, count in pairs(getgenv().FarmStats) do
            displayString = displayString .. "• " .. item .. " : " .. tostring(count) .. "x\n"
            hasItem = true
        end
        if hasItem then StatsDisplay:SetText(displayString) end
    end
end)

local WebhookSection = StatsTab:AddSection({ Title = "Discord Webhook Logging" })
local webhookPlaceholder = (getgenv().WebhookURL ~= "") and "Webhook tersimpan (Ketik untuk ganti)" or "Silahkan masukan webhook nya..."

WebhookSection:AddInput({Text = "Webhook URL", Default = getgenv().WebhookURL, Placeholder = webhookPlaceholder, Callback = function(t) 
    if t then
        getgenv().WebhookURL = t
        SaveSettings()
        if t ~= "" then MigiiNotify("Webhook", "Webhook baru berhasil disimpan!", 2) end
    end
end})

WebhookSection:AddButton({Text = "🔔 Uji Coba Webhook (Test)", Callback = function() TestWebhook() end})

local WebhookToggleAPI = WebhookSection:AddToggle({Text = "✅ Aktifkan Webhook", Default = getgenv().UseWebhook, Callback = function(state) 
    getgenv().UseWebhook = state
    SaveSettings()
end})

WebhookSection:AddButton({Text = "🗑️ Reset Statistik", Callback = function() 
    getgenv().FarmStats = {}
    getgenv().WebhookMessageIDs = {} 
    StatsDisplay:SetText("Statistik direset ke nol.")
    MigiiNotify("Reset", "Data tracker dikosongkan.", 2)
end})

-- [ FARM BESI & BELUT ]
local BesiSection = FarmTab:AddSection({ Title = "Auto Farm Besi" })
BesiSection:AddDropdown({Text = "Pilih Target Farm Besi", Options = TargetList, Default = TargetList[1], Callback = function(val) getgenv().SelectedTarget = val end})
BesiSection:AddToggle({Text = "▶ START AUTO FARM BESI", Default = false, Callback = function(state) getgenv().AutoFarmBesi = state; if state then startFarmBesi() end end})

local BelutSection = FarmTab:AddSection({ Title = "Auto Farm Belut" })
BelutSection:AddToggle({Text = "🐍 START AUTO BELUT", Default = false, Callback = function(state) getgenv().AutoFarmBelut = state; if state then startFarmBelut() end end})

-- [ AVATAR ]
local AvaSection = AvatarTab:AddSection({ Title = "Change Your Avatar" })
local AvaInputAPI = AvaSection:AddInput({Text = "Target Username", Placeholder = "Ketik username...", Callback = function(t) getgenv().TargetAvatar = t end})
local PlayerDropdown = AvaSection:AddDropdown({Text = "Pilih Player", Options = {"Scan dulu..."}, Callback = function(s) if s ~= "Scan dulu..." and s ~= "Kosong (Cuma kamu)" then getgenv().TargetAvatar = s; AvaInputAPI:SetText(s) end end})

AvaSection:AddButton({Text = "🔍 Scan Server", Callback = function() 
    local list = {}; 
    for _, p in pairs(Players:GetPlayers()) do if p.Name ~= LocalPlayer.Name then table.insert(list, p.Name) end end
    if #list == 0 then table.insert(list, "Kosong (Cuma kamu)") end
    PlayerDropdown.Refresh(list) 
    MigiiNotify("Scan Avatar", "Berhasil memuat nama " .. #list .. " pemain!", 2)
end})

local HistoryDropdown = AvaSection:AddDropdown({Text = "History", Options = getHistory(), Callback = function(s) if s ~= "Belum ada history" then getgenv().TargetAvatar = s; AvaInputAPI:SetText(s) end end})

AvaSection:AddButton({Text = "🗑️ Hapus History", Callback = function() 
    if getgenv().TargetAvatar ~= "" then
        local new = removeHistory(getgenv().TargetAvatar)
        HistoryDropdown.Refresh(new) 
        MigiiNotify("History", "History target berhasil dihapus!", 2)
    else
        MigiiNotify("Gagal", "Pilih username dari history dulu!", 2)
    end
end})

AvaSection:AddButton({Text = "✨ Load Avatar", Callback = function() 
    if getgenv().TargetAvatar == "" then MigiiNotify("Gagal", "Pilih username dulu!", 2) return end
    MigiiNotify("Memproses", "Mengirim data avatar ke server...", 3)
    local s, m = loadAvatar(getgenv().TargetAvatar)
    if s then 
        MigiiNotify("Berhasil!", m, 3)
        HistoryDropdown.Refresh(addHistory(getgenv().TargetAvatar))
    else 
        MigiiNotify("Gagal", m, 3) 
    end
end})

AvaSection:AddButton({Text = "🧍 Balik ke Avatar Asli", Callback = function() 
    MigiiNotify("Memproses", "Mengembalikan avatar aslimu...", 3)
    local s, m = loadAvatar(LocalPlayer.Name)
    if s then 
        MigiiNotify("Berhasil!", "Karakter asli berhasil dimuat!", 3)
    else 
        MigiiNotify("Gagal", m, 3) 
    end
end})

AvaSection:AddButton({Text = "🔄 Refresh Karakter (!re)", Callback = function() 
    task.spawn(function()
        local success, err = pcall(function()
            local args = {"CommandUsed", "!re"}
            game:GetService("ReplicatedStorage"):WaitForChild("Events", 3):WaitForChild("RemoteFunction", 3):WaitForChild("AdminCommands", 3):InvokeServer(unpack(args))
        end)
        if success then 
            MigiiNotify("Refresh", "Karakter asli sedang dimuat ulang!", 2)
        else 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
                MigiiNotify("Reset", "Mereset karakter untuk mengembalikan avatar.", 2)
            end
        end
    end)
end})

-- [ PERTANIAN ]
local TaniSection = TaniTab:AddSection({ Title = "Auto Bercocok Tanam (Pola & Equip)" })
local TaniPlantLabel = TaniSection:AddLabel({Text = "Tanaman Kamu: 0 / 40", Color = Color3.fromRGB(80, 255, 120)})
task.spawn(function()
    while task.wait(1) do 
        TaniPlantLabel:SetText("Tanaman Kamu: " .. countMyPlants() .. " / " .. getgenv().MaxPlantLimit) 
    end
end)

TaniSection:AddInput({
    Text = "Batas Tanam (Min 15, Max 100)", 
    Default = "40", 
    Placeholder = "Kosongin = 40", 
    Callback = function(val)
        local num = tonumber(val)
        if not num then
            getgenv().MaxPlantLimit = 40
        else
            if num < 15 then num = 15 end
            if num > 100 then num = 100 end
            getgenv().MaxPlantLimit = num
        end
        MigiiNotify("Setting", "Batas auto plant diset ke: " .. getgenv().MaxPlantLimit, 2)
    end
})

TaniSection:AddDropdown({Text = "Pilih Pola Tanam", Options = {"Kotak (Grid)", "Lingkaran", "Menumpuk (Tengah)"}, Default = "Kotak (Grid)", Callback = function(val) getgenv().PlantPattern = val end})
TaniSection:AddSlider({Text = "Jarak Antar Bibit (Studs)", Min = 1, Max = 10, Default = 3, Increment = 1, Callback = function(val) getgenv().PlantSpacing = val end})

TaniSection:AddLabel({Text = "--- SINGLE SEED ---", Color = Color3.fromRGB(200, 200, 255)})
TaniSection:AddDropdown({Text = "Pilih Bibit Tunggal", Options = SeedList, Default = SeedList[1], Callback = function(val) getgenv().SeedName = val end})
TaniSection:AddToggle({Text = "🌱 Auto Plant (Single)", Default = false, Callback = function(state) 
    getgenv().AutoPlantSingle = state 
    if state and getgenv().AutoPlantMulti then 
        MigiiNotify("Info", "Matikan Multi-Seed jika ingin memakai Single-Seed!", 3)
    end
end})

TaniSection:AddLabel({Text = "--- MULTI SEED ---", Color = Color3.fromRGB(200, 200, 255)})
local MultiSeedDropdownAPI = TaniSection:AddMultiDropdown({Text = "Pilih Bibit (Multi Target)", Options = {"Scan Dulu..."}, Default = {}, Callback = function(val) getgenv().SelectedMultiSeeds = val end})

TaniSection:AddButton({Text = "🔍 Scan Bibit di Tas", Callback = function()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local found = {}
    local function check(t)
        if t:IsA("Tool") and string.find(string.lower(t.Name), "bibit") then
            local baseName = t.Name
            local matchName = string.match(t.Name, "(Bibit%s+%w+)")
            if matchName then baseName = matchName end
            if not table.find(found, baseName) then table.insert(found, baseName) end
        end
    end
    if backpack then for _, t in ipairs(backpack:GetChildren()) do check(t) end end
    if char then for _, t in ipairs(char:GetChildren()) do check(t) end end
    
    getgenv().ScannedSeeds = found
    if #found > 0 then 
        MultiSeedDropdownAPI.Refresh(found)
        MigiiNotify("Scan Berhasil", "Ditemukan " .. #found .. " jenis bibit! Silahkan pilih di Dropdown.", 3)
    else 
        MultiSeedDropdownAPI.Refresh({"Kosong"})
        MigiiNotify("Scan Gagal", "Tidak ada bibit di tas!", 3)
    end
end})

TaniSection:AddToggle({Text = "🔀 Auto Plant (Multi-Seed)", Default = false, Callback = function(state) 
    getgenv().AutoPlantMulti = state 
    if state and getgenv().AutoPlantSingle then 
        MigiiNotify("Info", "Matikan Single-Seed jika ingin memakai Multi-Seed!", 3)
    end
end})

local PanenSection = TaniTab:AddSection({ Title = "Auto Panen (Strictly Yours)" })
PanenSection:AddToggle({Text = "🌾 Auto Panen (Sekitar)", Default = false, Callback = function(state) getgenv().AutoHarvestSekitar = state end})
PanenSection:AddToggle({Text = "🌾 Auto Panen (Teleport)", Default = false, Callback = function(state) getgenv().AutoHarvestTP = state end})

local BeliBibitSection = TaniTab:AddSection({ Title = "Auto Beli & Jual Tani" })
BeliBibitSection:AddDropdown({Text = "Pilih Bibit Dibeli", Options = SeedList, Default = SeedList[1], Callback = function(val) getgenv().BuySeedName = val end})
BeliBibitSection:AddDropdown({Text = "Pilih Hasil Tani Dijual", Options = CropList, Default = CropList[1], Callback = function(val) getgenv().SellCropName = val end})
BeliBibitSection:AddInput({Text = "Jumlah Beli/Jual", Default = "50", Callback = function(val)
    getgenv().BuyBibitAmount = tonumber(val) or 50
    getgenv().SellTaniAmount = tonumber(val) or 50
end})
BeliBibitSection:AddButton({Text = "🛒 Beli Bibit (Manual)", Callback = function()
    local remotes = ReplicatedStorage:FindFirstChild("ProgressRemotes")
    if remotes and remotes:FindFirstChild("BuyBibit") then
        pcall(function() remotes.BuyBibit:FireServer(getgenv().BuySeedName, getgenv().BuyBibitAmount) end)
        MigiiNotify("Toko Bibit", "Membeli " .. getgenv().BuyBibitAmount .. "x " .. getgenv().BuySeedName, 3)
    end
end})

-- KODE SMART FARM UNTUK TOMBOL JUAL
BeliBibitSection:AddButton({Text = "💰 Jual Hasil Tani (Manual)", Color = Color3.fromRGB(80, 255, 120), Callback = function()
    local remotes = ReplicatedStorage:FindFirstChild("ProgressRemotes")
    if remotes and remotes:FindFirstChild("OnJual") then
        local cropName = getgenv().SellCropName
        local amount = getgenv().SellTaniAmount
        pcall(function() remotes.OnJual:FireServer(cropName, amount) end)
        
        local totalCuan = CalculateProfit(cropName, amount)
        MigiiNotify("Toko Tani", "Mencoba menjual " .. amount .. "x " .. cropName .. "\nTotal Cuan: Rp " .. totalCuan, 3)
    end
end})

BeliBibitSection:AddToggle({Text = "🛒 Auto Beli Bibit", Default = false, Callback = function(state) getgenv().AutoBuyBibit = state end})
BeliBibitSection:AddToggle({Text = "💰 Auto Jual Hasil Tani", Default = false, Callback = function(state) getgenv().AutoSellTani = state end})

-- [ FISHING ]
local FishFarmSection = FishTab:AddSection({ Title = "Auto Fishing (Safe Mode)" })
FishFarmSection:AddToggle({Text = "🎣 Auto Lempar Kail (Auto Cast)", Default = false, Callback = function(state) getgenv().AutoCast = state end})
FishFarmSection:AddSlider({Text = "Kekuatan Lempar (Cast Power)", Min = 10, Max = 100, Default = 50, Increment = 1, Callback = function(val) getgenv().CastPower = val end})
FishFarmSection:AddToggle({Text = "Auto Tangkap ikan", Default = false, Callback = function(state) getgenv().AutoWinMinigame = state end})
FishFarmSection:AddSlider({Text = "Jeda Awal Tangkap ikan (Detik)\nInfo: Kalau kedetect anticheat Naikin delay nya", Min = 1, Max = 10, Default = 3, Increment = 0.5, Callback = function(val) getgenv().MinigameDelay = val end})
FishFarmSection:AddToggle({Text = "Auto Mancing Normal (Bypass gamepass)", Default = false, Callback = function(state) 
    getgenv().AutoWinSmartBypass = state 
    
    if state then
        if getgenv().AutoWinMinigame or getgenv().AutoCast then
            MigiiNotify("Info", "Tolong matikan Auto Cast & Auto Tangkap (Remote) yang lama biar scriptnya nggak bentrok!", 4)
        end
    end
end})


local AntiCheatSection = FishTab:AddSection({ Title = "Anti-Cheat Protection" })
AntiCheatSection:AddToggle({Text = "🛡️ Auto Return Tools (Jika Mati)", Default = false, Callback = function(state) getgenv().AutoReturn = state end})

-- [ Miscelious / ETC FITUR ]
local MiscSection = MiscTab:AddSection({ Title = "Lain-lain / Miscelious" })
MiscSection:AddToggle({
    Text = "🛡️ Anti-AFK", 
    Default = true, 
    Callback = function(state)
        getgenv().AntiAFK = state
        if state then
            MigiiNotify("Anti-AFK", "Fitur Anti-AFK telah AKTIF", 2)
        else
            MigiiNotify("Anti-AFK", "Fitur Anti-AFK dimatikan", 2)
        end
    end
})

local EspSection = MiscTab:AddSection({ Title = "ESP & Wallhacks" })
EspSection:AddToggle({Text = "⏳ Tampilkan ESP Barang & Cooldown", Default = false, Callback = function(state) getgenv().ESP_Cooldown = state end})
EspSection:AddToggle({Text = "🌱 Tampilkan ESP Tanaman (Plant)", Default = false, Callback = function(state) getgenv().ESP_Plant = state end})

----- Pakai aksesoris
local EtcSection = MiscTab:AddSection({ Title = "AKSESORIS " })
EtcSection:AddButton({
    Text = "🎩 Pakai Topi",
    Callback = function()        
        local prompt = workspace:FindFirstChild("PinjamTopi") and workspace.PinjamTopi:FindFirstChild("ProximityPrompt")
        if prompt and prompt.Enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldPos = hrp.CFrame
                pcall(function() hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0) end)
                task.wait(0.5)
                if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 1, true) end) end
                task.wait(0.5)
                pcall(function() hrp.CFrame = oldPos end)
                MigiiNotify("Topi", "Berhasil pakai Topi!", 2)
            end
        else
            MigiiNotify("Topi", "Topi tidak ditemukan atau sedang dipakai!", 2)
        end
    end
})

EtcSection:AddButton({
    Text = "🎒 Pakai Tas",
    Callback = function()
        local prompt = workspace:FindFirstChild("PinjamTas") and workspace.PinjamTas:FindFirstChild("ProximityPrompt")
        if prompt and prompt.Enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldPos = hrp.CFrame
                pcall(function() hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0) end)
                task.wait(0.5)
                if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 1, true) end) end
                task.wait(0.5)
                pcall(function() hrp.CFrame = oldPos end)
                MigiiNotify("Tas", "Berhasil pakai Tas!", 2)
            end
        else
            MigiiNotify("Tas", "Tas tidak ditemukan atau sedang dipakai!", 2)
        end
    end
})

EtcSection:AddButton({
    Text = "😷 Pakai Masker",
    Callback = function()  
        local prompt = workspace:FindFirstChild("PinjamTopi1") and workspace.PinjamTopi1:FindFirstChild("ProximityPrompt")
        if prompt and prompt.Enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldPos = hrp.CFrame
                pcall(function() hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0) end)
                task.wait(0.5)
                if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 1, true) end) end
                task.wait(0.5)
                pcall(function() hrp.CFrame = oldPos end)
                MigiiNotify("Masker", "Berhasil pakai Masker!", 2)
            end
        else
            MigiiNotify("Masker", "Masker tidak ditemukan atau sedang dipakai!", 2)
        end
    end
})

EtcSection:AddButton({
    Text = "⛑️ Pakai Helm",
    Callback = function()
        local prompt = workspace:FindFirstChild("PinjamTopi2") and workspace.PinjamTopi2:FindFirstChild("ProximityPrompt")
        if prompt and prompt.Enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldPos = hrp.CFrame
                pcall(function() hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 0) end)
                task.wait(0.5)
                if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 1, true) end) end
                task.wait(0.5)
                pcall(function() hrp.CFrame = oldPos end)
                MigiiNotify("Helm", "Berhasil pakai Helm!", 2)
            end
        else
            MigiiNotify("Helm", "Helm tidak ditemukan atau sedang dipakai!", 2)
        end
    end
})

-- [ TELEPORT ]
local TPLocSection = TPTab:AddSection({ Title = "Teleportasi Toko & Lokasi" })
TPLocSection:AddDropdown({Text = "Pilih Lokasi Tujuan", Options = TokoList, Default = TokoList[1], Callback = function(val) getgenv().SelectedToko = val end})
TPLocSection:AddButton({Text = "🚀 Teleport ke Toko", Callback = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetPart = nil
    if getgenv().SelectedToko == "Jual Ikan" then
        targetPart = workspace:FindFirstChild("dagang stand") and workspace["dagang stand"]:FindFirstChild("Fish (karasyonok karasyonok)")
    elseif getgenv().SelectedToko == "Toko Pancing" then
        targetPart = workspace:FindFirstChild("Rumah") and workspace.Rumah:FindFirstChild("Part5")
    elseif getgenv().SelectedToko == "Toko Gergaji" then
        targetPart = workspace:FindFirstChild("TokoGergaji") and workspace.TokoGergaji:FindFirstChild("Part")
    elseif getgenv().SelectedToko == "Jual Besi" then
        targetPart = workspace:FindFirstChild("JualBesi") and workspace.JualBesi:FindFirstChild("JualBesi")
    elseif getgenv().SelectedToko == "Toko Bibit" then
        targetPart = workspace:FindFirstChild("NPC_Bibit") and workspace.NPC_Bibit:FindFirstChild("npcbibit")
    elseif getgenv().SelectedToko == "Toko Hasil Tani" then
        targetPart = workspace:FindFirstChild("NPC_Penjual") and workspace.NPC_Penjual:FindFirstChild("npcpenjual")
    end
    
    if targetPart and targetPart:IsA("BasePart") then
        teleportTo(targetPart.Position + Vector3.new(0, 3, 0))
        MigiiNotify("Teleport", "Pindah ke " .. getgenv().SelectedToko, 2)
    else
        MigiiNotify("Error", "Lokasi tidak ditemukan di server ini!", 2)
    end
end})

local TaniTeleportSection = TPTab:AddSection({ Title = "Teleport Lahan Tani" })
TaniTeleportSection:AddDropdown({Text = "Pilih Lahan", Options = LahanList, Default = LahanList[1], Callback = function(val) getgenv().SelectedLahan = val end})
TaniTeleportSection:AddButton({Text = "🚀 Teleport ke Lahan", Callback = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and getgenv().SelectedLahan ~= "" then
        local areaFolder = workspace:FindFirstChild("AreaTanamFolder")
        local targetPlot = areaFolder and areaFolder:FindFirstChild(getgenv().SelectedLahan)
        if targetPlot then teleportTo(targetPlot.Position + Vector3.new(0, 3, 0)) end
    end
end})

local SpotMancingSection = TPTab:AddSection({ Title = "Teleport Spot Mancing" })
SpotMancingSection:AddDropdown({Text = "Pilih Spot", Options = KolamList, Default = KolamList[1], Callback = function(val) getgenv().SelectedKolam = val end})
SpotMancingSection:AddButton({Text = "🚀 Teleport ke Kolam", Callback = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and KolamCoords[getgenv().SelectedKolam] then teleportTo(KolamCoords[getgenv().SelectedKolam]) end
end})

local PlayerTPSection = TPTab:AddSection({ Title = "Player Teleport & Spectate" })
local PlayerTPDropdown = PlayerTPSection:AddDropdown({Text = "Pilih Player", Options = {"Scan dulu..."}, Callback = function(v) getgenv().TargetPlayerTP = v end})
PlayerTPSection:AddButton({Text = "🔍 Scan / Refresh Player", Callback = function()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do 
        if p.Name ~= LocalPlayer.Name then table.insert(list, p.Name) end 
    end
    if #list == 0 then table.insert(list, "Tidak ada player lain") end
    PlayerTPDropdown.Refresh(list)
    getgenv().TargetPlayerTP = list[1]
    MigiiNotify("Scan Berhasil", "Daftar player diperbarui!", 2)
end})
PlayerTPSection:AddButton({Text = "🚀 Teleport ke Player", Callback = function()
    local tName = getgenv().TargetPlayerTP
    if tName == "" or tName == "Scan dulu..." or tName == "Tidak ada player lain" then
        MigiiNotify("Gagal", "Pilih player yang valid!", 2)
        return
    end
    local tPlayer = Players:FindFirstChild(tName)
    if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
        teleportTo(tPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 3)) 
        MigiiNotify("Teleport", "Berhasil teleport ke " .. tName, 2)
    else
        MigiiNotify("Gagal", "Player tidak ditemukan atau mati!", 2)
    end
end})
PlayerTPSection:AddToggle({Text = "👁️ View Player (Spectate)", Default = false, Callback = function(v)
    local camera = workspace.CurrentCamera
    if v then
        local tName = getgenv().TargetPlayerTP
        local tPlayer = Players:FindFirstChild(tName)
        if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = tPlayer.Character.Humanoid
            MigiiNotify("Spectate", "Melihat kamera " .. tName, 2)
        else
            MigiiNotify("Gagal", "Player tidak bisa di-spectate!", 2)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then camera.CameraSubject = LocalPlayer.Character.Humanoid end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
            MigiiNotify("Spectate", "Kamera kembali normal.", 2)
        end
    end
end})

-- [ SHOP & SELL ]
local ShopPancingSection = SellTab:AddSection({ Title = "Toko Pancing" })
ShopPancingSection:AddDropdown({Text = "Pilih Pancingan", Options = RodList, Default = RodList[1], Callback = function(val)
    if RodShopData[val] then
        getgenv().RodNameBuy = RodShopData[val][1]
        getgenv().RodPriceBuy = RodShopData[val][2]
    end
end})
ShopPancingSection:AddButton({Text = "🛒 Beli Pancingan", Callback = function()
    local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remote and remote:FindFirstChild("PurchaseRodEvent") then
        pcall(function() remote.PurchaseRodEvent:FireServer(getgenv().RodNameBuy, getgenv().RodPriceBuy) end)
        MigiiNotify("Toko", "Membeli " .. getgenv().RodNameBuy, 3)
    end
end})

local ShopGergajiSection = SellTab:AddSection({ Title = "Toko Gergaji" })
ShopGergajiSection:AddDropdown({Text = "Pilih Gergaji", Options = SawList, Default = SawList[1], Callback = function(val)
    if SawShopData[val] then
        getgenv().SawNameBuy = SawShopData[val][1]
        getgenv().SawPriceBuy = SawShopData[val][2]
    end
end})
ShopGergajiSection:AddButton({Text = "🪚 Beli Gergaji", Callback = function()
    local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remote and remote:FindFirstChild("PurchaseGergajiEvent") then
        pcall(function() remote.PurchaseGergajiEvent:FireServer(getgenv().SawNameBuy, getgenv().SawPriceBuy) end)
        MigiiNotify("Toko", "Membeli " .. getgenv().SawNameBuy, 3)
    else
        MigiiNotify("Error", "Remote PurchaseGergajiEvent tidak ditemukan!", 3)
    end
end})

local SellTabSection = SellTab:AddSection({ Title = "Jual Hasil Farm (Manual & Auto)" })
SellTabSection:AddButton({Text = "💰 Jual Besi (Manual)", Color = Color3.fromRGB(80, 255, 120), Callback = sellBesi})
SellTabSection:AddToggle({Text = "🔄 Auto Jual Semua Besi", Default = false, Callback = function(state) getgenv().AutoSellBesi = state end})
SellTabSection:AddButton({Text = "💰 Jual Belut (Manual)", Color = Color3.fromRGB(80, 255, 120), Callback = sellBelut})
SellTabSection:AddToggle({Text = "🔄 Auto Jual Semua Belut", Default = false, Callback = function(state) getgenv().AutoSellBelut = state end})
SellTabSection:AddButton({Text = "💰 Jual Ikan (Manual)", Color = Color3.fromRGB(80, 255, 120), Callback = sellIkan})
SellTabSection:AddToggle({Text = "🔄 Auto Jual Semua Ikan", Default = false, Callback = function(state) getgenv().AutoSellIkan = state end})

-- [ VISUALS & HIDE STREAMER MODE ]
local HideSection = VisualTab:AddSection({ Title = "👻 Mode Hide" })
HideSection:AddInput({Text = "Input Fake Nickname", Default = "MigiiHUB", Callback = function(txt)
    if txt and txt ~= "" then
        if getgenv().isHideActive then RestoreOriginalUI() end 
        getgenv().fakeNickname = txt
        if getgenv().isHideActive then ApplyFakeUI() end
        MigiiNotify("Mode Hide", "Fake Nickname diubah: " .. txt, 2)
    end
end})
HideSection:AddInput({Text = "Input Fake Level", Default = "100", Placeholder = "Contoh: 100", Callback = function(txt)
    if txt and txt ~= "" then
        if getgenv().isHideActive then RestoreOriginalUI() end
        getgenv().fakeLevel = "Level : " .. txt
        if getgenv().isHideActive then ApplyFakeUI() end
        MigiiNotify("Mode Hide", "Fake Level diubah: " .. getgenv().fakeLevel, 2)
    end
end})

local TogHide = HideSection:AddToggle({Text = "🟢 Aktifkan Mode Hide", Default = false, Callback = function(v)
    getgenv().isHideActive = v
    if v then
        MigiiNotify("Mode Hide", "Mode Streamer Aktif!", 2)
        ApplyFakeUI()
    else
        MigiiNotify("Mode Hide", "Mode Streamer Mati!", 2)
        RestoreOriginalUI()
        task.delay(0.5, RestoreOriginalUI)
    end
end})

HideSection:AddToggle({Text = "🌈 Aktifkan Title RGB (MIGII-HUB)", Default = false, Callback = function(v)
    getgenv().RGBTitleActive = v
    UpdateRGBTitle()
end})

HideSection:AddButton({Text = "🔄 Force Update Tampilan", Callback = function()
    if getgenv().isHideActive then 
        ApplyFakeUI(); MigiiNotify("Mode Hide", "Tampilan berhasil di-update!", 2)
    else 
        MigiiNotify("Mode Hide", "Aktifkan Mode Hide dulu!", 2)
    end
end})
HideSection:AddButton({Text = "♻️ Reset ke Asli (Tanpa Respawn)", Color = Color3.fromRGB(255, 100, 100), Callback = function()
    getgenv().isHideActive = false
    RestoreOriginalUI()
    task.delay(0.5, RestoreOriginalUI)
    MigiiNotify("Mode Hide", "Berhasil di-reset ke asli!", 2)
end})

