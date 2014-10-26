local ScriptName = "BigFatBundle"
local ScriptVersion = 0.02

local Credits = {
    "Big Fat Corki", 
    "Astoriane"
}

local champions = {
    
    ["Corki"] = true,
    ["Ezreal"] = true,
    ["Graves"] = true

}

for k, _ in pairs(champions) do

    local className = k:gsub("%s+", "")
    class(className)
    champions[k] = _G[className]

end

-- CORKI --
