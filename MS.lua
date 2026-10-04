--========================================================--
--                    MAKIMA SCRIPTS                     --
--                      MakimaDev                         --
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- CONFIGURAÇÕES
--========================================================--

local WINDUI_URL =
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"

local DISCORD_URL =
    "https://discord.gg/4aEBbw7BQf"

local JJS_URL =
    "https://rawscripts.net/raw/Universal-Script-Auto-jjs-EB-do-delta-126144"

local PARKOUR_URL =
    "https://pastebin.com/raw/Ld2V1LSL"

--========================================================--
-- FUNÇÃO HTTP SEGURA
--========================================================--

local function SafeHttpGet(url)

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then

        warn("[Makima Scripts] HTTP ERROR:")
        warn(url)
        warn(result)

        return nil
    end

    if type(result) ~= "string" or result == "" then

        warn("[Makima Scripts] Resposta HTTP vazia:")
        warn(url)

        return nil
    end

    return result
end

--========================================================--
-- CARREGAR WINDUI
--========================================================--

local WindUISource = SafeHttpGet(WINDUI_URL)

if not WindUISource then
    warn("[Makima Scripts] Não foi possível carregar o WindUI.")
    return
end

local WindUI

do

    local success, result = pcall(function()

        local fn = loadstring(WindUISource)

        if not fn then
            error("WindUI retornou código inválido.")
        end

        return fn()

    end)

    if not success then

        warn("[Makima Scripts] Erro ao iniciar WindUI:")
        warn(result)

        return
    end

    WindUI = result
end

if not WindUI then
    warn("[Makima Scripts] WindUI não carregou.")
    return
end

--========================================================--
-- PANDA AUTH - PUSL V4
--========================================================--
-- O Panda Auth controla a Key e o link de obtenção.
-- Não há Kick() quando a Key é inválida/expirada.

local PANDA_SERVICE_ID = "mskey"
local PANDA_LIB_URL = "https://secure.pandauth.com/pv4/lib"

local PUSL
do
    local success, result = pcall(function()
        local source = game:HttpGet(PANDA_LIB_URL)
        local loader = loadstring(source)
        if type(loader) ~= "function" then
            error("Panda Auth retornou código inválido.")
        end
        return loader()
    end)

    if not success or type(result) ~= "table" then
        warn("[Makima Scripts] Falha ao carregar Panda Auth:", result)
        return
    end

    PUSL = result
end

if type(PUSL.configure) ~= "function" or type(PUSL.validate) ~= "function" then
    warn("[Makima Scripts] Panda Auth incompatível: configure()/validate() não encontrados.")
    return
end

local pandaConfigured = pcall(function()
    PUSL.configure({
        serviceId = PANDA_SERVICE_ID,
    })
end)

if not pandaConfigured then
    warn("[Makima Scripts] Não foi possível configurar o serviço Panda Auth.")
    return
end

local function GetPandaKeyLink()
    if type(PUSL.getKeyUrl) ~= "function" then
        return nil
    end

    local success, link = pcall(function()
        return PUSL.getKeyUrl()
    end)

    if success and type(link) == "string" and link ~= "" then
        return link
    end

    return nil
end

local function ValidateKey(key)
    if type(key) ~= "string" then
        return false
    end

    key = key:gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        return false
    end

    local success, result = pcall(function()
        return PUSL.validate(key)
    end)

    if not success or type(result) ~= "table" then
        warn("[Makima Scripts] Erro ao validar Key no Panda Auth:", result)
        return false
    end

    if result.success == true then
        pcall(function()
            getgenv().SCRIPT_KEY = key
        end)
        return true
    end

    warn("[Makima Scripts] Key recusada pelo Panda Auth:", tostring(result.message or result.error or "INVALID"))
    return false
end

local PANDA_KEY_URL = GetPandaKeyLink()

--========================================================--
-- TEMA
--========================================================--

pcall(function()

    WindUI:AddTheme({

        Name = "MakimaRed",

        Accent = Color3.fromRGB(
            190,
            20,
            45
        ),

        Background = Color3.fromRGB(
            12,
            9,
            10
        ),

        Outline = Color3.fromRGB(
            90,
            25,
            35
        ),

        Text = Color3.fromRGB(
            245,
            245,
            245
        ),

        Placeholder = Color3.fromRGB(
            130,
            125,
            128
        ),

        Button = Color3.fromRGB(
            55,
            22,
            28
        ),

        Icon = Color3.fromRGB(
            255,
            80,
            100
        ),
    })

end)

pcall(function()
    WindUI:SetTheme("MakimaRed")
end)

--========================================================--
-- WINDOW + KEYSYSTEM NATIVO
--========================================================--

local Window = WindUI:CreateWindow({

    Title = "Makima Scripts",

    Author = "by MakimaDev",

    Icon = "flame",

    Folder = "MakimaScriptsAuthV2",

    Size = UDim2.fromOffset(
        580,
        460
    ),

    Transparent = false,

    Theme = "MakimaRed",

    Resizable = true,

    SideBarWidth = 180,

    --====================================================--
    -- KEY SYSTEM DO PRÓPRIO WINDUI
    --====================================================--

    KeySystem = {

        Title = "Makima Scripts",

        Note = "Insira sua Key para continuar.",

        URL = PANDA_KEY_URL or "",

        SaveKey = true,

        KeyValidator = function(key)

            return ValidateKey(key)

        end,
    },
})

--========================================================--
-- NOTIFICAÇÃO
--========================================================--

local function Notify(title, content, duration)

    pcall(function()

        WindUI:Notify({

            Title = title,

            Content = content,

            Duration = duration or 3,

        })

    end)

end

--========================================================--
-- CLIPBOARD
--========================================================--

local function Copy(text)

    if type(setclipboard) ~= "function" then

        Notify(
            "Clipboard",
            "Seu executor não suporta copiar para a área de transferência.",
            4
        )

        return
    end

    local success = pcall(function()
        setclipboard(text)
    end)

    if success then

        Notify(
            "Copiado",
            "Link copiado para a área de transferência.",
            2
        )

    end
end

--========================================================--
-- TABS
--========================================================--

local PerguntasTab = Window:Tab({
    Title = "Perguntas",
    Icon = "help-circle",
})

local ParkourTab = Window:Tab({
    Title = "Parkour",
    Icon = "footprints",
})

local JJsTab = Window:Tab({
    Title = "JJs",
    Icon = "zap",
})

local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "tractor",
})

local PatchTab = Window:Tab({
    Title = "Patch",
    Icon = "clipboard-list",
})

local OutrosTab = Window:Tab({
    Title = "Outros",
    Icon = "settings",
})

local CreditosTab = Window:Tab({
    Title = "Créditos",
    Icon = "heart",
})

--========================================================--
-- RECURSOS DA SOURCE DRIP MENU
--========================================================--

local DripDiscordTab = Window:Tab({
    Title = "Discord",
    Icon = "message-circle",
})

local DripParkoursTab = Window:Tab({
    Title = "Parkours",
    Icon = "footprints",
})

local TorresTab = Window:Tab({
    Title = "Torres",
    Icon = "tower-control",
})

local DripBrutalTab = Window:Tab({
    Title = "Brutal",
    Icon = "skull",
})

local DripCharTab = Window:Tab({
    Title = "Char",
    Icon = "user",
})


--========================================================--
-- PERGUNTAS
--========================================================--

PerguntasTab:Paragraph({

    Title = "Siglas",

    Desc = "Consulte o significado das siglas.",

    Color = "Red",
})

local Siglas = {

    {
        "AMAN",
        "Academia de Agulhas Negras"
    },

    {
        "E.P.C",
        "Escola Preparatória de Coronéis"
    },

    {
        "APG",
        "Academia Preparatória de Generais"
    },

    {
        "BIP",
        "Batalhão de Infantaria Paraquedistas"
    },

    {
        "BPE",
        "Batalhão da Polícia do Exército"
    },

    {
        "BFE",
        "Batalhão de Forças Especiais"
    },

    {
        "BAC",
        "Batalhão de Ações de Comandos"
    },

    {
        "CIE",
        "Centro de Inteligência do Exército"
    },

    {
        "CIGS",
        "Centro de Instrução de Guerras na Selva"
    },

    {
        "CYBER",
        "Comando de Defesa Cibernética"
    },

    {
        "BI-CAAT",
        "Batalhão de Infantaria da Caatinga"
    },

    {
        "REC-MEC",
        "Regimento da Cavalaria Mecânica"
    },
}

for _, info in ipairs(Siglas) do

    PerguntasTab:Button({

        Title = info[1],

        Desc = info[2],

        Callback = function()

            Copy(
                info[1]
                .. ": "
                .. info[2]
            )

        end,
    })

end


--========================================================--
-- DISCORD
--========================================================--

DripDiscordTab:Paragraph({
    Title = "🌐 Discord",
    Desc = "Entre no nosso Discord.",
    Color = "Red",
})

DripDiscordTab:Button({
    Title = "📋 Copiar link",
    Desc = DISCORD_URL,
    Callback = function()
        Copy(DISCORD_URL)
    end,
})

DripDiscordTab:Input({
    Title = "Link",
    Value = DISCORD_URL,
    Placeholder = "Link...",
    Callback = function() end,
})

-- PASTAS
-- ========================================================================

local VisualFolder = workspace:FindFirstChild("AstolfoPathVisual")
if not VisualFolder then
    VisualFolder = Instance.new("Folder")
    VisualFolder.Name = "AstolfoPathVisual"
    VisualFolder.Parent = workspace
end

local TriggerFolder = workspace:FindFirstChild("DripTriggers")
if not TriggerFolder then
    TriggerFolder = Instance.new("Folder")
    TriggerFolder.Name = "DripTriggers"
    TriggerFolder.Parent = workspace
end

local HitboxFolder = workspace:FindFirstChild("DripHitboxes")
if not HitboxFolder then
    HitboxFolder = Instance.new("Folder")
    HitboxFolder.Name = "DripHitboxes"
    HitboxFolder.Parent = workspace
end

-- ========================================================================
-- ROTAS
-- ========================================================================

_G.SavedPaths = _G.SavedPaths or {}

_G.GlobalPaths = {
    ["parkour1_rapido"] = "https://pastefy.app/zT6zxUge/raw",
    ["parkour2_rapido"] = "https://pastefy.app/lCbhnx2T/raw",
    ["parkour3_rapido"] = "https://pastefy.app/uZnip0PL/raw",
    ["parkour4_rapido"] = "https://pastefy.app/nW4Eo4nd/raw",
    ["parkour5_rapido"] = "https://pastefy.app/Ef1ZaCWz/raw",
    ["torre1_rapido"]   = "https://pastefy.app/vCcXEVf3/raw",
    ["torre2_rapido"]   = "https://pastefy.app/gGF2CFZN/raw",
}

-- ========================================================================
-- VISUAL
-- ========================================================================

local function clearVisualPath()
    pcall(function() VisualFolder:ClearAllChildren() end)
end

local function drawVisualPath(path)
    clearVisualPath()
    if not path or #path < 2 then return end

    local lastAttachment = nil

    for i = 1, #path, 5 do
        local node = path[i]
        if node then
            local cf = node.CFrameInstance
            if not cf and node.CF then
                pcall(function() cf = CFrame.new(unpack(node.CF)) end)
            end

            if cf then
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.CFrame = cf - Vector3.new(0, 2.5, 0)
                part.Anchored = true
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
                part.Transparency = 1
                part.Parent = VisualFolder

                local attachment = Instance.new("Attachment")
                attachment.Parent = part

                if lastAttachment then
                    local beam = Instance.new("Beam")
                    beam.Attachment0 = lastAttachment
                    beam.Attachment1 = attachment
                    beam.Width0 = 0.35
                    beam.Width1 = 0.35
                    beam.Color = ColorSequence.new(Color3.fromRGB(220, 38, 38))
                    beam.FaceCamera = true
                    beam.Transparency = NumberSequence.new(0.1)
                    beam.Parent = part
                end

                lastAttachment = attachment
            end
        end
    end
end

-- ========================================================================
-- PREPROCESS
-- ========================================================================

local function preprocessPath(p)
    if not p or #p == 0 then return p end

    for i, node in ipairs(p) do
        if not node.Time then
            node.Time = (i - 1) * (1 / 60)
        end

        if node.CFrameInstance then
        elseif type(node.CF) == "table" then
            local ok, cf = pcall(function()
                return CFrame.new(unpack(node.CF))
            end)
            node.CFrameInstance = (ok and cf) or CFrame.new(0, 0, 0)
        elseif node.Position then
            node.CFrameInstance = CFrame.new(node.Position)
        else
            node.CFrameInstance = CFrame.new(0, 0, 0)
        end
    end

    return p
end

-- ========================================================================
-- DOWNLOAD
-- ========================================================================

local function fetchUrl(url)
    local ok, content = pcall(function() return game:HttpGet(url, true) end)

    if ok and content and #content > 20 then
        if content:find("<html") or content:find("<!DOCTYPE") then
            local ex = content:match("<pre[^>]*>(.-)</pre>")
                or content:match("<code[^>]*>(.-)</code>")
            if ex then
                ex = ex:gsub("&lt;", "<"):gsub("&gt;", ">")
                    :gsub("&amp;", "&"):gsub("&quot;", '"'):gsub("&#39;", "'")
                return ex
            end
        else
            return content
        end
    end

    ok, content = pcall(function() return game:HttpGetAsync(url) end)
    if ok and content and #content > 20 then return content end

    if syn and syn.request then
        local res = syn.request({Url = url, Method = "GET"})
        if res and res.Body and #res.Body > 20 then return res.Body end
    end

    if request then
        local res = request({Url = url, Method = "GET"})
        if res and res.Body and #res.Body > 20 then return res.Body end
    end

    if http_request then
        local res = http_request({Url = url, Method = "GET"})
        if res and res.Body and #res.Body > 20 then return res.Body end
    end

    return nil
end

-- ========================================================================
-- PARSE
-- ========================================================================

local function cleanContent(c)
    if not c then return nil end
    c = c:gsub("^\239\187\191", "")
    return c:match("^%s*(.-)%s*$") or c
end

local function parseRoute(content)
    if not content or #content < 10 then return nil end

    content = cleanContent(content)
    if not content then return nil end

    content = content:gsub("\r\n", "\n")

    local fOk, f = pcall(function() return loadstring(content) end)
    if fOk and f then
        local rOk, r = pcall(f)
        if rOk and type(r) == "table" and #r > 0 then return r end
    end

    if content:sub(1,1) == "[" or content:sub(1,1) == "{" then
        local jOk, j = pcall(function() return HttpService:JSONDecode(content) end)
        if jOk and type(j) == "table" and #j > 0 then return j end
    end

    local wrapped = "return (function() " .. content .. " end)()"
    local wOk, wf = pcall(function() return loadstring(wrapped) end)
    if wOk and wf then
        local wrOk, wr = pcall(wf)
        if wrOk and type(wr) == "table" and #wr > 0 then return wr end
    end

    return nil
end

-- ========================================================================
-- PLAYBACK
-- ========================================================================

local playbackConnection = nil
local activeRouteName = nil
local activeVisualName = nil

local originalCollides = {}
local antiGravity = nil

local function stopPlayback()
    if playbackConnection then
        playbackConnection:Disconnect()
        playbackConnection = nil
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")

    if antiGravity then
        pcall(function() antiGravity:Destroy() end)
        antiGravity = nil
    end

    if hum then hum.AutoRotate = true end

    for part, status in pairs(originalCollides) do
        if part and part.Parent then
            part.CanCollide = status
        end
    end

    table.clear(originalCollides)
    activeRouteName = nil
end

-- ========================================================================
-- START ROUTE (INSTANTÂNEO + TOGGLE)
-- ========================================================================

local function startRoute(routeKey)
    if playbackConnection and activeRouteName == routeKey then
        stopPlayback()
        Notify("Miragem já foi também 💀💀", "Execução interrompida.")
        return
    end

    if playbackConnection then
        pcall(function() playbackConnection:Disconnect() end)
        playbackConnection = nil
    end

    local pathData = _G.SavedPaths[routeKey]
    if not pathData or #pathData == 0 then
        Notify("Erro", "Rota não carregada!")
        return
    end

    activeRouteName = routeKey
    local path = preprocessPath(pathData)

    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    local startCF = path[1].CFrameInstance
    if not startCF then return end

    pcall(function() hrp.CFrame = startCF end)
    hum.AutoRotate = false

    if antiGravity then
        pcall(function() antiGravity:Destroy() end)
    end
    antiGravity = Instance.new("BodyForce")
    antiGravity.Parent = hrp

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            originalCollides[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    Notify("Miragem já foi também 💀💀", "Executando...")

    local startTime = os.clock()
    local totalPoints = #path
    local currentIndex = 1

    playbackConnection = RunService.Heartbeat:Connect(function()
        local elapsedTime = os.clock() - startTime

        while currentIndex < totalPoints
            and elapsedTime >= path[currentIndex + 1].Time do
            currentIndex += 1
        end

        if currentIndex >= totalPoints then
            stopPlayback()
            Notify("Miragem já foi também 💀💀", "Parkour finalizado!")
            return
        end

        local p0 = path[currentIndex]
        local p1 = path[currentIndex + 1]
        if not p0.CFrameInstance or not p1.CFrameInstance then
            stopPlayback()
            return
        end

        local alpha = (p1.Time - p0.Time > 0)
            and math.clamp((elapsedTime - p0.Time) / (p1.Time - p0.Time), 0, 1)
            or 1

        hrp.CFrame = p0.CFrameInstance:Lerp(p1.CFrameInstance, alpha)

        local totalMass = 0
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                totalMass += part:GetMass()
            end
        end

        if antiGravity and antiGravity.Parent then
            antiGravity.Force = Vector3.new(0, totalMass * workspace.Gravity, 0)
        end

        if p1.Velocity then
            hrp.AssemblyLinearVelocity = Vector3.new(
                p1.Velocity[1], p1.Velocity[2], p1.Velocity[3]
            )
        end

        if p0.State then
            pcall(function() hum:ChangeState(p0.State) end)
        end
    end)
end

-- ========================================================================
-- LINHA BONECO
-- ========================================================================

local activeTriggers = {}

local function removeTrigger(routeKey)
    local data = activeTriggers[routeKey]
    if not data then return end

    if data.model then pcall(function() data.model:Destroy() end) end
    if data.marker then pcall(function() data.marker:Destroy() end) end
    if data.inner then pcall(function() data.inner:Destroy() end) end

    activeTriggers[routeKey] = nil
end

local function clearAllTriggers()
    local keys = {}
    for k in pairs(activeTriggers) do table.insert(keys, k) end
    for _, k in ipairs(keys) do removeTrigger(k) end
end

local function createMarker(position)
    local marker = Instance.new("Part")
    marker.Name = "DripMarker"
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(0.35, 4, 4)
    marker.CFrame = CFrame.new(position - Vector3.new(0, 2.8, 0))
        * CFrame.Angles(0, 0, math.rad(90))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanQuery = false
    marker.CanTouch = false
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(50, 255, 120)
    marker.Transparency = 0.25
    marker.Parent = TriggerFolder

    local inner = Instance.new("Part")
    inner.Name = "DripMarkerInner"
    inner.Shape = Enum.PartType.Cylinder
    inner.Size = Vector3.new(0.5, 3, 3)
    inner.CFrame = CFrame.new(position - Vector3.new(0, 2.75, 0))
        * CFrame.Angles(0, 0, math.rad(90))
    inner.Anchored = true
    inner.CanCollide = false
    inner.CanQuery = false
    inner.CanTouch = false
    inner.Material = Enum.Material.ForceField
    inner.Color = Color3.fromRGB(80, 255, 150)
    inner.Transparency = 0.55
    inner.Parent = TriggerFolder

    return marker, inner
end

local function createFallback(startCF)
    local model = Instance.new("Model")
    model.Name = "DripBoneco"

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 3, 1)
    body.CFrame = startCF * CFrame.new(0, 1.5, 0)
    body.Anchored = true
    body.CanCollide = false
    body.CanTouch = true
    body.CanQuery = false
    body.Material = Enum.Material.ForceField
    body.Color = BONECO_COLOR
    body.Transparency = BONECO_TRANSPARENCY
    body.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(1.5, 1.5, 1.5)
    head.CFrame = startCF * CFrame.new(0, 3.8, 0)
    head.Anchored = true
    head.CanCollide = false
    head.CanTouch = true
    head.CanQuery = false
    head.Material = Enum.Material.ForceField
    head.Color = BONECO_COLOR
    head.Transparency = BONECO_TRANSPARENCY
    head.Parent = model

    model.Parent = TriggerFolder
    return model
end

local function buildClone(startCF)
    local char = LocalPlayer.Character
    if not char then return nil end

    local originalRoot = char:FindFirstChild("HumanoidRootPart")
    if not originalRoot then return nil end

    local oldArchivable = char.Archivable
    pcall(function() char.Archivable = true end)

    local clone = nil
    local ok = pcall(function() clone = char:Clone() end)

    pcall(function() char.Archivable = oldArchivable end)

    if not ok or not clone then return nil end

    clone.Name = "DripBoneco"

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("SurfaceAppearance") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript")
            or d:IsA("Sound") or d:IsA("ParticleEmitter") or d:IsA("Trail")
            or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
            pcall(function() d:Destroy() end)
        end
    end

    local rootOffset = originalRoot.CFrame
    local baseParts = 0

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            baseParts += 1

            local originalPartCF = d.CFrame
            local relCF = rootOffset:ToObjectSpace(originalPartCF)

            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = true
            d.CanQuery = false
            d.Massless = true
            d.Color = BONECO_COLOR
            d.Transparency = BONECO_TRANSPARENCY
            d.Material = Enum.Material.ForceField

            pcall(function()
                d.AssemblyLinearVelocity = Vector3.zero
                d.AssemblyAngularVelocity = Vector3.zero
            end)

            d.CFrame = startCF * relCF
        end

        if d:IsA("Decal") or d:IsA("Texture") then
            d.Transparency = 1
        end
    end

    local humanoid = clone:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end)
        pcall(function() humanoid.NameDisplayDistance = 0 end)
        pcall(function() humanoid.HealthDisplayDistance = 0 end)
        pcall(function() humanoid:Destroy() end)
    end

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint")
            or d:IsA("ManualWeld") then
            pcall(function() d:Destroy() end)
        end
    end

    clone.Parent = TriggerFolder

    if baseParts <= 0 then
        pcall(function() clone:Destroy() end)
        return nil
    end

    return clone
end

local function createBoneco(routeKey)
    removeTrigger(routeKey)

    local pathData = _G.SavedPaths[routeKey]
    if not pathData or #pathData == 0 then
        Notify("Erro", "Rota ainda não carregou! Aguarde.")
        return
    end

    local path = preprocessPath(pathData)
    if not path or #path == 0 then
        Notify("Erro", "Path inválido.")
        return
    end

    local startCF = path[1].CFrameInstance
    if not startCF then
        Notify("Erro", "CFrame inicial inválido.")
        return
    end

    local clone = buildClone(startCF)
    local usingFallback = false

    if not clone then
        clone = createFallback(startCF)
        usingFallback = true
    end

    if not clone then
        Notify("Erro", "Não foi possível criar o boneco.")
        return
    end

    local marker, inner = createMarker(startCF.Position)

    activeTriggers[routeKey] = {
        model = clone,
        marker = marker,
        inner = inner,
        startCF = startCF,
        triggered = false
    }

    if usingFallback then
        Notify("Linha Boneco", "Boneco verde criado (fallback).")
    else
        Notify("Linha Boneco", "Boneco verde criado! Encoste nele.")
    end
end

local function toggleBoneco(routeKey)
    if activeTriggers[routeKey] then
        removeTrigger(routeKey)
        Notify("Linha Boneco", "Boneco desativado.")
    else
        createBoneco(routeKey)
    end
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for routeKey, data in pairs(activeTriggers) do
        if data.startCF and not data.triggered then
            local distance = (hrp.Position - data.startCF.Position).Magnitude

            if distance <= TRIGGER_RADIUS then
                data.triggered = true

                local triggerData = activeTriggers[routeKey]
                activeTriggers[routeKey] = nil

                if triggerData.model then
                    pcall(function() triggerData.model:Destroy() end)
                end
                if triggerData.marker then
                    pcall(function() triggerData.marker:Destroy() end)
                end
                if triggerData.inner then
                    pcall(function() triggerData.inner:Destroy() end)
                end

                Notify("Início", "Rota iniciada pelo boneco!")

                task.spawn(function()
                    startRoute(routeKey)
                end)
            end
        end
    end
end)

-- ========================================================================
-- CARREGAR ROTAS
-- ========================================================================

local function loadPermanentFiles()
    for name, url in pairs(_G.GlobalPaths) do
        if url and url ~= "" then
            task.spawn(function()
                local success = false
                local attempts = 0

                while not success and attempts < 15 do
                    attempts += 1

                    local content = fetchUrl(url)
                    if content then
                        local routeData = parseRoute(content)
                        if routeData and #routeData > 0 then
                            _G.SavedPaths[name] = routeData
                            success = true
                            print("[Drip] ✓ " .. name .. " (" .. #routeData .. " pontos)")
                        else
                            print("[Drip] ✗ Parse falhou: " .. name)
                        end
                    else
                        print("[Drip] ✗ Download falhou: " .. name)
                    end

                    if not success then task.wait(2) end
                end
            end)
        end
    end
end

loadPermanentFiles()



--========================================================--
-- PARKOURS / TORRES DA SOURCE DRIP
--========================================================--

local function MakeDripRouteSection(tab, sectionName, routeKey)
    local section = tab:Section({
        Title = sectionName,
        TextXAlignment = "Left",
    })

    section:Button({
        Title = "▶ Iniciar",
        Callback = function()
            startRoute(routeKey)
        end,
    })

    section:Button({
        Title = "📍 Ver linha",
        Callback = function()
            if activeVisualName == routeKey then
                clearVisualPath()
                activeVisualName = nil
                Notify("Visualização", "Linha desativada.", 2)
            else
                local pathData = _G.SavedPaths[routeKey]
                if pathData and #pathData > 0 then
                    drawVisualPath(preprocessPath(pathData))
                    activeVisualName = routeKey
                    Notify("Visualização", "Linha ativada.", 2)
                else
                    Notify("Erro", "Rota não carregada.", 4)
                end
            end
        end,
    })

    section:Button({
        Title = "🧍 Linha Boneco",
        Callback = function()
            toggleBoneco(routeKey)
        end,
    })
end

MakeDripRouteSection(DripParkoursTab, "🏃 Parkour 1", "parkour1_rapido")
MakeDripRouteSection(DripParkoursTab, "🏃 Parkour 2", "parkour2_rapido")
MakeDripRouteSection(DripParkoursTab, "🏃 Parkour 3", "parkour3_rapido")
MakeDripRouteSection(DripParkoursTab, "🏃 Parkour 4", "parkour4_rapido")
MakeDripRouteSection(DripParkoursTab, "🏃 Parkour 5", "parkour5_rapido")
MakeDripRouteSection(TorresTab, "🗼 Torre 1", "torre1_rapido")
MakeDripRouteSection(TorresTab, "🗼 Torre 2", "torre2_rapido")

--========================================================--
-- PARKOUR
--========================================================--

local ParkourEnabled = false
local Hitboxes = {}

local function ClearHitboxes()

    for _, object in ipairs(Hitboxes) do

        pcall(function()
            object:Destroy()
        end)

    end

    table.clear(Hitboxes)
end

local function GetHitboxData()

    local source = SafeHttpGet(PARKOUR_URL)

    if not source then
        return nil
    end

    local tableText =
        source:match(
            "local hitboxData%s*=%s*(%b{})"
        )

    if not tableText then

        warn(
            "[Makima Scripts] hitboxData não encontrada."
        )

        return nil
    end

    local success, data = pcall(function()

        local fn = loadstring(
            "return " .. tableText
        )

        if not fn then
            error("Não foi possível interpretar hitboxData.")
        end

        return fn()

    end)

    if success and type(data) == "table" then
        return data
    end

    return nil
end

local function CreateHitboxes()

    ClearHitboxes()

    local hitboxData = GetHitboxData()

    if not hitboxData then

        Notify(
            "Parkour",
            "Não foi possível carregar os pontos do Parkour.",
            5
        )

        return false
    end

    for _, data in ipairs(hitboxData) do

        if data.pos and data.size then

            local part = Instance.new("Part")

            part.Name = "MakimaParkourHitbox"

            part.Size = data.size

            part.Position = data.pos

            part.Anchored = true

            part.Transparency = 1

            part.CanCollide = false

            part.Parent = workspace

            local selection =
                Instance.new("SelectionBox")

            selection.Adornee = part

            selection.Color3 =
                Color3.fromRGB(
                    190,
                    20,
                    45
                )

            selection.SurfaceTransparency = 0.5

            selection.LineThickness = 0.05

            selection.Parent = part

            table.insert(
                Hitboxes,
                part
            )

        end

    end

    return true
end

ParkourTab:Paragraph({

    Title = "Parkour Auxiliar",

    Desc =
        "Auxilia nos obstáculos do Parkour.",

    Color = "Red",
})

ParkourTab:Toggle({

    Title = "Parkour Auxiliar",

    Desc =
        "Ativa ou desativa os auxiliares.",

    Value = false,

    Callback = function(state)

        ParkourEnabled = state

        if state then

            if CreateHitboxes() then

                Notify(
                    "Parkour",
                    "Ativado.",
                    2
                )

            else

                ParkourEnabled = false

            end

        else

            ClearHitboxes()

            Notify(
                "Parkour",
                "Desativado.",
                2
            )

        end

    end,
})

RunService.Heartbeat:Connect(function()

    if not ParkourEnabled then
        return
    end

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    local velocityY =
        root.AssemblyLinearVelocity.Y

    for _, part in ipairs(Hitboxes) do

        if part
            and part.Parent then

            part.CanCollide =
                (
                    velocityY <= 0.5
                    and
                    root.Position.Y >
                    (
                        part.Position.Y
                        + part.Size.Y / 2
                        - 1
                    )
                )

        end

    end

end)

--========================================================--
-- TAS | SISTEMA DE MOVIMENTO DO MAKIMA SCRIPTS
--========================================================--
--
-- Esta versão NÃO reproduz CFrame/teleporte por frame.
-- O TAS grava a direção de movimento e eventos de pulo e reproduz
-- esses comandos através do Humanoid, mantendo as animações normais.
--
-- Arquivos:
--   MakimaScripts/TAS/Saved/   -> biblioteca local do usuário
--   MakimaScripts/TAS/Exports/ -> arquivos exportados para o dispositivo

local TAS_FOLDER = "MakimaScripts/TAS"
local TAS_SAVED_FOLDER = TAS_FOLDER .. "/Saved"
local TAS_EXPORT_FOLDER = TAS_FOLDER .. "/Exports"
local TAS_VERSION = 3
local TAS_RECORD_RATE = 60
local TAS_ENABLED = false
local TAS_RECORDING = false
local TAS_PLAYING = false
local TAS_STOP_REQUESTED = false
local TAS_AUTO_WALK = true
local TAS_CURRENT_NAME = "MeuTAS"
local TAS_CURRENT_DATA = nil
local TAS_RECORD = nil
local TAS_START_MARKER = nil
local TAS_TRAJECTORY_FOLDER = nil
local TAS_SELECTED_NAME = nil
local TAS_SAVED_DROPDOWN = nil
local TAS_STATUS = nil
local TAS_RECORD_TOGGLE = nil
local TAS_PLAY_TOGGLE = nil
local TAS_TOGGLE_UPDATING = false
local TAS_JUMP_CONNECTION = nil
local TASNameInput = nil
local TASRenameInput = nil
local TASControlsSection = nil

local function TASFileAPI()
    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function TASNormalizeName(name)
    name = tostring(name or "MeuTAS")
    name = name:gsub("[^%w_%-%s]", "")
    name = name:gsub("%s+", "_")
    if name == "" then name = "MeuTAS" end
    return name
end

local function TASEnsureFolders()
    if type(makefolder) ~= "function" then return true end
    pcall(function()
        if type(isfolder) ~= "function" or not isfolder("MakimaScripts") then makefolder("MakimaScripts") end
        if type(isfolder) ~= "function" or not isfolder(TAS_FOLDER) then makefolder(TAS_FOLDER) end
        if type(isfolder) ~= "function" or not isfolder(TAS_SAVED_FOLDER) then makefolder(TAS_SAVED_FOLDER) end
        if type(isfolder) ~= "function" or not isfolder(TAS_EXPORT_FOLDER) then makefolder(TAS_EXPORT_FOLDER) end
    end)
    return true
end

local function TASSavedPath(name)
    return TAS_SAVED_FOLDER .. "/" .. TASNormalizeName(name) .. ".json"
end

local function TASExportPath(name)
    return TAS_EXPORT_FOLDER .. "/" .. TASNormalizeName(name) .. ".json"
end

local function TASClearVisuals()
    if TAS_TRAJECTORY_FOLDER then pcall(function() TAS_TRAJECTORY_FOLDER:Destroy() end) end
    TAS_TRAJECTORY_FOLDER = nil
    if TAS_START_MARKER then pcall(function() TAS_START_MARKER:Destroy() end) end
    TAS_START_MARKER = nil
end

local function TASArrayToVector(v)
    if type(v) ~= "table" or #v < 3 then return Vector3.zero end
    return Vector3.new(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)
end

local function TASVectorToArray(v)
    return {v.X, v.Y, v.Z}
end

local function TASGetCharacter()
    local character = LocalPlayer.Character
    if not character then return nil, nil, nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function TASWaitForCharacter()
    for _ = 1, 100 do
        local c, h, r = TASGetCharacter()
        if c and h and r and h.Health > 0 then return c, h, r end
        task.wait(0.1)
    end
    return nil, nil, nil
end

local function TASShowStartArea(position)
    if TAS_START_MARKER then pcall(function() TAS_START_MARKER:Destroy() end) end
    if not position then return end

    local marker = Instance.new("Part")
    marker.Name = "MakimaTASStartArea"
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.Size = Vector3.new(8, 0.12, 8)
    marker.Position = position - Vector3.new(0, 2.8, 0)
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(40, 255, 100)
    marker.Transparency = 0.42
    marker.Parent = workspace

    local box = Instance.new("SelectionBox")
    box.Adornee = marker
    box.Color3 = Color3.fromRGB(40, 255, 100)
    box.LineThickness = 0.05
    box.SurfaceTransparency = 0.55
    box.Parent = marker
    TAS_START_MARKER = marker
end

local function TASDrawTrajectory(samples)
    TASClearVisuals()
    if type(samples) ~= "table" or #samples < 2 then return end

    TAS_TRAJECTORY_FOLDER = Instance.new("Folder")
    TAS_TRAJECTORY_FOLDER.Name = "MakimaTASTrajectory"
    TAS_TRAJECTORY_FOLDER.Parent = workspace

    local lastPosition = nil
    for i, sample in ipairs(samples) do
        if i % 3 == 1 and sample.p then
            local position = TASArrayToVector(sample.p)
            if lastPosition then
                local delta = position - lastPosition
                local length = delta.Magnitude
                if length > 0.05 then
                    local line = Instance.new("Part")
                    line.Name = "TASLine"
                    line.Anchored = true
                    line.CanCollide = false
                    line.CanTouch = false
                    line.CanQuery = false
                    line.Material = Enum.Material.Neon
                    line.Color = Color3.fromRGB(255, 45, 70)
                    line.Transparency = 0.18
                    line.Size = Vector3.new(0.10, 0.10, length)
                    line.CFrame = CFrame.lookAt((lastPosition + position) / 2, position)
                    line.Parent = TAS_TRAJECTORY_FOLDER
                end
            end
            lastPosition = position
        end
    end

    if samples[1] and samples[1].p then
        TASShowStartArea(TASArrayToVector(samples[1].p))
    end
end

local function TASEncode(data)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    return ok and encoded or nil
end

local function TASDecode(raw)
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    return ok and type(data) == "table" and data or nil
end

local function TASValidate(data)
    if type(data) ~= "table" then return false, "Arquivo inválido." end
    if tonumber(data.Version) ~= TAS_VERSION then return false, "Versão incompatível." end
    if tonumber(data.PlaceId) ~= game.PlaceId then return false, "Esse TAS pertence a outro jogo." end
    if type(data.Samples) ~= "table" or #data.Samples < 2 then return false, "O TAS não possui movimento suficiente." end
    return true
end

local function TASBuildData(name, samples)
    local first = samples[1]
    return {
        Version = TAS_VERSION,
        Name = TASNormalizeName(name),
        PlaceId = game.PlaceId,
        CreatedAt = os.time(),
        SampleRate = TAS_RECORD_RATE,
        StartPosition = first and first.p or nil,
        Samples = samples,
    }
end

local function TASWrite(path, data)
    if not TASFileAPI() then
        Notify("TAS", "Seu ambiente não permite arquivos locais.", 5)
        return false
    end
    TASEnsureFolders()
    local encoded = TASEncode(data)
    if not encoded then
        Notify("TAS", "Não foi possível criar o arquivo JSON.", 5)
        return false
    end
    local ok = pcall(function() writefile(path, encoded) end)
    if not ok then
        Notify("TAS", "Não foi possível salvar o arquivo.", 5)
        return false
    end
    return true
end

local function TASRead(path)
    if not TASFileAPI() or not isfile(path) then return nil end
    local raw
    local ok = pcall(function() raw = readfile(path) end)
    if not ok or type(raw) ~= "string" then return nil end
    local data = TASDecode(raw)
    local valid = data and TASValidate(data)
    if not valid then return nil end
    return data
end

local function TASListSaved()
    local names = {}
    if type(listfiles) ~= "function" then return names end
    TASEnsureFolders()
    local ok, files = pcall(function() return listfiles(TAS_SAVED_FOLDER) end)
    if not ok or type(files) ~= "table" then return names end
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

local function TASRefreshSavedList()
    if not TAS_SAVED_DROPDOWN then return end
    local values = TASListSaved()
    if #values == 0 then values = {"Nenhum TAS salvo"} end
    pcall(function() TAS_SAVED_DROPDOWN:Refresh(values) end)
end

local function TASLoadSelected()
    if not TAS_SELECTED_NAME or TAS_SELECTED_NAME == "Nenhum TAS salvo" then return nil end
    local data = TASRead(TASSavedPath(TAS_SELECTED_NAME))
    if not data then
        Notify("TAS", "Não foi possível carregar " .. tostring(TAS_SELECTED_NAME) .. ".", 4)
        return nil
    end
    TAS_CURRENT_DATA = data
    TAS_CURRENT_NAME = TASNormalizeName(data.Name or TAS_SELECTED_NAME)
    TASDrawTrajectory(data.Samples)
    if TASNameInput then pcall(function() TASNameInput:Set(TAS_CURRENT_NAME) end) end
    return data
end

local function TASSetToggle(toggle, state)
    if not toggle then return end
    if TAS_TOGGLE_UPDATING then return end
    TAS_TOGGLE_UPDATING = true
    pcall(function() toggle:Set(state) end)
    TAS_TOGGLE_UPDATING = false
end

local function TASStop()
    TAS_STOP_REQUESTED = true
    TAS_RECORDING = false
    TAS_PLAYING = false
    TASSetToggle(TAS_RECORD_TOGGLE, false)
    TASSetToggle(TAS_PLAY_TOGGLE, false)
    local _, humanoid = TASGetCharacter()
    if humanoid then
        pcall(function() humanoid:Move(Vector3.zero, false) end)
        pcall(function() humanoid.Jump = false end)
        pcall(function() humanoid.AutoRotate = true end)
    end
end

local function TASStartRecording(name)
    if not TAS_ENABLED then Notify("TAS", "Ative o TAS primeiro.", 3); return end
    if TAS_RECORDING or TAS_PLAYING then Notify("TAS", "Pare o TAS atual primeiro.", 3); return end
    local _, humanoid, root = TASWaitForCharacter()
    if not humanoid or not root then Notify("TAS", "Personagem não encontrado.", 4); return end

    TASClearVisuals()
    TAS_CURRENT_NAME = TASNormalizeName(name)
    TAS_RECORD = {started = os.clock(), accumulator = 0, samples = {}}
    TAS_RECORDING = true
    TAS_STOP_REQUESTED = false
    table.insert(TAS_RECORD.samples, {
        t = 0,
        p = TASVectorToArray(root.Position),
        d = TASVectorToArray(humanoid.MoveDirection),
        j = false,
    })

    if TAS_JUMP_CONNECTION then
        pcall(function() TAS_JUMP_CONNECTION:Disconnect() end)
        TAS_JUMP_CONNECTION = nil
    end

    TAS_JUMP_CONNECTION = humanoid.StateChanged:Connect(function(_, newState)
        if not TAS_RECORDING or not TAS_RECORD then return end
        if newState == Enum.HumanoidStateType.Jumping then
            local _, currentHumanoid, currentRoot = TASGetCharacter()
            if currentHumanoid and currentRoot then
                table.insert(TAS_RECORD.samples, {
                    t = os.clock() - TAS_RECORD.started,
                    p = TASVectorToArray(currentRoot.Position),
                    d = TASVectorToArray(currentHumanoid.MoveDirection),
                    j = true,
                })
            end
        end
    end)

    Notify("TAS", "Gravando movimento: " .. TAS_CURRENT_NAME, 3)
end

local function TASFinishRecording()
    if not TAS_RECORDING or not TAS_RECORD then return nil end
    TAS_RECORDING = false
    TASSetToggle(TAS_RECORD_TOGGLE, false)

    if TAS_JUMP_CONNECTION then
        pcall(function() TAS_JUMP_CONNECTION:Disconnect() end)
        TAS_JUMP_CONNECTION = nil
    end

    local samples = TAS_RECORD.samples
    TAS_RECORD = nil
    if #samples < 2 then
        Notify("TAS", "Movimento insuficiente.", 4)
        return nil
    end

    TAS_CURRENT_DATA = TASBuildData(TAS_CURRENT_NAME, samples)
    TAS_CURRENT_NAME = TASNormalizeName(TAS_CURRENT_DATA.Name)

    -- Salva automaticamente assim que a gravação termina.
    if TASWrite(TASSavedPath(TAS_CURRENT_NAME), TAS_CURRENT_DATA) then
        TAS_SELECTED_NAME = TAS_CURRENT_NAME
        TASRefreshSavedList()
        pcall(function()
            if TAS_SAVED_DROPDOWN then TAS_SAVED_DROPDOWN:Select(TAS_SELECTED_NAME) end
        end)
        pcall(function()
            if TASNameInput then TASNameInput:Set(TAS_CURRENT_NAME) end
            if TASRenameInput then TASRenameInput:Set(TAS_CURRENT_NAME) end
        end)
        Notify("TAS", "Gravação finalizada e salva automaticamente.", 3)
    else
        Notify("TAS", "Gravação finalizada, mas não foi possível salvar automaticamente.", 4)
    end

    TASDrawTrajectory(samples)
    return TAS_CURRENT_DATA
end

local function TASRecordSample()
    if not TAS_RECORDING or not TAS_RECORD then return end
    local _, humanoid, root = TASGetCharacter()
    if humanoid and root then
        table.insert(TAS_RECORD.samples, {
            t = os.clock() - TAS_RECORD.started,
            p = TASVectorToArray(root.Position),
            d = TASVectorToArray(humanoid.MoveDirection),
            j = false,
        })
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not TAS_RECORDING or not TAS_RECORD then return end
    TAS_RECORD.accumulator += dt
    local interval = 1 / TAS_RECORD_RATE
    while TAS_RECORD.accumulator >= interval do
        TAS_RECORD.accumulator -= interval
        TASRecordSample()
    end
end)

local function TASMoveToStart(position)
    if not TAS_AUTO_WALK or not position then return true end
    local _, humanoid, root = TASWaitForCharacter()
    if not humanoid or not root then return false end
    if (root.Position - position).Magnitude <= 5 then return true end

    local ok, path = pcall(function()
        local p = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 3})
        p:ComputeAsync(root.Position, position)
        return p
    end)

    if ok and path and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if TAS_STOP_REQUESTED then return false end
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(waypoint.Position)
            local reached = humanoid.MoveToFinished:Wait()
            if not reached and (root.Position - position).Magnitude > 5 then break end
        end
    else
        humanoid:MoveTo(position)
        local deadline = os.clock() + 12
        while os.clock() < deadline and not TAS_STOP_REQUESTED do
            if (root.Position - position).Magnitude <= 5 then break end
            task.wait(0.1)
        end
    end
    return not TAS_STOP_REQUESTED and (root.Position - position).Magnitude <= 7
end

local function TASPlay(data)
    if not TAS_ENABLED then Notify("TAS", "Ative o TAS primeiro.", 3); return end
    if TAS_RECORDING or TAS_PLAYING then Notify("TAS", "Pare o TAS atual primeiro.", 3); return end

    local valid, reason = TASValidate(data)
    if not valid then Notify("TAS", reason, 4); return end

    TAS_PLAYING = true
    TAS_STOP_REQUESTED = false
    TASDrawTrajectory(data.Samples)

    task.spawn(function()
        local startPos = TASArrayToVector(data.Samples[1].p)

        if not TASMoveToStart(startPos) then
            TAS_PLAYING = false
            TASSetToggle(TAS_PLAY_TOGGLE, false)
            Notify("TAS", "Não foi possível chegar ao início.", 4)
            return
        end

        local _, humanoid, root = TASWaitForCharacter()
        if not humanoid or not root then
            TAS_PLAYING = false
            TASSetToggle(TAS_PLAY_TOGGLE, false)
            Notify("TAS", "Personagem não encontrado.", 4)
            return
        end

        pcall(function()
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
            humanoid:Move(Vector3.zero, false)
        end)

        local samples = data.Samples
        local startClock = os.clock()
        local sampleIndex = 1
        local lastJumpTime = -math.huge
        local connection

        -- O controle padrão do Roblox também escreve o MoveDirection.
        -- RenderStep em prioridade alta mantém o movimento do TAS aplicado
        -- depois do PlayerModule, sem mover o RootPart por CFrame.
        local bindName = "MakimaTASPlayback"
        pcall(function() RunService:UnbindFromRenderStep(bindName) end)
        RunService:BindToRenderStep(bindName, 201, function()
            if TAS_STOP_REQUESTED or not TAS_PLAYING then
                pcall(function() RunService:UnbindFromRenderStep(bindName) end)
                return
            end

            local elapsed = os.clock() - startClock

            while sampleIndex < #samples and (tonumber(samples[sampleIndex + 1].t) or 0) <= elapsed do
                sampleIndex += 1
            end

            local current = samples[sampleIndex]
            if not current then return end

            local direction = TASArrayToVector(current.d)
            if direction.Magnitude > 1 then direction = direction.Unit end

            pcall(function()
                humanoid:Move(direction, false)
                humanoid.AutoRotate = true
                humanoid.PlatformStand = false
            end)

            if current.j and (elapsed - lastJumpTime) > 0.05 then
                pcall(function() humanoid.Jump = true end)
                lastJumpTime = elapsed
            end

            if elapsed >= (tonumber(samples[#samples].t) or 0) then
                pcall(function() RunService:UnbindFromRenderStep(bindName) end)
                pcall(function()
                    humanoid:Move(Vector3.zero, false)
                    humanoid.Jump = false
                    humanoid.AutoRotate = true
                    humanoid.PlatformStand = false
                end)
                TAS_PLAYING = false
                TAS_STOP_REQUESTED = false
                TASSetToggle(TAS_PLAY_TOGGLE, false)
                Notify("TAS", "Reprodução concluída.", 3)
            end
        end)

        while TAS_PLAYING and not TAS_STOP_REQUESTED do
            task.wait(0.1)
        end

        if connection then pcall(function() connection:Disconnect() end) end
    end)
end

--========================================================--
-- UI DO TAS
--========================================================--

local function BuildTASControls()
    if TASControlsSection then return end
    local ok, section = pcall(function()
        return ParkourTab:Section({
            Title = "TAS",
            Desc = "Grave e reproduza movimento real do Humanoid com timing preciso.",
            Box = true,
            BoxBorder = true,
            Opened = true,
        })
    end)
    if not ok or not section then
        warn("[Makima Scripts] Falha ao criar a seção TAS:", section)
        return
    end
    TASControlsSection = section
    pcall(function() TASControlsSection.ElementFrame.Visible = false end)

    pcall(function()
        TASControlsSection:Paragraph({
            Title = "⚠ TAS em Beta",
            Desc = "Pode não funcionar perfeitamente em todos os parkours e situações.",
            Color = "Yellow",
        })
    end)

    local function AddElement(method, config)
        local success, element = pcall(function() return TASControlsSection[method](TASControlsSection, config) end)
        if not success then warn("[Makima Scripts] Erro TAS " .. method .. ":", element); return nil end
        return element
    end

    TASNameInput = AddElement("Input", {
        Title = "Nome do TAS",
        Desc = "Nome da gravação.",
        Value = TAS_CURRENT_NAME,
        Placeholder = "Ex.: MeuParkour",
        InputIcon = "file-video",
        Callback = function(value) TAS_CURRENT_NAME = TASNormalizeName(value) end,
    })

    TASRenameInput = AddElement("Input", {
        Title = "Novo nome do TAS",
        Desc = "Digite o novo nome antes de clicar em Renomear.",
        Value = TAS_CURRENT_NAME,
        Placeholder = "Ex.: EB_Torre_A",
        InputIcon = "pencil",
        Callback = function(value) end,
    })

    TAS_SAVED_DROPDOWN = AddElement("Dropdown", {
        Title = "Meus TAS salvos",
        Desc = "Selecione uma gravação salva na sua biblioteca local.",
        Values = {"Nenhum TAS salvo"},
        Value = "Nenhum TAS salvo",
        SearchBarEnabled = true,
        AllowNone = true,
        Callback = function(option)
            if type(option) == "string" then
                TAS_SELECTED_NAME = option
                TASLoadSelected()
            end
        end,
    })

    AddElement("Toggle", {
        Title = "Ir até o início automaticamente",
        Desc = "Anda normalmente até o ponto inicial antes de reproduzir.",
        Value = TAS_AUTO_WALK,
        Callback = function(state) TAS_AUTO_WALK = state end,
    })

    TAS_RECORD_TOGGLE = AddElement("Toggle", {
        Title = "⏺ Gravar TAS",
        Desc = "Ative para gravar movimento. Ao desligar, salva automaticamente na sua Hub.",
        Value = false,
        Callback = function(state)
            if TAS_TOGGLE_UPDATING then return end
            if state then
                if TAS_PLAYING then
                    TASSetToggle(TAS_RECORD_TOGGLE, false)
                    Notify("TAS", "Pare a reprodução antes de gravar.", 3)
                    return
                end
                TASStartRecording(TAS_CURRENT_NAME)
                if not TAS_RECORDING then TASSetToggle(TAS_RECORD_TOGGLE, false) end
            else
                if TAS_RECORDING then
                    TASFinishRecording()
                end
            end
        end,
    })

    TAS_PLAY_TOGGLE = AddElement("Toggle", {
        Title = "▶ Executar TAS",
        Desc = "Ative para executar o TAS selecionado. Desliga sozinho ao terminar.",
        Value = false,
        Callback = function(state)
            if TAS_TOGGLE_UPDATING then return end
            if state then
                if TAS_RECORDING then
                    TASSetToggle(TAS_PLAY_TOGGLE, false)
                    Notify("TAS", "Finalize a gravação antes de reproduzir.", 3)
                    return
                end
                if not TAS_CURRENT_DATA and TAS_SELECTED_NAME then TASLoadSelected() end
                if TAS_CURRENT_DATA then
                    TASPlay(TAS_CURRENT_DATA)
                    if not TAS_PLAYING then TASSetToggle(TAS_PLAY_TOGGLE, false) end
                else
                    TASSetToggle(TAS_PLAY_TOGGLE, false)
                    Notify("TAS", "Selecione ou grave um TAS primeiro.", 4)
                end
            else
                if TAS_PLAYING then
                    TASStop()
                    Notify("TAS", "Reprodução interrompida.", 2)
                end
            end
        end,
    })

    AddElement("Button", {
        Title = "🗑 Excluir TAS selecionado",
        Desc = "Remove a gravação da biblioteca local.",
        Icon = "trash-2",
        Callback = function()
            if not TAS_SELECTED_NAME or TAS_SELECTED_NAME == "Nenhum TAS salvo" then Notify("TAS", "Nenhum TAS selecionado.", 3); return end
            if type(delfile) == "function" and isfile(TASSavedPath(TAS_SELECTED_NAME)) then
                pcall(function() delfile(TASSavedPath(TAS_SELECTED_NAME)) end)
                if TAS_CURRENT_DATA and TAS_CURRENT_DATA.Name == TAS_SELECTED_NAME then TAS_CURRENT_DATA = nil end
                TAS_SELECTED_NAME = nil
                TASClearVisuals()
                TASRefreshSavedList()
                Notify("TAS", "TAS excluído.", 3)
            else
                Notify("TAS", "Seu ambiente não suporta excluir arquivos.", 4)
            end
        end,
    })

    AddElement("Button", {
        Title = "📥 Importar do dispositivo",
        Desc = "Lê um JSON da pasta MakimaScripts/TAS/Exports usando o nome informado acima.",
        Icon = "download",
        Callback = function()
            local name = TASNormalizeName(TAS_CURRENT_NAME)
            local data = TASRead(TASExportPath(name))
            if not data then Notify("TAS", "Arquivo não encontrado em Exports: " .. name .. ".json", 4); return end

            TAS_CURRENT_DATA = data
            TAS_CURRENT_NAME = TASNormalizeName(data.Name or name)
            TAS_SELECTED_NAME = TAS_CURRENT_NAME

            if TASWrite(TASSavedPath(TAS_CURRENT_NAME), TAS_CURRENT_DATA) then
                TASRefreshSavedList()
                pcall(function()
                    if TAS_SAVED_DROPDOWN then TAS_SAVED_DROPDOWN:Select(TAS_SELECTED_NAME) end
                end)
            end

            TASDrawTrajectory(data.Samples)
            pcall(function()
                if TASNameInput then TASNameInput:Set(TAS_CURRENT_NAME) end
                if TASRenameInput then TASRenameInput:Set(TAS_CURRENT_NAME) end
            end)
            Notify("TAS", "Importado e adicionado à sua biblioteca: " .. TAS_CURRENT_NAME, 3)
        end,
    })

    AddElement("Button", {
        Title = "📤 Exportar para o dispositivo",
        Desc = "Cria um arquivo JSON em MakimaScripts/TAS/Exports/.",
        Icon = "upload",
        Callback = function()
            if TAS_RECORDING then TASFinishRecording() end
            if not TAS_CURRENT_DATA then Notify("TAS", "Grave ou carregue um TAS primeiro.", 4); return end
            local name = TASNormalizeName(TAS_CURRENT_NAME)
            TAS_CURRENT_DATA.Name = name
            if TASWrite(TASExportPath(name), TAS_CURRENT_DATA) then
                Notify("TAS", "Exportado para MakimaScripts/TAS/Exports/" .. name .. ".json", 4)
            end
        end,
    })

    AddElement("Button", {
        Title = "🧹 Limpar TAS atual",
        Desc = "Remove a gravação carregada e as linhas da tela, sem apagar arquivos salvos.",
        Icon = "eraser",
        Callback = function()
            TAS_CURRENT_DATA = nil
            TASClearVisuals()
            Notify("TAS", "TAS atual limpo.", 2)
        end,
    })

    TASRefreshSavedList()
end

BuildTASControls()

ParkourTab:Toggle({
    Title = "Ativar TAS",
    Desc = "Mostra os controles do sistema TAS.",
    Value = false,
    Callback = function(state)
        TAS_ENABLED = state
        if TASControlsSection and TASControlsSection.ElementFrame then
            pcall(function() TASControlsSection.ElementFrame.Visible = state end)
        end
        if not state then
            TASStop()
            TASClearVisuals()
            Notify("TAS", "Desativado.", 2)
        else
            TASRefreshSavedList()
            if TAS_CURRENT_DATA then TASDrawTrajectory(TAS_CURRENT_DATA.Samples) end
            Notify("TAS", "Sistema TAS ativado.", 2)
        end
    end,
})

--========================================================--
-- JJS | AUTO JJS INTEGRADO
--========================================================--

local JJSRunning = false
local JJSAmount = 10
local JJSInterval = 0.20
local JJSStartedAt = 0
local JJS_TOGGLE = nil
local JJS_TOGGLE_UPDATING = false

local function JJSGetRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    local remote = remotes:FindFirstChild("Polichinelos")
    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
    return nil
end

local function JJSGetScreen()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local polichinelos = playerGui:FindFirstChild("Polichinelos")
    if not polichinelos then return nil end
    return polichinelos:FindFirstChild("Screen")
end

local function JJSFindTapButton(screen, processed)
    if not screen then return nil end

    for _, object in ipairs(screen:GetChildren()) do
        if object:IsA("ImageButton")
            and object.Visible
            and not processed[object]
            and not object:GetAttribute("Completed") then
            local label = object:FindFirstChildWhichIsA("TextLabel")
            if label and tostring(label.Text or ""):upper():gsub("%s+", "") == "TAP" then
                return object
            end
        end
    end

    for _, object in ipairs(screen:GetDescendants()) do
        if object:IsA("GuiButton")
            and object.Visible
            and not processed[object]
            and not object:GetAttribute("Completed") then
            local label = object:FindFirstChildWhichIsA("TextLabel")
            local text = label and tostring(label.Text or "") or tostring(object.Text or "")
            local normalized = text:upper():gsub("%s+", "")
            if normalized == "TAP" or tostring(object.Name):upper() == "TAP" then
                return object
            end
        end
    end

    return nil
end

local function JJSActivateButton(button)
    if not button then return false end
    local fired = false

    pcall(function()
        if type(firesignal) == "function" then
            firesignal(button.MouseButton1Down)
            firesignal(button.MouseButton1Click)
            firesignal(button.TouchTap)
        end
    end)

    pcall(function()
        button:Activate()
        fired = true
    end)

    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local x = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
        local y = button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
        vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.01)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
        fired = true
    end)

    return fired
end

local function JJSSetToggle(state)
    if not JJS_TOGGLE then return end
    JJS_TOGGLE_UPDATING = true
    pcall(function() JJS_TOGGLE:Set(state) end)
    JJS_TOGGLE_UPDATING = false
end

local function JJSStop(silent)
    JJSRunning = false
    if not silent then
        JJSSetToggle(false)
        Notify("Auto JJs", "Interrompido.", 2)
    end
end

local function JJSStart()
    if JJSRunning then
        Notify("Auto JJs", "O Auto JJs já está ativo.", 3)
        return
    end

    local amount = math.max(1, math.floor(tonumber(JJSAmount) or 10))
    local interval = math.max(0.05, tonumber(JJSInterval) or 0.20)

    JJSRunning = true
    JJSStartedAt = os.clock()

    task.spawn(function()
        local remote = JJSGetRemote()
        if not remote then
            JJSStop(true)
            JJSSetToggle(false)
            Notify("Auto JJs", "Remote Polichinelos não encontrado.", 5)
            return
        end

        pcall(function() remote:FireServer("Prepare") end)
        task.wait()
        pcall(function() remote:FireServer("Start") end)

        local processed = {}
        local completed = 0
        local startedWait = os.clock()
        local maxWait = math.max(15, amount * math.max(interval, 0.20) + 10)

        while JJSRunning and completed < amount do
            if os.clock() - startedWait > maxWait then
                break
            end

            local screen = JJSGetScreen()
            local button = JJSFindTapButton(screen, processed)

            if button then
                processed[button] = true

                if JJSActivateButton(button) then
                    pcall(function() remote:FireServer("Add", 1) end)
                    completed += 1
                end

                if completed < amount then
                    task.wait(interval)
                end
            else
                task.wait(0.01)
            end

            local count = 0
            for _ in pairs(processed) do count += 1 end
            if count > 15 then table.clear(processed) end
        end

        local elapsed = os.clock() - JJSStartedAt
        JJSRunning = false
        JJSSetToggle(false)

        if completed >= amount then
            Notify("Auto JJs",
                string.format("Concluído: %d/%d JJs em %.2fs.", completed, amount, elapsed), 4)
        else
            Notify("Auto JJs",
                string.format("Parado: %d/%d JJs em %.2fs.", completed, amount, elapsed), 4)
        end
    end)
end

JJsTab:Paragraph({
    Title = "Auto JJs",
    Desc = "Executa os JJs usando o botão TAP real da interface.",
    Color = "Red",
})

JJsTab:Input({
    Title = "Quantidade de JJs",
    Desc = "Quantidade de TAPs que serão executados.",
    Value = "10",
    Placeholder = "Ex.: 10",
    InputIcon = "hash",
    Callback = function(value)
        local number = tonumber(value)
        if number then JJSAmount = math.max(1, math.floor(number)) end
    end,
})

JJsTab:Input({
    Title = "Intervalo entre JJs",
    Desc = "Tempo entre cada TAP. Padrão: 0,20 segundos.",
    Value = "0.20",
    Placeholder = "Ex.: 0.20",
    InputIcon = "timer",
    Callback = function(value)
        local number = tonumber(value)
        if number then JJSInterval = math.max(0.05, number) end
    end,
})

JJS_TOGGLE = JJsTab:Toggle({
    Title = "Auto JJs",
    Desc = "Executa a quantidade configurada e desliga ao terminar.",
    Value = false,
    Callback = function(state)
        if JJS_TOGGLE_UPDATING then return end
        if state then
            JJSStart()
        elseif JJSRunning then
            JJSStop(false)
        end
    end,
})

--========================================================--
-- FARM
--========================================================--

local Lixos = {

    Vector3.new(-393, 3, -872),
    Vector3.new(-389, 3, -1069),
    Vector3.new(-420, 3, -968),
    Vector3.new(-56, 3, -1134),
    Vector3.new(-154, 3, -1162),
    Vector3.new(113, 3, -1162),
    Vector3.new(204, 3, -1135),
    Vector3.new(225, 3, -974),
    Vector3.new(-52, 3, -895),
    Vector3.new(-32, 3, -974),
    Vector3.new(318, 3, -687),
    Vector3.new(139, 3, -691),
    Vector3.new(64, 3, -717),
    Vector3.new(469, 3, -880),
    Vector3.new(436, 3, -742),

}

local Lixeira =
    Vector3.new(
        -394.31,
        3.04,
        -779.87
    )

local Foice =
    Vector3.new(-91, 3, -512)

local Gramas = {

    Vector3.new(-199, 3, -520),
    Vector3.new(-241, 3, -659),
    Vector3.new(-377, 3, -773),
    Vector3.new(9, 3, -745),
    Vector3.new(-69, 3, -735),
    Vector3.new(-134, 3, -672),
    Vector3.new(-41, 3, -668),
    Vector3.new(-22, 3, -565),
    Vector3.new(-12, 3, -925),
    Vector3.new(45, 3, -886),
    Vector3.new(54, 3, -776),
    Vector3.new(-289, 3, -1113),
    Vector3.new(-204, 3, -1019),
    Vector3.new(-145, 3, -1095),
    Vector3.new(-95, 3, -1030),
    Vector3.new(-13, 3, -995),
    Vector3.new(-328, 3, -987),
    Vector3.new(-367, 3, -1110),

}

local CaixaPega =
    Vector3.new(
        77.48,
        3.04,
        -429.99
    )

local CaixaEntrega =
    Vector3.new(
        440.87,
        3.85,
        -224.70
    )

local AutoLixo = false
local AutoGrama = false
local AutoCaixa = false

local function TeleportTo(position)

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    root.CFrame =
        CFrame.new(
            position
            + Vector3.new(
                0,
                3,
                0
            )
        )
end

local function FireNearbyPrompts()

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    if type(fireproximityprompt) ~= "function" then

        return
    end

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do

        if object:IsA("ProximityPrompt")
            and object.Enabled then

            local parent = object.Parent

            if parent
                and parent:IsA("BasePart") then

                local distance =
                    (
                        parent.Position
                        - root.Position
                    ).Magnitude

                if distance <= 15 then

                    pcall(function()

                        fireproximityprompt(
                            object
                        )

                    end)

                end

            end

        end

    end
end

local function StartAutoLixo()

    task.spawn(function()

        while AutoLixo do

            for _, position in ipairs(Lixos) do

                if not AutoLixo then
                    break
                end

                TeleportTo(position)

                task.wait(1)

                FireNearbyPrompts()

                task.wait(1)

                TeleportTo(Lixeira)

                task.wait(1)

                FireNearbyPrompts()

                task.wait(1)

            end

        end

    end)
end

local function StartAutoGrama()

    task.spawn(function()

        TeleportTo(Foice)

        task.wait(1)

        FireNearbyPrompts()

        task.wait(1)

        while AutoGrama do

            for _, position in ipairs(Gramas) do

                if not AutoGrama then
                    break
                end

                TeleportTo(position)

                task.wait(1)

                FireNearbyPrompts()

                task.wait(1)

            end

        end

    end)
end

local function StartAutoCaixa()

    task.spawn(function()

        while AutoCaixa do

            TeleportTo(CaixaPega)

            task.wait(1)

            FireNearbyPrompts()

            task.wait(1)

            TeleportTo(CaixaEntrega)

            task.wait(1)

            FireNearbyPrompts()

            task.wait(2)

        end

    end)
end

FarmTab:Paragraph({

    Title = "Farms Automáticos",

    Desc =
        "Farms disponíveis no hub.",

    Color = "Red",
})

FarmTab:Toggle({

    Title = "Auto Lixo",

    Desc =
        "Coleta lixo automaticamente.",

    Value = false,

    Callback = function(state)

        AutoLixo = state

        if state then
            StartAutoLixo()
        end

    end,
})

FarmTab:Toggle({

    Title = "Auto Grama",

    Desc =
        "Corta grama automaticamente.",

    Value = false,

    Callback = function(state)

        AutoGrama = state

        if state then
            StartAutoGrama()
        end

    end,
})

FarmTab:Toggle({

    Title = "Auto Caixa",

    Desc =
        "Transporta caixas automaticamente.",

    Value = false,

    Callback = function(state)

        AutoCaixa = state

        if state then
            StartAutoCaixa()
        end

    end,
})

--========================================================--
-- PATCH
--========================================================--

PatchTab:Paragraph({
    Title = "Atualizações",
    Desc = "Novidades e correções recentes do Makima Scripts.",
    Color = "Red",
})

PatchTab:Paragraph({
    Title = "Versão atual",
    Desc = "Atualização de Farms + TAS em Beta.",
})

PatchTab:Paragraph({
    Title = "Novidades",
    Desc =
        "• Novos locais adicionados para a Farm de Lixo.\n"
        .. "• O ponto da lixeira foi mantido.\n"
        .. "• Novos locais adicionados para a Farm da Foice.\n"
        .. "• Novo ponto inicial para pegar a foice.\n"
        .. "• Aviso de Beta adicionado ao sistema TAS.\n"
        .. "• Melhorias gerais na organização das Farms.",
})

PatchTab:Paragraph({
    Title = "Correções",
    Desc =
        "• Atualizados os pontos usados pelas Farms de Lixo e Foice.\n"
        .. "• Ajustes gerais de estabilidade e interface.\n"
        .. "• O TAS permanece em Beta e pode apresentar falhas em alguns percursos.",
})

-- ========================================================================
-- ABA CHAR (10 botões)
-- ========================================================================

local charSection = DripCharTab:Section({
    Title = "🧑 Chars para copiar",
    TextXAlignment = "Left"
})

local charList = {
    "2_kd",
    "S4ENRIQUE",
    "GMIRASAWFAN",
    "THEAVENZFAMILY",
    "ETINHOZICA",
    "GATUNO77737",
    "COCA1REAL",
    "ARTHUR_TS10",
    "KLARKYTB",
    "MILYPIPOCA",
}

for _, name in ipairs(charList) do
    charSection:Button({
        Title = name,
        Callback = function()
            if copyText(name) then
                Notify("Char", "Copiado: " .. name)
            else
                Notify("Char", "Falha ao copiar: " .. name)
            end
        end
    })
end

-- ========================================================================
-- BRUTAL
-- ========================================================================

_G.AimbotEnabled    = false
_G.AimbotTeamCheck  = false
_G.AimbotSmoothness = 0.3
_G.AimbotFOV        = 90
_G.AimbotTargetPart = "Head"

_G.HitboxEnabled      = false
_G.HitboxSize         = 5
_G.HitboxColor        = Color3.fromRGB(255, 0, 0)
_G.HitboxTransparency = 0.5

local camera = workspace.CurrentCamera

local function isVisible(part)
    local ok, result = pcall(function()
        local ray = Ray.new(
            camera.CFrame.Position,
            (part.Position - camera.CFrame.Position).Unit * 500
        )
        local hit = workspace:FindPartOnRayWithIgnoreList(
            ray, { LocalPlayer.Character, camera }
        )
        return hit and hit:IsDescendantOf(part.Parent)
    end)
    return ok and result
end

local function getTarget()
    local closest, shortest = nil, _G.AimbotFOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not (_G.AimbotTeamCheck and player.Team == LocalPlayer.Team) then
                local targetPart = player.Character:FindFirstChild(_G.AimbotTargetPart)
                local hum = player.Character:FindFirstChildOfClass("Humanoid")

                if targetPart and hum and hum.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen then
                        local dist = (
                            Vector2.new(screenPos.X, screenPos.Y)
                            - Vector2.new(
                                camera.ViewportSize.X / 2,
                                camera.ViewportSize.Y / 2
                            )
                        ).Magnitude

                        if dist < shortest then
                            if isVisible(targetPart) then
                                shortest = dist
                                closest = targetPart
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local target = getTarget()
        if target then
            local goal = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, _G.AimbotSmoothness)
        end
    end
end)

-- ========================================================================
-- UI BRUTAL
-- ========================================================================

local brutalPage = DripBrutalTab:Section({ Title = "💀 Brutal", TextXAlignment = "Left" })

local aimbotOpen = false
local aimbotRefs = {}

local aimbotToggleBtn
aimbotToggleBtn = brutalPage:Button({
    Title = "▸ Aimbot",
    Callback = function()
        aimbotOpen = not aimbotOpen
        pcall(function()
            aimbotToggleBtn:SetTitle(aimbotOpen and "▾ Aimbot" or "▸ Aimbot")
        end)
        for _, obj in ipairs(aimbotRefs) do
            pcall(function() obj:SetVisible(aimbotOpen) end)
        end
    end
})

local function regAimbot(obj)
    pcall(function() obj:SetVisible(false) end)
    table.insert(aimbotRefs, obj)
end

regAimbot(brutalPage:Slider({
    Title = "Smooth (0.1 - 1.0)",
    Value = { Min = 0.1, Max = 1.0, Default = 0.3 },
    Callback = function(val) _G.AimbotSmoothness = val end
}))

regAimbot(brutalPage:Slider({
    Title = "FOV (60 - 120)",
    Value = { Min = 60, Max = 120, Default = 90 },
    Callback = function(val) _G.AimbotFOV = val end
}))

regAimbot(brutalPage:Toggle({
    Title = "Ativar Aimbot",
    Value = false,
    Callback = function(state)
        _G.AimbotEnabled = state
        Notify("Aimbot", state and "Ativado!" or "Desativado.")
    end
}))

regAimbot(brutalPage:Toggle({
    Title = "Grudar em Time",
    Value = false,
    Callback = function(state)
        _G.AimbotTeamCheck = not state
    end
}))

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "DripFovCircle"
fovGui.ResetOnSpawn = false
pcall(function() fovGui.Parent = game:GetService("CoreGui") end)
if not fovGui.Parent then
    fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local fovCircle = Instance.new("Frame", fovGui)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false

local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(220, 38, 38)
fovStroke.Thickness = 2
fovStroke.Transparency = 0.2

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Size = UDim2.new(0, _G.AimbotFOV * 2, 0, _G.AimbotFOV * 2)
    else
        fovCircle.Visible = false
    end
end)

-- HITBOX
local hitboxOpen = false
local hitboxRefs = {}

local hitboxToggleBtn
hitboxToggleBtn = brutalPage:Button({
    Title = "▸ Hitbox",
    Callback = function()
        hitboxOpen = not hitboxOpen
        pcall(function()
            hitboxToggleBtn:SetTitle(hitboxOpen and "▾ Hitbox" or "▸ Hitbox")
        end)
        for _, obj in ipairs(hitboxRefs) do
            pcall(function() obj:SetVisible(hitboxOpen) end)
        end
    end
})

local function regHitbox(obj)
    pcall(function() obj:SetVisible(false) end)
    table.insert(hitboxRefs, obj)
end

regHitbox(brutalPage:Slider({
    Title = "Tamanho (1 - 15)",
    Value = { Min = 1, Max = 15, Default = 5 },
    Callback = function(val) _G.HitboxSize = val end
}))

regHitbox(brutalPage:Slider({
    Title = "Transparência (0 - 1)",
    Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(val) _G.HitboxTransparency = val end
}))

regHitbox(brutalPage:Dropdown({
    Title = "Cor da Hitbox",
    Values = { "Vermelho", "Azul", "Preto" },
    Value = "Vermelho",
    Callback = function(val)
        if val == "Vermelho" then
            _G.HitboxColor = Color3.fromRGB(255, 0, 0)
        elseif val == "Azul" then
            _G.HitboxColor = Color3.fromRGB(0, 100, 255)
        elseif val == "Preto" then
            _G.HitboxColor = Color3.fromRGB(0, 0, 0)
        end
    end
}))

regHitbox(brutalPage:Toggle({
    Title = "Ativar Hitbox",
    Value = false,
    Callback = function(state)
        _G.HitboxEnabled = state
        Notify("Hitbox", state and "Ativada!" or "Desativada.")
    end
}))

local activeHitboxes = {}

RunService.Heartbeat:Connect(function()
    for player, box in pairs(activeHitboxes) do
        if not box or not box.Parent
            or not player.Character
            or not player.Character:FindFirstChild("HumanoidRootPart") then
            if box then
                pcall(function() box:Destroy() end)
            end
            activeHitboxes[player] = nil
        end
    end

    if not _G.HitboxEnabled then
        for player, box in pairs(activeHitboxes) do
            if box then
                pcall(function() box:Destroy() end)
            end
            activeHitboxes[player] = nil
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local box = activeHitboxes[player]
                if not box or not box.Parent then
                    box = Instance.new("Part")
                    box.Name = "DripHitbox_" .. player.Name
                    box.Shape = Enum.PartType.Ball
                    box.Anchored = true
                    box.CanCollide = false
                    box.CanQuery = false
                    box.CanTouch = false
                    box.Massless = true
                    box.Material = Enum.Material.ForceField
                    box.Parent = HitboxFolder
                    activeHitboxes[player] = box
                end

                box.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                box.Color = _G.HitboxColor
                box.Transparency = _G.HitboxTransparency
                box.CFrame = root.CFrame
            end
        end
    end
end)



PatchTab:Paragraph({
    Title = "Integração Drip Menu",
    Desc =
        "• 5 Parkours rápidos adicionados.\n"
        .. "• 2 Torres rápidas adicionadas.\n"
        .. "• Iniciar, Ver linha e Linha Boneco adicionados às rotas.\n"
        .. "• Aba Char adicionada com os 10 nomes da source.\n"
        .. "• Aba Brutal adicionada com Aimbot e Hitbox.\n"
        .. "• Círculo visual de FOV incluído.\n"
        .. "• Sistema de Unload pelo Delete adicionado.\n"
        .. "• Auto JJs próprio e Farms existentes foram preservados.",
})

--========================================================--
-- OUTROS
--========================================================--

OutrosTab:Paragraph({

    Title = "Outros",

    Desc =
        "Funções adicionais da Hub.",

    Color = "Red",
})

OutrosTab:Button({

    Title = "Liberar Chat",

    Desc =
        "Reativa o Chat do Roblox.",

    Callback = function()

        pcall(function()

            StarterGui:SetCoreGuiEnabled(
                Enum.CoreGuiType.Chat,
                true
            )

        end)

        pcall(function()

            StarterGui:SetCore(
                "ChatActive",
                true
            )

        end)

        pcall(function()

            TextChatService
                .ChatWindowConfiguration
                .Enabled = true

        end)

        pcall(function()

            TextChatService
                .ChatInputBarConfiguration
                .Enabled = true

        end)

        Notify(
            "Chat",
            "Comando executado.",
            3
        )

    end,
})

OutrosTab:Button({

    Title = "Copiar Link da Key",

    Desc =
        "Copia o link para obter sua Key.",

    Callback = function()

        local link = GetPandaKeyLink()
        if link then
            Copy(link)
        else
            Notify("Panda Auth", "Não foi possível obter o link da Key.", 4)
        end

    end,
})

OutrosTab:Button({

    Title = "Copiar Discord",

    Desc =
        "Copia o convite do Discord.",

    Callback = function()

        Copy(DISCORD_URL)

    end,
})

--========================================================--
-- CRÉDITOS
--========================================================--

CreditosTab:Paragraph({

    Title = "Makima Scripts",

    Desc =
        "Hub desenvolvida por MakimaDev.",

    Color = "Red",
})

CreditosTab:Paragraph({

    Title = "Criador",

    Desc =
        "MakimaDev",

    Color = "Red",
})

CreditosTab:Button({
    Title = "👑 O Caro rei 👑",
    Desc = "Crédito da source Drip Menu incorporada.",
    Callback = function()
        Notify("Créditos", "O Caro rei 👑", 3)
    end,
})

CreditosTab:Button({

    Title = "Discord",

    Desc =
        "discord.gg/4aEBbw7BQf",

    Callback = function()

        Copy(DISCORD_URL)

    end,
})

--========================================================--
-- FINAL
--========================================================--

Notify(
    "Makima Scripts",
    "Hub carregada.",
    3
)

print(
    "[Makima Scripts] Carregada."
)


--========================================================--
-- UNLOAD COMPLETO
--========================================================--

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= Enum.KeyCode.Delete then return end

    pcall(function() JJSStop(true) end)
    pcall(function() TASStop() end)
    pcall(function() stopPlayback() end)
    pcall(function() clearVisualPath() end)
    pcall(function() clearAllTriggers() end)
    pcall(function() ClearHitboxes() end)

    pcall(function()
        if fovGui then fovGui:Destroy() end
    end)

    pcall(function()
        if TAS_TRAJECTORY_FOLDER then TAS_TRAJECTORY_FOLDER:Destroy() end
        if TAS_START_MARKER then TAS_START_MARKER:Destroy() end
    end)

    pcall(function()
        for _, folder in ipairs({
            workspace:FindFirstChild("DripTriggers"),
            workspace:FindFirstChild("DripHitboxes"),
            workspace:FindFirstChild("AstolfoPathVisual"),
        }) do
            if folder then folder:Destroy() end
        end
    end)

    _G.AimbotEnabled = false
    _G.HitboxEnabled = false
    ParkourEnabled = false

    pcall(function() ClearHitboxes() end)
    pcall(function() Window:Destroy() end)

    print("[Makima Scripts] Hub descarregada.")
end)

