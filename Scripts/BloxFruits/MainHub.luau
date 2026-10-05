-- =============================================================================
-- 🌋 VOLCANNON HUB - MAIN INTERFACE & CONTROLLER (BLOX FRUITS)
-- =============================================================================

-- 1. CONFIGURAÇÕES DO SERVIDOR DO GITHUB
-- Substitua "SEU_USUARIO" pelo seu nome real do GitHub quando publicar
local GithubUser = "Ark1nz"
local BaseUrl = "https://githubusercontent.com" .. GithubUser .. "/VolcannonHub/main/Scripts/BloxFruits/"

-- 2. CARREGAMENTO DOS SUBMÓDULOS MODULARES (Via Internet)
local Tween = loadstring(game:HttpGet(BaseUrl .. "TweenModule.luau"))()
local AutoFarm = loadstring(game:HttpGet(BaseUrl .. "AutoFarm.luau"))()

-- 3. CARREGAMENTO DA INTERFACE GRÁFICA (Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- 4. CRIAÇÃO DA JANELA PRINCIPAL
local Window = Rayfield:CreateWindow({
   Name = "🌋 Volcannon Hub | Blox Fruits",
   LoadingTitle = "Volcannon Hub Loading...",
   LoadingSubtitle = "by Volcannon Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "VolcannonConfigs",
      FileName = "BloxFruits"
   },
   KeySystem = false -- Ativaremos nas próximas etapas do projeto
})

-- 5. CONFIGURAÇÕES LOCAIS DO MENU
local LocalConfig = {
    VelocidadeAtiva = false,
    VelocidadeValor = 16
}

-- 6. LOOP DE ATUALIZAÇÕES DO LOCALPLAYER (WalkSpeed)
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    local Character = game:GetService("Players").LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") then
        if LocalConfig.VelocidadeAtiva then
            Character.Humanoid.WalkSpeed = LocalConfig.VelocidadeValor
        end
    end
end)

-- 7. CRIAÇÃO DAS ABAS VISUAIS
local FarmTab = Window:CreateTab("📜 Auto Farm", 4483362458)
local PlayerTab = Window:CreateTab("⚡ Player", 4483362458)

-- 8. COMPONENTES DA ABA: "Auto Farm"
FarmTab:CreateToggle({
   Name = "Ativar Auto Farm (Bandits)",
   CurrentValue = false,
   Flag = "ToggleAutoFarm", 
   Callback = function(Value)
       -- Envia o comando direto para o arquivo AutoFarm.luau que carregamos no topo
       AutoFarm:AlternarFarm(Value)
       
       Rayfield:Notify({
          Title = "Volcannon Hub",
          Content = Value and "Auto Farm iniciado com sucesso!" or "Auto Farm paralisado.",
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

-- 9. COMPONENTES DA ABA: "Player"
PlayerTab:CreateToggle({
   Name = "Ativar Super Velocidade",
   CurrentValue = false,
   Flag = "ToggleWalkspeed",
   Callback = function(Value)
       LocalConfig.VelocidadeAtiva = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Velocidade de Movimento",
   Range = {16, 120},
   Increment = 1,
   Suffix = " Studs",
   CurrentValue = 16,
   Flag = "SliderWalkspeed",
   Callback = function(Value)
       LocalConfig.VelocidadeValor = Value
   end,
})

-- 10. NOTIFICAÇÃO DE SUCESSO DE INICIALIZAÇÃO
Rayfield:Notify({
   Title = "🌋 Volcannon Hub",
   Content = "Menu visual renderizado. Aproveite o Farm!",
   Duration = 5,
   Image = 4483362458,
})
