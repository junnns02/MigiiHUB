local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isRunning = true 

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SubmitWordRemote = RemotesFolder and RemotesFolder:FindFirstChild("SubmitWord")
local GameStartRemote = RemotesFolder and RemotesFolder:FindFirstChild("GameStart")
local GameEndRemote = RemotesFolder and RemotesFolder:FindFirstChild("GameEnd")

-- ==========================================
-- 0. DETEKSI NAMA GAME & SETUP FOLDER (HURUF TERAKHIR)
-- ==========================================
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
-- SETTINGS & STATE 
-- ==========================================
local SambungKataState = { 
    AutoPlay = false, 
    Delay = 1.0,       
    TypeSpeed = 0.30,  
    ShowIndicator = false,
    HardMode = false,
    KillMode = false,
    ShowSuggestUI = false,
    InstantMode = false 
}
local FastDict = {} 
local UsedWords = {}
local TotalKamusKata = 0
local HardEndings = {"x", "q", "z", "v", "w", "f", "ng", "ny", "ax", "ex", "ix", "ox", "ux"}
local isTypingManual = false 

local function GetUsedCount()
    local count = 0
    for _, _ in pairs(UsedWords) do count = count + 1 end
    return count
end

-- ==========================================
-- 1. UI LIVE MATCH INDICATOR 
-- ==========================================
local targetGui = (gethui and gethui()) or CoreGui 
local IndicatorGui = Instance.new("ScreenGui")
IndicatorGui.Name = "MigiiSambungKataIndicator"
pcall(function() IndicatorGui.Parent = targetGui end)
if not IndicatorGui.Parent then IndicatorGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") end
IndicatorGui.Enabled = false 

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(0, 280, 0, 135) 
InfoFrame.Position = UDim2.new(1, -290, 0, 20) 
InfoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
InfoFrame.BackgroundTransparency = 0.2
InfoFrame.Active = true 
InfoFrame.Parent = IndicatorGui
InfoFrame.Visible = true
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", InfoFrame)
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.Thickness = 1.5

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 25)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "🔍 Live Match Info"
InfoTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 13
InfoTitle.Parent = InfoFrame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, -75)
InfoText.Position = UDim2.new(0, 10, 0, 25)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Menunggu giliran..."
InfoText.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoText.TextWrapped = true
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 12
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.Parent = InfoFrame

local InfoStats = Instance.new("TextLabel")
InfoStats.Size = UDim2.new(1, -20, 0, 20)
InfoStats.Position = UDim2.new(0, 10, 1, -45)
InfoStats.BackgroundTransparency = 1
InfoStats.Text = "Kata: 0 | Terpakai: 0 | Sisa: 0"
InfoStats.TextColor3 = Color3.fromRGB(150, 255, 150) 
InfoStats.Font = Enum.Font.GothamMedium
InfoStats.TextSize = 11
InfoStats.TextYAlignment = Enum.TextYAlignment.Center
InfoStats.TextXAlignment = Enum.TextXAlignment.Left
InfoStats.Parent = InfoFrame

local InfoSaran = Instance.new("TextLabel")
InfoSaran.Size = UDim2.new(1, -20, 0, 20)
InfoSaran.Position = UDim2.new(0, 10, 1, -25)
InfoSaran.BackgroundTransparency = 1
InfoSaran.Text = "💡 Saran: -"
InfoSaran.TextColor3 = Color3.fromRGB(255, 255, 100) 
InfoSaran.TextWrapped = true
InfoSaran.Font = Enum.Font.GothamMedium
InfoSaran.TextSize = 11
InfoSaran.TextYAlignment = Enum.TextYAlignment.Center
InfoSaran.TextXAlignment = Enum.TextXAlignment.Left
InfoSaran.Parent = InfoFrame

local function UpdateIndicator(text, color, saran)
    if SambungKataState.ShowIndicator then
        if text then InfoText.Text = text end
        if saran then 
            InfoSaran.Text = "💡 Saran: " .. saran 
            InfoSaran.Visible = true
        elseif saran == false then
            InfoSaran.Visible = false
        end
        if color then Stroke.Color = color; InfoTitle.TextColor3 = color end
        
        local used = GetUsedCount()
        local sisa = TotalKamusKata - used
        InfoStats.Text = "Kosa Kata: " .. TotalKamusKata .. " | Terpakai: " .. used .. " | Sisa: " .. sisa
    end
end

local dragging, dragInput, dragStart, startPos
InfoFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = InfoFrame.Position
    end
end)
InfoFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        InfoFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
InfoFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==========================================
-- PANEL MILLIONAIRE 
-- ==========================================
local SuggestGui = Instance.new("ScreenGui")
SuggestGui.Name = "MigiiSambungKataSuggestUI"
SuggestGui.DisplayOrder = 100 
pcall(function() SuggestGui.Parent = targetGui end)
if not SuggestGui.Parent then SuggestGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") end
SuggestGui.Enabled = true 

local SuggestPanel = Instance.new("Frame")
SuggestPanel.Size = UDim2.new(0, 360, 0, 165)
SuggestPanel.Position = UDim2.new(0, 20, 0, 80) 
SuggestPanel.BackgroundTransparency = 1 
SuggestPanel.Active = true
SuggestPanel.Visible = false
SuggestPanel.Parent = SuggestGui

local QuestionBox = Instance.new("Frame", SuggestPanel)
QuestionBox.Size = UDim2.new(1, 0, 0, 38)
QuestionBox.Position = UDim2.new(0, 0, 0, 0)
QuestionBox.BackgroundColor3 = Color3.fromRGB(5, 5, 20) 
Instance.new("UICorner", QuestionBox).CornerRadius = UDim.new(0.5, 0) 
local qStroke = Instance.new("UIStroke", QuestionBox)
qStroke.Color = Color3.fromRGB(255, 255, 255)
qStroke.Thickness = 2

local QuestionText = Instance.new("TextLabel", QuestionBox)
QuestionText.Size = UDim2.new(1, 0, 1, 0)
QuestionText.BackgroundTransparency = 1
QuestionText.RichText = true
QuestionText.Text = "Menunggu giliran..."
QuestionText.TextColor3 = Color3.fromRGB(255, 255, 255)
QuestionText.Font = Enum.Font.GothamMedium
QuestionText.TextSize = 14

local BtnContainer = Instance.new("Frame", SuggestPanel)
BtnContainer.Size = UDim2.new(1, 0, 0, 85)
BtnContainer.Position = UDim2.new(0, 0, 0, 48)
BtnContainer.BackgroundTransparency = 1

local GridLayout = Instance.new("UIGridLayout", BtnContainer)
GridLayout.CellSize = UDim2.new(0.48, 0, 0, 38) 
GridLayout.CellPadding = UDim2.new(0.04, 0, 0, 8)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.FillDirection = Enum.FillDirection.Horizontal 

local suggestButtons = {}
for i = 1, 4 do
    local btn = Instance.new("TextButton", BtnContainer)
    btn.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
    btn.AutoButtonColor = true
    btn.Text = "" 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0) 
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 2
    
    local btnLabel = Instance.new("TextLabel", btn)
    btnLabel.Size = UDim2.new(1, -30, 1, 0)
    btnLabel.Position = UDim2.new(0, 15, 0, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.RichText = true
    btnLabel.Text = "..."
    btnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnLabel.Font = Enum.Font.GothamBold
    btnLabel.TextSize = 13
    btnLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    btn:SetAttribute("TargetWord", "")
    table.insert(suggestButtons, {Button = btn, Label = btnLabel})
end

local HapusBtn = Instance.new("TextButton", SuggestPanel)
HapusBtn.Size = UDim2.new(0.6, 0, 0, 25)
HapusBtn.Position = UDim2.new(0.2, 0, 0, 140) 
HapusBtn.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
HapusBtn.AutoButtonColor = true
HapusBtn.Text = "" 
Instance.new("UICorner", HapusBtn).CornerRadius = UDim.new(0.5, 0)

local hStroke = Instance.new("UIStroke", HapusBtn)
hStroke.Color = Color3.fromRGB(255, 255, 255)
hStroke.Thickness = 1.5

local HapusLabel = Instance.new("TextLabel", HapusBtn)
HapusLabel.Size = UDim2.new(1, 0, 1, 0)
HapusLabel.BackgroundTransparency = 1
HapusLabel.Text = "❌ HAPUS KATA SALAH"
HapusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
HapusLabel.Font = Enum.Font.GothamBold
HapusLabel.TextSize = 11

local dragS, dragInS, dragStartS, startPosS
SuggestPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragS = true; dragStartS = input.Position; startPosS = SuggestPanel.Position
    end
end)
SuggestPanel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInS = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInS and dragS then
        local delta = input.Position - dragStartS
        SuggestPanel.Position = UDim2.new(startPosS.X.Scale, startPosS.X.Offset + delta.X, startPosS.Y.Scale, startPosS.Y.Offset + delta.Y)
    end
end)
SuggestPanel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragS = false end
end)

-- ==========================================
-- PASSIVE REMOTE LISTENERS 
-- ==========================================
if GameStartRemote then
    GameStartRemote.OnClientEvent:Connect(function()
        if isRunning then
            UsedWords = {} 
            UpdateIndicator("✅ Match Dimulai! Memori kata di-reset.", Color3.fromRGB(0, 255, 100), false)
        end
    end)
end

if GameEndRemote then
    GameEndRemote.OnClientEvent:Connect(function()
        if isRunning then UpdateIndicator("🛑 Match Selesai / Menunggu", Color3.fromRGB(255, 50, 50), false) end
    end)
end

-- ==========================================
-- MULTI-SOURCE DICTIONARY ENGINE 
-- ==========================================
task.spawn(function()
    UpdateIndicator("Memuat Multi-Database Kamus...", Color3.fromRGB(255, 200, 0), false)
    for i = 97, 122 do FastDict[string.char(i)] = {} end
    local loadedSet = {} 

    local function addWord(w)
        if string.find(w, "-") or string.find(w, " ") then return end
        local cleanWord = w:lower():gsub("[^a-z]", "")
        if #cleanWord > 1 and not loadedSet[cleanWord] then
            local firstChar = cleanWord:sub(1, 1)
            if FastDict[firstChar] then
                table.insert(FastDict[firstChar], cleanWord)
                loadedSet[cleanWord] = true
                TotalKamusKata = TotalKamusKata + 1
            end
        end
    end

    local s1, res1 = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/hanahaneull/pc-sambungkata/master/kbbi.json") end)
    if s1 and res1 then
        local ds, data = pcall(function() return HttpService:JSONDecode(res1) end)
        if ds and type(data) == "table" then for _, v in pairs(data) do if type(v) == "string" then addWord(v) end end end
    end

    UpdateIndicator("Memuat CSV Github...", Color3.fromRGB(255, 150, 0), false)
    local s2, res2 = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Hidayathamir/kata-kbbi-github/refs/heads/main/kbbi.csv") end)
    if s2 and res2 then for word in res2:gmatch("[^,\r\n]+") do addWord(word) end end

    UpdateIndicator("Menarik Data A-Z (Background)...", Color3.fromRGB(0, 200, 255), false)
    for i = 97, 122 do
        task.spawn(function()
            if not isRunning then return end 
            local letter = string.char(i)
            local s3, res3 = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/rizaumami/kbbi/master/teks/hasil_akhir/" .. letter .. ".txt") end)
            if s3 and res3 then for word in res3:gmatch("[^\r\n]+") do addWord(word) end end
            UpdateIndicator(nil, nil, nil) 
        end)
        task.wait(0.05) 
    end

    local extraWords = {
        "aku","akan","ada","apa","atas","atau","anak","ambil","baru","bisa","buku","baik",
        "banyak","bukan","buat","bawa","cinta","coba","dalam","dari","dengan","engkau",
        "emas","fokus","gajah","hari","ikan","juga","kita","lama","makan","nasi","orang",
        "pasti","rasa","satu","tahu","uang","waktu","yakin","zaman","axel","axis","axle",
        "axolotl","axon","axing","axial","extra","extreme","exit","exam","exist","execute",
        "export","express","explore","ixora","icon","idea","ideal","idiot","oxford","oksigen",
        "oasis","opera","orbit","uxui","ungu","ujian","utama","utara","xenon","xylem","xray",
        "xerox","xylophone","xenia","xilem","queen","qatar","quran","query","quota","qurban",
        "quote","zebra","zombie","zodiac","zoom","zero","zona","zakat","zamrud","zodiak",
        "zonasi","zikir","ziarah","zaitun","zigot","zink","vibes","vampir","video","visual",
        "viral","valid","vaksin","virus","vocal","volume","vakum","visa","vas","voli","vonis",
        "vibrasi","woles","wkwk","wajib","wakil","wanita","warga","warna","wabah","anjay",
        "anjir","baper","caper","mager","kepo","gabut","bestie","cuy","bro","enggan","engsel",
        "engap","engkok","engkong","engkoh","engku","angka","angsa","angkut","angkat","anggur",
        "anggun","angin","angkasa","anglo","anggar","angkit"
    }
    for _, w in ipairs(extraWords) do addWord(w) end
    
    loadedSet = nil 
    task.wait(1.5)
    UpdateIndicator("✅ Kamus Raksasa Siap!", Color3.fromRGB(0, 255, 150), false)
    task.wait(2)
    UpdateIndicator("Menunggu giliran / permainan dimulai...", Color3.fromRGB(200, 200, 200), false)
end)

local function GetSuggestions(prefix, limit)
    if not prefix or prefix == "" then return "-" end
    local firstChar = prefix:sub(1, 1)
    local list = FastDict[firstChar]
    
    if not list then return "-" end

    local suggestions = {}
    for _, w in ipairs(list) do
        if w:sub(1, #prefix) == prefix and #w > #prefix and not UsedWords[w] then
            table.insert(suggestions, w:upper())
            if #suggestions >= limit then break end
        end
    end
    if #suggestions > 0 then return table.concat(suggestions, ", ") else return "Kosong/Habis" end
end

-- ==========================================
-- ENGINE KILL-WORD (PREDIKSI LANGKAH LAWAN)
-- ==========================================
local function GetKillWord(prefix)
    local firstChar = prefix:sub(1, 1)
    local list = FastDict[firstChar]
    local avail = {}
    
    if list then
        for _, w in ipairs(list) do
            if w:sub(1, #prefix) == prefix and #w > #prefix and not UsedWords[w] then
                table.insert(avail, w)
                if #avail > 250 then break end 
            end
        end
    end
    
    if #avail == 0 then return nil end
    
    local bestWord = avail[1]
    local minOpponentChoices = math.huge
    local absoluteKillWords = {}
    
    for _, w in ipairs(avail) do
        local lastChar = w:sub(-1) 
        local opponentList = FastDict[lastChar]
        local opponentChoicesCount = 0
        
        if opponentList then
            for _, ow in ipairs(opponentList) do
                if ow:sub(1, 1) == lastChar and #ow > 1 and not UsedWords[ow] then
                    opponentChoicesCount = opponentChoicesCount + 1
                    if opponentChoicesCount > 15 then break end 
                end
            end
        end
        
        if opponentChoicesCount < minOpponentChoices then
            minOpponentChoices = opponentChoicesCount
            bestWord = w
        end
        
        if opponentChoicesCount == 0 then
            table.insert(absoluteKillWords, w)
        end
    end
    
    if #absoluteKillWords > 0 then
        return absoluteKillWords[math.random(1, #absoluteKillWords)]
    end
    
    return bestWord
end

local function GetWord(prefix)
    if SambungKataState.KillMode then
        local killWord = GetKillWord(prefix)
        if killWord then return killWord end
    end

    local firstChar = prefix:sub(1, 1)
    local list = FastDict[firstChar]
    local avail = {}
    local hardAvail = {} 
    
    if list then
        for _, w in ipairs(list) do
            if w:sub(1, #prefix) == prefix and #w > #prefix and not UsedWords[w] then
                table.insert(avail, w)
                if SambungKataState.HardMode then
                    for _, ending in ipairs(HardEndings) do
                        if w:sub(-#ending) == ending then
                            table.insert(hardAvail, w)
                            break
                        end
                    end
                end
                if #avail > 250 then break end 
            end
        end
    end
    
    if SambungKataState.HardMode and #hardAvail > 0 then return hardAvail[math.random(1, #hardAvail)]
    elseif #avail > 0 then return avail[math.random(1, #avail)] 
    else local vokal = {"a", "i", "u", "e", "o"}; return prefix .. vokal[math.random(1, 5)] end
end

-- ==========================================
-- PC KEYBOARD SIMULATION ENGINE 
-- ==========================================
local function SimulateTyping(text)
    for i = 1, #text do
        if not isRunning then break end 
        local char = text:sub(i, i):upper()
        local keyCode = Enum.KeyCode[char]
        if keyCode then
            pcall(function()
                VIM:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.01)
                VIM:SendKeyEvent(false, keyCode, false, game)
            end)
            task.wait(SambungKataState.TypeSpeed) 
        end
    end
end

local function SimulateEnter()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
end

local function SimulateBackspace()
    pcall(function()
        for _ = 1, 35 do 
            VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
            task.wait(0.01) 
        end
    end)
end

HapusBtn.MouseButton1Click:Connect(function() SimulateBackspace() end)

-- ==========================================
-- LOGIC 2: MANUAL ASSIST MILLIONAIRE
-- ==========================================
local function HandleManualClick(word, prefix)
    if isTypingManual then return end
    isTypingManual = true
    SuggestPanel.Visible = false 
    
    task.spawn(function()
        task.wait(0.1) 
        
        if SambungKataState.InstantMode and SubmitWordRemote then
            pcall(function() SubmitWordRemote:FireServer(word) end)
        else
            local restOfWord = word:sub(#prefix + 1)
            SimulateTyping(restOfWord)
            task.wait(0.1)
            SimulateEnter()
        end
        
        UsedWords[word] = true
        UpdateIndicator(nil, nil, nil) 
        
        local stillTurn = true
        local isWrongWord = false
        local waitTimeout = 0
        
        while stillTurn and waitTimeout < 40 do
            task.wait(0.1)
            if not isRunning then break end
            waitTimeout = waitTimeout + 1
            local kbVisible = false
            local errorFound = false
            
            for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if (v.Name == "A" and v.Parent and v.Parent.Name:find("Row") and v.Visible and v.AbsoluteSize.X > 0) or
                   (v.Name == "CustomKeyboard" and v.Visible and v.AbsoluteSize.X > 0) then
                    kbVisible = true
                end
                if v.Name == "FeedbackLabel" and v:IsA("TextLabel") and v.Visible then
                    local txt = string.lower(v.Text)
                    if string.find(txt, "tidak ada") or string.find(txt, "salah") or string.find(txt, "coba kata lain") then
                        errorFound = true
                    end
                end
            end
            
            if errorFound then
                isWrongWord = true
                break 
            end
            if not kbVisible then stillTurn = false end
        end
        
        if stillTurn or isWrongWord then
            UpdateIndicator("⚠️ Kata Salah! Menghapus otomatis...", Color3.fromRGB(255, 100, 50), false)
            SimulateBackspace() 
            task.wait(0.5) 
        end
        isTypingManual = false
    end)
end

-- ==========================================
-- FUNGSI UNIVERSAL PENCARI GILIRAN & PREFIX
-- ==========================================
local function GetTurnAndPrefix()
    local isMyTurn = false
    local prefix = ""

    for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if (v.Name == "A" and v:IsA("TextButton") and v.Parent and v.Parent.Name:find("Row") and v.Visible and v.AbsoluteSize.X > 0) or
           (v.Name == "CustomKeyboard" and v.Visible and v.AbsoluteSize.X > 0) then
            isMyTurn = true
        end

        if v.Name == "CurrentLetterLabel" and v:IsA("TextLabel") and v.Visible then
            local letter = v.Text:lower():gsub("[^a-z]", "")
            if letter ~= "" then prefix = letter end
        end

        if v:IsA("TextLabel") and v.Visible and prefix == "" then
            local match = v.Text:lower():match("adalah:%s*([a-z]+)")
            if match then prefix = match end
        end
    end

    if prefix == "" then
        local wordFrames = {}
        for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if v.Name == "Word" and v.Parent and v.Parent.Name == "WordSubmit" then table.insert(wordFrames, v) end
        end
        if #wordFrames > 0 then
            table.sort(wordFrames, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
            for _, w in ipairs(wordFrames) do prefix = prefix .. tostring(w.Text):lower():gsub("[^a-z]", "") end
        end
    end

    return isMyTurn, prefix
end

for i, item in ipairs(suggestButtons) do
    item.Button.MouseButton1Click:Connect(function()
        local word = item.Button:GetAttribute("TargetWord")
        if not word or word == "" then return end
        
        local _, currentPrefix = GetTurnAndPrefix()
        if currentPrefix ~= "" then HandleManualClick(word, currentPrefix) end
    end)
end

-- Updater Dinamis Teks 
task.spawn(function()
    local lastSuggestPrefix = ""
    local optionsLetter = {"A: ", "B: ", "C: ", "D: "}
    
    while isRunning do 
        task.wait(0.05) 
        
        if not SambungKataState.ShowSuggestUI or isTypingManual then 
            SuggestPanel.Visible = false
            lastSuggestPrefix = ""
            continue 
        else
            SuggestPanel.Visible = true
        end
        
        if isTypingManual then 
            QuestionText.Text = "Sedang mengetik otomatis..."
            for i = 1, 4 do suggestButtons[i].Label.Text = "..."; suggestButtons[i].Button:SetAttribute("TargetWord", "") end
            continue 
        end
        
        local isMyTurn, prefix = GetTurnAndPrefix()
        
        if isMyTurn and prefix ~= "" then
            SuggestPanel.Visible = true
            if prefix ~= lastSuggestPrefix then
                lastSuggestPrefix = prefix
                QuestionText.Text = "Lanjutkan awalan kata: <font color='#FFD700'><b>" .. prefix:upper() .. "</b></font>"
                
                local list = FastDict[prefix:sub(1,1)] or {}
                local count = 0
                for _, w in ipairs(list) do
                    if w:sub(1, #prefix) == prefix and #w > #prefix and not UsedWords[w] then
                        count = count + 1
                        local item = suggestButtons[count]
                        item.Button:SetAttribute("TargetWord", w)
                        item.Label.Text = "<font color='#FFD700'><b>" .. optionsLetter[count] .. "</b></font>" .. w:upper()
                        if count >= 4 then break end 
                    end
                end
                
                for i = count + 1, 4 do
                    local item = suggestButtons[i]
                    item.Button:SetAttribute("TargetWord", "")
                    item.Label.Text = "<font color='#FFD700'><b>" .. optionsLetter[i] .. "</b></font>-"
                end
            end
        else
            lastSuggestPrefix = ""
            QuestionText.Text = "Menunggu giliranmu..."
            for i = 1, 4 do suggestButtons[i].Button:SetAttribute("TargetWord", ""); suggestButtons[i].Label.Text = "..." end
        end
    end
end)

-- ==========================================
-- PASSIVE SCANNER & PERFECT WORD FILTER 
-- ==========================================
task.spawn(function()
    local lastLiveWord = "" 
    while isRunning do
        task.wait(0.05)
        
        if not SambungKataState.AutoPlay and not SambungKataState.ShowIndicator and not SambungKataState.ShowSuggestUI then 
            task.wait(1); continue 
        end

        local isMyTurn, prefix = GetTurnAndPrefix()

        local currentLiveWord = ""
        local wordFrames = {}
        for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if v.Name == "Word" and v.Parent and v.Parent.Name == "WordSubmit" then table.insert(wordFrames, v) end
        end
        if #wordFrames > 0 then
            table.sort(wordFrames, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
            for _, w in ipairs(wordFrames) do currentLiveWord = currentLiveWord .. tostring(w.Text):lower():gsub("[^a-z]", "") end
        end
        
        if #currentLiveWord > 0 then
            lastLiveWord = currentLiveWord 
        else
            if #lastLiveWord >= 2 then
                if not UsedWords[lastLiveWord] then UsedWords[lastLiveWord] = true; UpdateIndicator(nil, nil, nil) end
                lastLiveWord = "" 
            end
        end
        
        if isMyTurn then
            if not SambungKataState.AutoPlay and prefix ~= "" then
                local saran = GetSuggestions(prefix, 4)
                UpdateIndicator("🟢 Giliran: KAMU\nHuruf Dasar Saat Ini: " .. prefix:upper(), Color3.fromRGB(0, 255, 100), saran)
            end
        else
            if prefix ~= "" then UpdateIndicator("⏳ Menunggu Giliranmu...\nHuruf Dasar Saat Ini: " .. prefix:upper(), Color3.fromRGB(200, 200, 200), false)
            else UpdateIndicator("🔍 Menunggu match dimulai...", Color3.fromRGB(150, 150, 150), false) end
        end
    end
end)

-- ==========================================
-- LOGIC 1: AUTO PLAY UTAMA
-- ==========================================
task.spawn(function()
    local isRetry = false
    while isRunning do
        task.wait(0.1)
        if not SambungKataState.AutoPlay then continue end

        local isMyTurn, prefix = GetTurnAndPrefix()

        if isMyTurn and not isTypingManual then 
            if prefix == "" then continue end
            
            local targetWord = GetWord(prefix)
            local restOfWord = targetWord:sub(#prefix + 1)
            local saran = GetSuggestions(prefix, 4)
            
            UpdateIndicator("🟢 Giliran: KAMU\nMemilih kata: " .. targetWord:upper(), Color3.fromRGB(0, 255, 100), saran)
            
            if not isRetry then task.wait(SambungKataState.Delay) end

            if SambungKataState.InstantMode and SubmitWordRemote then
                pcall(function() SubmitWordRemote:FireServer(targetWord) end)
                task.wait(0.1) 
            else
                SimulateTyping(restOfWord)
                task.wait(0.1)
                SimulateEnter()
            end
            
            UsedWords[targetWord] = true
            UpdateIndicator(nil, nil, nil) 
            
            local stillTurn = true
            local isWrongWord = false
            local waitTimeout = 0
            
            while stillTurn and waitTimeout < 40 do
                task.wait(0.1)
                waitTimeout = waitTimeout + 1
                local kbVisible = false
                local errorFound = false
                
                for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if (v.Name == "A" and v.Parent and v.Parent.Name:find("Row") and v.Visible and v.AbsoluteSize.X > 0) or
                       (v.Name == "CustomKeyboard" and v.Visible and v.AbsoluteSize.X > 0) then
                        kbVisible = true
                    end
                    if v.Name == "FeedbackLabel" and v:IsA("TextLabel") and v.Visible then
                        local txt = string.lower(v.Text)
                        if string.find(txt, "tidak ada") or string.find(txt, "salah") or string.find(txt, "coba kata lain") then
                            errorFound = true
                        end
                    end
                end
                
                if errorFound then
                    isWrongWord = true
                    break 
                end
                
                if not kbVisible then stillTurn = false end
            end
            
            if stillTurn or isWrongWord then
                UpdateIndicator("⚠️ Kata Salah! Menghapus otomatis...", Color3.fromRGB(255, 100, 50), saran)
                SimulateBackspace()
                task.wait(0.5)
                isRetry = true 
            else
                isRetry = false
            end
        else
            isRetry = false
        end
    end
end)

-- ==========================================
-- 1. LOAD UI LIBRARY MIGIIHUB & EKSTENSI
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/migii02/MigiiHUB/refs/heads/main/UI/LibraryLite.lua"))()

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

-- ==========================================
-- 2. MEMBANGUN UI MIGIIHUB UNTUK SAMBUNG KATA
-- ==========================================
Library.ShowMigiiLoader()
local LOGO_ID = "rbxthumb://type=Asset&id=132319281050903&w=150&h=150"
local Window = Library.new({Title = "MigiiHUB | " .. gameDisplayName, Size = UDim2.new(0, 480, 0, 360)})
Window:CreateToggleButton({ Icon = LOGO_ID })

local MainTab = Window:AddTab({ Name = "Main Auto", Icon = "🎮" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "⚙️" })

local MainSection = MainTab:AddSection({ Title = "🔥 Auto Sambung Kata (Universal)" })

MainSection:AddToggle({Text = "🤖 Mode AutoPlay ", Default = false, Callback = function(v) SambungKataState.AutoPlay = v end})
MainSection:AddToggle({Text = "⚡ Mode Instan (Bypass Ngetik)", Default = false, Callback = function(v) SambungKataState.InstantMode = v end})
MainSection:AddToggle({Text = "🖱️ Mode Manual", Default = false, Callback = function(v) SambungKataState.ShowSuggestUI = v end})
MainSection:AddToggle({Text = "😈 Mode Gacor (Akhiran Susah)", Default = false, Callback = function(v) SambungKataState.HardMode = v end})
MainSection:AddToggle({Text = "☠️ Mode Simple (Auto jawab huruf dasar)", Default = false, Callback = function(v) SambungKataState.KillMode = v end})
MainSection:AddToggle({Text = "📊 Tampilkan Panel Info", Default = false, Callback = function(v) 
    SambungKataState.ShowIndicator = v
    if IndicatorGui then IndicatorGui.Enabled = v end
end})

MainSection:AddButton({Text = "🔄 Reset Memori Kata (Manual)", Callback = function()
    UsedWords = {}
    UpdateIndicator(nil, nil, nil) 
    Window:Toast({Title = "Berhasil", Message = "Memori kata berhasil dikosongkan!", Duration = 3, Type = "Success"})
end})
MainSection:AddLabel({Text = "Bot memprioritaskan kata dengan akhiran ng, x, z, q, f, w, v", Color = Color3.fromRGB(150, 150, 150)})

local SpeedSection = MainTab:AddSection({ Title = "⚡ Pengaturan Kecepatan & Jeda" })
SpeedSection:AddSlider({ Text = "Kecepatan Ngetik (Detik per Huruf)", Min = 0.05, Max = 1.0, Default = 0.30, Increment = 0.05, Callback = function(v) SambungKataState.TypeSpeed = v end})
SpeedSection:AddSlider({ Text = "Jeda Sebelum Mulai (Detik)", Min = 0.0, Max = 3.0, Default = 1.0, Increment = 0.1, Callback = function(v) SambungKataState.Delay = v end})

local ConfigSection = SettingsTab:AddSection({ Title = "Konfigurasi Sistem" })
ConfigSection:AddButton({Text = "❌ Tutup & Hapus Loader", Callback = function()
    isRunning = false 
    SambungKataState.AutoPlay = false; SambungKataState.ShowIndicator = false; SambungKataState.ShowSuggestUI = false
    if IndicatorGui then IndicatorGui:Destroy() end
    if SuggestGui then SuggestGui:Destroy() end
    
    local function WipeUI(parentGui)
        for _, child in pairs(parentGui:GetChildren()) do
            if child:IsA("ScreenGui") then
                if child:FindFirstChild("Main") or string.match(child.Name, "Migii") then child:Destroy()
                else
                    for _, desc in pairs(child:GetDescendants()) do
                        if (desc:IsA("ImageButton") or desc:IsA("ImageLabel")) and desc.Image == LOGO_ID then child:Destroy(); break end
                    end
                end
            end
        end
    end

    WipeUI(CoreGui)
    if LocalPlayer:FindFirstChild("PlayerGui") then WipeUI(LocalPlayer.PlayerGui) end
end})

Window:Toast({Title = "MIGII HUB", Message = "Memuat Script Universal... \nSupport 6 Game!", Duration = 4, Type = "Success"})
