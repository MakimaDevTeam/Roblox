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
-- RECURSOS ADICIONAIS
--========================================================--

local ExtrasDiscordTab = Window:Tab({
    Title = "Discord",
    Icon = "message-circle",
})

local ExtrasParkoursTab = Window:Tab({
    Title = "Parkours",
    Icon = "footprints",
})

local TorresTab = Window:Tab({
    Title = "Torres",
    Icon = "tower-control",
})

local ExtrasBrutalTab = Window:Tab({
    Title = "Brutal",
    Icon = "skull",
})

local ExtrasCharTab = Window:Tab({
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

ExtrasDiscordTab:Paragraph({
    Title = "🌐 Discord",
    Desc = "Entre no nosso Discord.",
    Color = "Red",
})

ExtrasDiscordTab:Button({
    Title = "📋 Copiar link",
    Desc = DISCORD_URL,
    Callback = function()
        Copy(DISCORD_URL)
    end,
})

ExtrasDiscordTab:Input({
    Title = "Link",
    Value = DISCORD_URL,
    Placeholder = "Link...",
    Callback = function() end,
})

-- ========================================================================
-- PASTAS
-- ========================================================================

local VisualFolder = workspace:FindFirstChild("MakimaRouteVisual")
if not VisualFolder then
    VisualFolder = Instance.new("Folder")
    VisualFolder.Name = "MakimaRouteVisual"
    VisualFolder.Parent = workspace
end

local TriggerFolder = workspace:FindFirstChild("MakimaRouteTriggers")
if not TriggerFolder then
    TriggerFolder = Instance.new("Folder")
    TriggerFolder.Name = "MakimaRouteTriggers"
    TriggerFolder.Parent = workspace
end

local HitboxFolder = workspace:FindFirstChild("MakimaRouteHitboxes")
if not HitboxFolder then
    HitboxFolder = Instance.new("Folder")
    HitboxFolder.Name = "MakimaRouteHitboxes"
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
    marker.Name = "MakimaMarker"
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
    inner.Name = "MakimaMarkerInner"
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
    model.Name = "MakimaBoneco"

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

    clone.Name = "MakimaBoneco"

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
                            print("[Makima Scripts] ✓ " .. name .. " (" .. #routeData .. " pontos)")
                        else
                            print("[Makima Scripts] ✗ Parse falhou: " .. name)
                        end
                    else
                        print("[Makima Scripts] ✗ Download falhou: " .. name)
                    end

                    if not success then task.wait(2) end
                end
            end)
        end
    end
end

loadPermanentFiles()

-- ========================================================================
-- SEÇÕES DE ROTAS
-- ========================================================================

local function makeSection(tab, sectionName, routeKey)
    local section = tab:Section({
        Title = sectionName,
        TextXAlignment = "Left"
    })

    section:Button({
        Title = "▶ Iniciar",
        Callback = function() startRoute(routeKey) end
    })

    section:Button({
        Title = "📍 Ver linha",
        Callback = function()
            if activeVisualName == routeKey then
                clearVisualPath()
                activeVisualName = nil
                Notify("Visualização", "Linha desativada.")
            else
                local pathData = _G.SavedPaths[routeKey]
                if pathData and #pathData > 0 then
                    drawVisualPath(preprocessPath(pathData))
                    activeVisualName = routeKey
                    Notify("Visualização", "Linha ativada!")
                else
                    Notify("Erro", "Rota não carregada!")
                end
            end
        end
    })

    section:Button({
        Title = "🧍 Linha Boneco",
        Callback = function() toggleBoneco(routeKey) end
    })
end

makeSection(ExtrasParkoursTab, "🏃 Parkour 1", "parkour1_rapido")
makeSection(ExtrasParkoursTab, "🏃 Parkour 2", "parkour2_rapido")
makeSection(ExtrasParkoursTab, "🏃 Parkour 3", "parkour3_rapido")
makeSection(ExtrasParkoursTab, "🏃 Parkour 4", "parkour4_rapido")
makeSection(ExtrasParkoursTab, "🏃 Parkour 5", "parkour5_rapido")
makeSection(TorresTab,   "🗼 Torre 1",   "torre1_rapido")
makeSection(TorresTab,   "🗼 Torre 2",   "torre2_rapido")



--========================================================--
-- PARKOURS / TORRES
--========================================================--

local function MakeRouteSection(tab, sectionName, routeKey)
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

MakeRouteSection(ExtrasParkoursTab, "🏃 Parkour 1", "parkour1_rapido")
MakeRouteSection(ExtrasParkoursTab, "🏃 Parkour 2", "parkour2_rapido")
MakeRouteSection(ExtrasParkoursTab, "🏃 Parkour 3", "parkour3_rapido")
MakeRouteSection(ExtrasParkoursTab, "🏃 Parkour 4", "parkour4_rapido")
MakeRouteSection(ExtrasParkoursTab, "🏃 Parkour 5", "parkour5_rapido")
MakeRouteSection(TorresTab, "🗼 Torre 1", "torre1_rapido")
MakeRouteSection(TorresTab, "🗼 Torre 2", "torre2_rapido")

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

local PARKOUR_REPLACEMENTS = {
    {old = Vector3.new(172.900, 53.260, -898.460), new = Vector3.new(172.900, 53.260, -897.660)},
    {old = Vector3.new(166.030, 5.040, -661.620), new = Vector3.new(165.030, 5.040, -661.620)},
    {old = Vector3.new(165.390, 14.260, -661.390), new = Vector3.new(165.390, 13.260, -661.390)},
    {old = Vector3.new(164.110, 21.280, -661.680), new = Vector3.new(165.110, 21.280, -661.680)},
    {old = Vector3.new(167.300, 29.290, -661.720), new = Vector3.new(165.300, 29.290, -661.720)},
    {old = Vector3.new(164.080, 37.360, -661.760), new = Vector3.new(164.880, 37.360, -661.760)},
    {old = Vector3.new(174.880, 37.360, -652.160), new = Vector3.new(175.680, 37.360, -652.160)},
    {old = Vector3.new(201.500, 53.330, -896.480), new = Vector3.new(200.700, 53.330, -896.480)},
    {old = Vector3.new(211.300, 53.330, -896.250), new = Vector3.new(211.300, 53.330, -896.250)},
    {old = Vector3.new(221.920, 53.330, -896.650), new = Vector3.new(221.920, 53.330, -896.650)},
    {old = Vector3.new(233.210, 53.330, -896.220), new = Vector3.new(232.410, 53.330, -896.220)},
    {old = Vector3.new(393.870, 5.270, -892.930), new = Vector3.new(393.870, 4.470, -892.930)},
    {old = Vector3.new(362.030, 11.530, -901.740), new = Vector3.new(362.030, 11.530, -902.540)},
    {old = Vector3.new(352.360, 11.530, -893.950), new = Vector3.new(352.360, 11.530, -893.150)},
    {old = Vector3.new(352.270, 11.530, -903.210), new = Vector3.new(352.270, 11.530, -903.210)},
    {old = Vector3.new(310.710, 11.530, -898.950), new = Vector3.new(310.710, 11.530, -898.150)},
    {old = Vector3.new(217.920, 12.700, -848.280), new = Vector3.new(217.920, 13.500, -848.280)},
    {old = Vector3.new(217.990, 12.840, -863.620), new = Vector3.new(217.990, 13.640, -863.620)},
}

local function GetHitboxData()
    local source = SafeHttpGet(PARKOUR_URL)
    if not source then return nil end
    local tableText = source:match("local hitboxData%s*=%s*(%b{})")
    if not tableText then
        tableText = source:match("hitboxData%s*=%s*(%b{})")
    end
    if not tableText then
        warn("[Makima Scripts] hitboxData não encontrada.")
        return nil
    end
    local ok, data = pcall(function()
        local fn = loadstring("return " .. tableText)
        if not fn then error("Tabela inválida") end
        return fn()
    end)
    if not ok or type(data) ~= "table" then return nil end

    local result, found = {}, {}
    local tolerance = 0.08
    for _, entry in ipairs(data) do
        local pos = type(entry) == "table" and entry.pos
        local idx
        if typeof(pos) == "Vector3" then
            for i, r in ipairs(PARKOUR_REPLACEMENTS) do
                if (pos - r.old).Magnitude <= tolerance then idx = i break end
            end
        end
        if idx then
            found[idx] = entry
        else
            table.insert(result, entry)
        end
    end
    for i, r in ipairs(PARKOUR_REPLACEMENTS) do
        local old = found[i]
        table.insert(result, {
            pos = r.new,
            size = old and old.size or Vector3.new(8, 1, 8),
        })
    end
    return result
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
-- TAS | GRAVADOR E REPRODUTOR
--========================================================--

local TAS_FOLDER = "MakimaScripts/TAS"
local TAS_SAVED_FOLDER = TAS_FOLDER .. "/Saved"
local TAS_EXPORT_FOLDER = TAS_FOLDER .. "/Exports"
local TAS_VERSION = 4
local TAS_RATE = 60
local TAS_ENABLED = false
local TAS_RECORDING = false
local TAS_PLAYING = false
local TAS_STOP = false
local TAS_AUTO_START = true
local TAS_NAME = "MeuTAS"
local TAS_DATA = nil
local TAS_RECORD = nil
local TAS_SELECTED = nil
local TAS_DROPDOWN = nil
local TAS_RECORD_TOGGLE = nil
local TAS_PLAY_TOGGLE = nil
local TAS_UI_GUARD = false
local TAS_VISUAL = nil
local TAS_MARKER = nil
local TAS_KEYS = {W=false,A=false,S=false,D=false,Space=false}
local TAS_KEYCODES = {W=Enum.KeyCode.W,A=Enum.KeyCode.A,S=Enum.KeyCode.S,D=Enum.KeyCode.D,Space=Enum.KeyCode.Space}
local TAS_INPUT = {}

local function TASFilesOK()
    return type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
end
local function TASName(name)
    name=tostring(name or "MeuTAS"):gsub("[^%w_%-%s]",""):gsub("%s+","_")
    return name~="" and name or "MeuTAS"
end
local function TASPath(name, export)
    return (export and TAS_EXPORT_FOLDER or TAS_SAVED_FOLDER).."/"..TASName(name)..".json"
end
local function TASMkdir()
    if type(makefolder)~="function" then return end
    for _,folder in ipairs({"MakimaScripts",TAS_FOLDER,TAS_SAVED_FOLDER,TAS_EXPORT_FOLDER}) do
        pcall(function() if type(isfolder)~="function" or not isfolder(folder) then makefolder(folder) end end)
    end
end
local function TASClearVisual()
    if TAS_VISUAL then pcall(function() TAS_VISUAL:Destroy() end) end
    if TAS_MARKER then pcall(function() TAS_MARKER:Destroy() end) end
    TAS_VISUAL=nil; TAS_MARKER=nil
end
local function TASVec(v)
    return Vector3.new(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)
end
local function TASA(v) return {v.X,v.Y,v.Z} end
local function TASCharacter()
    local c=LocalPlayer.Character
    return c,c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart")
end
local function TASDraw(data)
    TASClearVisual()
    if type(data)~="table" or #data<2 then return end
    local folder=Instance.new("Folder"); folder.Name="MakimaTASPath"; folder.Parent=workspace; TAS_VISUAL=folder
    local last
    for i=1,#data,3 do
        local p=data[i] and data[i].p and TASVec(data[i].p)
        if p and last then
            local d=p-last; local len=d.Magnitude
            if len>0.05 then
                local part=Instance.new("Part")
                part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
                part.Material=Enum.Material.Neon; part.Color=Color3.fromRGB(190,20,45); part.Transparency=.15
                part.Size=Vector3.new(.08,.08,len); part.CFrame=CFrame.lookAt((p+last)/2,p); part.Parent=folder
            end
        end
        if p then last=p end
    end
    if data[1] and data[1].p then
        local m=Instance.new("Part"); m.Name="MakimaTASStart"; m.Anchored=true; m.CanCollide=false; m.CanTouch=false; m.CanQuery=false
        m.Size=Vector3.new(6,.1,6); m.Position=TASVec(data[1].p)-Vector3.new(0,3,0); m.Material=Enum.Material.Neon; m.Color=Color3.fromRGB(190,20,45); m.Transparency=.45; m.Parent=workspace; TAS_MARKER=m
    end
end
local function TASSave(path,data)
    if not TASFilesOK() then Notify("TAS","Seu executor não suporta arquivos locais.",4); return false end
    TASMkdir()
    local ok,raw=pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    return pcall(function() writefile(path,raw) end)
end
local function TASRead(path)
    if not TASFilesOK() or not isfile(path) then return nil end
    local ok,raw=pcall(readfile,path); if not ok then return nil end
    local ok2,data=pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or type(data)~="table" or type(data.Samples)~="table" or #data.Samples<2 then return nil end
    if tonumber(data.PlaceId) and tonumber(data.PlaceId)~=game.PlaceId then return nil end
    return data
end
local function TASRefresh()
    if not TAS_DROPDOWN or type(listfiles)~="function" then return end
    TASMkdir(); local values={}
    local ok,files=pcall(listfiles,TAS_SAVED_FOLDER)
    if ok and type(files)=="table" then for _,f in ipairs(files) do local n=tostring(f):match("([^/\\]+)%.json$"); if n then table.insert(values,n) end end end
    table.sort(values); if #values==0 then values={"Nenhum TAS salvo"} end
    pcall(function() TAS_DROPDOWN:Refresh(values) end)
end
local function TASSet(toggle,state)
    if not toggle or TAS_UI_GUARD then return end
    TAS_UI_GUARD=true; pcall(function() toggle:Set(state) end); TAS_UI_GUARD=false
end
local function TASStop()
    TAS_STOP=true; TAS_RECORDING=false; TAS_PLAYING=false
    for key,down in pairs(TAS_KEYS) do
        if down then
            local kc=TAS_KEYCODES[key]
            pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(false,kc,false,game) end)
            TAS_KEYS[key]=false
        end
    end
    TASSet(TAS_RECORD_TOGGLE,false); TASSet(TAS_PLAY_TOGGLE,false)
end
local function TASStartRecord()
    if not TAS_ENABLED then Notify("TAS","Ative o TAS primeiro.",3); return end
    if TAS_RECORDING or TAS_PLAYING then Notify("TAS","Pare o TAS atual primeiro.",3); return end
    local _,hum,root=TASCharacter(); if not hum or not root then Notify("TAS","Personagem não encontrado.",4); return end
    TASClearVisual(); TAS_STOP=false; TAS_RECORDING=true; TAS_RECORD={started=os.clock(),acc=0,samples={}}
    table.insert(TAS_RECORD.samples,{t=0,p=TASA(root.Position),d=TASA(hum.MoveDirection),keys={W=false,A=false,S=false,D=false,Space=false}})
    Notify("TAS","Gravando...",2)
end
local function TASFinishRecord()
    if not TAS_RECORDING or not TAS_RECORD then return end
    TAS_RECORDING=false
    local samples=TAS_RECORD.samples; TAS_RECORD=nil
    if #samples<2 then Notify("TAS","Movimento insuficiente.",3); TASSet(TAS_RECORD_TOGGLE,false); return end
    TAS_DATA={Version=TAS_VERSION,Name=TASName(TAS_NAME),PlaceId=game.PlaceId,SampleRate=TAS_RATE,CreatedAt=os.time(),Samples=samples}
    if TASSave(TASPath(TAS_NAME),TAS_DATA) then TAS_SELECTED=TASName(TAS_NAME); TASRefresh(); Notify("TAS","Gravação salva.",3) else Notify("TAS","Gravação feita, mas não foi possível salvar.",4) end
    TASDraw(samples); TASSet(TAS_RECORD_TOGGLE,false)
end
RunService.Heartbeat:Connect(function(dt)
    if not TAS_RECORDING or not TAS_RECORD then return end
    TAS_RECORD.acc+=dt; local step=1/TAS_RATE
    while TAS_RECORD.acc>=step do
        TAS_RECORD.acc-=step
        local _,hum,root=TASCharacter()
        if hum and root then
            local keys={W=TAS_KEYS.W,A=TAS_KEYS.A,S=TAS_KEYS.S,D=TAS_KEYS.D,Space=TAS_KEYS.Space}
            table.insert(TAS_RECORD.samples,{t=os.clock()-TAS_RECORD.started,p=TASA(root.Position),d=TASA(hum.MoveDirection),keys=keys})
        end
    end
end)
for _,key in ipairs({"W","A","S","D","Space"}) do
    local kc=TAS_KEYCODES[key]
    TAS_INPUT[key]=UserInputService.InputBegan:Connect(function(input,gp)
        if gp or input.KeyCode~=kc then return end
        if TAS_RECORDING then TAS_KEYS[key]=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode==kc and TAS_RECORDING then TAS_KEYS[key]=false end
    end)
end
local function TASPlay(data)
    if not TAS_ENABLED then Notify("TAS","Ative o TAS primeiro.",3); return end
    if TAS_RECORDING or TAS_PLAYING then Notify("TAS","Pare o TAS atual primeiro.",3); return end
    if type(data)~="table" or type(data.Samples)~="table" or #data.Samples<2 then Notify("TAS","TAS inválido.",4); return end
    TAS_PLAYING=true; TAS_STOP=false; TASDraw(data.Samples)
    task.spawn(function()
        local _,hum,root=TASCharacter(); if not hum or not root then TASStop(); return end
        local start=TASVec(data.Samples[1].p)
        if TAS_AUTO_START and (root.Position-start).Magnitude>4 then
            hum:MoveTo(start)
            local deadline=os.clock()+15
            while os.clock()<deadline and not TAS_STOP and (root.Position-start).Magnitude>4 do task.wait(.05) end
        end
        if TAS_STOP then TASStop(); return end
        local vim=game:GetService("VirtualInputManager")
        local function keyEvent(kc,down) pcall(function() vim:SendKeyEvent(down,kc,false,game) end) end
        local held={W=false,A=false,S=false,D=false,Space=false}
        local t0=os.clock(); local i=1; local samples=data.Samples
        while TAS_PLAYING and not TAS_STOP and i<=#samples do
            local elapsed=os.clock()-t0
            while i<#samples and (tonumber(samples[i+1].t) or 0)<=elapsed do i+=1 end
            local sample=samples[i]; local ks=sample.keys
            if type(ks)=="table" then
                for _,k in ipairs({"W","A","S","D","Space"}) do
                    local want=ks[k]==true
                    if want~=held[k] then keyEvent(TAS_KEYCODES[k],want); held[k]=want end
                end
            else
                local dir=TASVec(sample.d or {0,0,0}); if dir.Magnitude>1 then dir=dir.Unit end; pcall(function() hum:Move(dir,false) end)
            end
            if type(ks)~="table" then
                local dir=TASVec(sample.d or {0,0,0}); if dir.Magnitude>1 then dir=dir.Unit end; pcall(function() hum:Move(dir,false) end)
            end
            if elapsed >= (tonumber(samples[#samples].t) or 0) then break end
            RunService.Heartbeat:Wait()
        end
        for _,k in ipairs({"W","A","S","D","Space"}) do if held[k] then keyEvent(TAS_KEYCODES[k],false) end end
        pcall(function() hum:Move(Vector3.zero,false); hum.Jump=false end)
        TAS_PLAYING=false; TASSet(TAS_PLAY_TOGGLE,false); Notify("TAS","Reprodução concluída.",3)
    end)
end

local function BuildTASControls()
    local section=ParkourTab:Section({Title="TAS",TextXAlignment="Left"})
    section:Paragraph({Title="Gravador TAS",Desc="Grava as teclas e o movimento e reproduz com o mesmo timing.",Color="Red"})
    section:Toggle({Title="Ativar TAS",Value=false,Callback=function(state) TAS_ENABLED=state; if not state then TASStop(); TASClearVisual() end end})
    section:Input({Title="Nome do TAS",Value=TAS_NAME,Callback=function(v) TAS_NAME=TASName(v) end})
    section:Toggle({Title="Ir ao início automaticamente",Value=true,Callback=function(v) TAS_AUTO_START=v end})
    TAS_DROPDOWN=section:Dropdown({Title="TAS salvos",Values={"Nenhum TAS salvo"},Value="Nenhum TAS salvo",SearchBarEnabled=true,Callback=function(v) if type(v)=="string" and v~="Nenhum TAS salvo" then TAS_SELECTED=v; local d=TASRead(TASPath(v)); if d then TAS_DATA=d; TAS_NAME=TASName(d.Name or v); TASDraw(d.Samples); Notify("TAS","Carregado: "..TAS_NAME,2) end end end})
    TAS_RECORD_TOGGLE=section:Toggle({Title="⏺ Gravar",Value=false,Callback=function(state) if TAS_UI_GUARD then return end; if state then TASStartRecord() else TASFinishRecord() end end})
    TAS_PLAY_TOGGLE=section:Toggle({Title="▶ Executar",Value=false,Callback=function(state) if TAS_UI_GUARD then return end; if state then if not TAS_DATA and TAS_SELECTED then TAS_DATA=TASRead(TASPath(TAS_SELECTED)) end; if TAS_DATA then TASPlay(TAS_DATA) else TASSet(TAS_PLAY_TOGGLE,false); Notify("TAS","Grave ou selecione um TAS primeiro.",3) end else if TAS_PLAYING then TASStop() end end end})
    section:Button({Title="🔄 Atualizar lista",Callback=function() TASRefresh() end})
    section:Button({Title="🧹 Limpar visualização",Callback=function() TASClearVisual() end})
    section:Button({Title="📤 Exportar",Callback=function() if TAS_DATA and TASSave(TASPath(TAS_NAME,true),TAS_DATA) then Notify("TAS","Exportado.",3) end end})
    section:Button({Title="📥 Importar",Callback=function() local d=TASRead(TASPath(TAS_NAME,true)); if d then TAS_DATA=d; TAS_SELECTED=TASName(d.Name); TASSave(TASPath(TAS_SELECTED),d); TASDraw(d.Samples); TASRefresh(); Notify("TAS","Importado.",3) else Notify("TAS","Arquivo não encontrado.",3) end end})
    TASRefresh()
end
BuildTASControls()

--========================================================--
-- JJS | AUTO JJS
--========================================================--

local JJSRunning=false
local JJSAmount=10
local JJSInterval=0.20
local JJS_TOGGLE=nil
local JJS_GUARD=false
local function JJSRemote()
    local r=ReplicatedStorage:FindFirstChild("Remotes")
    local e=r and r:FindFirstChild("Polichinelos")
    return e and e:IsA("RemoteEvent") and e or nil
end
local function JJSScreen()
    local pg=LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local p=pg and pg:FindFirstChild("Polichinelos")
    return p and p:FindFirstChild("Screen")
end
local function JJSTap(screen)
    if not screen then return nil end
    for _,o in ipairs(screen:GetDescendants()) do
        if o:IsA("ImageButton") and o.Visible and not o:GetAttribute("Completed") then
            local label=o:FindFirstChildWhichIsA("TextLabel",true)
            local text=label and label.Text or ""
            if tostring(text):upper():gsub("%s+","")=="TAP" then return o end
        end
    end
    for _,o in ipairs(screen:GetDescendants()) do
        if o:IsA("TextButton") and o.Visible and not o:GetAttribute("Completed") then
            if tostring(o.Text):upper():gsub("%s+","")=="TAP" then return o end
        end
    end
    return nil
end
local function JJSClick(button)
    if not button or not button.Visible then return false end
    local clicked=false
    pcall(function()
        if type(firesignal)=="function" then
            firesignal(button.MouseButton1Down); firesignal(button.MouseButton1Click); firesignal(button.TouchTap)
            clicked=true
        end
    end)
    pcall(function() button:Activate(); clicked=true end)
    pcall(function()
        local vim=game:GetService("VirtualInputManager")
        local x=button.AbsolutePosition.X+button.AbsoluteSize.X/2
        local y=button.AbsolutePosition.Y+button.AbsoluteSize.Y/2
        vim:SendMouseButtonEvent(x,y,0,true,game,1); task.wait(.01); vim:SendMouseButtonEvent(x,y,0,false,game,1)
        clicked=true
    end)
    return clicked
end
local function JJSSet(v)
    if JJS_TOGGLE and not JJS_GUARD then JJS_GUARD=true; pcall(function() JJS_TOGGLE:Set(v) end); JJS_GUARD=false end
end
local function JJSStop()
    JJSRunning=false; JJSSet(false)
end
local function JJSStart()
    if JJSRunning then return end
    local remote=JJSRemote()
    if not remote then Notify("Auto JJs","Remote Polichinelos não encontrado.",5); JJSSet(false); return end
    local amount=math.max(1,math.floor(tonumber(JJSAmount) or 10))
    local interval=math.max(.05,tonumber(JJSInterval) or .20)
    JJSRunning=true
    task.spawn(function()
        pcall(function() remote:FireServer("Prepare") end)
        task.wait(.05)
        pcall(function() remote:FireServer("Start") end)
        local done=0; local deadline=os.clock()+math.max(20,amount*interval+20)
        while JJSRunning and done<amount and os.clock()<deadline do
            local button=JJSTap(JJSScreen())
            if button then
                if JJSClick(button) then
                    pcall(function() remote:FireServer("Add",1) end)
                    done+=1
                    task.wait(interval)
                else
                    task.wait(.03)
                end
            else
                task.wait(.01)
            end
        end
        JJSRunning=false; JJSSet(false)
        if done==amount then Notify("Auto JJs",string.format("Concluído: %d/%d.",done,amount),3) else Notify("Auto JJs",string.format("Parado: %d/%d.",done,amount),4) end
    end)
end
JJsTab:Paragraph({Title="Auto JJs",Desc="Executa o botão TAP real da interface, mantendo a interação visual.",Color="Red"})
JJsTab:Input({Title="Quantidade de JJs",Value="10",Callback=function(v) local n=tonumber(v); if n then JJSAmount=math.max(1,math.floor(n)) end end})
JJsTab:Input({Title="Intervalo",Value="0.20",Callback=function(v) local n=tonumber(v); if n then JJSInterval=math.max(.05,n) end end})
JJS_TOGGLE=JJsTab:Toggle({Title="Auto JJs",Desc="Ativa/desativa o sistema.",Value=false,Callback=function(state) if JJS_GUARD then return end; if state then JJSStart() else JJSStop() end end})

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

local charSection = ExtrasCharTab:Section({
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

local brutalPage = ExtrasBrutalTab:Section({ Title = "💀 Brutal", TextXAlignment = "Left" })

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
fovGui.Name = "MakimaFovCircle"
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
                    box.Name = "MakimaHitbox_" .. player.Name
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
    Title = "Recursos adicionais",
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
    Desc = "Recursos adicionais integrados.",
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
            workspace:FindFirstChild("MakimaRouteTriggers"),
            workspace:FindFirstChild("MakimaRouteHitboxes"),
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

