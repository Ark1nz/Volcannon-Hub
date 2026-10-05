--!nocheck
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = "https://raw.githubusercontent.com/Ark1nz/Volcannon-Hub/refs/heads/main/Scripts/BloxFruits/"

-- Confirme os IDs com print(game.PlaceId) em cada sea
local Seas = {
    [2753915549] = 1,
    [4442272183] = 2,
    [7449423635] = 3,
}

local sea = Seas[game.PlaceId]
if not sea then
    warn("[Volcannon] PlaceId " .. game.PlaceId .. " não suportado.")
    return
end

getgenv().VolcannonSea = sea

local ok, src = pcall(game.HttpGet, game, BASE .. "MainHub.luau")
if not ok then
    warn("[Volcannon] Não foi possível baixar o MainHub: " .. tostring(src))
    return
end

local fn, err = loadstring(src)
if not fn then
    warn("[Volcannon] Erro de sintaxe no MainHub: " .. tostring(err))
    return
end

local okRun, errRun = pcall(fn)
if not okRun then
    warn("[Volcannon] Erro ao executar o MainHub: " .. tostring(errRun))
end