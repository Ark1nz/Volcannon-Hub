--!nocheck
--!nolint UnknownGlobal
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Scanner = {}
local linhasSpy = {}
local spyAtivo = false
local hookado = false
local MAX_LINHAS = 300

-- Troca "Players.SeuNome" por "Players.LocalPlayer" (formato aceito pelo AutoAscend)
local function Curto(inst)
    local nome = inst:GetFullName()
    local meu = LocalPlayer.Name:gsub("%p", "%%%0")
    return (nome:gsub("^Players%." .. meu, "Players.LocalPlayer"))
end

local function Texto(v)
    local t = typeof(v)
    if t == "Instance" then return Curto(v) end
    if t == "table" then return "{tabela}" end
    return tostring(v)
end

function Scanner:Copiar(texto)
    print(texto)
    if setclipboard then
        pcall(setclipboard, texto)
        return true
    end
    return false
end

-- Procura valores do jogador, remotes e botões relacionados a "ascend"
function Scanner:Procurar()
    local out = {}
    local function add(t)
        if #out < MAX_LINHAS then table.insert(out, t) end
    end

    add("== VALORES DO JOGADOR (candidatos a nível/reino) ==")
    for _, d in ipairs(LocalPlayer:GetDescendants()) do
        if d:IsA("ValueBase") then
            add("VALOR: " .. Curto(d) .. " = " .. tostring(d.Value))
        end
    end
    for nome, v in pairs(LocalPlayer:GetAttributes()) do
        add("ATRIBUTO: Players.LocalPlayer@" .. nome .. " = " .. tostring(v))
    end

    add("== REMOTES com 'ascen' ==")
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction"))
            and d.Name:lower():find("ascen", 1, true) then
            add("REMOTE: " .. Curto(d) .. " [" .. d.ClassName .. "]")
        end
    end

    add("== INTERFACE com 'ascen' / 'realm' ==")
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        for _, d in ipairs(gui:GetDescendants()) do
            local texto = ""
            if d:IsA("TextLabel") or d:IsA("TextButton") then texto = d.Text:lower() end
            local nome = d.Name:lower()

            if nome:find("ascen", 1, true) or texto:find("ascen", 1, true) then
                add("UI: " .. Curto(d) .. " [" .. d.ClassName .. "] texto=" .. (d:IsA("TextLabel") or d:IsA("TextButton") and d.Text or ""))
                local b = d
                while b and b ~= gui and not b:IsA("GuiButton") do b = b.Parent end
                if b and b:IsA("GuiButton") then
                    add("BOTAO: " .. Curto(b) .. " [" .. b.ClassName .. "]")
                end
            elseif texto:find("realm", 1, true) or texto:find("stage", 1, true) then
                add("TEXTO: " .. Curto(d) .. " = " .. d.Text)
            end
        end
    end

    local resultado = table.concat(out, "\n")
    return resultado, Scanner:Copiar(resultado)
end

local function Registrar(remoto, metodo, pack)
    local partes = {}
    for i = 1, pack.n do partes[i] = Texto(pack[i]) end
    local linha = Curto(remoto) .. " : " .. metodo .. "(" .. table.concat(partes, ", ") .. ")"
    if linhasSpy[#linhasSpy] == linha then return end -- ignora repetição seguida
    table.insert(linhasSpy, linha)
    if #linhasSpy > MAX_LINHAS then table.remove(linhasSpy, 1) end
    print("[Spy] " .. linha)
end

function Scanner:Spy(ativo)
    spyAtivo = ativo
    if ativo and not hookado then
        if not (hookmetamethod and getnamecallmethod) then
            warn("[Volcannon] Seu executor não suporta hookmetamethod.")
            spyAtivo = false
            return false
        end
        hookado = true
        local antigo
        antigo = hookmetamethod(game, "__namecall", function(self, ...)
            if spyAtivo then
                local metodo = getnamecallmethod()
                if metodo == "FireServer" or metodo == "InvokeServer" then
                    -- registra fora do hook para não atrapalhar a chamada original
                    task.defer(function(...) pcall(Registrar, self, metodo, ...) end, table.pack(...))
                end
            end
            return antigo(self, ...)
        end)
    end
    return spyAtivo
end

function Scanner:CopiarSpy()
    local texto = table.concat(linhasSpy, "\n")
    local copiou = Scanner:Copiar(texto)
    return #linhasSpy, copiou
end

function Scanner:LimparSpy()
    linhasSpy = {}
end

return Scanner