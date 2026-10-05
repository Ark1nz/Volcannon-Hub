--!nocheck
--!nolint UnknownGlobal
if getgenv().VolcannonLoaded then
    warn("[Volcannon] Já está em execução.")
    return
end
getgenv().VolcannonLoaded = true

local BASE = "https://raw.githubusercontent.com/Ark1nz/Volcannon-Hub/refs/heads/main/Scripts/BloxFruits/"

local function Baixar(url)
    local ok, src = pcall(function()
        return (game :: any):HttpGet(url)
    end)
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

local Tween    = Baixar(BASE .. "TweenModule.luau")
local Quests   = Baixar(BASE .. "QuestData.luau")
local AutoFarm = Baixar(BASE .. "AutoFarm.luau")
local Rayfield = Baixar("https://sirius.menu/rayfield")

if not (Tween and Quests and AutoFarm and Rayfield) then
    getgenv().VolcannonLoaded = nil
    return
end

local sea = getgenv().VolcannonSea or 1
local listaDeMissoes = Quests[sea] or {}
AutoFarm:Init(Tween, listaDeMissoes)

-- ===== Velocidade =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VELOCIDADE_PADRAO = 16
local velocidadeAtiva, velocidadeValor = false, VELOCIDADE_PADRAO

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local conexaoVelocidade = RunService.Heartbeat:Connect(function()
    if velocidadeAtiva then
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = velocidadeValor end
    end
end)

-- ===== Interface =====
local Window = Rayfield:CreateWindow({
    Name = "🌋 Volcannon Hub | Blox Fruits",
    LoadingTitle = "Volcannon Hub",
    LoadingSubtitle = "Sea " .. sea,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VolcannonConfigs",
        FileName = "BloxFruits",
    },
    KeySystem = false,
})

local FarmTab = Window:CreateTab("📜 Auto Farm", 4483362458)
local PlayerTab = Window:CreateTab("⚡ Player", 4483362458)

local StatusLabel = FarmTab:CreateLabel("Status: parado")
AutoFarm.OnStatus = function(texto)
    StatusLabel:Set("Status: " .. texto)
end

FarmTab:CreateToggle({
    Name = "Auto Farm (por nível)",
    CurrentValue = false,
    Flag = "ToggleAutoFarm",
    Callback = function(Value)
        if Value and #listaDeMissoes == 0 then
            Rayfield:Notify({
                Title = "Volcannon Hub",
                Content = "Sem dados de missão para o Sea " .. sea .. ".",
                Duration = 4,
            })
            return
        end
        AutoFarm:AlternarFarm(Value)
    end,
})

FarmTab:CreateDropdown({
    Name = "Tipo de arma",
    Options = { "Melee", "Sword", "Blox Fruit", "Gun" },
    CurrentOption = { "Melee" },
    MultipleOptions = false,
    Flag = "DropdownArma",
    Callback = function(Option)
        AutoFarm.Config.ArmaTipo = type(Option) == "table" and Option[1] or Option
    end,
})

FarmTab:CreateSlider({
    Name = "Altura do ataque",
    Range = { 2, 30 },
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 7,
    Flag = "SliderAltura",
    Callback = function(Value)
        AutoFarm.Config.AlturaAtaque = Value
    end,
})

FarmTab:CreateButton({
    Name = "Debug (imprimir NPCs/inimigos no console)",
    Callback = function() AutoFarm:Debug() end,
})

PlayerTab:CreateToggle({
    Name = "Super Velocidade",
    CurrentValue = false,
    Flag = "ToggleWalkspeed",
    Callback = function(Value)
        velocidadeAtiva = Value
        if not Value then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = VELOCIDADE_PADRAO end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Velocidade de Movimento",
    Range = { 16, 120 },
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "SliderWalkspeed",
    Callback = function(Value)
        velocidadeValor = Value
    end,
})

PlayerTab:CreateButton({
    Name = "Fechar Hub",
    Callback = function()
        AutoFarm:Destroy()
        conexaoVelocidade:Disconnect()
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = VELOCIDADE_PADRAO end
        getgenv().VolcannonLoaded = nil
        Rayfield:Destroy()
    end,
})

Rayfield:Notify({
    Title = "🌋 Volcannon Hub",
    Content = "Carregado (Sea " .. sea .. ").",
    Duration = 4,
})

Rayfield:LoadConfiguration()