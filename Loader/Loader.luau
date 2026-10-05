-- =============================================================================
-- 🌋 VOLCANNON HUB - LOADER EXCLUSIVO: BLOX FRUITS (CORRIGIDO)
-- =============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local PlaceId = game.PlaceId
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("=========================================")
print("[🌋] BIENVENIDO A VOLCANNON HUB")
print("[🌋] Verificando servidor de Blox Fruits...")
print("=========================================")

local BloxFruitsSeas = {
    [2753915549]  = "Sea 1 (Pirate Starter)", 
    [4442272183]  = "Sea 2 (Kingdom of Rose)", 
    [7407953315]  = "Sea 3 (Floating Turtle)"  
}

-- LINK CORRIGIDO APONTANDO PARA O LINK RAW OFICIAL DO SEU REPOSITÓRIO
local MainHubUrl = "https://githubusercontent.com"

local function CarregarVolcannon()
    local seaDetectado = BloxFruitsSeas[PlaceId]
    
    if seaDetectado then
        print("[🌋] " .. seaDetectado .. " Detectado com sucesso!")
        print("[🌋] Baixando a interface grafica do servidor...")
        
        local ok, codigoFonte = pcall(game.HttpGet, game, MainHubUrl)
        
        if ok and codigoFonte then
            loadstring(codigoFonte)()
        else
            warn("[🌋] Erro de conexao: Nao foi possivel baixar o MainHub do Volcannon.")
            LocalPlayer:Kick("🌋 Volcannon: Erro de conexao com o servidor. Verifique o link RAW no GitHub.")
        end
    else
        print("[🌋] Bloqueio: Este jogo nao e o Blox Fruits legítimo.")
        warn("[🌋] Volcannon Loader cancelado. ID nao listado.")
    end
end

CarregarVolcannon()
