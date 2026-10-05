--!nocheck
--!nolint UnknownGlobal
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local AutoFarm = {}

AutoFarm.OnStatus = nil -- função(texto), definida pelo MainHub
AutoFarm.Config = {
    Velocidade = 250,     -- studs/s nos voos longos
    AlturaAtaque = 7,     -- distância acima do inimigo ao atacar
    ArmaTipo = "Melee",   -- "Melee", "Sword", "Blox Fruit", "Gun"
}
local Config = AutoFarm.Config

local Tween = nil
local Quests = {}
local rodando = false
local threadId = 0
local missaoAceita = nil   -- "quest#id" aceita por este script
local cacheMob = {}        -- última posição vista de cada mob
local conexoes = {}
local ultimoStatus = ""

local function Status(texto)
    if texto ~= ultimoStatus then
        ultimoStatus = texto
        if AutoFarm.OnStatus then pcall(AutoFarm.OnStatus, texto) end
    end
end

-- ===== Utilitários =====

local function Nivel()
    local ok, v = pcall(function() return LocalPlayer.Data.Level.Value end)
    return (ok and v) or 1
end

local function EscolherMissao(nivel)
    local melhor = nil
    for _, q in ipairs(Quests) do
        if nivel >= q.min and (not melhor or q.min > melhor.min) then
            melhor = q
        end
    end
    return melhor
end

local function MissaoAtiva()
    local ok, v = pcall(function() return LocalPlayer.PlayerGui.Main.Quest.Visible end)
    return ok and v == true
end

local function Invocar(...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if not commF then
        warn("[Volcannon] CommF_ não encontrado.")
        return false
    end
    local ok, err = pcall(commF.InvokeServer, commF, ...)
    if not ok then warn("[Volcannon] Falha no InvokeServer: " .. tostring(err)) end
    return ok
end

local function PosicaoDoModelo(m)
    if m:IsA("BasePart") then return m.Position end
    local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
    return r and r.Position
end

local function PosicaoSpawn(mob)
    local origem = workspace:FindFirstChild("_WorldOrigin")
    local spawns = origem and origem:FindFirstChild("EnemySpawns")
    if not spawns then return nil end
    for _, s in ipairs(spawns:GetChildren()) do
        if s.Name == mob or s.Name:find(mob, 1, true) then
            local p = PosicaoDoModelo(s)
            if p then return p end
        end
    end
    return nil
end

-- ===== Inimigos =====

local function AcharInimigo(mob)
    local _, root = Tween.GetChar()
    if not root then return nil end
    local pasta = workspace:FindFirstChild("Enemies")
    if not pasta then return nil end

    local melhor, melhorDist = nil, math.huge
    for _, e in ipairs(pasta:GetChildren()) do
        if e.Name == mob then
            local h = e:FindFirstChildOfClass("Humanoid")
            local r = e:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then
                local d = (r.Position - root.Position).Magnitude
                if d < melhorDist then
                    melhor, melhorDist = e, d
                end
            end
        end
    end
    if melhor then
        cacheMob[mob] = melhor.HumanoidRootPart.Position
    end
    return melhor
end

-- Posição do NPC: usa npcPos se existir; senão pega o NPC mais perto da área do mob
local function AcharNPC(missao)
    if missao.npcPos then
        return CFrame.new(missao.npcPos)
    end

    local ref = missao.mobPos or cacheMob[missao.mob] or PosicaoSpawn(missao.mob)
    if not ref then
        local e = AcharInimigo(missao.mob)
        ref = e and e.HumanoidRootPart.Position
    end
    if not ref then return nil end

    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    local melhorPos, melhorDist = nil, math.huge
    for _, n in ipairs(npcs:GetChildren()) do
        local p = PosicaoDoModelo(n)
        if p then
            local d = (p - ref).Magnitude
            if d < melhorDist then
                melhorPos, melhorDist = p, d
            end
        end
    end
    return melhorPos and CFrame.new(melhorPos) or nil
end

-- ===== Combate =====

local function EquiparArma()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end

    local mochila = LocalPlayer:FindFirstChildOfClass("Backpack")
    if mochila then
        for _, t in ipairs(mochila:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == Config.ArmaTipo then
                hum:EquipTool(t)
                return t
            end
        end
    end
    return nil
end

local function Atacar(inimigo, meuId)
    local eRoot = inimigo:FindFirstChild("HumanoidRootPart")
    local eHum = inimigo:FindFirstChildOfClass("Humanoid")
    if not eRoot or not eHum then return end

    local offset = CFrame.new(0, Config.AlturaAtaque, 0)

    local _, root = Tween.GetChar()
    if not root then return end
    if (root.Position - eRoot.Position).Magnitude > 60 then
        if not Tween:To(eRoot.CFrame * offset, Config.Velocidade) then return end
    end

    while rodando and meuId == threadId and inimigo.Parent and eHum.Health > 0 and MissaoAtiva() do
        local _, r = Tween.GetChar()
        if not r then break end -- morreu: o loop principal cuida do respawn

        Tween:Segurar(true)
        r.CFrame = eRoot.CFrame * offset

        local tool = EquiparArma()
        if tool then pcall(function() tool:Activate() end) end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
        end)

        task.wait(0.1)
    end
end

-- ===== Lógica principal =====

local function Passo(meuId)
    local _, root = Tween.GetChar()
    if not root then
        Status("Morto/respawnando...")
        task.wait(1)
        return
    end
    Tween:Segurar(true)

    local nivel = Nivel()
    local missao = EscolherMissao(nivel)
    if not missao then
        Status("Sem missão cadastrada para o nível " .. nivel)
        task.wait(2)
        return
    end
    local chave = missao.quest .. "#" .. missao.id

    -- Missão ativa, mas não é a que o nível pede (subiu de nível ou foi aceita antes do script)
    if MissaoAtiva() and missaoAceita ~= chave then
        Status("Trocando missão...")
        Invocar("AbandonQuest")
        missaoAceita = nil
        task.wait(0.5)
    end

    -- Pegar missão se não houver
    if not MissaoAtiva() then
        local npcCF = AcharNPC(missao)
        if not npcCF then
            Status("NPC não encontrado para " .. missao.mob .. " (preencha npcPos)")
            task.wait(2)
            return
        end
        Status("Indo pegar missão: " .. missao.mob)
        if not Tween:To(npcCF * CFrame.new(0, 0, 4), Config.Velocidade) then return end
        if meuId ~= threadId then return end

        task.wait(0.3)
        Invocar("StartQuest", missao.quest, missao.id)
        task.wait(0.6)

        if not MissaoAtiva() then
            Status("Missão não foi aceita, tentando de novo...")
            return
        end
        missaoAceita = chave
    end

    -- Atacar
    local inimigo = AcharInimigo(missao.mob)
    if inimigo then
        Status("Farmando: " .. missao.mob .. " (Lv " .. nivel .. ")")
        Atacar(inimigo, meuId)
    else
        local alvo = missao.mobPos or cacheMob[missao.mob] or PosicaoSpawn(missao.mob)
        if alvo then
            Status("Indo até a área de " .. missao.mob)
            Tween:To(CFrame.new(alvo + Vector3.new(0, Config.AlturaAtaque, 0)), Config.Velocidade)
        else
            Status("Procurando " .. missao.mob .. "...")
            task.wait(1)
        end
    end
end

-- ===== API pública =====

function AutoFarm:Init(tweenModule, listaDeMissoes)
    Tween = tweenModule
    Quests = listaDeMissoes or {}

    -- Respawn: cancela voo antigo; o loop principal retoma sozinho
    table.insert(conexoes, LocalPlayer.CharacterAdded:Connect(function()
        Tween:Cancel()
        task.wait(2)
    end))

    -- Anti-AFK
    table.insert(conexoes, LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))
end

function AutoFarm:AlternarFarm(estado)
    if not Tween then
        warn("[Volcannon] Chame AutoFarm:Init(Tween, Quests) antes.")
        return
    end
    if estado == rodando then return end

    rodando = estado
    threadId = threadId + 1
    local meuId = threadId

    if not estado then
        Tween:Cancel()
        Tween:Segurar(false)
        Status("Parado")
        return
    end

    task.spawn(function()
        while rodando and meuId == threadId do
            local ok, err = pcall(Passo, meuId)
            if not ok then warn("[Volcannon] Erro no farm: " .. tostring(err)) end
            task.wait(0.2)
        end
    end)
end

function AutoFarm:Debug()
    local linhas = {}
    local function add(t) table.insert(linhas, t) end

    local _, root = Tween.GetChar()
    add("Nivel: " .. Nivel() .. " | Missao ativa: " .. tostring(MissaoAtiva()))
    add("Minha posicao: " .. tostring(root and root.Position))

    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, n in ipairs(npcs:GetChildren()) do
            add("NPC: " .. n.Name .. " " .. tostring(PosicaoDoModelo(n)))
        end
    else
        add("workspace.NPCs nao existe")
    end

    local origem = workspace:FindFirstChild("_WorldOrigin")
    local spawns = origem and origem:FindFirstChild("EnemySpawns")
    if spawns then
        for _, s in ipairs(spawns:GetChildren()) do
            add("Spawn: " .. s.Name .. " " .. tostring(PosicaoDoModelo(s)))
        end
    else
        add("_WorldOrigin.EnemySpawns nao existe")
    end

    local texto = table.concat(linhas, "\n")
    print(texto)
    local copiar = (getgenv and getgenv().setclipboard) or setclipboard
    if copiar then pcall(copiar, texto) end
end

function AutoFarm:Destroy()
    self:AlternarFarm(false)
    for _, c in ipairs(conexoes) do c:Disconnect() end
    table.clear(conexoes)
end

return AutoFarm