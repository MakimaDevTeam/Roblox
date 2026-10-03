--========================================================--
--                    MAKIMA SCRIPTS                     --
--                      MakimaDev                         --
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- CONFIGURAÇÕES
--========================================================--

local WINDUI_URL =
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"

local JNKIE_SDK_URL =
    "https://jnkie.com/sdk/library.lua"

local KEY_URL =
    "https://jnkie.com/get-key/makimascripts"

local JNKIE_SERVICE = "Key"
local JNKIE_IDENTIFIER = "1207333"
local JNKIE_PROVIDER = "LootLabs"

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
-- JNKIE (CARREGAMENTO SOB DEMANDA)
--========================================================--
-- O SDK NÃO é carregado antes da tela de Key.
-- Ele só é inicializado quando o WindUI realmente recebe
-- uma Key para validar. Isso evita qualquer camada de
-- autenticação externa sendo executada no início.

local Junkie = nil
local JunkieLoadAttempted = false

local function LoadJunkie()

    if Junkie then
        return Junkie
    end

    if JunkieLoadAttempted then
        return nil
    end

    JunkieLoadAttempted = true

    local source = SafeHttpGet(JNKIE_SDK_URL)

    if not source then
        warn("[Makima Scripts] Não foi possível carregar o JNKIE SDK.")
        return nil
    end

    local success, result = pcall(function()

        local fn = loadstring(source)

        if type(fn) ~= "function" then
            error("JNKIE SDK retornou código inválido.")
        end

        return fn()

    end)

    if not success or type(result) ~= "table" then

        warn("[Makima Scripts] Erro ao iniciar JNKIE:")
        warn(result)

        return nil
    end

    result.service = JNKIE_SERVICE
    result.identifier = JNKIE_IDENTIFIER
    result.provider = JNKIE_PROVIDER

    Junkie = result

    return Junkie
end

--========================================================--
-- VALIDAÇÃO DA KEY
--========================================================--
-- Estrutura baseada no SDK oficial do JNKIE:
-- Junkie.check_key(userKey)
--
-- O SDK retorna uma tabela como:
-- { valid = true, message = "KEY_VALID" }
-- ou
-- { valid = false, error = "KEY_EXPIRED" }
--
-- Nenhuma Key vazia é enviada ao JNKIE e nenhuma Kick()
-- é executada para Key inválida/expirada.

local function ValidateKey(key)

    if type(key) ~= "string" then
        return false
    end

    key = key:gsub("^%s+", "")
    key = key:gsub("%s+$", "")

    if key == "" then
        return false
    end

    local validator = LoadJunkie()

    if not validator then
        return false
    end

    if type(validator.check_key) ~= "function" then

        warn("[Makima Scripts] JNKIE não possui check_key().")

        return false
    end

    local success, result = pcall(function()
        return validator.check_key(key)
    end)

    if not success then

        warn("[Makima Scripts] Erro no check_key:")
        warn(result)

        return false
    end

    if type(result) == "table" and result.valid == true then

        -- Mantém a Key validada disponível para integrações
        -- que utilizem o padrão do loader externo do JNKIE.
        pcall(function()
            getgenv().SCRIPT_KEY = key
        end)

        return true
    end

    if type(result) == "table" then

        warn(
            "[Makima Scripts] Key recusada: "
            .. tostring(result.error or result.message or "INVALID")
        )

    end

    return false
end

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

        URL = KEY_URL,

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

local OutrosTab = Window:Tab({
    Title = "Outros",
    Icon = "settings",
})

local CreditosTab = Window:Tab({
    Title = "Créditos",
    Icon = "heart",
})

local PatchTab = Window:Tab({
    Title = "Patch",
    Icon = "scroll-text",
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
-- PARKOUR
--========================================================--

local ParkourEnabled = false
local Hitboxes = {}
local AdminApplyOverrides
local AdminOverrides = {}

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

    if AdminApplyOverrides then
        pcall(AdminApplyOverrides)
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
-- JJS
--========================================================--

local JJSRunning = false

JJsTab:Paragraph({

    Title = "Auto JJS",

    Desc =
        "Executa o script Auto JJS.",

    Color = "Red",
})

JJsTab:Button({

    Title = "Executar Auto JJS",

    Desc =
        "Carrega o script externo.",

    Callback = function()

        if JJSRunning then

            Notify(
                "Auto JJS",
                "O script já foi executado.",
                3
            )

            return
        end

        Notify(
            "Auto JJS",
            "Carregando...",
            2
        )

        local source =
            SafeHttpGet(JJS_URL)

        if not source then

            Notify(
                "Auto JJS",
                "O servidor retornou erro HTTP ou não respondeu.",
                5
            )

            return
        end

        local success, result =
            pcall(function()

                local fn =
                    loadstring(source)

                if not fn then
                    error(
                        "O conteúdo recebido não pôde ser executado."
                    )
                end

                return fn()

            end)

        if not success then

            warn(
                "[Makima Scripts] Erro Auto JJS:"
            )

            warn(result)

            Notify(
                "Auto JJS",
                "Erro ao executar o script.",
                5
            )

            return
        end

        JJSRunning = true

        Notify(
            "Auto JJS",
            "Ativado.",
            3
        )

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
    Vector3.new(
        -91,
        3,
        -512
    )

local FoiceLocations = {
    Vector3.new(-91, 3, -512),
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

local Gramas = {

    Vector3.new(82.63, 3.00, -671.36),
    Vector3.new(-45.00, 3.00, -671.39),
    Vector3.new(-15.39, 3.00, -619.51),
    Vector3.new(218.96, 3.00, -758.32),
    Vector3.new(112.01, 3.00, -652.70),
    Vector3.new(123.73, 3.00, -741.72),
    Vector3.new(51.76, 3.00, -1001.02),
    Vector3.new(173.18, 3.00, -987.78),
    Vector3.new(175.72, 3.00, -931.94),
    Vector3.new(120.00, 3.00, -848.69),
    Vector3.new(54.60, 3.00, -780.14),
    Vector3.new(10.21, 3.00, -744.73),

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
-- EDITOR ADMIN DO PARKOUR
--========================================================--

local ADMIN_PASSWORD = "msontop"
local ADMIN_FOLDER = "MakimaScripts/ParkourAdmin"
local ADMIN_FILE = ADMIN_FOLDER .. "/positions.json"
local AdminEditorEnabled = false
local AdminPasswordSection = nil
local AdminPasswordInput = nil
local AdminSelected = nil
local AdminOriginalPositions = {}
local AdminEditorSection = nil
local AdminDropdown = nil
local AdminXInput = nil
local AdminYInput = nil
local AdminZInput = nil
local AdminNameInput = nil

local function AdminFileAPI()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function AdminEnsureFolder()
    if type(makefolder) ~= "function" then return end
    pcall(function()
        if type(isfolder) ~= "function" or not isfolder("MakimaScripts") then makefolder("MakimaScripts") end
        if type(isfolder) ~= "function" or not isfolder(ADMIN_FOLDER) then makefolder(ADMIN_FOLDER) end
    end)
end

local function AdminEncode(data)
    local ok, result = pcall(function() return HttpService:JSONEncode(data) end)
    return ok and result or nil
end

local function AdminDecode(raw)
    local ok, result = pcall(function() return HttpService:JSONDecode(raw) end)
    return ok and type(result) == "table" and result or nil
end

local function AdminLoad()
    if not AdminFileAPI() or not isfile(ADMIN_FILE) then return end
    local raw
    if not pcall(function() raw = readfile(ADMIN_FILE) end) then return end
    local data = AdminDecode(raw)
    if type(data) ~= "table" then return end
    AdminOverrides = data
end

local function AdminSave()
    if not AdminFileAPI() then
        Notify("Editor Admin", "Seu executor não suporta salvar posições locais.", 4)
        return false
    end
    AdminEnsureFolder()
    local encoded = AdminEncode(AdminOverrides)
    if not encoded then return false end
    local ok = pcall(function() writefile(ADMIN_FILE, encoded) end)
    if ok then
        Notify("Editor Admin", "Posições salvas.", 3)
    else
        Notify("Editor Admin", "Não foi possível salvar.", 4)
    end
    return ok
end

local function AdminVecToArray(v)
    return {v.X, v.Y, v.Z}
end

local function AdminArrayToVec(v)
    if type(v) ~= "table" then return nil end
    return Vector3.new(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)
end

AdminApplyOverrides = function()
    for _, part in ipairs(Hitboxes) do
        if part and part.Parent then
            local key = part:GetAttribute("MakimaParkourId")
            local override = key and AdminOverrides[tostring(key)]
            if override then
                local pos = AdminArrayToVec(override.position)
                if pos then part.Position = pos end
            end
        end
    end
end

local function AdminRefreshDropdown()
    if not AdminDropdown then return end
    local values = {}
    for i, part in ipairs(Hitboxes) do
        if part and part.Parent then
            table.insert(values, "Flutuante " .. tostring(i))
        end
    end
    if #values == 0 then values = {"Nenhum flutuante"} end
    pcall(function() AdminDropdown:Refresh(values) end)
end

local function AdminSetInputs(part)
    if not part then return end
    local p = part.Position
    pcall(function()
        if AdminXInput then AdminXInput:Set(tostring(p.X)) end
        if AdminYInput then AdminYInput:Set(tostring(p.Y)) end
        if AdminZInput then AdminZInput:Set(tostring(p.Z)) end
    end)
end

local function AdminSelectByText(option)
    local index = tonumber(tostring(option):match("(%d+)$"))
    if not index then return end
    local part = Hitboxes[index]
    if not part then return end
    AdminSelected = index
    AdminSetInputs(part)
    if AdminNameInput then pcall(function() AdminNameInput:Set("Flutuante " .. index) end) end
end

local function AdminApplySelected()
    local part = AdminSelected and Hitboxes[AdminSelected]
    if not part then
        Notify("Editor Admin", "Selecione um flutuante primeiro.", 3)
        return
    end
    local old = part.Position
    local x = tonumber(AdminXInput and AdminXInput.Value or "")
    local y = tonumber(AdminYInput and AdminYInput.Value or "")
    local z = tonumber(AdminZInput and AdminZInput.Value or "")
    if not x or not y or not z then
        Notify("Editor Admin", "X, Y e Z precisam ser números.", 3)
        return
    end
    local newPosition = Vector3.new(x, y, z)
    part.Position = newPosition
    local id = tostring(AdminSelected)
    if not AdminOriginalPositions[id] then
        AdminOriginalPositions[id] = AdminVecToArray(old)
    end
    AdminOverrides[id] = {
        position = AdminVecToArray(newPosition),
        original = AdminOriginalPositions[id],
    }
    Notify("Editor Admin", string.format("Flutuante %d movido.", AdminSelected), 2)
end

local function AdminCreate()
    local x = tonumber(AdminXInput and AdminXInput.Value or "0") or 0
    local y = tonumber(AdminYInput and AdminYInput.Value or "0") or 0
    local z = tonumber(AdminZInput and AdminZInput.Value or "0") or 0
    local part = Instance.new("Part")
    part.Name = "MakimaParkourHitbox"
    part.Size = Vector3.new(4, 1, 4)
    part.Position = Vector3.new(x, y, z)
    part.Anchored = true
    part.Transparency = 1
    part.CanCollide = false
    part.Parent = workspace
    local selection = Instance.new("SelectionBox")
    selection.Adornee = part
    selection.Color3 = Color3.fromRGB(190, 20, 45)
    selection.SurfaceTransparency = 0.5
    selection.LineThickness = 0.05
    selection.Parent = part
    table.insert(Hitboxes, part)
    local id = tostring(#Hitboxes)
    AdminOverrides[id] = {position = AdminVecToArray(part.Position), original = AdminVecToArray(part.Position), created = true}
    AdminSelected = #Hitboxes
    AdminRefreshDropdown()
    AdminSetInputs(part)
    Notify("Editor Admin", "Novo flutuante criado.", 3)
end

local function AdminDelete()
    local index = AdminSelected
    local part = index and Hitboxes[index]
    if not part then
        Notify("Editor Admin", "Selecione um flutuante primeiro.", 3)
        return
    end
    pcall(function() part:Destroy() end)
    table.remove(Hitboxes, index)
    local rebuilt = {}
    for i, value in pairs(AdminOverrides) do
        local n = tonumber(i)
        if n and n > index then
            rebuilt[tostring(n - 1)] = value
        elseif n and n < index then
            rebuilt[tostring(n)] = value
        end
    end
    AdminOverrides = rebuilt
    AdminSelected = nil
    AdminRefreshDropdown()
    Notify("Editor Admin", "Flutuante excluído.", 3)
end

local function AdminRestore()
    local index = AdminSelected
    local part = index and Hitboxes[index]
    if not part then return end
    local original = AdminOriginalPositions[tostring(index)] or (AdminOverrides[tostring(index)] and AdminOverrides[tostring(index)].original)
    local pos = AdminArrayToVec(original)
    if pos then
        part.Position = pos
        AdminOverrides[tostring(index)] = nil
        AdminSetInputs(part)
        Notify("Editor Admin", "Posição original restaurada.", 3)
    else
        Notify("Editor Admin", "Não há posição original registrada.", 3)
    end
end

local function BuildAdminEditor()
    if AdminEditorSection then return end
    local ok, section = pcall(function()
        return CreditosTab:Section({
            Title = "Editor de Parkour (Admin)",
            Desc = "Ferramenta administrativa para ajustar os flutuantes.",
            Box = true,
            BoxBorder = true,
            Opened = true,
        })
    end)
    if not ok or not section then return end
    AdminEditorSection = section
    pcall(function() AdminEditorSection.ElementFrame.Visible = true end)
    local function Add(method, config)
        local success, element = pcall(function() return AdminEditorSection[method](AdminEditorSection, config) end)
        return success and element or nil
    end
    AdminDropdown = Add("Dropdown", {
        Title = "Flutuante",
        Desc = "Selecione o ponto que deseja editar.",
        Values = {"Nenhum flutuante"},
        Value = "Nenhum flutuante",
        SearchBarEnabled = true,
        Callback = AdminSelectByText,
    })
    AdminXInput = Add("Input", {Title = "X", Desc = "Coordenada X", Value = "0", Placeholder = "X"})
    AdminYInput = Add("Input", {Title = "Y", Desc = "Coordenada Y", Value = "0", Placeholder = "Y"})
    AdminZInput = Add("Input", {Title = "Z", Desc = "Coordenada Z", Value = "0", Placeholder = "Z"})
    Add("Button", {Title = "Aplicar posição", Desc = "Move o flutuante selecionado para X/Y/Z.", Callback = AdminApplySelected})
    Add("Button", {Title = "Criar novo flutuante", Desc = "Cria um novo ponto usando X/Y/Z.", Callback = AdminCreate})
    Add("Button", {Title = "Restaurar original", Desc = "Volta o selecionado à posição original conhecida.", Callback = AdminRestore})
    Add("Button", {Title = "Excluir flutuante", Desc = "Remove o ponto selecionado da sessão atual.", Callback = AdminDelete})
    Add("Button", {Title = "Salvar posições", Desc = "Salva as alterações localmente para a sua próxima sessão.", Callback = AdminSave})
    AdminRefreshDropdown()
end

AdminLoad()

CreditosTab:Button({
    Title = "🔐 Editor de Parkour (Admin)",
    Desc = "Mostra o acesso protegido do editor.",
    Callback = function()
        if not AdminPasswordSection then
            local ok, section = pcall(function()
                return CreditosTab:Section({
                    Title = "Acesso Administrativo",
                    Desc = "Digite a senha para abrir o editor.",
                    Box = true,
                    BoxBorder = true,
                    Opened = true,
                })
            end)
            if not ok or not section then
                Notify("Editor Admin", "Não foi possível abrir o acesso.", 3)
                return
            end
            AdminPasswordSection = section
            AdminPasswordInput = section:Input({
                Title = "Senha",
                Desc = "Senha do Editor de Parkour.",
                Value = "",
                Placeholder = "Digite a senha",
            })
            section:Button({
                Title = "Entrar no Editor",
                Desc = "Valida a senha e libera a ferramenta.",
                Callback = function()
                    local entered = tostring(AdminPasswordInput and AdminPasswordInput.Value or "")
                    if entered ~= ADMIN_PASSWORD then
                        Notify("Editor Admin", "Senha incorreta.", 3)
                        return
                    end
                    AdminEditorEnabled = true
                    BuildAdminEditor()
                    AdminRefreshDropdown()
                    if AdminEditorSection and AdminEditorSection.ElementFrame then
                        pcall(function() AdminEditorSection.ElementFrame.Visible = true end)
                    end
                    Notify("Editor Admin", "Acesso autorizado.", 3)
                end,
            })
        end
        pcall(function()
            AdminPasswordSection.ElementFrame.Visible = true
        end)
    end,
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

        Copy(KEY_URL)

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
-- PATCH DE ATUALIZAÇÕES
--========================================================--

PatchTab:Paragraph({
    Title = "Atualizações",
    Desc = "Mudanças recentes da Makima Scripts.",
    Color = "Red",
})

PatchTab:Paragraph({
    Title = "Nova atualização",
    Desc = "• Farm de Lixo atualizada com novos locais.\n• Farm da Foice adicionada com novos pontos.\n• Posição de pegar a foice mantida no início.\n• Editor de Parkour para administração adicionado.\n• TAS identificado como Beta: pode não funcionar perfeitamente.",
    Color = "Red",
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