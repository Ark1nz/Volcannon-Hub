-- =============================================================================
-- VOLCANNON HUB - MÓDULO DE AUTO FARM (CORRIGIDO)
-- =============================================================================

local AutoFarm = {}

-- IMPORTANTE: Mudamos de 'readfile' para 'game:HttpGet' para rodar na nuvem!
local GithubUser = "Ark1nz"
local TweenUrl = "https://githubusercontent.com" .. GithubUser .. "/Volcannon-Hub/main/Scripts/BloxFruits/TweenModule.luau"
local Tween = loadstring(game:HttpGet(TweenUrl))()

-- VARIÁVEIS DE CONTROLE
local FarmAtivo = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
-- 3. FUNÇÃO PARA PEGAR A MISSÃO AUTOMATICAMENTE
local function PegarMissao(nomeDaMissao, numeroDaMissao)
    -- O Blox Fruits usa um RemoteFunction para o jogador aceitar missões
    local rFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    rFunctions:InvokeServer("StartQuest", nomeDaMissao, numeroDaMissao)
end

-- 4. LOOP PRINCIPAL DO FARM (Roda em segundo plano)
task.spawn(function()
    while true do
        task.wait(1) -- Checa o objetivo a cada 1 segundo
        
        if FarmAtivo then
            local Character = LocalPlayer.Character
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if RootPart then
                -- CONCEITO DE LOGICA:
                -- Se o jogador não tem missão ativa, voa até o NPC e pega a missão
                -- Se já tem a missão, voa até o monstro e ativa o Auto-Attack
                
                -- EXEMPLO: Farmando Bandidos (Ilha Inicial)
                local npcQuest = workspace.NPCs:FindFirstChild("Quest Giver")
                if npcQuest then
                    print("🌋 Volcannon: Voando ate o NPC de Missao...")
                    Tween:To(npcQuest.HumanoidRootPart.CFrame, 250)
                    task.wait(2)
                    PegarMissao("BanditQuest1", 1)
                end
            end
        end
    end
end)

-- 5. FUNÇÃO QUE O BOTÃO DA SUA INTERFACE VAI CHAMAR
function AutoFarm:AlternarFarm(estado)
    FarmAtivo = estado
    if estado then
        print("🌋 Volcannon: Auto Farm LIGADO.")
    else
        print("🌋 Volcannon: Auto Farm DESLIGADO.")
    end
end

return AutoFarm
