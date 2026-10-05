--!nocheck
--!nolint UnknownGlobal
if getgenv().EvermortalLoaded then
    warn("[Volcannon] Já está em execução.")
    return
end
getgenv().EvermortalLoaded = true

local BASE = "https://raw.githubusercontent.com/Ark1nz/Volcannon-Hub/refs/heads/main/Scripts/Evermortal/"

local function Baixar(url)
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok then
        warn("[Volcannon] Falha ao baixar: " .. url)
        return nil
    end
    local fn, err = loadstring(src)
    if not fn then
        warn("[Volcannon] Erro de sintaxe em " .. url .. ": " .. tostring(err))
        return nil
    end
    local okRun, result = pcall(fn)
    if not okRun then
        warn("[Volcannon] Erro ao executar " .. url .. ": " .. tostring(result))
        return nil
    end
    return result
end

local AutoAscend = Baixar(BASE .. "AutoAscend.luau")
local Scanner    = Baixar(BASE .. "Scanner.luau")
local Rayfield   = Baixar("https://sirius.menu/rayfield")

if not (AutoAscend and Scanner and Rayfield) then
    getgenv().EvermortalLoaded = nil
    return
end

local function ParseArgs(txt)
    local args = {}
    for parte in string.gmatch(txt or "", "[^,]+") do
        parte = parte:match("^%s*(.-)%s*$")
        if tonumber(parte) then
            table.insert(args, tonumber(parte))
        elseif parte == "true" then
            table.insert(args, true)
        elseif parte == "false" then
            table.insert(args, false)
        elseif parte ~= "" then
            table.insert(args, parte)
        end
    end
    return args
end

local function Aviso(titulo, conteudo)
    Rayfield:Notify({ Title = titulo, Content = conteudo, Duration = 4, Image = 4483362458 })
end

local Window = Rayfield:CreateWindow({
    Name = "🌋 Volcannon Hub | Evermortal",
    LoadingTitle = "Volcannon Hub",
    LoadingSubtitle = "Cultivation: Evermortal",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VolcannonConfigs",
        FileName = "Evermortal",
    },
    KeySystem = false,
})

-- ===== Aba Auto Ascend =====
local AscendTab = Window:CreateTab("🔁 Auto Ascend", 4483362458)
local StatusLabel = AscendTab:CreateLabel("Status: parado")
AutoAscend.OnStatus = function(texto)
    StatusLabel:Set("Status: " .. texto)
end

AscendTab:CreateInput({
    Name = "Nível alvo para ascender",
    CurrentValue = "",
    PlaceholderText = "ex.: 100",
    RemoveTextAfterFocusLost = false,
    Flag = "InputAlvo",
    Callback = function(Text)
        AutoAscend.Alvo = tonumber(Text) or 0
    end,
})

AscendTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "ToggleAutoAscend",
    Callback = function(Value)
        AutoAscend:Alternar(Value)
    end,
})

AscendTab:CreateInput({
    Name = "Caminho do nível (da aba Descoberta)",
    CurrentValue = "",
    PlaceholderText = "Players.LocalPlayer.leaderstats.Realm",
    RemoveTextAfterFocusLost = false,
    Flag = "InputNivelCaminho",
    Callback = function(Text)
        AutoAscend.Config.NivelCaminho = Text
    end,
})

AscendTab:CreateInput({
    Name = "Caminho do Ascend (remote ou botão)",
    CurrentValue = "",
    PlaceholderText = "ReplicatedStorage.Remotes.Ascend",
    RemoveTextAfterFocusLost = false,
    Flag = "InputAscendCaminho",
    Callback = function(Text)
        AutoAscend.Config.AscendCaminho = Text
    end,
})

AscendTab:CreateInput({
    Name = "Argumentos do remote (separados por vírgula)",
    CurrentValue = "",
    PlaceholderText = "deixe vazio se não houver",
    RemoveTextAfterFocusLost = false,
    Flag = "InputAscendArgs",
    Callback = function(Text)
        AutoAscend.Config.AscendArgs = ParseArgs(Text)
    end,
})

AscendTab:CreateButton({
    Name = "⚠️ Testar Ascend AGORA (vai ascender de verdade!)",
    Callback = function()
        local ok, msg = AutoAscend:Testar()
        Aviso("Teste de Ascend", ok and "Comando enviado." or ("Falhou: " .. tostring(msg)))
    end,
})

-- ===== Aba Descoberta =====
local DescTab = Window:CreateTab("🔎 Descoberta", 4483362458)

DescTab:CreateButton({
    Name = "Procurar nível, remotes e botões (copia o resultado)",
    Callback = function()
        local texto, copiou = Scanner:Procurar()
        Aviso("Scanner", copiou and "Resultado copiado. Cole no chat." or "Veja o resultado no console.")
    end,
})

DescTab:CreateToggle({
    Name = "Spy de remotes (ligue e faça a ação manualmente)",
    CurrentValue = false,
    Flag = "ToggleSpy",
    Callback = function(Value)
        local ativo = Scanner:Spy(Value)
        if Value and not ativo then
            Aviso("Spy", "Seu executor não suporta hookmetamethod.")
        end
    end,
})

DescTab:CreateButton({
    Name = "Copiar log do Spy",
    Callback = function()
        local n, copiou = Scanner:CopiarSpy()
        Aviso("Spy", n .. " linhas. " .. (copiou and "Copiado." or "Veja o console."))
    end,
})

DescTab:CreateButton({
    Name = "Limpar log do Spy",
    Callback = function() Scanner:LimparSpy() end,
})

DescTab:CreateButton({
    Name = "Fechar Hub",
    Callback = function()
        AutoAscend:Destroy()
        Scanner:Spy(false)
        getgenv().EvermortalLoaded = nil
        Rayfield:Destroy()
    end,
})

Aviso("🌋 Volcannon Hub", "Carregado. Comece pela aba Descoberta.")
Rayfield:LoadConfiguration()