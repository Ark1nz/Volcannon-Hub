--!nocheck
--!nolint UnknownGlobal
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local PLACE_ID = 96179204081384
local BASE = "https://raw.githubusercontent.com/Ark1nz/Volcannon-Hub/refs/heads/main/Scripts/Evermortal/"

if game.PlaceId ~= PLACE_ID then
    warn("[Volcannon] Loader só para Cultivation: Evermortal. PlaceId atual: " .. game.PlaceId)
    return
end

local ok, src = pcall(function()
    return game:HttpGet(BASE .. "MainHub.luau")
end)
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