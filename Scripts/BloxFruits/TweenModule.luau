--!nocheck
-- =============================================================================
-- VOLCANNON HUB - MÓDULO DE TELETRANSPORTE (TWEEN)
-- =============================================================================
local TweenModule = {}

-- 1. SERVIÇOS DO ROBLOX
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 2. FUNÇÃO PRINCIPAL DE MOVIMENTAÇÃO SUCESSIVA
function TweenModule:To(posicaoAlvo, velocidade)
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    
    -- Garante que o personagem e a parte central dele existam antes de mover
    if not RootPart then return end
    
    -- Se o usuário não definir a velocidade, usamos 250 (velocidade padrão de farm seguro)
    velocidade = velocidade or 250
    
    -- Cálculo matemático: Distância = Posição Atual - Posição Alvo
    local distancia = (RootPart.Position - posicaoAlvo.Position).Magnitude
    local duracaoDoVoo = distancia / velocidade
    
    -- Configuração do comportamento do movimento (Linear = Sem aceleração/frenagem)
    local tweenInfo = TweenInfo.new(duracaoDoVoo, Enum.EasingStyle.Linear)
    
    -- Cria o objeto de animação física no motor do jogo
    local voo = TweenService:Create(RootPart, tweenInfo, {CFrame = posicaoAlvo})
    
    -- Inicia o voo suave
    voo:Play()
    
    -- Retorna o objeto do voo caso o script principal queira cancelar o movimento no meio do caminho
    return voo
end

return TweenModule
