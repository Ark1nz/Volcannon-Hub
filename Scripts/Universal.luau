-- =============================================================================
-- 🌋 VOLCANNON HUB - MAIN INTERFACE (UNIVERSAL MODE)
-- =============================================================================

-- 1. CARREGAMENTO DA INTERFACE GRÁFICA (Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- 2. CRIAÇÃO DA JANELA PRINCIPAL
local Window = Rayfield:CreateWindow({
   Name = "🌋 Volcannon Hub | Universal Mode",
   LoadingTitle = "Volcannon Universal Loading...",
   LoadingSubtitle = "by Volcannon Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "VolcannonUniversalConfigs",
      FileName = "Universal"
   },
   KeySystem = false
})

-- 3. VARIÁVEIS DE CONFIGURAÇÃO LOCAIS
local UniversalConfig = {
    SpeedActive = false,
    SpeedValue = 16,
    JumpActive = false,
    JumpValue = 50,
    InfJump = false
}

-- 4. LOGICA DO PERSONAGEM (Loops de Funcionamento Contínuo)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Loop Principal via Heartbeat (Atualiza a cada frame do jogo)
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") then
        local Humanoid = Character.Humanoid
        
        -- Aplica Velocidade Modificada
        if UniversalConfig.SpeedActive then
            Humanoid.WalkSpeed = UniversalConfig.SpeedValue
        end
        
        -- Aplica Pulo Modificado
        if UniversalConfig.JumpActive then
            Humanoid.JumpPower = UniversalConfig.JumpValue
            Humanoid.UseJumpPower = true
        end
    end
end)

-- Mecânica de Pulo Infinito (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
    if UniversalConfig.InfJump then
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- 5. CRIAÇÃO DAS ABAS VISUAIS
local PlayerTab = Window:CreateTab("⚡ Player", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- 6. COMPONENTES DA ABA: "Player"
PlayerTab:CreateToggle({
   Name = "Enable Super Speed",
   CurrentValue = false,
   Flag = "UniToggleSpeed",
   Callback = function(Value)
       UniversalConfig.SpeedActive = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Speed Power",
   Range = {16, 250},
   Increment = 1,
   Suffix = " Studs",
   CurrentValue = 16,
   Flag = "UniSliderSpeed",
   Callback = function(Value)
       UniversalConfig.SpeedValue = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Enable High Jump",
   CurrentValue = false,
   Flag = "UniToggleJump",
   Callback = function(Value)
       UniversalConfig.JumpActive = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 400},
   Increment = 1,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "UniSliderJump",
   Callback = function(Value)
       UniversalConfig.JumpValue = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump (Fly)",
   CurrentValue = false,
   Flag = "UniToggleInfJump",
   Callback = function(Value)
       UniversalConfig.InfJump = Value
   end,
})

-- 7. COMPONENTES DA ABA: "Visuals"
VisualsTab:CreateButton({
   Name = "Enable FullBright (Night Vision)",
   Callback = function()
       -- Altera a iluminação do ambiente do jogo localmente para remover sombras
       local Lighting = game:GetService("Lighting")
       Lighting.Ambient = Color3.fromRGB(255, 255, 255)
       Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
       Lighting.Brightness = 2
       Lighting.ClockTime = 14
       
       Rayfield:Notify({
          Title = "Volcannon Visuals",
          Content = "FullBright ativado! Sombras removidas.",
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

-- Notificação de inicialização bem-sucedida
Rayfield:Notify({
   Title = "🌋 Volcannon Universal",
   Content = "Modo de compatibilidade universal ativado.",
   Duration = 5,
   Image = 4483362458,
})
