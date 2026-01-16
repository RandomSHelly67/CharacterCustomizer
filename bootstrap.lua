local function requireModule(name)
    local url = BASE_URL .. name .. ".lua"
    local success, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        error("[CharacterCustomizer] Failed to fetch module: "..name.." from URL: "..url)
    end

    local fn, err = loadstring(src)
    if not fn then
        error("[CharacterCustomizer] Failed to load module: "..name.."\n"..err)
    end

    local result = fn()
    Loaded[name] = result
    return result
end
