--!nocheck
--!nolint UnknownGlobal
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Scanner = {}
local linhasSpy = {}
local spyAtivo = false
local hookado = false
local MAX_SPY = 300

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

-- Procura valores do jogador, remotes e textos de "realm"/"ascend"
function Scanner:Procurar()
    local out = {}

    local function secao(titulo, max, coletor)
        table.insert(out, "== " .. titulo .. " ==")
        local n = 0
        coletor(function(linha)
            if n < max then
                n += 1
                table.insert(out, linha)
            elseif n == max then
                n += 1
                table.insert(out, "... (cortado em " .. max .. " linhas)")
            end
        end)
    end

    -- 1) Valores do jogador FORA da interface (leaderstats, Data, atributos)
    secao("VALORES DO JOGADOR (fora da interface)", 80, function(add)
        for _, d in ipairs(LocalPlayer:GetDescendants()) do
            if d:IsA("ValueBase") and not d:FindFirstAncestor("PlayerGui") then
                add("VALOR: " .. Curto(d) .. " = " .. tostring(d.Value))
            end
        end
        for nome, v in pairs(LocalPlayer:GetAttributes()) do
            add("ATRIBUTO: Players.LocalPlayer@" .. nome .. " = " .. tostring(v))
        end
    end)

    -- 2) Remotes com "ascen" no nome (ou na pasta pai)
    secao("REMOTES com 'ascen'", 30, function(add)
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction"))
                and Curto(d):lower():find("ascen", 1, true) then
                add("REMOTE: " .. Curto(d) .. " [" .. d.ClassName .. "]")
            end
        end
    end)

    -- 3) Todos os remotes (para achar o Ascend pelo nome)
    secao("TODOS OS REMOTES (RF = função, RE = evento)", 200, function(add)
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local caminho = Curto(d):gsub("^ReplicatedStorage%.Packages%.Knit%.Services%.", "")
                add(caminho .. " [" .. d.ClassName:gsub("Remote", "") .. "]")
            end
        end
    end)

    -- 4) Textos e botões da interface (ignora os modelos 3D)
    secao("INTERFACE com 'ascen' / 'realm' / 'stage'", 80, function(add)
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        for _, d in ipairs(gui:GetDescendants()) do
            if not d:FindFirstAncestorOfClass("ViewportFrame") then
                local ehTexto = d:IsA("TextLabel") or d:IsA("TextButton")
                local conteudo = ehTexto and d.Text or ""
                local texto = conteudo:lower()
                local nome = d.Name:lower()

                if nome:find("ascen", 1, true) or texto:find("ascen", 1, true) then
                    add("UI: " .. Curto(d) .. " [" .. d.ClassName .. "] texto=" .. conteudo)
                    local b = d
                    while b and b ~= gui and not b:IsA("GuiButton") do b = b.Parent end
                    if b and b:IsA("GuiButton") then
                        add("BOTAO: " .. Curto(b) .. " [" .. b.ClassName .. "]")
                    end
                elseif texto:find("realm", 1, true) or texto:find("stage", 1, true) then
                    add("TEXTO: " .. Curto(d) .. " = " .. conteudo)
                end
            end
        end
    end)

    local resultado = table.concat(out, "\n")
    return resultado, Scanner:Copiar(resultado)
end

local function Registrar(remoto, metodo, pack)
    local partes = {}
    for i = 1, pack.n do partes[i] = Texto(pack[i]) end
    local linha = Curto(remoto) .. " : " .. metodo .. "(" .. table.concat(partes, ", ") .. ")"
    if linhasSpy[#linhasSpy] == linha then return end -- ignora repetição seguida
    table.insert(linhasSpy, linha)
    if #linhasSpy > MAX_SPY then table.remove(linhasSpy, 1) end
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