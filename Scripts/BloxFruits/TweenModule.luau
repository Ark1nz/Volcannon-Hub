local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local TweenModule = {}

local tweenAtual = nil
local bv = nil
local noclipConn = nil

-- Função simples (chamar com ponto): Tween.GetChar()
function TweenModule.GetChar()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health > 0 then
        return char, root, hum
    end
    return nil
end

function TweenModule:Cancel()
    if tweenAtual then
        tweenAtual:Cancel()
        tweenAtual = nil
    end
end

-- Segura o personagem parado no ar e sem colisão. Seguro chamar várias vezes.
function TweenModule:Segurar(ativo)
    if ativo then
        local _, root = TweenModule.GetChar()
        if root and (not bv or bv.Parent ~= root) then
            if bv then bv:Destroy() end
            bv = Instance.new("BodyVelocity")
            bv.Name = "VolcannonHold"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = root
        end
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        end
    else
        if bv then bv:Destroy() bv = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end

-- Move até `alvo` (CFrame). Retorna true se chegou.
function TweenModule:To(alvo, velocidade)
    local _, root = TweenModule.GetChar()
    if not root then return false end

    self:Cancel()
    velocidade = velocidade or 250

    local distancia = (root.Position - alvo.Position).Magnitude
    if distancia < 1 then
        root.CFrame = alvo
        return true
    end

    local duracao = distancia / velocidade
    local tween = TweenService:Create(root, TweenInfo.new(duracao, Enum.EasingStyle.Linear), { CFrame = alvo })
    tweenAtual = tween

    -- Timeout de segurança (ex.: personagem morreu no meio do voo)
    local timeout = task.delay(duracao + 2, function()
        tween:Cancel()
    end)

    tween:Play()
    local estado = tween.Completed:Wait()
    pcall(task.cancel, timeout)

    if tweenAtual == tween then tweenAtual = nil end
    return estado == Enum.PlaybackState.Completed
end

return TweenModule