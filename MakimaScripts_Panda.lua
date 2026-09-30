--========================================================--
--                    MAKIMA SCRIPTS                     --
--                      MakimaDev                         --
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

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

local VolversTab = Window:Tab({
    Title = "VOLVERS",
    Icon = "rotate-ccw",
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

    Vector3.new(470.87, 3.04, -885.88),
    Vector3.new(377.87, 3.04, -940.65),
    Vector3.new(225.02, 3.04, -974.52),
    Vector3.new(102.27, 3.04, -889.48),
    Vector3.new(-160.73, 3.04, -803.28),
    Vector3.new(-389.38, 3.04, -1075.70),
    Vector3.new(-421.97, 3.04, -970.06),

}

local Lixeira =
    Vector3.new(
        -394.31,
        3.04,
        -779.87
    )

local Foice =
    Vector3.new(
        -351.95,
        3.12,
        -631.06
    )

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
-- VOLVERS
--========================================================--

local SavedLookVector

local function SaveRotation()

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if root then

        SavedLookVector =
            root.CFrame.LookVector

    end
end

local function Rotate(degrees)

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if root then

        root.CFrame =
            root.CFrame
            * CFrame.Angles(
                0,
                math.rad(degrees),
                0
            )

    end
end

VolversTab:Paragraph({

    Title = "VOLVERS",

    Desc =
        "Controles de rotação.",

    Color = "Red",
})

VolversTab:Button({

    Title = "Retaguarda",

    Desc = "Girar 180°.",

    Callback = function()

        SaveRotation()

        Rotate(180)

    end,
})

VolversTab:Button({

    Title = "Voltaguarda",

    Desc = "Voltar para a direção salva.",

    Callback = function()

        local character =
            LocalPlayer.Character

        local root =
            character
            and character:FindFirstChild(
                "HumanoidRootPart"
            )

        if root
            and SavedLookVector then

            local position =
                root.Position

            root.CFrame =
                CFrame.new(
                    position,
                    position
                    + SavedLookVector
                )

        end

    end,
})

VolversTab:Button({

    Title = "Direita",

    Desc = "Girar 90° para a direita.",

    Callback = function()

        Rotate(-90)

    end,
})

VolversTab:Button({

    Title = "Esquerda",

    Desc = "Girar 90° para a esquerda.",

    Callback = function()

        Rotate(90)

    end,
})

SaveRotation()

LocalPlayer.CharacterAdded:Connect(function()

    task.wait(1)

    SaveRotation()

end)

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