-- =============================================================================
-- 🌋 VOLCANNON HUB - LOADER EXCLUSIVO: BLOX FRUITS
-- =============================================================================

-- 1. AGUARDAR O JOGO CARREGAR TOTALMENTE (Evita travamentos e erros no Delta Mobile)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- 2. IDENTIFICAÇÃO DO ID DO MAPA ATUAL
local PlaceId = game.PlaceId
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("=========================================")
print("[🌋] BIENVENIDO A VOLCANNON HUB")
print("[🌋] Verificando servidor de Blox Fruits...")
print("=========================================")

-- 3. MAPEAMENTO OFICIAL DE IDS DO BLOX FRUITS
local BloxFruitsSeas = {
    [2753915549]  = "Sea 1 (Pirate Starter)", -- ID Oficial do Sea 1
    [4442272183]  = "Sea 2 (Kingdom of Rose)", -- ID Oficial do Sea 2
    [7407953315]  = "Sea 3 (Floating Turtle)"  -- ID Oficial do Sea 3
}

-- 4. LINK PARA O SEU REPOSITÓRIO (Substitua SEU_USUARIO quando subir para o GitHub)
local GithubUser = "Ark1nz"
local MainHubUrl = "https://githubusercontent.com" .. GithubUser .. "/VolcannonHub/main/Scripts/BloxFruits/MainHub.luau"

-- 5. FUNÇÃO EXECUTORA
local function CarregarVolcannon()
    local seaDetectado = BloxFruitsSeas[PlaceId]
    
    if seaDetectado then
        print("[🌋] " .. seaDetectado .. " Detectado com sucesso!")
        print("[🌋] Baixando a interface grafica do servidor...")
        
        -- Faz a requisição web para puxar o painel visual
        local ok, codigoFonte = pcall(game.HttpGet, game, MainHubUrl)
        
        if ok and codigoFonte then
            -- Transforma o texto do GitHub em código executável na memória do celular
            loadstring(codigoFonte)()
        else
            -- Tratamento de erro caso o link do GitHub mude ou caia
            warn("[🌋] Erro de conexao: Nao foi possivel baixar o MainHub do Volcannon.")
            LocalPlayer:Kick("🌋 Volcannon: Erro de conexao com o servidor GitHub. Tente novamente!")
        end
    else
        -- Se o usuário tentar rodar esse loader específico em outro jogo (Ex: Murder Mystery 2)
        print("[🌋] Bloqueio: Este jogo nao e o Blox Fruits legítimo.")
        warn("[🌋] Volcannon Loader cancelado. ID nao listado.")
    end
end

-- Executa a inicialização
CarregarVolcannon()
