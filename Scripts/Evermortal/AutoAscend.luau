--!nocheck
--!nolint UnknownGlobal
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoAscend = {}
AutoAscend.OnStatus = nil
AutoAscend.Alvo = 0
AutoAscend.Config = {
    NivelCaminho = "",   -- ex.: Players.LocalPlayer.PlayerGui.Main.RealmLabel  ou  Players.LocalPlayer@Realm
    AscendCaminho = "",  -- RemoteEvent, RemoteFunction ou botão da interface
    AscendArgs = {},
    Intervalo = 5,       -- segundos entre checagens
    Cooldown = 20,       -- espera depois de ascender
}
local Config = AutoAscend.Config

local rodando = false
local threadId = 0
local ultimoStatus = ""

local function Status(texto)
    if texto ~= ultimoStatus then
        ultimoStatus = texto
        if AutoAscend.OnStatus then pcall(AutoAscend.OnStatus, texto) end
    end
end

-- "Players.LocalPlayer.PlayerGui.X" -> instância
local function Resolver(caminho)
    if type(caminho) ~= "string" or caminho == "" then return nil end
    local atual = game
    for parte in string.gmatch(caminho, "[^%.]+") do
        if parte == "LocalPlayer" then
            atual = LocalPlayer
        else
            atual = atual:FindFirstChild(parte)
        end
        if not atual then return nil end
    end
    return atual
end

-- "caminho@Atributo" -> caminho, Atributo
local function Separar(caminho)
    local base, attr = string.match(caminho or "", "^(.-)@(.+)$")
    if base then return base, attr end
    return caminho, nil
end

local function LerNivel()
    local base, attr = Separar(Config.NivelCaminho)
    if not base or base == "" then return nil, "Defina o caminho do nível" end

    local inst = Resolver(base)
    if not inst then return nil, "Caminho do nível não encontrado" end

    local valor
    if attr then
        valor = inst:GetAttribute(attr)
    elseif inst:IsA("ValueBase") then
        valor = inst.Value
    elseif inst:IsA("TextLabel") or inst:IsA("TextButton") then
        valor = inst.Text
    else
        return nil, "Tipo não suportado: " .. inst.ClassName
    end

    if valor == nil then return nil, "Valor vazio" end
    if type(valor) == "number" then return valor end

    -- Lê o número logo depois de "Realm"; se não houver, usa o primeiro número
    local texto = tostring(valor):gsub(",", "")
    local n = tonumber(texto:match("[Rr]ealm%s*(%d+)")) or tonumber(texto:match("%d+%.?%d*"))
    if not n then return nil, "Não achei número em: " .. tostring(valor) end
    return n
end

local function Clicar(btn)
    local disparou = false
    if getconnections then
        for _, nome in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up" }) do
            local okS, sinal = pcall(function() return btn[nome] end)
            if okS and sinal then
                local okC, conns = pcall(getconnections, sinal)
                if okC and conns then
                    for _, c in ipairs(conns) do
                        if pcall(function() c:Fire() end) then disparou = true end
                    end
                end
            end
        end
    end
    if not disparou and firesignal then
        for _, nome in ipairs({ "MouseButton1Click", "Activated" }) do
            if pcall(function() firesignal(btn[nome]) end) then disparou = true end
        end
    end
    return disparou
end

local function Ascender()
    local inst = Resolver(Config.AscendCaminho)
    if not inst then return false, "Caminho do Ascend não encontrado" end

    local args = Config.AscendArgs or {}
    if inst:IsA("RemoteEvent") then
        local ok, err = pcall(function() inst:FireServer(table.unpack(args)) end)
        return ok, ok and "ok" or tostring(err)
    elseif inst:IsA("RemoteFunction") then
        local ok, err = pcall(function() inst:InvokeServer(table.unpack(args)) end)
        return ok, ok and "ok" or tostring(err)
    elseif inst:IsA("GuiButton") then
        local ok = Clicar(inst)
        return ok, ok and "ok" or "Executor sem getconnections/firesignal"
    end
    return false, "Tipo não suportado: " .. inst.ClassName
end

function AutoAscend:Testar()
    return Ascender()
end

function AutoAscend:Alternar(estado)
    if estado == rodando then return end
    rodando = estado
    threadId += 1
    local meuId = threadId

    if not estado then
        Status("Parado")
        return
    end

    task.spawn(function()
        while rodando and meuId == threadId do
            local ok, err = pcall(function()
                if AutoAscend.Alvo <= 0 then
                    Status("Defina o nível alvo")
                    return
                end
                local nivel, motivo = LerNivel()
                if not nivel then
                    Status(motivo)
                    return
                end
                if nivel >= AutoAscend.Alvo then
                    Status("Realm " .. nivel .. " >= alvo. Ascendendo...")
                    local okA, msg = Ascender()
                    if okA then
                        Status("Ascend enviado. Aguardando " .. Config.Cooldown .. "s")
                        task.wait(Config.Cooldown)
                    else
                        Status("Falha: " .. tostring(msg))
                    end
                else
                    Status("Realm " .. nivel .. " / alvo " .. AutoAscend.Alvo)
                end
            end)
            if not ok then warn("[Volcannon] Erro no Auto Ascend: " .. tostring(err)) end
            task.wait(Config.Intervalo)
        end
    end)
end

function AutoAscend:Destroy()
    self:Alternar(false)
end

return AutoAscend