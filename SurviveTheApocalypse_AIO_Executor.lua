local IS_APOC = game.GameId == 9098570654; local Players = game:GetService("Players")
if not game:IsLoaded() then game.Loaded:Wait() end; while not Players.LocalPlayer do task.wait() end; local LocalPlayer = Players.LocalPlayer

-- Survive the Apocalypse All-in-One, other-executor version, by DeadEyeZJhin, coded with Claude (Anthropic). Build aio-2026-11-25zzx.
-- Install: put this file in your executor's autoexec folder or run it in a match. Own menu window: Right Alt hides / shows it. V = Speed, N = Noclip.
-- Runs only in Survive the Apocalypse. Settings go to the executor's workspace folder. Use at your own risk: it sends the game's own messages (pickup, crates) and the game has an anti-cheat. Vibecoded.
local NO_LOGS = true  -- true = no log files and no console lines (public copy)
local VERSION = "aio-2026-11-25zzx"  -- bump on every edit so the log shows which copy ran
local GAME_ID, LOG_FILE, APOC_DIR = "", "hbx_log.txt", "SurviveTheApocalypse"
local logDirOk, logDirErr = pcall(function()
    local ok, id = pcall(function() return game.GameId end); if not ok or not id or id == 0 then id = game.PlaceId end
    GAME_ID = tostring(id); LOG_FILE = "hbx_log_" .. GAME_ID .. ".txt"
    _G.APOC_LOG_FILE = nil; if GAME_ID ~= "9098570654" then return end  -- nil: no stale file in other games
    pcall(makefolder, APOC_DIR); if NO_LOGS then return end;  -- NO_LOGS: set only by the public release header pcall(makefolder, APOC_DIR .. "/logs")
    local kind, idx = (game.PlaceId == 90148635862803 or game.PlaceId == 80046280333935) and "lobby" or "game", APOC_DIR .. "/logs/index.txt"
    local n, okR, txt = 0, pcall(readfile, idx)  -- pcall: a missing index.txt must not stop the log
    for k in string.gmatch(okR and type(txt) == "string" and txt or "", kind .. "(%d+)_") do n = math.max(n, tonumber(k)) end
    LOG_FILE = APOC_DIR .. "/logs/" .. kind .. (n + 1) .. "_" .. VERSION .. ".txt"; _G.APOC_LOG_FILE = LOG_FILE
end)
pcall(function()  -- other games: one file, trimmed to its last ~300 KB
    local s = not string.find(LOG_FILE, "/", 1, true) and isfile(LOG_FILE) and readfile(LOG_FILE) or ""
    if #s > 300000 then s = s:sub(-300000); writefile(LOG_FILE, s:sub((s:find("\n") or 0) + 1)) end end)
local function log(msg) if NO_LOGS then return end
    local ok, t = pcall(os.date, "%H:%M:%S")
    pcall(appendfile, LOG_FILE, (ok and t or tostring(tick())) .. " " .. msg .. "\n")
end
local function say(msg) if not NO_LOGS then print("[HBX] " .. msg) end; log(msg) end
-- Errors also pop up in Matcha (notify) once per message, so a broken test is noticed while playing, not only in the log.
local alerted = {}
local function alert(msg)
    say(msg)
    -- Leaving a game (teleport) always ends the run with this one; harmless, so no pop-up.
    if alerted[msg] or string.find(msg, "missing method 'GetPlayers'", 1, true) then return end
    alerted[msg] = true
    pcall(notify, msg .. (NO_LOGS and "" or " -- please send the logs from C:\\matcha\\workspace to the script author"), "NPC Hitbox", 10)
end
-- Matcha's error messages carry no line number. An xpcall handler runs where the error happened, so debug.info
-- can still read the line there (level 1 = this handler, 2+ = the failing code; C functions report -1).
local function try(fn)
    if type(xpcall) ~= "function" then return pcall(fn) end
    return xpcall(fn, function(e)
        local line
        if type(debug) == "table" and type(debug.info) == "function" then
            for level = 2, 5 do
                local l = debug.info(level, "l")
                if type(l) == "number" and l > 0 then line = l; break end
            end
        end
        return tostring(e) .. (line and (" (line " .. line .. ")") or "")
    end)
end
pcall(function() log("==== Run started (v" .. VERSION .. "): " .. tostring(getgamename()) .. " (place " .. tostring(game.PlaceId) .. ")") end)
-- Self-check, logged once per run: the line should end in "(line 54)", the line just below.
do local _, e = try(function() local t = nil; return t.x end); log("Line check: " .. tostring(e)) end
-- Other executors (owner, 2026-11-25, risk accepted): Matcha's own globals are filled in only when they are missing,
-- so on Matcha (which has UI) none of this runs. The menu below copies Matcha's UI calls with a plain Roblox window.
-- _G.EXEC_SHIM_STOP is set by an earlier run of this copy: it runs again so a new Execute replaces the old window.
if UI == nil or _G.EXEC_SHIM_STOP then pcall(function()
    -- Execute again (owner): close the earlier run's window, keys and movement first; its loops stop on _G.HBX_RUN.
    if type(_G.EXEC_SHIM_STOP) == "function" then pcall(_G.EXEC_SHIM_STOP) end
    -- Real's autoexec runs on through the lobby -> match teleport, so the stop-before-teleport is skipped here.
    EXEC_COPY = true
    -- First run only (owner, 2026-11-25): with no settings file yet, a player starts from the owner's settings
    -- (ExecutorDefaults\*.json, put in here by build_apoc_aio.py). Existing settings files are never touched.
    local EXEC_DEFAULTS = {["SurviveTheApocalypse/hitbox_settings.json"] = [==[{"aimKey":4,"aimMode":1,"auraBounce":60,"auraCraft":true,"auraCraftAt":50,"auraGuide":true,"auraMin":2,"auraMode":2,"auraRange":130,"auraSleep":true,"auraTurret":true,"auraWait":1,"enabled":true,"folder":"Characters","fov":120,"fovOn":true,"hideCorpses":true,"hitboxSize":6.5,"hotkey":0,"ignorePlayers":true,"killOn":true,"maxDistance":503,"partIndex":1,"skipNames":"Merchant"}]==], ["SurviveTheApocalypse/pickup_settings.json"] = [==[{"antiAfk":true,"armor":true,"badge":"","bagUp":true,"batt":true,"battPack":true,"crateMinTier":3,"crates":true,"esp":{"ammo":false,"armor":true,"bandage":false,"battery":true,"battpack":true,"bloodtrial":true,"compound":false,"crate":true,"emeraldcrate":true,"epicscrap":true,"food":false,"fuel":false,"gem":true,"goodscrap":true,"gun":false,"med":false,"medkit":false,"melee":false,"military":true,"milturret":true,"nuclear":true,"nuclearraid":true,"other":false,"pistolammo":true,"rarecrate":false,"refined":false,"res":false,"scrap":false,"super":true,"survivor":true,"throw":false,"upgrader":true,"vehicle":true,"wear":false},"espAmmo":0,"espColor":{"battpack":[0.15686273574829102,1,0.16908210515975952],"crate":[1,0,0],"military":[0,0.5590909123420715,0.12154147028923035],"nuclear":[0.9999995231628418,0,1],"nuclearraid":[0.8840579986572266,0,1],"pistolammo":[1,1,1],"upgrader":[0,1,0.9710142612457275]},"espDist":368,"espOn":true,"espVehicle":0,"extra":"","food":true,"fuel":true,"fuelStopDay":20,"goodScrap":" tv, aircon, air con, watch, satellite dish, ac","hotkey":0,"joinMin":2,"joinMode":0,"leaveAt":2,"mask":true,"mreBag2":true,"partySize":2,"pick":{"ammo":true,"bandage":true,"blueprint":false,"car":false,"compound":true,"emerald":true,"gasmask":false,"gun":false,"keycard":true,"medical":true,"medkit":true,"throwable":false,"turret":true,"wrench":true},"range":9,"scrap":true,"weapon":true,"weaponBag":true}]==]}
    pcall(makefolder, "SurviveTheApocalypse")
    for path, text in pairs(EXEC_DEFAULTS) do
        if not isfile(path) then pcall(writefile, path, text) end
    end
    local UIS = game:GetService("UserInputService")
    local LP = game:GetService("Players").LocalPlayer
    -- Matcha gives every Instance a number .Address; the script keys tables by it. Same idea: one number per Instance.
    -- Hooked once per game session: a second Execute keeps the first hook and its numbers.
    local ids, nextId = setmetatable({}, {__mode = "k"}), 0
    if _G.EXEC_ADDR_HOOKED then
        -- already hooked by an earlier run
    elseif type(hookmetamethod) == "function" then
        _G.EXEC_ADDR_HOOKED = true
        local old
        old = hookmetamethod(game, "__index", (newcclosure or function(f) return f end)(function(self, k)
            if k == "Address" and typeof(self) == "Instance" then
                local a = ids[self]
                if not a then nextId = nextId + 1; a = nextId; ids[self] = a end
                return a
            end
            return old(self, k)
        end))
    else
        log("Executor has no hookmetamethod: .Address reads will fail")
    end
    -- Windows key codes the script uses -> Roblox keys.
    local VK = {[0x20] = "Space", [0x09] = "Tab", [0x0D] = "Return", [0x1B] = "Escape", [0xA0] = "LeftShift",
        [0xA1] = "RightShift", [0xA2] = "LeftControl", [0xA3] = "RightControl", [0xA4] = "LeftAlt", [0xA5] = "RightAlt",
        [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down"}
    local DIGITS = {"Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"}
    local MOUSE = {[0x01] = Enum.UserInputType.MouseButton1, [0x02] = Enum.UserInputType.MouseButton2,
        [0x04] = Enum.UserInputType.MouseButton3}
    local function keyOf(vk)
        local n = VK[vk] or (vk >= 0x41 and vk <= 0x5A and string.char(vk)) or (vk >= 0x30 and vk <= 0x39 and DIGITS[vk - 0x2F])
        return n and Enum.KeyCode[n] or nil
    end
    if type(iskeypressed) ~= "function" then
        -- shortcut: mouse side buttons (0x05/0x06) read as never pressed; Roblox does not report them.
        iskeypressed = function(vk)
            if MOUSE[vk] then return UIS:IsMouseButtonPressed(MOUSE[vk]) end
            local k = keyOf(vk)
            return k ~= nil and UIS:IsKeyDown(k)
        end
    end
    if type(keypress) ~= "function" or type(keyrelease) ~= "function" then
        local VIM = game:GetService("VirtualInputManager")
        keypress = function(vk) local k = keyOf(vk); if k then VIM:SendKeyEvent(true, k, false, game) end end
        keyrelease = function(vk) local k = keyOf(vk); if k then VIM:SendKeyEvent(false, k, false, game) end end
    end
    if type(notify) ~= "function" then
        notify = function(msg, title, secs)
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",
                {Title = tostring(title or "Script"), Text = tostring(msg), Duration = secs or 5}) end)
        end
    end
    if type(getgamename) ~= "function" then
        getgamename = function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
            return ok and info and info.Name or game.Name
        end
    end
    if type(WorldToScreen) ~= "function" then
        WorldToScreen = function(p)
            local v, on = workspace.CurrentCamera:WorldToViewportPoint(p)
            return Vector2.new(v.X, v.Y), on
        end
    end

    -- Menu: Matcha calls each tab's function every frame and reads widgets by id. Here the function runs 4 times a
    -- second; each widget is made once (by id) and then only its text changes. Widgets not drawn this pass are hidden.
    -- Two columns like Matcha: tab:Section(name, "Left" | "Right").
    local vals, tabs = {}, {}
    local comboItems = {}  -- Combo id -> its latest item list
    local C = {bg = Color3.fromRGB(20, 20, 26), col = Color3.fromRGB(28, 28, 36), row = Color3.fromRGB(40, 40, 52),
        btn = Color3.fromRGB(58, 52, 86), accent = Color3.fromRGB(125, 95, 230), fg = Color3.fromRGB(235, 235, 240),
        dim = Color3.fromRGB(165, 165, 180), box = Color3.fromRGB(14, 14, 18)}
    local PALETTE = {{1, 1, 1}, {1, 0.3, 0.3}, {1, 0.6, 0.2}, {1, 1, 0.3}, {0.3, 1, 0.3}, {0.3, 1, 1}, {0.4, 0.5, 1}, {1, 0.4, 1}}
    local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function corner(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r or 4)}, o) end

    -- Speed (V) and Noclip (N), this copy only (owner, 2026-11-25, accepts the anti-cheat risk). Both start off.
    -- Speed holds Humanoid.WalkSpeed at the menu value and puts the game's own value back when turned off.
    -- Noclip turns collision off on your character's parts each physics step and back on when turned off.
    local MOVE_FILE = "SurviveTheApocalypse/movement.json"
    local HS, RS = game:GetService("HttpService"), game:GetService("RunService")
    local conns = {}
    vals.move_speedOn, vals.move_noclip, vals.move_speed = false, false, 30
    local savedMove = {}
    pcall(function() savedMove = HS:JSONDecode(readfile(MOVE_FILE)) end)
    vals.move_speed = tonumber(savedMove.speed) or 30
    local savedSpeed, origSpeed, offParts = vals.move_speed, nil, {}
    -- Drive through the play-zone border (owner, 2026-11-25, Explorer: workspace.Map.Border holds Border, Invis,
    -- Visual1-3 and folders 1-3). Every part in it loses collision and touch on your side only, so your car (your
    -- game moves it) passes through. Re-applied every second in case the game resets them; put back when turned off.
    vals.move_border = savedMove.border == true  -- remembered like the settings (owner); Speed / Noclip always start off
    local borderOff, borderNext, savedBorder = {}, 0, vals.move_border
    local function restoreBorder()
        for p, o in pairs(borderOff) do pcall(function() p.CanCollide, p.CanTouch = o[1], o[2] end) end
        borderOff = {}
    end
    local function restoreMove()
        restoreBorder()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and origSpeed then pcall(function() hum.WalkSpeed = origSpeed end) end
        origSpeed = nil
        for p in pairs(offParts) do pcall(function() p.CanCollide = true end) end
        offParts = {}
    end
    conns[#conns + 1] = UIS.InputBegan:Connect(function(i, typing)
        if typing then return end
        local key = i.KeyCode == Enum.KeyCode.V and "move_speedOn" or i.KeyCode == Enum.KeyCode.N and "move_noclip"
        if not key then return end
        vals[key] = not vals[key]
        notify((key == "move_speedOn" and "Speed " or "Noclip ") .. (vals[key] and "on" or "off"), "Movement", 2)
    end)
    conns[#conns + 1] = RS.Stepped:Connect(function()
        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum and vals.move_speedOn then
            if not origSpeed then origSpeed = hum.WalkSpeed end
            -- _G.APOC_SPEED_CAP: Auto Farm keeps you under the game's KM_MAX_PLAYER_SPEED (rubber-banding test)
            hum.WalkSpeed = math.min(tonumber(vals.move_speed) or 30, tonumber(_G.APOC_SPEED_CAP) or math.huge)
        elseif hum and origSpeed then
            hum.WalkSpeed = origSpeed
            origSpeed = nil
        end
        if vals.move_noclip and ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false; offParts[p] = true end
            end
        elseif next(offParts) then
            for p in pairs(offParts) do pcall(function() p.CanCollide = true end) end
            offParts = {}
        end
        if vals.move_border and os.clock() >= borderNext then
            borderNext = os.clock() + 1
            local map = workspace:FindFirstChild("Map")
            local b = map and map:FindFirstChild("Border")
            for _, p in ipairs(b and b:GetDescendants() or {}) do
                if p:IsA("BasePart") then
                    if not borderOff[p] then borderOff[p] = {p.CanCollide, p.CanTouch} end
                    p.CanCollide, p.CanTouch = false, false
                end
            end
        elseif not vals.move_border and next(borderOff) then
            restoreBorder()
        end
        if vals.move_speed ~= savedSpeed or vals.move_border ~= savedBorder then
            savedSpeed, savedBorder = vals.move_speed, vals.move_border
            pcall(writefile, MOVE_FILE, HS:JSONEncode({speed = savedSpeed, border = savedBorder}))
        end
    end)
    -- Anti AFK in the background (owner, 2026-11-25): Roblox fires LocalPlayer.Idled after 2 min without input; a
    -- VirtualUser click then resets the 20 min idle kick even when Roblox is not the focused window or is minimized.
    -- Follows the menu's Anti AFK toggle (_G.APOC_ANTIAFK). The Space tap in the helper still runs as before.
    local idleLogged = false
    conns[#conns + 1] = LP.Idled:Connect(function()
        if _G.APOC_ANTIAFK == false then return end
        local ok = pcall(function()
            local VU = game:GetService("VirtualUser")
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
        if not idleLogged then idleLogged = true; log("Anti AFK: idle click sent in the background (ok " .. tostring(ok) .. ")") end
    end)
    local function moveMenu(tab)
        local s = tab:Section("Movement", "Left")
        s:Toggle("move_speedOn", "Speed (V)", false)
        s:SliderFloat("move_speed", "Walk speed", 16, 120, 30, "%.1f")
        s:Toggle("move_noclip", "Noclip (N)", false)
        s:Toggle("move_border", "Drive through the map border (remembered)", false)
    end

    UI = {}
    function UI.GetValue(id) return vals[id] end
    function UI.SetValue(id, v) vals[id] = v end
    function UI.RemoveTab(name)
        local t = tabs[name]
        if not t then return end
        tabs[name] = nil
        t.alive = false
        for _, c in ipairs(t.conns) do pcall(function() c:Disconnect() end) end
        pcall(function() t.sg:Destroy() end)
    end
    local quick  -- the quick-toggle tail; only the newest menu's round button carries it
    function UI.AddTab(name, draw)
        UI.RemoveTab(name)
        local t = {alive = true, conns = {}}
        tabs[name] = t
        local function on(sig, fn) t.conns[#t.conns + 1] = sig:Connect(fn) end
        local sg = mk("ScreenGui", {Name = name, ResetOnSpawn = false})
        t.sg = sg
        if not pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end) then
            sg.Parent = LP:WaitForChild("PlayerGui")
        end
        -- Mobile (owner, 2026-11-25): drag with mouse or finger, so the old Frame.Draggable (mouse only) is gone.
        local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
        local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
        local function dragger(h, begin, move, done)
            local from
            on(h.InputBegan, function(i) if isPress(i) then from = i.Position; begin() end end)
            on(UIS.InputChanged, function(i) if from and isMove(i) then move(i.Position.X - from.X, i.Position.Y - from.Y) end end)
            on(UIS.InputEnded, function(i) if from and isPress(i) then from = nil; if done then done() end end end)
        end
        local vp = workspace.CurrentCamera.ViewportSize
        local small = vp.X < 760
        -- Owner: the menu remembers the size (and spot) the player left it at, per menu, in this file.
        local LAYOUT_FILE = "SurviveTheApocalypse/menu_" .. name:gsub("%W", "") .. ".json"
        local lay = {}
        pcall(function() lay = HS:JSONDecode(readfile(LAYOUT_FILE)) end)
        -- Owner (2026-11-25): tap a section title to fold / unfold it; remembered here with the size and spot.
        local collapsed = type(lay.collapsed) == "table" and lay.collapsed or {}
        local curCollapsed = false
        local W0 = math.clamp(tonumber(lay.w) or 680, 300, math.max(300, vp.X - 20))
        local H0 = math.clamp(tonumber(lay.h) or 540, 200, math.max(200, vp.Y - 70))
        local X0 = math.clamp(tonumber(lay.x) or (small and 10 or 40), 0, math.max(0, vp.X - W0))
        local Y0 = math.clamp(tonumber(lay.y) or (small and 50 or 60), 0, math.max(0, vp.Y - 30))
        local win = mk("Frame", {Size = UDim2.new(0, W0, 0, H0), Position = UDim2.new(0, X0, 0, Y0), BackgroundColor3 = C.bg,
            BorderSizePixel = 0, Active = true}, sg)
        local fullSize
        local function saveLayout()
            local s = fullSize or win.Size
            pcall(writefile, LAYOUT_FILE, HS:JSONEncode({w = s.X.Offset, h = s.Y.Offset,
                x = win.AbsolutePosition.X, y = win.AbsolutePosition.Y, collapsed = collapsed}))
        end
        corner(win, 6)
        local title = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.accent, BorderSizePixel = 0, TextColor3 = C.fg,
            Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            Text = name .. "   (Right Alt or the round button hides / shows, drag here)"}, win)
        mk("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 70)}, title)
        local p0
        dragger(title, function() p0 = win.Position end, function(dx, dy) win.Position = p0 + UDim2.new(0, dx, 0, dy) end, saveLayout)
        local function titleBtn(txt, x)
            local b = mk("TextButton", {Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, x, 0, 3), BackgroundColor3 = C.row,
                BorderSizePixel = 0, Text = txt, TextColor3 = C.fg, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false}, win)
            corner(b, 4)
            return b
        end
        local minBtn, closeBtn = titleBtn("-", -64), titleBtn("X", -32)
        on(closeBtn.MouseButton1Click, function() win.Visible = false end)
        local grip = mk("TextButton", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -18, 1, -18), BackgroundColor3 = C.accent,
            BackgroundTransparency = 0.3, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 5}, win)
        corner(grip, 4)
        local s0
        dragger(grip, function() s0 = win.AbsoluteSize end, function(dx, dy)
            win.Size = UDim2.new(0, math.max(300, s0.X + dx), 0, math.max(200, s0.Y + dy))
        end, saveLayout)
        -- Round button: tap = hide / show the menu, drag = move it. One per menu, stacked down the left edge.
        local nTabs = 0
        for _ in pairs(tabs) do nTabs = nTabs + 1 end
        local icon = mk("TextButton", {Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 10, 0.35, (nTabs - 1) * 54),
            BackgroundColor3 = C.accent, BorderSizePixel = 0, Text = name == "Apocalypse" and "STA" or name:sub(1, 3),
            TextColor3 = Color3.new(1, 1, 1), TextStrokeColor3 = Color3.new(0, 0, 0), TextStrokeTransparency = 0,
            Font = Enum.Font.GothamBlack, TextSize = 16, AutoButtonColor = false, ZIndex = 50}, sg)
        corner(icon, 23)
        -- Border mode: the default (Contextual) stroked the letters instead and made them blurry (owner: hard to read).
        mk("UIStroke", {Color = C.fg, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, icon)
        local ip0, moved
        dragger(icon, function() ip0, moved = icon.Position, false end, function(dx, dy)
            if math.abs(dx) + math.abs(dy) > 8 then moved = true end
            if moved then icon.Position = ip0 + UDim2.new(0, dx, 0, dy) end
        end)
        on(icon.MouseButton1Click, function() if not moved then win.Visible = not win.Visible end end)
        -- Quick toggles (owner): a small tab under the round button opens a list; tap a name to switch it on / off.
        -- It hangs under the newest button (the lowest one), so it never covers the other button. A row hides when
        -- that setting is not in the menu (Kill Aura is Pro-only).
        if quick then pcall(function() quick:Destroy() end) end
        -- Owner: compact list, the open / close tab sits at the bottom, under the toggles.
        local list = mk("Frame", {Position = UDim2.new(0.5, -36, 1, 3), Size = UDim2.new(0, 72, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1}, icon)
        mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, list)
        quick = list
        local tail = mk("TextButton", {Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = 9,
            Text = "v", TextColor3 = C.fg, Font = Enum.Font.GothamBold, TextSize = 15, AutoButtonColor = false, ZIndex = 50}, list)
        corner(tail, 4)
        list.Visible = true
        local rows = {}
        local function keyOf(pat)
            for k in pairs(vals) do if type(k) == "string" and k:find(pat) then return k end end
        end
        local function flip(pat) local k = keyOf(pat); if k then vals[k] = not vals[k] end end
        local function small(parent, txt, w, fn)
            local s = mk("TextButton", {Size = UDim2.new(0, w, 0, 22), BackgroundColor3 = C.row, BorderSizePixel = 0, Text = txt,
                TextColor3 = C.fg, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 50}, parent)
            corner(s, 4)
            if fn then on(s.MouseButton1Click, fn) end
            return s
        end
        local function stepSpeed(d)
            vals.move_speed = math.clamp(math.floor(((tonumber(vals.move_speed) or 30) + d) * 10 + 0.5) / 10, 16, 120)
        end
        -- Owner: a ">" beside a row opens a side panel (Speed: +/- 0.1 and 1; Kill Aura: its guide circles).
        local sides = {
            Speed = function(f)
                small(f, "-1", 26, function() stepSpeed(-1) end)
                small(f, "-.1", 26, function() stepSpeed(-0.1) end)
                local v = small(f, "", 40)
                small(f, "+.1", 26, function() stepSpeed(0.1) end)
                small(f, "+1", 26, function() stepSpeed(1) end)
                return function() v.Text = string.format("%.1f", tonumber(vals.move_speed) or 30) end
            end,
            ["Kill Aura"] = function(f)
                local g = small(f, "Guide", 50, function() flip("^hbx_auraGuide_") end)
                return function() local k = keyOf("^hbx_auraGuide_"); g.BackgroundColor3 = k and vals[k] and C.accent or C.row end
            end,
        }
        for i, q in ipairs({{"Speed", "^move_speedOn$"}, {"Noclip", "^move_noclip$"}, {"Kill Aura", "^hbx_killOn_"},
                {"Auto Loot", "^apoc_on_"}, {"ESP", "^apoc_espOn_"}}) do
            local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = i,
                Text = q[1], TextColor3 = C.fg, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 50,
                Visible = false}, list)
            corner(b, 4)
            local r = {b = b, pat = q[2]}
            rows[#rows + 1] = r
            on(b.MouseButton1Click, function() flip(q[2]) end)
            if sides[q[1]] then
                local f = mk("Frame", {Position = UDim2.new(1, 24, 0, 0), Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1, Visible = false}, b)
                mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)}, f)
                local arrow = mk("TextButton", {Size = UDim2.new(0, 20, 0, 22), Position = UDim2.new(1, 2, 0, 0), BackgroundColor3 = C.row,
                    BorderSizePixel = 0, Text = ">", TextColor3 = C.fg, Font = Enum.Font.GothamBold, TextSize = 13,
                    AutoButtonColor = false, ZIndex = 50}, b)
                corner(arrow, 4)
                on(arrow.MouseButton1Click, function() f.Visible = not f.Visible; arrow.Text = f.Visible and "<" or ">" end)
                r.refresh = sides[q[1]](f)
            end
        end
        local open = false
        on(tail.MouseButton1Click, function()
            open = not open
            tail.Text = open and "^" or "v"
            if not open then for _, r in ipairs(rows) do r.b.Visible = false end end
        end)
        on(RS.Heartbeat, function()
            if not open then return end
            for _, r in ipairs(rows) do
                local k = keyOf(r.pat)
                r.b.Visible = k ~= nil
                r.b.BackgroundColor3 = k and vals[k] and C.accent or C.row
                if r.refresh and k then r.refresh() end
            end
        end)
        local cols = {}
        for i, side in ipairs({"Left", "Right"}) do
            local f = mk("ScrollingFrame", {Position = UDim2.new((i - 1) / 2, i == 1 and 6 or 3, 0, 36),
                Size = UDim2.new(0.5, -9, 1, -42), BackgroundColor3 = C.col, BorderSizePixel = 0, ScrollBarThickness = 4,
                ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, win)
            corner(f, 4)
            mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)}, f)
            mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 10)}, f)
            cols[side] = f
        end
        on(minBtn.MouseButton1Click, function()
            local mini = cols.Left.Visible
            for _, f in pairs(cols) do f.Visible = not mini end
            grip.Visible = not mini
            minBtn.Text = mini and "+" or "-"
            if mini then fullSize = win.Size; win.Size = UDim2.new(0, win.AbsoluteSize.X, 0, 30) else win.Size, fullSize = fullSize, nil end
        end)
        on(UIS.InputBegan, function(i, typing)
            if not typing and i.KeyCode == Enum.KeyCode.RightAlt then win.Visible = not win.Visible end
        end)
        -- Owner: the game hides the mouse icon, so the menu was hard to click. A white dot shows where the mouse is when
        -- it is over the menu. The mouse is never freed or locked by the menu (25h did that: it broke shift lock and
        -- right-click camera, owner): with shift lock on, turn it off to click the menu. Right Alt hides / shows it
        -- (owner: Right Ctrl is used by something else).
        sg.IgnoreGuiInset, sg.DisplayOrder = true, 1000
        local dot = mk("Frame", {Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            ZIndex = 100, Visible = false}, sg)
        corner(dot, 4)
        mk("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1}, dot)
        on(RS.RenderStepped, function()
            if not win.Visible then dot.Visible = false; return end
            local m, p, s = UIS:GetMouseLocation(), win.AbsolutePosition, win.AbsoluteSize
            dot.Visible = m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y
            dot.Position = UDim2.new(0, m.X - 4, 0, m.Y - 4)
        end)

        local W, seen, order, lastW = {}, {}, 0, nil
        -- props apply once, when the widget is made; text and colours that change are set by the caller every pass.
        local function widget(class, key, col, props)
            order = order + 1
            seen[key] = true
            local w, fresh = W[key], false
            if not w then
                fresh = true
                w = mk(class, {Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = C.row, BorderSizePixel = 0})
                if class ~= "Frame" then
                    w.TextColor3, w.Font, w.TextSize, w.TextXAlignment = C.fg, Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
                    w.TextWrapped, w.AutomaticSize = true, Enum.AutomaticSize.Y
                    mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4),
                        PaddingBottom = UDim.new(0, 4)}, w)
                end
                if class == "TextButton" then w.AutoButtonColor = false end
                corner(w, 4)
                for k, v in pairs(props or {}) do w[k] = v end
                w.Parent = col
                W[key] = w
            end
            w.LayoutOrder, w.Visible = order, not curCollapsed
            lastW = w
            return w, fresh
        end
        local pages = {}
        -- Owner: short labels. Text in (brackets) moves behind a small "i" button; tap it to read, tap again to close.
        local tip = mk("TextLabel", {Size = UDim2.new(0, 230, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.box,
            BorderSizePixel = 0, TextColor3 = C.fg, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 60, Visible = false}, sg)
        corner(tip, 4)
        mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)}, tip)
        local infoOf, tipFor = {}, nil
        on(RS.Heartbeat, function() if tipFor and not (win.Visible and tipFor.Visible) then tip.Visible, tipFor = false, nil end end)
        local function short(w, text)
            local info = {}
            text = tostring(text):gsub("%s*%b()", function(p) info[#info + 1] = p:sub(2, -2); return "" end)
            local ib = w:FindFirstChild("Info")
            if #info > 0 and not ib then
                ib = mk("TextButton", {Name = "Info", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, -24, 0, -1),
                    BackgroundColor3 = C.box, BorderSizePixel = 0, Text = "i", TextColor3 = C.fg, Font = Enum.Font.GothamBold,
                    TextSize = 12, AutoButtonColor = false}, w)
                corner(ib, 9)
                w.UIPadding.PaddingLeft = UDim.new(0, 30)
                on(ib.MouseButton1Click, function()
                    if tipFor == ib then tip.Visible, tipFor = false, nil; return end
                    local p = ib.AbsolutePosition
                    local x = p.X + 24
                    if x + 230 > workspace.CurrentCamera.ViewportSize.X then x = p.X - 236 end
                    tip.Text, tip.Position, tip.Visible, tipFor = infoOf[ib] or "", UDim2.new(0, x, 0, p.Y), true, ib
                end)
            end
            if ib then
                infoOf[ib] = table.concat(info, "; ")
                if tipFor == ib then tip.Text = infoOf[ib] end
            end
            return text
        end

        local function section(sname, side, names)
            local col = cols[side] or cols.Left
            local sec, n = {}, 0
            local function nextKey(kind) n = n + 1; return kind .. ":" .. sname .. ":" .. n end
            curCollapsed = false
            local hb, hfresh = widget("TextButton", "sec:" .. sname, col, {Font = Enum.Font.GothamBold, TextSize = 15,
                TextColor3 = C.accent, BackgroundTransparency = 1})
            if hfresh then
                on(hb.MouseButton1Click, function() collapsed[sname] = not collapsed[sname] or nil; saveLayout() end)
            end
            hb.Text = (collapsed[sname] and "+  " or "-  ") .. sname
            curCollapsed = collapsed[sname] == true
            if names then
                pages[sname] = math.clamp(pages[sname] or 0, 0, #names - 1)
                sec.page = pages[sname]
                local bar, fresh = widget("Frame", "pages:" .. sname, col, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
                if fresh then
                    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder}, bar)
                end
                for i, pn in ipairs(names) do
                    local b = bar:FindFirstChild(pn)
                    if not b then
                        b = mk("TextButton", {Name = pn, Size = UDim2.new(1 / #names, -3, 1, 0), BorderSizePixel = 0, LayoutOrder = i,
                            Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.fg, Text = pn, AutoButtonColor = false}, bar)
                        corner(b, 4)
                        on(b.MouseButton1Click, function() pages[sname] = i - 1 end)
                    end
                    b.BackgroundColor3 = sec.page == i - 1 and C.accent or C.row
                end
            end
            function sec:Text(s)
                widget("TextLabel", nextKey("text"), col, {BackgroundTransparency = 1, TextColor3 = C.dim, TextSize = 12}).Text = tostring(s)
            end
            function sec:Tip() end
            function sec:Spacing() widget("Frame", nextKey("space"), col, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6)}) end
            function sec:Toggle(id, label, def, cb)
                if vals[id] == nil then vals[id] = def and true or false end
                local b, fresh = widget("TextButton", id, col)
                if fresh then
                    b.UIPadding.PaddingRight = UDim.new(0, 30)
                    local box = mk("Frame", {Name = "Box", Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, 6, 0.5, -8),
                        BorderSizePixel = 0}, b)
                    corner(box, 3)
                    on(b.MouseButton1Click, function()
                        vals[id] = not vals[id]
                        if cb then pcall(cb, vals[id]) end
                    end)
                end
                b.Text = short(b, label)
                b.Box.BackgroundColor3 = vals[id] and C.accent or C.box
            end
            -- shortcut: no key capture; the key comes from the settings file. Add a capture button if users ask.
            function sec:Keybind(id, vk)
                if vals[id] == nil then vals[id] = vk end
                return {AddToHotkey = function() end, GetKey = function() return vals[id] end}
            end
            local function slider(id, label, mn, mx, def, fmt, isInt, cb)
                if vals[id] == nil then vals[id] = def or mn end
                local b, fresh = widget("TextButton", id, col)
                if fresh then
                    b.UIPadding.PaddingBottom = UDim.new(0, 14)
                    local track = mk("Frame", {Name = "Track", Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, 4),
                        BackgroundColor3 = C.box, BorderSizePixel = 0}, b)
                    corner(track, 3)
                    corner(mk("Frame", {Name = "Fill", BackgroundColor3 = C.accent, BorderSizePixel = 0}, track), 3)
                    local drag = false
                    local function set(x)
                        local v = mn + (mx - mn) * math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        if isInt then v = math.floor(v + 0.5) end
                        vals[id] = v
                        if cb then pcall(cb, v) end
                    end
                    on(b.MouseButton1Down, function(x) drag = true; set(x) end)
                    on(UIS.InputChanged, function(i)
                        if drag and isMove(i) then set(i.Position.X) end
                    end)
                    on(UIS.InputEnded, function(i)
                        if isPress(i) then drag = false end
                    end)
                end
                local v = tonumber(vals[id]) or mn
                b.Text = short(b, label) .. ":  " .. (isInt and tostring(v) or string.format(fmt or "%.2f", v))
                b.Track.Fill.Size = UDim2.new(math.clamp((v - mn) / (mx - mn), 0, 1), 0, 1, 0)
            end
            function sec:SliderInt(id, label, mn, mx, def, cb) slider(id, label, mn, mx, def, nil, true, cb) end
            function sec:SliderFloat(id, label, mn, mx, def, fmt, cb) slider(id, label, mn, mx, def, fmt, false, cb) end
            -- Combo: left click = next item, right click = previous (0-based value, like Matcha).
            function sec:Combo(id, label, items, def, cb)
                if vals[id] == nil then vals[id] = def or 0 end
                -- Owner 2026-11-25 (badge could not be chosen): the click uses the LATEST list. It kept the first one,
                -- so a list that loaded later (24 badges) still cycled through the 2 it started with.
                comboItems[id] = items
                local b, fresh = widget("TextButton", id, col)
                if fresh then
                    local function step(d)
                        vals[id] = ((tonumber(vals[id]) or 0) + d) % math.max(#(comboItems[id] or items), 1)
                        if cb then pcall(cb, vals[id]) end
                    end
                    on(b.MouseButton1Click, function() step(1) end)
                    on(b.MouseButton2Click, function() step(-1) end)
                end
                b.Text = short(b, label .. ":  < " .. tostring(items[(tonumber(vals[id]) or 0) + 1] or "?") .. " >")
            end
            function sec:InputText(id, label, def, cb)
                if vals[id] == nil then vals[id] = def or "" end
                local lb = widget("TextLabel", id .. ":label", col, {BackgroundTransparency = 1, TextColor3 = C.dim, TextSize = 12})
                lb.Text = short(lb, label)
                local box, fresh = widget("TextBox", id, col, {BackgroundColor3 = C.box, ClearTextOnFocus = false})
                if fresh then
                    on(box.FocusLost, function()
                        vals[id] = box.Text
                        if cb then pcall(cb, box.Text) end
                    end)
                end
                if not box:IsFocused() then box.Text = tostring(vals[id]) end
            end
            function sec:Button(label, cb)
                local b, fresh = widget("TextButton", "button:" .. label, col,
                    {BackgroundColor3 = C.btn, TextXAlignment = Enum.TextXAlignment.Center})
                b.Text = label
                if fresh and cb then on(b.MouseButton1Click, function() pcall(cb) end) end
            end
            -- Colour: click to step through 8 colours. Owner: it sits on the same row as the ESP toggle it belongs to
            -- (toggle box, then colour swatch); only without a toggle right above does it get its own row.
            function sec:ColorPicker(id, r, g, b0, _, cb)
                if vals[id] == nil then vals[id] = {r, g, b0} end
                local host = lastW and lastW:FindFirstChild("Box") and lastW
                lastW = nil
                local b, sw, fresh
                if host then
                    host.UIPadding.PaddingRight = UDim.new(0, 74)
                    sw = host:FindFirstChild("Swatch:" .. id)
                    fresh = not sw
                    if fresh then
                        sw = mk("TextButton", {Name = "Swatch:" .. id, Size = UDim2.new(0, 36, 0, 16), Position = UDim2.new(1, 30, 0.5, -8),
                            BorderSizePixel = 0, Text = "", AutoButtonColor = false}, host)
                        corner(sw, 3)
                    end
                    b = sw
                else
                    b, fresh = widget("TextButton", id, col, {TextColor3 = C.dim, TextSize = 12})
                    if fresh then
                        b.UIPadding.PaddingRight = UDim.new(0, 46)
                        corner(mk("Frame", {Name = "Swatch", Size = UDim2.new(0, 36, 0, 14), Position = UDim2.new(1, 8, 0.5, -7),
                            BorderSizePixel = 0}, b), 3)
                    end
                    b.Text = "      colour (click to change)"
                    sw = b.Swatch
                end
                if fresh then
                    on(b.MouseButton1Click, function()
                        local c, at = vals[id], 0
                        for i, p in ipairs(PALETTE) do
                            if math.abs(p[1] - c[1]) + math.abs(p[2] - c[2]) + math.abs(p[3] - c[3]) < 0.05 then at = i end
                        end
                        vals[id] = PALETTE[at % #PALETTE + 1]
                        if cb then pcall(cb, Color3.new(vals[id][1], vals[id][2], vals[id][3])) end
                    end)
                end
                local c = vals[id]
                sw.BackgroundColor3 = Color3.new(c[1], c[2], c[3])
            end
            return sec
        end

        local tabObj = {Section = function(_, sname, side, names) return section(sname, side, names) end}
        task.spawn(function()
            local logged = false
            while t.alive do
                order, seen, curCollapsed = 0, {}, false
                local ok, err = pcall(draw, tabObj)
                if ok then ok, err = pcall(moveMenu, tabObj) end
                if not ok and not logged then logged = true; log("Menu draw error: " .. tostring(err)) end
                for k, w in pairs(W) do if not seen[k] then w.Visible = false end end
                task.wait(0.25)
            end
        end)
    end
    _G.EXEC_SHIM_STOP = function()
        for name in pairs(tabs) do pcall(UI.RemoveTab, name) end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        restoreMove()
    end
    log("Not Matcha: using the built-in menu and stand-ins for Matcha's calls")
end) end
-- v-16d (owner: logging lags Matcha; only log what is new or being tested): DEBUG_LOG = true turns the routine lines
-- back on (crumb file, "Slow:", Status, Taken, Crate opened). Errors, settings, events and test lines always log.
local DEBUG_LOG = false
-- v-17a (owner): one script for Matcha Pro and Regular. Kill Aura sends the game's remotes (Pro only); on Regular it
-- shows "(Pro)" and switches itself back off.
-- shortcut: only the documented Pro global is checked, not tested on a Regular account yet; owner will test.
local IS_PRO = type(fireproximityprompt) == "function" and (type(ishybridenabled) ~= "function" or select(2, pcall(ishybridenabled)) ~= false)  -- Pro calls also need Hybrid mode on
local PRO_TAG = IS_PRO and "" or " (Pro)"
log("Matcha Pro: " .. tostring(IS_PRO) .. " (hybrid: " .. (type(ishybridenabled) == "function" and tostring(select(2, pcall(ishybridenabled))) or "no api") .. ")")
-- Freeze hunt (Matcha's whole Lua engine has hung in big waves): crumb(slot, stage) keeps what each thread is doing in
-- crumb_<GameId>.txt (overwritten, a few lines), so after a freeze that file names the stage that never finished.
-- A stage that took over 0.3 s before the next crumb in its slot is logged as "Slow:". The helper uses it too.
local CRUMB_FILE = (string.find(LOG_FILE, "/", 1, true) and APOC_DIR .. "/" or "") .. "crumb_" .. GAME_ID .. ".txt"
local crumbs, crumbOrder = {}, {}
-- The previous run's file names the stage it was in when it died (a freeze or a crash; "wait" = idle).
pcall(function()
    if DEBUG_LOG and isfile(CRUMB_FILE) then log("Previous run's last crumbs: " .. string.gsub(readfile(CRUMB_FILE), "\n", " | ")) end
end)
local function crumb(slot, stage)
    if not DEBUG_LOG then return end
    local now = os.clock()
    local c = crumbs[slot]
    if not c then c = {}; crumbs[slot] = c; crumbOrder[#crumbOrder+1] = slot end
    if c.stage and c.stage ~= "wait" and now - c.t > 0.3 then
        log("Slow: " .. slot .. " " .. c.stage .. " took " .. math.floor((now - c.t) * 1000) .. " ms")
    end
    c.stage, c.t = stage, now
    local ok, t = pcall(os.date, "%H:%M:%S")
    c.at = ok and t or ""
    local out = {}
    for _, s in ipairs(crumbOrder) do out[#out+1] = crumbs[s].at .. " " .. s .. ": " .. crumbs[s].stage end
    if not NO_LOGS then pcall(writefile, CRUMB_FILE, table.concat(out, "\n")) end
end

-- ===== Size helper ===========================================================
-- Matcha applies normal property writes to the game itself, so no memory offsets are needed.
-- Other-executor copy (EXEC_COPY, owner 2026-11-25): enlarged parts and their face decals turn see-through, and get
-- their own look back when the size is restored. Matcha has no Transparency, so its copies skip this.
local seeThru = setmetatable({}, {__mode = "k"})
local function setSize(part, sx, sy, sz, expand)
    local ok = pcall(function() part.Size = Vector3.new(sx, sy, sz) end)
    if EXEC_COPY and ok then pcall(function()
        if expand and not seeThru[part] then
            local saved = {t = part.Transparency, decals = {}}
            for _, d in ipairs(part:GetChildren()) do
                if d:IsA("Decal") then saved.decals[d] = d.Transparency; d.Transparency = 1 end
            end
            seeThru[part] = saved
            part.Transparency = 1
        elseif not expand and seeThru[part] then
            local saved = seeThru[part]
            seeThru[part] = nil
            part.Transparency = saved.t
            for d, t in pairs(saved.decals) do pcall(function() d.Transparency = t end) end
        end
    end) end
    return ok
end

-- ===== Config =================================================================
local cfg = {
    enabled     = true,
    hitboxSize  = 5.0,
    maxDistance = 500.0,
    partIndex   = 1,
    folderName  = IS_APOC and "Characters" or "",
    ignorePlayers = true,  -- off: other players' characters get the hitbox too
    hideCorpses   = true,  -- hide dead NPCs (see the Dead NPC hider)
    hotkey        = 0,     -- VK code for the Enable hotkey, 0 = unbound
    skipNames     = "Merchant",  -- comma list of NPC names that never get the hitbox (friendly NPCs)
    aimKey        = 0x05,  -- VK code (AIM_KEYS), default mouse side button X1
    aimMode       = 1,     -- 0 = hold the key, 1 = press to switch on / off
    fovOn         = true,  -- camera field of view; owner's sign the script runs. NEVER remove (owner, 2026-11-14)
    fov           = 120,
    killOn        = false, -- Auto Kill (owner's TODO): aim + shoot zombies in reach with the gun in hand
    auraRange     = 60,    -- Kill Aura reach in studs (green circle on the ground)
    auraSleep     = false, -- Kill Aura also shoots sleeping (Hibernating) zombies
    auraGuide     = true,  -- Kill Aura green range ring + red target ring / line (owner v-15r: can be switched off)
    auraBounce    = 40,    -- Kill Aura: max studs between two zombies for an Outlaw bounce
    auraMin       = 3,     -- Kill Aura only shoots when one bullet reaches at least this many zombies
    auraWait      = 3,     -- ...or when a zombie has been inside the circle this many seconds (0 = never)
    auraMode      = 2,     -- v-15k target type, index into AURA_MODES (2 = Group Priority, the old behaviour)
    auraCraft     = false, -- Kill Aura crafts ammo for the gun in hand when the reserve drops below auraCraftAt
    auraCraftAt   = 50,
    auraTurret    = true,  -- v-18k: Kill Aura also fires the turrets on your vehicle (no ammo used)
}

-- ===== Saved settings ========================================================
-- Kept in C:\matcha\workspace\hbx_settings.json (writefile creates it), so autoexec runs after a
-- teleport start with the last menu values. Only known keys with the expected type are taken.
local HttpService    = game:GetService("HttpService")
-- Survive the Apocalypse: keep the last 30 run logs (owner, v-14g). shortcut: our notes list no Matcha file listing,
-- so logs/index.txt remembers the names; without delfile the old files stay.
if not logDirOk then log("Log folder failed, using " .. LOG_FILE .. ": " .. tostring(logDirErr)) end
if string.find(LOG_FILE, "/", 1, true) then pcall(function()
    local idx = APOC_DIR .. "/logs/index.txt"
    local names = {}
    local okR, txt = pcall(readfile, idx)
    for line in string.gmatch(okR and type(txt) == "string" and txt or "", "[^\n]+") do names[#names+1] = line end
    names[#names+1] = LOG_FILE
    while #names > 30 do
        if type(delfile) == "function" then pcall(delfile, names[1]) end
        table.remove(names, 1)
    end
    writefile(idx, table.concat(names, "\n") .. "\n")
end) end
-- v-14g: settings moved into the SurviveTheApocalypse folder (owner); copy the old files there once.
pcall(function()
    pcall(makefolder, "SurviveTheApocalypse")
    for old, new in pairs({["aio_hitbox_settings.json"] = "SurviveTheApocalypse/hitbox_settings.json",
                           ["aio_pickup_settings.json"] = "SurviveTheApocalypse/pickup_settings.json"}) do
        if not isfile(new) and isfile(old) then writefile(new, readfile(old)) end
    end
end)
local SETTINGS_FILE  = IS_APOC and "SurviveTheApocalypse/hitbox_settings.json" or ("aio_hbx_" .. GAME_ID .. ".json")
local SAVED_KEYS     = {"enabled","hitboxSize","maxDistance","partIndex","ignorePlayers","hideCorpses","hotkey","skipNames",
    "aimKey","aimMode","fovOn","fov","killOn","auraRange","auraSleep","auraBounce","auraMin","auraWait","auraMode","auraGuide","auraCraft","auraCraftAt","auraTurret"}
local folderFromFile = false
do
    local ok, data = pcall(function()
        return isfile(SETTINGS_FILE) and HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if ok and type(data) == "table" then
        for _, k in ipairs(SAVED_KEYS) do
            if type(data[k]) == type(cfg[k]) then cfg[k] = data[k] end
        end
        -- Only a folder the user typed is saved; an auto-detected one is found again each game.
        if type(data.folder) == "string" and data.folder ~= "" then
            cfg.folderName = data.folder
            folderFromFile = true
        end
        say("Settings loaded from " .. SETTINGS_FILE)
    end
end

local PARTS = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
if not PARTS[cfg.partIndex] then cfg.partIndex = 1 end  -- a hand-edited settings file may hold anything

-- ===== Friendly NPCs =========================================================
-- Skipped by GetNPCModels: names typed in "Skip NPC Names" (case-insensitive), and allies, e.g. a Necromancer's
-- zombies in Survive the Apocalypse. shortcut: allies are guessed by an "Owner"/"Ally"/"Summoner" child or attribute
-- (that game marks player-owned structures with an "Owner" ObjectValue); confirm with a scan while an ally is out.
local skipSet = {}
local function setSkipNames(text)
    skipSet = {}
    for name in string.gmatch(text, "[^,]+") do
        name = string.lower(string.match(name, "^%s*(.-)%s*$"))
        if name ~= "" then skipSet[name] = true end
    end
end
setSkipNames(cfg.skipNames)

local ALLY_KEYS = {"Owner", "Ally", "Summoner", "Survivor"}  -- v-14k: Apocalypse Medic / Scavenger / Soldier have Survivor = true
local allyCache, allyCount, allyLogged, allyBudget = {}, 0, {}, 25  -- npc addr -> {ally=, t=}; "name/key" -> true once logged
local function isSet(v) return v ~= nil and v ~= false and v ~= "" and v ~= 0 end
local function isAlly(m)
    local a, now = m.Address, os.clock()
    local c = allyCache[a]
    if c and now - c.t < 5.0 then return c.ally end  -- re-checked every 5 s: a dead zombie may be raised as an ally
    -- v-20d (owner: heavy lag; log game39: loot stalled 1-2.6 s every ~6 s with 150-240 zombies): all re-checks fell
    -- due at once, up to 8 game reads per zombie in one go. Now at most 25 re-checks per rebuild; the rest keep their
    -- old answer until a later rebuild. New zombies are always checked.
    if c then
        if allyBudget <= 0 then return c.ally end
        allyBudget = allyBudget - 1
    end
    local found
    for _, k in ipairs(ALLY_KEYS) do
        local ok, v = pcall(function()
            local ch = m:FindFirstChild(k)
            -- ClassName, not IsA: Matcha's IsA matches wrong classes. A non-value child (e.g. a Folder) counts as set.
            if ch then
                if string.sub(ch.ClassName, -5) == "Value" then return ch.Value end  -- empty Owner = not an ally
                return true
            end
            return m:GetAttribute(k)
        end)
        if ok and isSet(v) then found = k; break end
    end
    if not c then
        allyCount = allyCount + 1
        if allyCount > 2000 then allyCache, allyCount = {}, 1 end  -- dead NPCs' entries pile up over a long game
    end
    allyCache[a] = {ally = found ~= nil, t = now}
    if found and not allyLogged[m.Name .. "/" .. found] then
        allyLogged[m.Name .. "/" .. found] = true
        log("Skipping ally NPC: " .. m.Name .. " (has " .. found .. ")")
    end
    return found ~= nil
end

-- ===== Auto-detect NPC folder ================================================
-- Picks the workspace folder/model holding the most NPCs. Re-run every few seconds from the main
-- loop (unless the user typed a folder), because at execute time the NPCs may not exist yet, e.g.
-- right after teleporting from a lobby, where it picked "Assets" (2 NPCs) instead of "Characters".
local function isPlayerChar(model)
    for _, plr in Players:GetPlayers() do
        if plr.Character == model or plr.Name == model.Name then return true end
    end
    return false
end
local function isNPC(model)
    if not model:IsA("Model") or not model:FindFirstChild("HumanoidRootPart") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    -- Living only: in Tower of Zombies "WeaponBlacklist" rose as "ActiveZombies" fell (dying zombies, it seems)
    -- and briefly outvoted the real folder in round 1.
    if hum then return hum.Health > 0 and not isPlayerChar(model) end
    -- No Humanoid: some games animate zombies with an AnimationController instead
    -- (Zombie Rush Survival: Workspace.Zombie_ClientVisuals.Zombie_6). Head required: Dead Rails keeps 30 weapon
    -- viewmodels (HumanoidRootPart + AnimationController, no Head) in Workspace.ViewmodelContainer.
    return model:FindFirstChildOfClass("AnimationController") ~= nil and model:FindFirstChild("Head") ~= nil
end
-- Groups living NPCs by the name of the folder/model holding them, anywhere in workspace, so same-name
-- folders spread over the map count as one target (Dead Rails: Workspace.Towns.town_1.ZombiePart.Zombies and
-- Workspace.RandomBuildings.OutlawCamp.StandaloneZombiePart.Zombies). NPCs sitting directly in workspace are
-- not grouped (that would target the whole map). Picks by the most NPCs ever seen under a name this run, not
-- the current count: with 1 zombie left in "ActiveZombies", decoy folders with 2 models won and the last
-- zombie lost its hitbox. Ties keep the current folder. Yields while walking a big map.
-- Returns best name, its peak, containers by name, and "name=now/peak ..." for the log.
local function pathOf(x)
    local names = {}
    while x and x ~= game and #names < 15 do
        table.insert(names, 1, x.Name)
        x = x.Parent
    end
    return table.concat(names, ".")
end

-- Every folder path that held living NPCs (path without "Workspace.", peak count), kept across runs in
-- C:\matcha\workspace\hbx_npc_<GameId>.json. make_npc_config.bat (D:\NPCHitBoxExpander) turns it into Matcha's
-- NPC ESP config (C:\matcha\npc_config\<GameId>.init), which a script cannot write itself.
local NPC_FILE, npcPaths = "hbx_npc_" .. GAME_ID .. ".json", {}
pcall(function()
    local data = isfile(NPC_FILE) and HttpService:JSONDecode(readfile(NPC_FILE))
    if type(data) == "table" and type(data.paths) == "table" then npcPaths = data.paths end
end)
local function recordNpcPaths(perC, byAddr)
    local changed = false
    for a, n in pairs(perC) do
        -- Skip folders inside a player's character (Bake or Die: <player>.HeldObjects holds carried corpses) or
        -- the camera (first-person arms), and folders where NPCs are under half the children: Matcha's ESP on
        -- Bake or Die's "Interactables" (7 corpses among ~150 items) lagged the game.
        local c, top = byAddr[a], byAddr[a]
        while top.Parent and top.Parent ~= workspace do top = top.Parent end
        if top.ClassName ~= "Camera" and not isPlayerChar(top) and n * 2 >= #c:GetChildren() then
            local p = (string.gsub(pathOf(byAddr[a]), "^Workspace%.", ""))
            if n > (tonumber(npcPaths[p]) or 0) then npcPaths[p] = n; changed = true end
        end
    end
    if changed then
        local ok, text = pcall(function()
            return HttpService:JSONEncode({game = tostring(getgamename()), paths = npcPaths})
        end)
        if ok and type(text) == "string" then pcall(writefile, NPC_FILE, text) end
    end
end

local folderPeak = {}
local HOSTILE_WORDS = {"zombie", "enem", "hostile", "monster", "mob"}
local function isHostileName(name)
    local n = string.lower(name)
    for _, w in ipairs(HOSTILE_WORDS) do
        if string.find(n, w, 1, true) then return true end
    end
    return false
end
local function detectNPCFolder()
    local counts, containers, seenC, perC = {}, {}, {}, {}
    local all = workspace:GetDescendants()
    for i, d in ipairs(all) do
        if i % 2000 == 0 then task.wait() end
        if d.Name == "HumanoidRootPart" then
            local m = d.Parent
            local c = m and m.Parent
            if c and c ~= workspace and isNPC(m) then
                local name = c.Name
                counts[name] = (counts[name] or 0) + 1
                local a = c.Address
                perC[a] = (perC[a] or 0) + 1
                if not seenC[a] then
                    seenC[a] = c
                    containers[name] = containers[name] or {}
                    table.insert(containers[name], c)
                end
            end
        end
    end
    pcall(recordNpcPaths, perC, seenC)
    for name in pairs(folderPeak) do counts[name] = counts[name] or 0 end
    local bestName, bestPeak, seen, hostile, hostilePeak = "", 0, {}, {}, 0
    for name, n in pairs(counts) do
        local peak = math.max(folderPeak[name] or 0, n)
        folderPeak[name] = peak
        seen[#seen+1] = name .. "=" .. peak
        if peak > bestPeak or (peak == bestPeak and name == cfg.folderName) then
            bestPeak = peak; bestName = name
        end
        if peak > 0 and isHostileName(name) then
            hostile[#hostile+1] = name
            hostilePeak = math.max(hostilePeak, peak)
        end
    end
    table.sort(seen)  -- fixed order, so the log line only changes when counts do
    -- Enemy-sounding folders win over any count, and all of them are targeted together: Dead Rails starts with 4
    -- friendly soldiers in "ActiveSoldiers" and spreads enemies over "Zombies", "NightEnemies", "RuntimeEnemies".
    if #hostile > 0 then
        table.sort(hostile)
        bestName, bestPeak = table.concat(hostile, ", "), hostilePeak
    end
    return bestName, bestPeak, containers, table.concat(seen, " ")
end

if folderFromFile then
    say("Using saved NPC folder: " .. cfg.folderName .. " (clear the box to auto-detect)")
else
    say("Looking for the NPC folder (scan every 10 s)")
end

-- ===== World scan (for Claude) ===============================================
-- Writes C:\matcha\workspace\hbx_scan.txt: the workspace tree (same-name children grouped, 3 levels) and every
-- model anywhere that looks like a character (Humanoid, AnimationController or HumanoidRootPart inside), with
-- its full path and distance. Used to find NPCs in games where auto-detect picks nothing useful.
local SCAN_FILE, scanning = "hbx_scan.txt", false


local function scanWorld(reason)
    if scanning then return end
    scanning = true
    local ok, err = try(function()
        local out = {}
        local function add(s) out[#out+1] = s end
        local okT, t = pcall(os.date, "%H:%M:%S")
        add("Scan (" .. reason .. ") " .. (okT and t or "") .. "  " .. tostring(getgamename()) .. " place " .. tostring(game.PlaceId))

        local me
        pcall(function() me = LocalPlayer.Character.HumanoidRootPart.Position end)
        local function distTo(model)
            local p
            pcall(function()
                local r = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if r then p = r.Position end
            end)
            if not (p and me) then return "?" end
            local d = p - me
            return tostring(math.floor(math.sqrt(d.X*d.X + d.Y*d.Y + d.Z*d.Z)))
        end

        add("")
        add("== Workspace tree (Class Name xCount, 3 levels; first of each group expanded) ==")
        local lines = 0
        local function tree(inst, depth)
            local okK, kids = pcall(function() return inst:GetChildren() end)
            if not okK then return end
            local groups, order = {}, {}
            for _, c in ipairs(kids) do
                local key = c.ClassName .. " " .. c.Name
                local g = groups[key]
                if not g then g = {n = 0, first = c}; groups[key] = g; order[#order+1] = key end
                g.n = g.n + 1
            end
            for _, key in ipairs(order) do
                lines = lines + 1
                if lines > 4000 then return end
                local g = groups[key]
                add(string.rep("  ", depth) .. key .. (g.n > 1 and (" x" .. g.n) or ""))
                local cn = g.first.ClassName
                if depth < 3 and (cn == "Folder" or cn == "Model") then tree(g.first, depth + 1) end
            end
        end
        tree(workspace, 0)

        -- v-20b (owner): attributes of each crate, vehicle and survivor, for telling kinds and states apart.
        -- Matcha's GetAttributes gives a list of names, not name -> value (scan v-14l): each value is read by name.
        local function attrText(inst)
            local okA, a = pcall(function() return inst:GetAttributes() end)
            if not (okA and type(a) == "table") then return "" end
            local s, done = {}, {}
            for k, v in pairs(a) do
                local name = type(k) == "number" and v or k
                if type(name) == "string" and not done[name] then
                    done[name] = true
                    local okV, val = pcall(function() return inst:GetAttribute(name) end)
                    if okV and val ~= nil then s[#s+1] = "@" .. name .. "=" .. tostring(val) end
                end
            end
            table.sort(s)
            return table.concat(s, " ")
        end
        local map = workspace:FindFirstChild("Map")
        for _, src in ipairs({{"Crates", map and map:FindFirstChild("Crates")},
                              {"Vehicles (Structures)", workspace:FindFirstChild("Structures")},
                              {"Survivors", map and map:FindFirstChild("Survivors")}}) do
            add("")
            add("== " .. src[1] .. ": name | distance | attributes ==")
            local okK, kids = pcall(function() return src[2]:GetChildren() end)
            for _, c in ipairs(okK and kids or {}) do
                add(tostring(c.Name) .. " | " .. distTo(c) .. " | " .. attrText(c))
            end
        end

        add("")
        add("== Character-like models anywhere in workspace ==")
        add("path | Humanoid health | HRP | AnimationController | Head | player | distance")
        local okD, all = pcall(function() return workspace:GetDescendants() end)
        local seen, found = {}, 0
        if okD then
            for i, d in ipairs(all) do
                if i % 3000 == 0 then task.wait() end  -- yield so a big map does not freeze Matcha
                local cn = d.ClassName
                if cn == "Humanoid" or cn == "AnimationController" or d.Name == "HumanoidRootPart" then
                    local m = d.Parent
                    local a = m and m.Address
                    if a and not seen[a] and found < 400 then
                        seen[a] = true
                        found = found + 1
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        local hp = "-"
                        if hum then pcall(function() hp = tostring(math.floor(hum.Health)) end) end
                        add(pathOf(m) .. " [" .. m.ClassName .. "] | " .. hp
                            .. " | " .. tostring(m:FindFirstChild("HumanoidRootPart") ~= nil)
                            .. " | " .. tostring(m:FindFirstChildOfClass("AnimationController") ~= nil)
                            .. " | " .. tostring(m:FindFirstChild("Head") ~= nil)
                            .. " | " .. tostring(isPlayerChar(m))
                            .. " | " .. distTo(m))
                    end
                end
            end
            add("(" .. #all .. " descendants checked, " .. found .. " character-like models)")
        else
            add("GetDescendants failed: " .. tostring(all))
        end
        writefile(SCAN_FILE, table.concat(out, "\n"))
        say("World scan written to " .. SCAN_FILE .. " (" .. found .. " character-like models)")
    end)
    if not ok then alert("World scan failed: " .. tostring(err)) end
    scanning = false
end

-- ===== HBX state =============================================================
local HBX = {
    originalSizes  = {},
    originalProps  = {},
    expandedParts  = {},
    origSizeByName = {},   -- npc.Name -> original part size (used by FixDeadClones)
    cachedModels   = {},
    cacheTime      = 0,
    partTypeCache  = {},
    npcInfo        = {},   -- v-15y: npc addr -> {hum, root, part, pa, pt, t}: re-found once a second, not every pass
    npcFolders     = {},   -- v-15y: {folder, n} per folder the target list came from (new-zombie check)
    newCheckT      = 0,
    cleanupTime    = 0,
    updateTime     = 0,
    wasEnabled     = false,
    hiddenHeads    = {},   -- addr -> true, ONE-SHOT guard prevents repeat writes
    fixCloneTime   = 0,
    corpses        = {},   -- hitbox part addr -> dead/left NPC being shrunk and/or hidden (see UpdateCorpses)
    hadHumanoid    = {},   -- npc addr -> true once a Humanoid was seen (its removal means death)
    deaths         = 0,    -- dead NPCs handled this run (shown in the Status log line)
    kindsLogged    = {},   -- NPC names already logged as "NPC kind targeted"
    containers     = {},   -- every folder named cfg.folderName anywhere in workspace (set by the folder scan)
    modelHome      = {},   -- npc addr -> folder it was listed in (set by GetNPCModels)
    partOwner      = {},   -- expanded part addr -> {addr, model, home} of its NPC
}

-- ===== Still-there check =====================================================
-- Matcha writes straight into the game's memory. A write to a part of an NPC the game already deleted lands in
-- freed memory and crashed Roblox (EXCEPTION_ACCESS_VIOLATION, Survive the Apocalypse 2026-11-04, ~260 NPCs and
-- ~300 deaths). Reads are harmless, so before any write the NPC must still be listed in its folder.
-- `cache` = {} per pass: each folder's children are read once per pass.
local function stillThere(cache, home, addr)
    if not home or not addr then return false end
    local okH, hk = pcall(function() return home.Address end)
    if not okH or not hk then return false end
    local set = cache[hk]
    if not set then
        set = {}
        local ok, kids = pcall(function() return home:GetChildren() end)
        if ok and kids then
            for _, k in ipairs(kids) do set[k.Address] = true end
        end
        cache[hk] = set
    end
    return set[addr] == true
end
-- Same, but follows an NPC moved to another folder (e.g. Bake or Die moves corpses to "Interactables"): its Parent
-- is read (safe) and only trusted when that folder really lists it. Updates owner.home.
local function stillThereMoved(cache, owner)
    if stillThere(cache, owner.home, owner.addr) then return true end
    local ok, parent = pcall(function() return owner.model.Parent end)
    if ok and parent and stillThere(cache, parent, owner.addr) then
        owner.home = parent
        return true
    end
    return false
end
do  -- self-check with stand-in objects (logged; never stops the script)
    local okC = pcall(function()
        local home  = {Address = 1, GetChildren = function() return {{Address = 5}} end}
        local other = {Address = 2, GetChildren = function() return {{Address = 7}} end}
        assert(stillThere({}, home, 5) and not stillThere({}, home, 6) and not stillThere({}, nil, 5))
        local owner = {addr = 7, home = home, model = {Parent = other}}
        assert(stillThereMoved({}, owner) and owner.home == other)
    end)
    if not okC then alert("Still-there self-check failed") end
end

-- ===== Dead NPC hider ========================================================
-- A dead NPC's parts are hidden three ways, because a single move did not stick (the server keeps
-- sending the corpse's physics, so parts snapped back): Transparency = 1 and CanCollide = false
-- (plain properties the server does not keep resending), plus a move underground. Repeated every 0.5 s for
-- 1 s after death (3 s before v-04p); the move underground only on the first pass. Decals/Textures (faces) get
-- Transparency = 1 too. v-04p reason: Roblox crashed 2026-11-04 16:42:55 in a wave (180 targets, ~3 deaths/s) with
-- "hitbox corpses" at 300-600 ms a pass; Matcha's docs: a Position write is thousands of memory writes, and these went
-- to bodies the game was deleting.
-- The hitbox part is also set back to its original size every 0.5 s for 10 s (with or without hiding):
-- Bake or Die moves dead zombies from "Monsters" to "Interactables" as pick-up corpses, and they kept the big
-- head because death only forgot the part instead of shrinking it.
local PART_CLASSES = {Part=true, MeshPart=true, UnionOperation=true, WedgePart=true, CornerWedgePart=true, TrussPart=true}
local CORPSE_SECONDS, SHRINK_SECONDS, CORPSE_REPEAT = 1.0, 10.0, 0.5

local function sink(bp)
    return (pcall(function() local p = bp.Position; bp.Position = Vector3.new(p.X, -10000, p.Z) end))
end

-- The corpse's parts and decals, read once per corpse: re-reading GetDescendants + every ClassName on each of the
-- 6 passes made "hitbox corpses" take 2-4 s in Survive the Apocalypse waves (~50 deaths per 10 s, 2026-11-04).
local function hideList(npc)
    local parts, decals = {}, {}
    local ok, all = pcall(function() return npc:GetDescendants() end)
    local list = {npc}
    for _, d in ipairs(ok and all or {}) do list[#list+1] = d end
    for _, obj in ipairs(list) do
        local cn = obj.ClassName
        if PART_CLASSES[cn] then parts[#parts+1] = obj
        elseif cn == "Decal" or cn == "Texture" then decals[#decals+1] = obj end
    end
    return {parts = parts, decals = decals}
end

local function hideObjects(list, sinkToo)
    -- Matcha has no Transparency (Matcha dev, 2026-11-16): only CanCollide and the move underground do anything.
    for _, obj in ipairs(list.parts) do
        pcall(function() obj.CanCollide = false end)
        if sinkToo then sink(obj) end
    end
end

-- Once per dead NPC: shrink its hitbox part back to `orig` (if known) and, if "Hide Dead NPCs" is on, hide it.
-- Returns true when the NPC was new.
local function markDead(npc, part, orig, reason, home)
    local addr = part.Address
    if not addr then return false end
    if HBX.hiddenHeads[addr] then return false end
    HBX.hiddenHeads[addr] = true
    local now = os.clock()
    -- Survive the Apocalypse: only dead Bloaters are hidden (owner, 2026-11-15). The game's own Settings toggle
    -- "Low Quality Mode" hides the body of every killed zombie EXCEPT Bloaters (exploding zombies); this script exists
    -- to fill that gap. The forced keeper in UpdateCorpses (`keep`) could be switched on for other zombie types too
    -- (change the "Bloater" check below), but each extra type adds a costly move per death: only on the owner's word.
    -- v-16c (owner, game42: 0 Bloaters stayed hidden): nothing is hidden in Survive the Apocalypse. Matcha can only move
    -- or shrink parts and the game's explode code puts them back (v-15w..v-16b all failed). Hitbox shrink still runs.
    local hide = cfg.hideCorpses and GAME_ID ~= "9098570654"
    HBX.corpses[addr] = {npc=npc, part=part, orig=orig, hide=hide,
        hideEndT=now+CORPSE_SECONDS, endT=now+SHRINK_SECONDS, nextT=0,
        owner={addr=npc.Address, model=npc, home=home or HBX.modelHome[npc.Address]}}
    HBX.deaths = HBX.deaths + 1
    return true
end

-- At most CORPSE_BUDGET seconds per call: corpses not reached keep their nextT and are done next tick, so one wave of
-- deaths can no longer stall the loop for seconds.
local CORPSE_BUDGET = 0.15
local bloaterLogged = false  -- log the first hide only
function HBX:UpdateCorpses()
    local now = os.clock()
    local cache = {}
    for addr, c in pairs(self.corpses) do
        if os.clock() - now > CORPSE_BUDGET then break end
        if now >= c.nextT and not (c.owner and stillThereMoved(cache, c.owner)) then
            self.corpses[addr] = nil  -- deleted by the game: never write to it again
        elseif now >= c.nextT then
            c.nextT = now + CORPSE_REPEAT
            if c.orig then setSize(c.part, c.orig.X, c.orig.Y, c.orig.Z) end
            -- v-16b (owner: the 11-04 hider hid Bloaters ~75% of the time; v-15x..16a re-moved the body every time it
            -- came back and it flickered, log game41: 5 "came back" in 3 s): back to the old way. CanCollide off at
            -- death and 0.5 s later, moved underground once, then never touched again.
            if c.hide and now < c.hideEndT and c.npc then
                c.list = c.list or hideList(c.npc)
                if not c.sunk and not bloaterLogged then
                    bloaterLogged = true
                    log("Dead NPC hidden (old way): " .. #c.list.parts .. " parts moved away once")
                end
                hideObjects(c.list, not c.sunk)
                c.sunk = true
            end
            if now >= c.endT then
                self.corpses[addr] = nil
                -- Only failures are logged. No Name read here: a destroyed corpse returned garbage names.
                if c.npc and c.orig then pcall(function()
                    local sz = c.part.Size
                    if math.abs(sz.X - c.orig.X) > 0.01 then
                        log("Shrink did not stick: size " .. tostring(sz) .. ", original " .. tostring(c.orig))
                    end
                end) end
            end
        end
    end
end

-- v-15w (owner: a dead Bloater vanished once, then came back; log game35: 164 "Slow: main bloater hider" lines at
-- 400-700 ms): the separate Bloater hider is gone. It re-read every Character and moved 20 parts per Bloater every
-- second (Position writes are costly). Dead Bloaters are now kept hidden by the corpse hider (UpdateCorpses, `keep`).

-- ===== HBX functions =========================================================
function HBX:GetNPCModels()
    local now = os.clock()
    if now - self.cacheTime < 2.0 and #self.cachedModels > 0 then
        -- v-15y (owner: new zombies got their hitbox far too late): every 0.25 s each NPC folder's child count is
        -- read (one call); when it changed, only unknown models are added now instead of waiting for the 2 s rebuild.
        if now - self.newCheckT >= 0.25 and self.addModel then
            self.newCheckT = now
            for _, f in ipairs(self.npcFolders) do
                local ok, kids = pcall(function() return f.folder:GetChildren() end)
                -- v-20b (owner: wave zombies got no hitbox): also when the last child changed, since in a wave
                -- zombies die and spawn together and the count can stay the same.
                local last = ok and kids and kids[#kids]
                local lastA = last and last.Address
                if ok and kids and (#kids ~= f.n or lastA ~= f.last) then
                    f.n, f.last = #kids, lastA
                    for _, m in ipairs(kids) do
                        if not self.modelHome[m.Address] and m.ClassName == "Model" then self.addModel(m, f.folder) end
                    end
                end
            end
        end
        return self.cachedModels
    end
    self.cachedModels = {}
    self.modelHome = {}
    self.npcFolders = {}
    allyBudget = 25
    local function folderSeen(f, kids) self.npcFolders[#self.npcFolders+1] = {folder = f, n = #kids} end
    -- Matcha has no PlayerAdded event, so the player list is re-read on every rebuild.
    local playerNames, playerChars, added = {}, {}, {}
    local okPl, plrs = pcall(function() return Players:GetPlayers() end)
    if not okPl then return self.cachedModels end  -- v-20f: fails while leaving the game (log game42, line 680 error)
    for _, plr in ipairs(plrs) do
        playerNames[plr.Name] = true
        if plr ~= LocalPlayer then playerChars[#playerChars+1] = plr.Character end
    end

    local function addModel(m, home)
        if m.Name == LocalPlayer.Name then return end
        if cfg.ignorePlayers and playerNames[m.Name] then return end
        if skipSet[string.lower(m.Name)] or isAlly(m) then return end
        local a = m.Address
        if added[a] then return end  -- a player inside the NPC folder would otherwise be added twice
        added[a] = true
        self.modelHome[a] = home or m.Parent
        table.insert(self.cachedModels, m)
        -- One line per NPC name, so a new kind (e.g. event zombies) shows in the log with the time it appeared.
        if not self.kindsLogged[m.Name] then self.kindsLogged[m.Name] = true; log("NPC kind targeted: " .. m.Name) end
    end
    self.addModel = addModel  -- v-15y: used by the new-zombie check until the next rebuild

    if not cfg.ignorePlayers then
        for _, c in ipairs(playerChars) do addModel(c) end
    end
    if cfg.folderName == "" then self.cacheTime=now; return self.cachedModels end
    local fn = cfg.folderName

    for _,child in ipairs(workspace:GetChildren()) do
        if child.Name == fn then
            if child:IsA("Folder") or child:IsA("Model") then
                local added = 0
                local kids = child:GetChildren()
                folderSeen(child, kids)
                for _,m in ipairs(kids) do
                    if m:IsA("Model") then addModel(m); added = added + 1 end
                end
                if added == 0 and child:IsA("Model") then addModel(child) end
            elseif child.ClassName=="Part" or child.ClassName=="MeshPart" then
                self.modelHome[child.Address] = workspace
                table.insert(self.cachedModels, child)
            end
        elseif child:IsA("Folder") then
            for _,item in ipairs(child:GetChildren()) do
                if item.Name == fn then
                    if item:IsA("Folder") or item:IsA("Model") then
                        local kids = item:GetChildren()
                        folderSeen(item, kids)
                        for _,m in ipairs(kids) do
                            if m:IsA("Model") then addModel(m) end
                        end
                    end
                end
            end
        end
    end
    -- Deeper folders with this name, found by the background folder scan.
    for _, c in ipairs(self.containers) do
        local ok, kids = pcall(function() return c:GetChildren() end)  -- the folder may be gone by now
        if ok then
            folderSeen(c, kids)
            for _, m in ipairs(kids) do
                if m:IsA("Model") then addModel(m) end
            end
        end
    end
    self.cacheTime = now
    return self.cachedModels
end

function HBX:FindPart(model, partType)
    local key = model.Address.."_"..partType
    local now = os.clock()
    if self.partTypeCache[key] then
        local c = self.partTypeCache[key]
        if now - c.t < 1.0 then
            local ok, p = pcall(function() return c.part.Parent end)
            if ok and p then return c.part end
        end
    end
    local function tryDirect(names)
        for _,n in ipairs(names) do
            local p = model:FindFirstChild(n)
            if p and p:IsA("BasePart") then return p end
        end
    end
    local function searchAttach(anames)
        for _,obj in ipairs(model:GetDescendants()) do
            local cn = obj.ClassName
            if cn=="Part" or cn=="MeshPart" then
                for _,ch in ipairs(obj:GetChildren()) do
                    if ch.ClassName=="Attachment" then
                        local ln = string.lower(ch.Name)
                        for _,an in ipairs(anames) do
                            if string.find(ln,string.lower(an)) then return obj end
                        end
                    end
                end
            end
        end
    end
    local found
    if     partType=="Head"      then found=tryDirect({"Head","head","HeadHB"}) or searchAttach({"FaceFront","FaceCenterAttachment","HatAttachment"})
    elseif partType=="Torso"     then found=tryDirect({"HumanoidRootPart","Torso","UpperTorso","LowerTorso"}) or searchAttach({"RootRigAttachment","BodyFrontAttachment"})
    elseif partType=="Left Arm"  then found=tryDirect({"LeftHand","LeftUpperArm","LeftLowerArm","LeftArm"}) or searchAttach({"LeftShoulderRigAttachment","LeftElbowRigAttachment"})
    elseif partType=="Right Arm" then found=tryDirect({"RightHand","RightUpperArm","RightLowerArm","RightArm"}) or searchAttach({"RightShoulderRigAttachment","RightElbowRigAttachment"})
    elseif partType=="Left Leg"  then found=tryDirect({"LeftFoot","LeftUpperLeg","LeftLowerLeg","LeftLeg"}) or searchAttach({"LeftHipRigAttachment","LeftKneeRigAttachment"})
    elseif partType=="Right Leg" then found=tryDirect({"RightFoot","RightUpperLeg","RightLowerLeg","RightLeg"}) or searchAttach({"RightHipRigAttachment","RightKneeRigAttachment"})
    end
    -- Universal fallback for NPCs without standard part names or rig attachments.
    found = found or tryDirect({"HumanoidRootPart"}) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if found then self.partTypeCache[key]={part=found, t=now} end
    return found
end

function HBX:IsPartValid(part)
    if not part then return false end
    local ok, p = pcall(function() return part.Parent end)
    return ok and p ~= nil
end

-- Returns true when the size was written (the NPC was still there).
function HBX:RestorePart(addr, part, cache)
    local orig, owner = self.originalSizes[addr], self.partOwner[addr]
    local written = false
    if orig and part and owner and stillThereMoved(cache, owner) then
        setSize(part, orig.X, orig.Y, orig.Z)
        written = true
    end
    self.expandedParts[addr] = nil
    self.originalSizes[addr] = nil
    self.originalProps[addr] = nil
    self.partOwner[addr] = nil
    return written, owner
end

function HBX:RestoreAll()
    local cache = {}
    for addr,part in pairs(self.expandedParts) do
        self:RestorePart(addr, part, cache)
    end
    self.expandedParts={}; self.partTypeCache={}; self.originalProps={}; self.partOwner={}; self.npcInfo={}
end

function HBX:Cleanup()
    local now = os.clock()
    if now - self.cleanupTime < 3.0 then return end
    self.cleanupTime = now

    local dead = {}
    for addr,part in pairs(self.expandedParts) do
        if not self:IsPartValid(part) then dead[#dead+1]=addr end
    end
    for _,a in ipairs(dead) do
        self.expandedParts[a]=nil; self.originalSizes[a]=nil; self.originalProps[a]=nil; self.partOwner[a]=nil
    end

    local stale = {}
    for k,d in pairs(self.partTypeCache) do
        if now - d.t > 30.0 then stale[#stale+1]=k end
    end
    for _,k in ipairs(stale) do self.partTypeCache[k]=nil end
    for a in pairs(self.npcInfo) do if not self.modelHome[a] then self.npcInfo[a] = nil end end

    -- Partial eviction of hiddenHeads: evict 50 at a time when over 200.
    -- A full wipe would cause all dead NPCs to be reprocessed in one frame -> crash.
    local hcount = 0
    for _ in pairs(self.hiddenHeads) do hcount = hcount + 1 end
    if hcount > 200 then
        local removed = 0
        for k in pairs(self.hiddenHeads) do
            self.hiddenHeads[k] = nil
            removed = removed + 1
            if removed >= 50 then break end
        end
    end
end

function HBX:ExpandHitboxes()
    local now = os.clock()
    if now - self.updateTime < 0.2 then return end
    self.updateTime = now
    local partType    = PARTS[cfg.partIndex]
    local expSz       = cfg.hitboxSize
    local maxDist     = cfg.maxDistance
    local models      = self:GetNPCModels()
    _G.HBX_NPC_COUNT = #models  -- read by the helper's "Loot loop stalled" test log
    if #models == 0 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lp = hrp.Position
    local cur = {}
    local cache = {}  -- still-there check; re-read every 40 NPCs, a pass over ~260 NPCs took up to 1.7 s

    local deadProcessed = 0

    -- v-20b (owner: new spawns and waves got their hitbox far too late, so zombies could not be cleared): NPCs not
    -- seen yet go first, so a fresh wave is expanded at the start of the pass instead of after every old zombie.
    local order, seenBefore = {}, {}
    for _, m in ipairs(models) do
        if self.npcInfo[m.Address] then seenBefore[#seenBefore+1] = m else order[#order+1] = m end
    end
    for _, m in ipairs(seenBefore) do order[#order+1] = m end
    local sliceT = os.clock()
    for _,npc in ipairs(order) do
        -- v-20a (owner: Auto Loot lags for seconds once the Military Base raid wave spawns): hand the turn to the loot
        -- loop. v-20b: only after 30 ms of work, not every 20 NPCs (13 pauses a pass with ~260 zombies made the hitbox
        -- reach new spawns seconds late). The still-there cache is re-read after the pause.
        if os.clock() - sliceT > 0.03 then task.wait(); cache = {}; sliceT = os.clock() end
        local function processNPC()
            local nkey = npc.Address
            local home = self.modelHome[nkey]
            if not stillThere(cache, home, nkey) then return end  -- deleted since the list was read
            -- v-15y (owner: expand pass 300-1600 ms with ~65 zombies, game37): Humanoid, root part and hitbox part are
            -- looked up once a second per NPC (each Matcha call is slow); a pass now reads Health, Position, Parent
            -- and writes Size. A removed Humanoid is noticed within 1 s.
            local info = self.npcInfo[nkey]
            if not info or now >= info.t or info.pt ~= partType then
                info = {t = now + 1.0, pt = partType}
                info.hum = npc:FindFirstChildOfClass("Humanoid")
                if npc.ClassName == "Part" or npc.ClassName == "MeshPart" then info.root = npc
                else info.root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc.PrimaryPart end
                info.part = self:FindPart(npc, partType)
                info.pa = info.part and info.part.Address
                -- v-18j (owner): friendly zombies (Necromancer summons, attribute Player = true) are not expanded.
                local okF, friend = pcall(function() return npc:GetAttribute("Player") end)
                info.friend = okF and friend == true
                -- A zombie that just spawned may not have its parts yet: look again next pass, not in 1 s.
                if not (info.part and info.root) then info.t = now end
                self.npcInfo[nkey] = info
            end
            local hum = info.hum
            -- Some games delete the Humanoid on death, so a missing one also means dead (if it had one).
            if hum then self.hadHumanoid[nkey] = true end
            -- A Humanoid-less copy of a known NPC (same name) is a corpse too: games may swap the dead NPC for
            -- a copy before we ever see Health reach 0, which seems to happen with other players' kills.
            local hp = hum and select(2, pcall(function() return hum.Health end))  -- kept Humanoid may be gone
            local reason = (hum and type(hp) == "number" and hp <= 0 and "health 0")
                or (not hum and self.hadHumanoid[nkey] and "humanoid removed")
                or (not hum and npc.ClassName == "Model" and self.origSizeByName[npc.Name] and "copy without humanoid")
            if reason then
                if deadProcessed >= 8 then return end
                local p = info.part
                if p then
                    local a = info.pa
                    -- Shrink regardless of distance; only expanded parts or known NPC names have an original size.
                    local orig = self.originalSizes[a] or self.origSizeByName[npc.Name]
                    if markDead(npc, p, orig, reason, home) then deadProcessed = deadProcessed + 1 end
                    self.expandedParts[a] = nil
                    self.originalSizes[a] = nil
                    self.originalProps[a] = nil
                    self.partOwner[a] = nil
                end
                return
            end

            -- No cap on live NPCs: a cap of 15 left the rest unexpanded, and the restore pass below
            -- shrank them back because they were missing from `cur`.
            local npos
            if info.root then
                local okP, pos = pcall(function() return info.root.Position end)
                if okP then npos = pos end
            end
            if npos and not info.friend then  -- left out of `cur`, so the restore pass shrinks a friend back
                local d = npos - lp
                if d.X*d.X+d.Y*d.Y+d.Z*d.Z <= maxDist*maxDist then
                    local p = info.part
                    -- Skip parts already reset on death: some games remove the dead NPC's Humanoid, so the corpse
                    -- looks alive here and was re-expanded (and re-measured as bigger) every tick.
                    -- Parent read kept every pass: a write to a removed part could crash (still-there rule).
                    if p and not self.hiddenHeads[info.pa] and self:IsPartValid(p) then
                        local a = info.pa
                        cur[a] = p
                        self.corpses[a] = nil  -- back in range: stop the shrink from the restore pass below
                        if not self.originalSizes[a] then
                            self.originalSizes[a]         = p.Size
                            self.originalProps[a]         = {canCol=p.CanCollide}
                            -- Humanoid NPCs only: the "no Humanoid = corpse copy" rules key on this table, and
                            -- AnimationController NPCs never have a Humanoid, so they would be hidden while alive.
                            if hum then self.origSizeByName[npc.Name] = p.Size end
                        end
                        local orig = self.originalSizes[a]
                        -- Rewrite every tick on purpose: skipping writes when Size already read as expanded
                        -- stopped hits from registering (the engine seems to reset the real hitbox).
                        if orig then
                            local ok = setSize(p,
                                orig.X + expSz,
                                orig.Y + expSz,
                                orig.Z + expSz, true)
                            if ok then
                                self.expandedParts[a] = p
                                self.partOwner[a] = self.partOwner[a] or {addr=nkey, model=npc, home=home}
                            end
                        end
                    end
                end
            end
        end
        processNPC()
    end

    cache = {}
    local rc = 0
    for a,p in pairs(self.expandedParts) do
        if rc >= 10 then break end
        if not cur[a] then
            -- Left the target list (out of range, or moved to another folder, e.g. as a corpse): one size write
            -- may not stick, so keep shrinking for a while like a corpse.
            -- A deleted NPC is only forgotten (no write, no corpse entry).
            local orig = self.originalSizes[a]
            local written, owner = self:RestorePart(a, p, cache); rc=rc+1
            if orig and written then
                self.corpses[a] = {part=p, orig=orig, endT=now+SHRINK_SECONDS, nextT=now+CORPSE_REPEAT, owner=owner}
            end
        end
    end
end

-- Secondary scan: catches dead NPCs that ExpandHitboxes missed.
-- This handles cases where an NPC dies between cache refreshes, or where
-- the game replaces a dead body with a fresh clone instance.
-- Throttled to 0.5s, capped at 10 per scan to stay lightweight.
function HBX:FixDeadClones()
    local now = os.clock()
    if now - self.fixCloneTime < 1.0 then return end
    self.fixCloneTime = now

    if not next(self.origSizeByName) then return end
    local partType = PARTS[cfg.partIndex]

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lp      = hrp.Position
    local maxDist = cfg.maxDistance
    local processed = 0

    local function scanContainer(container)
        if processed >= 10 then return end
        for _, child in ipairs(container:GetChildren()) do
            if processed >= 10 then return end
            if self.origSizeByName[child.Name] and child:IsA("Model") then
                local hum = nil
                pcall(function() hum = child:FindFirstChildOfClass("Humanoid") end)
                -- No Humanoid on a known NPC name means a corpse copy (see ExpandHitboxes).
                local isDead = not hum
                if hum then pcall(function() isDead = hum.Health <= 0 end) end

                if isDead then
                    local p = self:FindPart(child, partType)
                    if p and not self.hiddenHeads[p.Address] then
                        local npos = nil
                        pcall(function()
                            local h2 = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head") or child.PrimaryPart
                            if h2 then npos = h2.Position end
                        end)
                        if npos then
                            local d = npos - lp
                            if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= maxDist*maxDist then
                                markDead(child, p, self.origSizeByName[child.Name], "dead clone scan", container)
                                processed = processed + 1
                            end
                        end
                    end
                end
            end
        end
    end

    -- Only the root and the NPC folder: scanning every map model every 0.5s was costly.
    scanContainer(workspace)
    local folder = cfg.folderName ~= "" and workspace:FindFirstChild(cfg.folderName)
    if folder then scanContainer(folder) end
    for _, c in ipairs(self.containers) do pcall(scanContainer, c) end
end

-- ===== Kill Aura key ========================================================
-- v-15b (owner): Line-up Aim and the cursor Auto Kill are removed; only Kill Aura, the hitbox and the FOV stay. The
-- key list (once Line-up Aim's) now switches Kill Aura. Key list instead of Matcha's Keybind widget: the owner could
-- not rebind that one. Not the right mouse button (Roblox turns the camera while it is held); Q is the game's scope.
local AIM_KEYS = {
    {"Mouse side button 1 (back)", 0x05}, {"Middle mouse (wheel click)", 0x04}, {"Mouse side button 2 (forward)", 0x06},
    {"C", 0x43}, {"X", 0x58},
    {"V", 0x56}, {"Left Alt", 0xA4}, {"Left mouse (while shooting)", 0x01},
}
local AIM_KEY_NAMES = {}
for i, k in ipairs(AIM_KEYS) do AIM_KEY_NAMES[i] = k[1] end
local function aimKeyIndex(vk)
    for i, k in ipairs(AIM_KEYS) do if k[2] == vk then return i end end
    return 1
end
local AIM_MODES = {"Hold the key", "Toggle (press on / press off)"}
-- v-15k (owner): Kill Aura target type. Group Priority = the old rule (N zombies per bullet or the wait); the others
-- shoot any single zombie: the highest Health in range, the nearest, or the highest Health among the 5 nearest.
local AURA_MODES = {"Strongest First (highest HP)", "Closest", "Group Priority (N per bullet)", "Hybrid (close + high HP)"}
-- ===== Kill Aura =============================================================
-- Owner's TODO "Auto kill from the middle of the base", tried as camera/cursor aim (v-14l..o), now only Kill Aura
-- (below). The menu toggle arms it; the key (owner: middle mouse) switches it on / off.
local kill = {nextGun = 0, gun = nil, status = "Kill Aura: off", active = false, wasDown = false}
local function gunInHand()  -- the Gun Tool in hand, or nil
    local c = LocalPlayer.Character
    for _, t in ipairs(c and c:GetChildren() or {}) do
        if t.ClassName == "Tool" then
            local ok, tt = pcall(function() return t:GetAttribute("ToolType") end)
            if ok and tt == "Gun" then return t end
        end
    end
    return nil
end
-- Kill Aura (owner 2026-11-14: PvE game, the shots use ammo, owner accepts the ban risk). Sends the message the
-- game's GunClient (dump 014) sends for a hitscan shot: Shoot:FireServer(barrel position, {{Target, HitData =
-- {{HitChar, HitPos, HitPart, Ricochet}}, EffectResults = {{Origin, End}}}}, 0, shot counter), at the gun's own fire
-- rate (60 / (Stats.FireRate * (1 + character FireRate))), at the nearest expanded zombie within min(aimDist,
-- Stats.BulletRange). One zombie per shot. Projectile guns (Stats.Projectile) are skipped. The client-side Ammo
-- attribute is only refreshed by SyncAmmo (every 1 s); at 0 it stops and waits for your reload (R).
-- shortcut: Ricochet = false and no wall check, guessed from a truncated Remote Spy line; upgrade if hits do no damage.
local aura = {tool = nil, stats = nil, counter = 0, nextShot = 0, nextSync = 0, sent = 0, logged = false,
    reloading = false, nextReload = 0, hit = 0, miss = 0, nextSum = 0, pending = {}, inside = {},
    missBy = {}, skipUntil = {}}
-- v-19a (owner: ammo drained on zombies inside a wall / building / behind a heavy wall while AFK): after
-- AURA_MISS_LIMIT misses in a row on the same first target, that zombie is skipped for AURA_SKIP_TIME seconds.
-- A hit clears its count; one more miss after the skip ends skips it again at once.
-- v-22e (owner: a 60 s skip got them killed): one miss now only moves to another target for 3 s; zombies within
-- AURA_CLOSE studs are never skipped and are shot first, before any group / priority rule.
local AURA_MISS_LIMIT, AURA_SKIP_TIME, AURA_CLOSE = 1, 3, 15
-- v-14r (owner: many misfires, ammo ran out): own log next to the run's log, "aura_<run log name>". One line per shot
-- (target, distance, on screen?, Hibernating?, health, hits sent, ammo) and 0.7 s later whether the target's
-- Humanoid.Health dropped ("HIT" / "MISS"); a summary every 10 s.
local AURA_FILE = (string.gsub(LOG_FILE, "([^/]+)$", "aura_%1"))
local function killRelease() aura.focus = nil end
local function auraLog(msg)
    if NO_LOGS then return end
    local ok, t = pcall(os.date, "%H:%M:%S")
    pcall(appendfile, AURA_FILE, (ok and t or tostring(tick())) .. " " .. msg .. "\n")
end
local function hpOf(model)
    local ok, v = pcall(function() return model:FindFirstChildOfClass("Humanoid").Health end)
    return ok and tonumber(v) or nil
end
-- v-15q: aura logs showed 11 of 17 Bloater "misses" were shots at dead Bloaters (hp=nil: Humanoid gone, the body
-- still in Characters with its expanded head). Kill Aura only aims at / bounces to zombies with Health > 0.
local function auraAlive(m)
    local hpv = hpOf(m)
    if not hpv or hpv <= 0 then return false end
    -- v-23g (logs game70/72: living Muscle hp 1000, Runner hp 75, Bloater hp 250 carry Dead = true): the Dead tag is
    -- not trusted at all; dead Bloaters already read hp = nil (v-15q), so Health alone decides.
    return true
end
-- Shared by the gun and turret aura. v-14s: 52 of 66 shots in the v-14r log went to sleeping zombies (Hibernating,
-- mostly in buildings) and none was seen to hit: skipped unless "auraSleep". v-18i (owner: aura shot friendly
-- zombies): a Necromancer's summons carry the attribute Player = true.
local function auraTargetOk(m)
    local okF, friend = pcall(function() return m:GetAttribute("Player") end)
    if okF and friend == true then return false end
    local okS, sleep = pcall(function() return m:GetAttribute("Hibernating") end)
    if not cfg.auraSleep and okS and sleep == true then return false end
    return auraAlive(m)
end
local function auraStats(tool)
    if aura.tool ~= tool then
        -- v-15m: the shot counter is kept per gun (by Address): restarting at 0 after a gun switch looked like old shots.
        aura.counters = aura.counters or {}
        if aura.tool and aura.tool.Address then aura.counters[aura.tool.Address] = aura.counter end
        aura.tool, aura.counter, aura.stats = tool, aura.counters[tool.Address] or 0, nil
        local ok, st = pcall(function() return tool:FindFirstChild("Stats"):GetAttributes() end)
        if ok and type(st) == "table" then
            -- Matcha's GetAttributes may give a list of names (scan v-14l): read each value.
            local t = {}
            for k, v in pairs(st) do
                if type(k) == "number" then
                    local okV, val = pcall(function() return tool.Stats:GetAttribute(v) end)
                    t[v] = okV and val or nil
                else
                    t[k] = v
                end
            end
            aura.stats = t
        end
        log("Kill Aura: gun " .. tostring(tool.Name) .. " FireRate=" .. tostring(aura.stats and aura.stats.FireRate)
            .. " BulletRange=" .. tostring(aura.stats and aura.stats.BulletRange) .. " Projectile=" .. tostring(aura.stats and aura.stats.Projectile))
    end
    return aura.stats
end
-- v-14s: each shot's targets are checked 0.7 s later from here (task.delay never ran in v-14r): "#n hit k/m".
local function auraCheck(now)
    local keep = {}
    for _, e in ipairs(aura.pending) do
        if now < e.at then
            keep[#keep+1] = e
        else
            local k, dead, hps, firstLost = 0, 0, {}, false
            for i, t in ipairs(e.targets) do
                local okP, par = pcall(function() return t.model.Parent end)
                local hp1 = hpOf(t.model)
                local died = not okP or par == nil or (hp1 and hp1 <= 0)
                local lost = died or (t.hp and hp1 and hp1 < t.hp)
                if lost then k = k + 1 end
                if i == 1 then firstLost = lost and true or false end
                if died then dead = dead + 1 end
                hps[#hps+1] = tostring(t.name) .. " " .. tostring(t.hp and math.floor(t.hp)) .. ">" .. (died and "dead" or tostring(hp1 and math.floor(hp1)))
            end
            if k > 0 then aura.hit = aura.hit + 1 else aura.miss = aura.miss + 1 end
            if e.addr then
                if firstLost then
                    aura.missBy[e.addr] = nil
                else
                    local c = (aura.missBy[e.addr] or 0) + 1
                    aura.missBy[e.addr] = c
                    -- v-23i (owner + wiki: Electrified zombies "dodge attacks every couple of seconds"): a dodge is
                    -- not a wall, the next bullet lands, so they get one extra miss before the skip.
                    local nm1 = string.lower(tostring(e.targets[1] and e.targets[1].name))
                    local limit = string.find(nm1, "electrified", 1, true) and AURA_MISS_LIMIT + 1 or AURA_MISS_LIMIT
                    if c >= limit and (aura.skipUntil[e.addr] or 0) <= now then
                        aura.skipUntil[e.addr] = now + AURA_SKIP_TIME
                        if DEBUG_LOG then log(string.format("Kill Aura: %s missed %d times in a row (wall / building?), skipped for %d s",
                            tostring(e.targets[1] and e.targets[1].name), c, AURA_SKIP_TIME)) end
                    end
                end
            end
            -- v-14t: also how many died and each target's health before > after (owner: only 1 of 3 close ones died).
            -- v-16e (owner): per-shot HIT / MISS lines only with DEBUG_LOG; the summary line keeps the counts.
            if DEBUG_LOG then
                auraLog(string.format("  #%d %s %d/%d targets lost health, %d died [%s]", e.n, k > 0 and "HIT" or "MISS", k,
                    #e.targets, dead, table.concat(hps, " ")))
            end
        end
    end
    aura.pending = keep
end
local function auraStep(tool, now)
    auraCheck(now)
    local st = auraStats(tool)
    if not st or not tonumber(st.FireRate) then kill.status = "Kill Aura: cannot read the gun's Stats"; return end
    if st.Projectile then kill.status = "Kill Aura: projectile guns not supported (use another gun)"; return end
    local shoot, sync = tool:FindFirstChild("Shoot"), tool:FindFirstChild("SyncAmmo")
    if not shoot then kill.status = "Kill Aura: this gun has no Shoot remote"; return end
    if sync and now >= aura.nextSync then aura.nextSync = now + 1; pcall(function() sync:FireServer() end) end
    local okA, ammo = pcall(function() return tool:GetAttribute("Ammo") end)
    -- v-15v (owner, Remote Spy): workspace.Structures["Ammo Crate"].CraftAmmo:InvokeServer("Pistol"). While Kill Aura
    -- runs and the reserve (LocalPlayer.Ammo attribute of the gun's AmmoType) is under auraCraftAt, ask for one craft
    -- every 3 s in its own thread (InvokeServer waits). Untested whether the server wants you near the crate.
    if cfg.auraCraft and now >= (aura.nextCraft or 0) and st.AmmoType then
        local okL, left = pcall(function() return LocalPlayer.Ammo:GetAttribute(st.AmmoType) end)
        left = okL and tonumber(left)
        if left and left < cfg.auraCraftAt then
            aura.nextCraft = now + 3
            local structs = workspace:FindFirstChild("Structures")
            local crate = structs and structs:FindFirstChild("Ammo Crate")
            local rf = crate and crate:FindFirstChild("CraftAmmo")
            if rf then
                local kind = tostring(st.AmmoType)
                task.spawn(function()
                    local okC, res = pcall(function() return rf:InvokeServer(kind) end)
                    local okN, after = pcall(function() return LocalPlayer.Ammo:GetAttribute(kind) end)
                    auraLog("Craft " .. kind .. " ammo: reserve " .. tostring(left) .. " -> " .. tostring(okN and after)
                        .. (okC and (", answer " .. tostring(res)) or (", failed: " .. tostring(res))))
                end)
            elseif not aura.noCrateLogged then
                aura.noCrateLogged = true
                auraLog("Craft ammo: no Structures[\"Ammo Crate\"].CraftAmmo found (build an Ammo Crate)")
            end
        end
    end
    if okA and tonumber(ammo) and tonumber(ammo) <= 0 then
        -- v-14q (owner): auto reload, the game's own calls (spy): Reload:InvokeServer(), then SyncAmmo.
        local reload = tool:FindFirstChild("Reload")
        local okL, left = pcall(function() return LocalPlayer.Ammo:GetAttribute(st.AmmoType) end)
        if okL and tonumber(left) and tonumber(left) <= 0 then
            if kill.status ~= "Kill Aura: no " .. tostring(st.AmmoType) .. " ammo left" then
                auraLog("Out of " .. tostring(st.AmmoType) .. " ammo (magazine 0, reserve 0)")
            end
            kill.status = "Kill Aura: no " .. tostring(st.AmmoType) .. " ammo left"
            return
        end
        if reload and not aura.reloading and now >= aura.nextReload then
            if DEBUG_LOG then auraLog("Reload (reserve " .. tostring(okL and left) .. ")") end
            aura.reloading, aura.nextReload = true, now + 3
            task.spawn(function()
                local okR, err = pcall(function() reload:InvokeServer() end)
                if not okR then log("Kill Aura: reload failed: " .. tostring(err)) end
                if sync then pcall(function() sync:FireServer() end) end
                aura.reloading = false
            end)
        end
        kill.status = "Kill Aura: reloading"
        return
    end
    if now < aura.nextShot then return end
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local range = math.min(cfg.auraRange, tonumber(st.BulletRange) or cfg.auraRange)
    local hp, r2, near = h.Position, range * range, {}
    -- v-15s (owner: Kill Aura made Auto Pickup slow, Matcha CPU high): every expanded part is read ONCE per shot into
    -- `pool`; the 8 trial shots and their bounce chains used to re-read every part's Position, Parent, Hibernating
    -- and Health for each bounce (thousands of cross-process reads per shot). Awake/alive is checked once per zombie.
    local function key(m) local ok, a = pcall(function() return m.Address end); return ok and a or m end
    local pool, usableBy = {}, {}
    for _, p in pairs(HBX.expandedParts) do
        local okP, pp = pcall(function() return p.Position end)
        local okM, m = pcall(function() return p.Parent end)
        if okP and okM and m and typeof(pp) == "Vector3" then pool[#pool+1] = {part = p, pos = pp, model = m, key = key(m)} end
    end
    local function usable(e)
        local v = usableBy[e.key]
        if v == nil then
            v = auraTargetOk(e.model)
            usableBy[e.key] = v
        end
        return v
    end
    for _, e in ipairs(pool) do
        local d = e.pos - hp
        local d2 = d.X*d.X + d.Y*d.Y + d.Z*d.Z
        local skipped = d2 > AURA_CLOSE * AURA_CLOSE and (aura.skipUntil[e.key] or 0) > now
        if d2 <= r2 and not skipped and usable(e) then near[#near+1] = {part = e.part, pos = e.pos, model = e.model, d2 = d2} end
    end
    -- v-23h (log game73: zombies that spawned during a 1.6 s lag had no expanded hitbox yet, Screamer at 3 studs):
    -- every 0.5 s, NPCs NOT in the pool are checked (only those cost a position read); a live one within AURA_CLOSE
    -- goes in aura.raw and is shot at its real head until the hitbox script catches up.
    if now >= (aura.closeCheck or 0) then
        aura.closeCheck, aura.raw = now + 0.5, {}
        local inPool = {}
        for _, e in ipairs(pool) do inPool[e.key] = true end
        for _, f in ipairs(HBX.npcFolders) do
            local okK, kids = pcall(function() return f.folder:GetChildren() end)
            for _, m in ipairs(okK and kids or {}) do
                if not inPool[key(m)] then
                    local okR, rp = pcall(function()
                        local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m.PrimaryPart
                        return r and r.Position end)
                    local d = okR and typeof(rp) == "Vector3" and math.sqrt((rp.X-hp.X)^2 + (rp.Y-hp.Y)^2 + (rp.Z-hp.Z)^2)
                    if d and d <= AURA_CLOSE and m.Name ~= LocalPlayer.Name and not skipSet[string.lower(m.Name)]
                        and not isAlly(m) and auraTargetOk(m) then
                        local h = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                        if h then aura.raw[#aura.raw+1] = {part = h, model = m} end
                    end
                end
            end
        end
    end
    local nearKeys = {}
    for _, e in ipairs(near) do nearKeys[key(e.model)] = true end
    local function inNearRaw(m) return nearKeys[key(m)] end  -- hitbox caught up since the 0.5 s check
    for _, e in ipairs(aura.raw or {}) do  -- one position read each, only for close zombies the hitbox missed
        local okP, pp = pcall(function() return e.part.Position end)
        -- v-23j (games 74-75: misses 22-25% vs 15% before v-23h): alive re-checked every shot, or a zombie killed
        -- right after the 0.5 s check stayed the nearest target and ate bullets as a corpse.
        if okP and typeof(pp) == "Vector3" and not inNearRaw(e.model) and auraAlive(e.model) then
            local dv = pp - hp
            near[#near+1] = {part = e.part, pos = pp, model = e.model, d2 = dv.X*dv.X + dv.Y*dv.Y + dv.Z*dv.Z}
        end
    end
    if #near == 0 then kill.status = "Kill Aura: ON, no zombie within " .. math.floor(range) .. " studs"; return end
    table.sort(near, function(x, y) return x.d2 < y.d2 end)
    local origin = hp + Vector3.new(0, 1.5, 0)
    local barrel = tool:FindFirstChild("Barrel")
    if barrel then
        local okB, wp = pcall(function() return barrel.WorldPosition end)
        if okB and typeof(wp) == "Vector3" then origin = wp end
    end
    local okR, rateMul = pcall(function() return c:GetAttribute("FireRate") end)
    local mul = 1 + ((okR and tonumber(rateMul)) or 0)
    -- Extra hits per shot, shaped like the real gun's (owner, v-14u): penetration = zombies BEHIND the first one on the
    -- same line (Stats.Penetration in total), then Outlaw bounces = a chain, each bounce to the nearest awake zombie
    -- within BOUNCE_RANGE of the previous hit (owner: "like electricity", 2-5 studs apart), up to the character's
    -- RicochetMax, each with RicochetChance. v-14q..t used the next nearest zombies to you, and some did no damage.
    -- v-14w: the bounce distance is a slider (auraBounce, 40). v-14v log with 15 studs: every multi-hit shot killed all
    -- its targets (2/2, 3/3, 4/4), but 29 of 47 shots found no 2nd zombie that close; owner: the real gun bounces farther.
    local pen = math.max(1, math.floor(tonumber(st.Penetration) or 1))
    local okC, rMax = pcall(function() return c:GetAttribute("RicochetMax") end)
    local okH, rChance = pcall(function() return c:GetAttribute("RicochetChance") end)
    rMax = math.floor((okC and tonumber(rMax)) or 0)
    rChance = (okH and tonumber(rChance)) or 0
    local BOUNCE_RANGE = cfg.auraBounce
    -- v-23e (owner: own bullets hit heads poking out of walls, Kill Aura's did not): aim at the point of the expanded
    -- head box nearest the gun (0.3 studs inside its edge), like the game's own raycast hit, not the head's centre.
    -- shortcut: box treated as unrotated; fine while the expanded head is near-cubic.
    local function edge(e)
        local okS, sz = pcall(function() return e.part.Size end)
        if not (okS and typeof(sz) == "Vector3") then return e.pos end
        local function c(o, p, h) h = math.max(0, h / 2 - 0.3); return p + math.clamp(o - p, -h, h) end
        return Vector3.new(c(origin.X, e.pos.X, sz.X), c(origin.Y, e.pos.Y, sz.Y), c(origin.Z, e.pos.Z, sz.Z))
    end
    local function build(first)
    local part, pos, model = first.part, first.pos, first.model
    local hits = {{HitChar = model, HitPos = edge(first), HitPart = part, Ricochet = false}}
    -- v-14v: keyed by Address. Matcha gives a new object per read, so used[model] never matched and v-14u's chain
    -- bounced back onto the first zombie (log: 4 identical "100>dead" per shot).
    local used = {[key(model)] = true}
    local dv = pos - origin
    local dlen = math.sqrt(dv.X*dv.X + dv.Y*dv.Y + dv.Z*dv.Z)
    local lineEnd = hits[1].HitPos
    if dlen > 0.1 and pen > 1 then
        local ux, uy, uz = dv.X / dlen, dv.Y / dlen, dv.Z / dlen
        local width = cfg.hitboxSize / 2 + 1
        local onLine = {}
        for _, e in ipairs(near) do
            if not used[key(e.model)] then
                local v = e.pos - origin
                local t = v.X*ux + v.Y*uy + v.Z*uz
                local px, py, pz = v.X - ux*t, v.Y - uy*t, v.Z - uz*t
                if t > dlen and px*px + py*py + pz*pz <= width * width then onLine[#onLine+1] = {e = e, t = t} end
            end
        end
        table.sort(onLine, function(x, y) return x.t < y.t end)
        for _, o in ipairs(onLine) do
            if #hits >= pen then break end
            hits[#hits+1] = {HitChar = o.e.model, HitPos = edge(o.e), HitPart = o.e.part, Ricochet = false}
            used[key(o.e.model)], lineEnd = true, hits[#hits].HitPos
        end
    end
    local effects = {{Origin = origin, End = lineEnd}}
    local last, bounces = lineEnd, 0
    while bounces < rMax and math.random() < rChance do
        local nb, nbPos, nbD2 = nil, nil, BOUNCE_RANGE * BOUNCE_RANGE
        for _, e in ipairs(pool) do
            if not used[e.key] then
                local d = e.pos - last
                local d2 = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                if d2 <= nbD2 and usable(e) then nb, nbPos, nbD2 = {part = e.part, model = e.model}, e.pos, d2 end
            end
        end
        if not nb then break end
        hits[#hits+1] = {HitChar = nb.model, HitPos = nbPos, HitPart = nb.part, Ricochet = true}
        effects[#effects+1] = {Origin = last, End = nbPos}
        used[key(nb.model)], last, bounces = true, nbPos, bounces + 1
    end
    return hits, effects
    end
    -- v-14y (owner: no bullet on 1 or 2 zombies): try the 8 nearest zombies as the first target, keep the one whose
    -- shot (pierce + bounce chain) reaches the most, and shoot only when that is at least auraMin. v-14x log: 67 of 76
    -- BOUNCE hits killed, so the chain is what makes multi-kills.
    local hits, effects, firstE = nil, nil, nil
    local waited = false
    -- v-23f (owner, wiki: Screamer / Aberrant Screamer are fast, hit hard and call the horde): the nearest Screamer
    -- in range is shot first, then anything within AURA_CLOSE. Names are cached per zombie (one game read each),
    -- the cache is emptied every 60 s.
    if now >= (aura.namesAt or 0) then aura.names, aura.namesAt = {}, now + 60 end
    local scream
    for _, e in ipairs(near) do
        local k = key(e.model)
        local nm = aura.names[k]
        if nm == nil then
            local okN, n = pcall(function() return e.model.Name end)
            nm = okN and string.lower(tostring(n)) or ""
            aura.names[k] = nm
        end
        if string.find(nm, "screamer", 1, true) then scream = e; break end
    end
    local closeE = scream or (near[1].d2 <= AURA_CLOSE * AURA_CLOSE and near[1])
    if closeE then  -- Screamer or too close: shoot it now, no group wait
        hits, effects = build(closeE)
        firstE = closeE
        aura.focus = {pos = firstE.pos, t = now}
    elseif cfg.auraMode ~= 2 then
        local pick, n = near[1], (cfg.auraMode == 0 and #near) or (cfg.auraMode == 3 and math.min(5, #near)) or 0
        local top = -1
        for i = 1, n do  -- near is sorted nearest first, so equal HP keeps the nearer one
            local v = hpOf(near[i].model) or 0
            if v > top then pick, top = near[i], v end
        end
        hits, effects = build(pick)
        firstE = pick
        aura.focus = {pos = pick.pos, t = now}
    else
    for i = 1, math.min(8, #near) do
        local h2, e2 = build(near[i])
        if not hits or #h2 > #hits then hits, effects, firstE = h2, e2, near[i] end
    end
    -- v-14z (owner): a zombie that stays inside the circle auraWait seconds is shot anyway (the 1-2 left over), with
    -- the best shot that starts on it. Time inside is kept per Address and forgotten once it leaves the circle.
    local seenNow = {}
    for _, e in ipairs(near) do
        local a = key(e.model)
        seenNow[a] = true
        aura.inside[a] = aura.inside[a] or now
    end
    for a in pairs(aura.inside) do if not seenNow[a] then aura.inside[a] = nil end end
    if firstE then aura.focus = {pos = firstE.pos, t = now} end
    if #hits < cfg.auraMin and cfg.auraWait > 0 then
        local oldest, oldT = nil, nil
        for _, e in ipairs(near) do
            local t = aura.inside[key(e.model)]
            if t and now - t >= cfg.auraWait and (not oldT or t < oldT) then oldest, oldT = e, t end
        end
        if oldest then
            hits, effects = build(oldest)
            firstE, waited = oldest, true
            aura.focus = {pos = oldest.pos, t = now}
        end
    end
    if #hits < cfg.auraMin and not waited then
        aura.nextShot = now + 0.1  -- look again soon, no bullet spent
        kill.status = "Kill Aura: waiting for a group (best shot reaches " .. #hits .. " of " .. cfg.auraMin .. ")"
        return
    end
    end
    local part, pos, model, best = firstE.part, firstE.pos, firstE.model, firstE.d2
    aura.nextShot = now + 60 / (tonumber(st.FireRate) * mul) + 0.02
    -- v-15m (log game29): the server ignored shots 1-48 (Ammo stayed 6, all MISS) and took them from #49 on, so it
    -- seems to want a shot number above the gun's own count (you shot by hand first). When Ammo has not dropped for
    -- 5 shots, the number jumps by 25.
    local a = tonumber(okA and ammo)
    if a ~= aura.lastAmmo then aura.lastAmmo, aura.stuck = a, 0 else aura.stuck = (aura.stuck or 0) + 1 end
    if aura.stuck >= 5 then
        aura.stuck = 0
        aura.counter = aura.counter + 25
        auraLog("Ammo stays " .. tostring(a) .. " for 5 shots (not taken): shot number jumps to " .. aura.counter)
    end
    aura.counter = aura.counter + 1
    -- v-15l: the game's GunClient sends one bullet entry per Stats.Pellets in one Shoot call (dump 014); Kill Aura sent
    -- one. Scattershot (+2 bullets, -40% damage) with Pellets still 1 counts as 3. v-15n: the fake "+2 bullets" test
    -- toggle is gone: log game31 showed the server ignores bullets the gun does not have (Brute lost 510 per shot either way).
    local pellets = math.max(1, math.floor(tonumber(st.Pellets) or 1))
    local okU, upg = pcall(function() return tool:GetAttribute("Upgrade") end)
    if okU and upg == "Scattershot" and pellets == 1 then pellets = 3 end
    local bullets = {}
    for i = 1, pellets do bullets[i] = {Target = hits[1].HitPos, HitData = hits, EffectResults = effects} end
    local ok, err = pcall(function()
        shoot:FireServer(origin, bullets, 0, aura.counter)
    end)
    aura.sent = aura.sent + 1
    if not ok then kill.status = "Kill Aura: Shoot failed: " .. tostring(err); log(kill.status); return end
    do
        local n, tgt, hp0 = aura.counter, model, hpOf(model)
        if DEBUG_LOG then  -- v-16e (owner): per-shot line only while testing (its two reads are skipped too)
            local _, onScreen = WorldToScreen(pos)
            local okHb, hib = pcall(function() return model:GetAttribute("Hibernating") end)
            auraLog(string.format("#%d %s %d studs onScreen=%s hibernating=%s hp=%s hits=%d bullets=%d ammo=%s%s", n, tostring(model.Name),
                math.floor(math.sqrt(best)), tostring(onScreen), tostring(okHb and hib), tostring(hp0), #hits, pellets, tostring(okA and ammo),
                waited and " (waited " .. cfg.auraWait .. " s)" or ""))
        end
        local targets = {}
        for _, h2 in ipairs(hits) do
            local okN, nm = pcall(function() return h2.HitChar.Name end)
            -- v-14x: kind per hit, so the log tells bounces from penetration (owner: they are different things).
            local kind = (#targets == 0 and "first") or (h2.Ricochet and "BOUNCE") or "pierce"
            targets[#targets+1] = {model = h2.HitChar, hp = hpOf(h2.HitChar), name = (okN and nm or "?") .. "(" .. kind .. ")"}
        end
        aura.pending[#aura.pending+1] = {n = n, at = now + 0.7, targets = targets, addr = key(model)}
        if now >= aura.nextSum then
            aura.nextSum = now + 10
            local skipped = 0
            for a, t in pairs(aura.skipUntil) do if t > now then skipped = skipped + 1 else aura.skipUntil[a] = nil end end
            auraLog(string.format("-- summary: sent %d, hit %d, miss %d, skipped now %d",
                aura.sent, aura.hit, aura.miss, skipped))
        end
    end
    if not aura.logged then
        aura.logged = true
        auraLog("Kill Aura log, version " .. VERSION .. ", gun " .. tostring(tool.Name) .. " FireRate=" .. tostring(st.FireRate)
            .. " Penetration=" .. tostring(st.Penetration) .. " AmmoType=" .. tostring(st.AmmoType)
            .. " RicochetMax=" .. rMax .. " RicochetChance=" .. rChance .. " Pellets=" .. tostring(st.Pellets)
            .. " Damage=" .. tostring(st.Damage) .. " Upgrade=" .. tostring(okU and upg))
        log("Kill Aura: first shot at " .. tostring(model.Name) .. " (" .. math.floor(math.sqrt(best)) .. " studs), hits "
            .. #hits .. ", Penetration=" .. tostring(st.Penetration) .. " RicochetMax=" .. rMax .. " RicochetChance=" .. rChance)
    end
    kill.status = "Kill Aura: shooting (" .. aura.sent .. " shots)"
end
-- v-18k (owner, Remote Spy): vehicle turrets (Basic / Heavy / Minigun Turret) use no ammo. v-18o: rebuilt from the
-- game's own TurretLocal (dump 2026-11-18, 042_TurretLocal): only the gunner can shoot (front passenger seat FR, or the
-- DriveSeat while FR is empty); the shot starts at Vertical.Barrel1 / Barrel2 (alternating) WorldPosition;
-- Shoot:FireServer(barrel, {{Target, HitData, EffectResults}}) with one entry per Pellets; gap 60 / (AttachmentStats
-- FireRate * (1 + character FireRate)) (Basic Turret 400 = 0.15 s); UpdateAim:FireServer(yaw, pitch) every 0.2 s says
-- where the turret points (from Base.CFrame:PointToObjectSpace(aim), pitch >= MinAngle). The game turns the turret at
-- TurnSpeed rad/s; Kill Aura sends the final angle at once.
-- shortcut: HitData = {{HitChar, HitPos, HitPart}} and EffectResults {{Origin, End}} like the gun, because the Bullet
-- module (BulletHitscan) is not in the dump. Upgrade if the shot log still says NO damage while seated.
local turret = {list = {}, nextScan = 0, sent = 0, status = nil, nextAim = 0}
local TURRET_NEAR, TURRET_RANGE = 40, 400
local function posOf(x, depth)
    local ok, p = pcall(function() return x.Position end)
    if ok and typeof(p) == "Vector3" then return p end
    if (depth or 0) >= 2 then return nil end
    local okC, kids = pcall(function() return x:GetChildren() end)
    for _, c in ipairs(okC and kids or {}) do
        local cp = posOf(c, (depth or 0) + 1)
        if cp then return cp end
    end
    return nil
end
local function addrOf(x) local ok, a = pcall(function() return x.Address end); return ok and a or nil end
local function occupant(seat)
    if not seat then return nil end
    local ok, o = pcall(function() return seat.Occupant end)
    return ok and o and addrOf(o) or nil
end
local SEAT_NEAR = 4
local function seatDist(seat, hp)
    local p = seat and posOf(seat)
    if not p then return math.huge end
    local d = p - hp
    return math.sqrt(d.X*d.X + d.Y*d.Y + d.Z*d.Z)
end
local function barrelPos(t)
    t.flip = not t.flip
    local v = t.vert
    local b = v and ((t.flip and v:FindFirstChild("Barrel1")) or v:FindFirstChild("Barrel2") or v:FindFirstChild("Barrel1"))
    if b then
        local ok, wp = pcall(function() return b.WorldPosition end)
        if ok and typeof(wp) == "Vector3" then return wp end
    end
    return posOf(v or t.model)
end
local function turretStep(now, hp)
    if not cfg.auraTurret then turret.status = nil; return 0 end
    if now >= turret.nextScan then
        turret.nextScan = now + 2
        local list, structs = {}, workspace:FindFirstChild("Structures")
        for _, v in ipairs(structs and structs:GetChildren() or {}) do
            local att = v:FindFirstChild("Attachments")
            for _, a in ipairs(att and att:GetChildren() or {}) do
                local t = a:FindFirstChild("Turret")
                local shoot = t and t:FindFirstChild("Shoot")
                if shoot then
                    local stats = a:FindFirstChild("AttachmentStats")
                    local function st(n)
                        local ok, x = pcall(function() return stats:GetAttribute(n) end)
                        return ok and tonumber(x) or nil
                    end
                    local old = turret.list[shoot.Address]
                    list[shoot.Address] = {model = a, shoot = shoot, aim = t:FindFirstChild("UpdateAim"), name = tostring(a.Name),
                        vert = a:FindFirstChild("Vertical"), base = a:FindFirstChild("Base"), main = v:FindFirstChild("MainHitbox"),
                        drive = v:FindFirstChild("DriveSeat"), fr = v:FindFirstChild("FR"),
                        rate = st("FireRate") or 240, pellets = math.max(1, math.floor(st("Pellets") or 1)),
                        pen = math.max(1, math.floor(st("Penetration") or 1)),
                        range = st("BulletRange") or TURRET_RANGE, minAngle = st("MinAngle") or -0.3,
                        next = old and old.next or 0, flip = old and old.flip}
                end
            end
        end
        turret.list = list
        local n = 0
        for _ in pairs(list) do n = n + 1 end
        if n ~= turret.lastCount then turret.lastCount = n; log('Kill Aura: ' .. n .. ' vehicle turret(s) found in Structures') end
    end
    local c = LocalPlayer.Character
    local me = addrOf(c and c:FindFirstChildOfClass("Humanoid"))
    local okR, fr = pcall(function() return c:GetAttribute("FireRate") end)
    local mul = 1 + (okR and tonumber(fr) or 0)
    local near2, shots, nNear, nGun = TURRET_NEAR * TURRET_NEAR, 0, 0, 0
    for _, t in pairs(turret.list) do
        local mp = t.main and posOf(t.main)
        local dv = mp and mp - hp
        if dv and dv.X*dv.X + dv.Y*dv.Y + dv.Z*dv.Z <= near2 then
            nNear = nNear + 1
            -- v-18p (game24: never fired while driving): Matcha may not read Seat.Occupant, so sitting also counts when
            -- your HumanoidRootPart is within SEAT_NEAR studs of the DriveSeat or FR seat.
            -- shortcut: with the seat check by distance, a driver also fires while someone sits in FR (the game gives FR the gun).
            local gunner = occupant(t.fr) or occupant(t.drive)
            local sd = math.min(seatDist(t.drive, hp), seatDist(t.fr, hp))
            if turret.seatLogged ~= t.name then  -- once per turret kind (owner swaps Basic / Heavy mid-match)
                turret.seatLogged = t.name
                log(string.format('Kill Aura: turret %s near you: gunner read=%s me=%s, seat distance %.1f, barrel=%s, aim=%s, base=%s, rate=%s',
                    t.name .. ' pen=' .. t.pen, tostring(gunner), tostring(me), sd, tostring(t.vert ~= nil), tostring(t.aim ~= nil), tostring(t.base ~= nil), tostring(t.rate)))
            end
            if (me and gunner == me) or sd <= SEAT_NEAR then
                nGun = nGun + 1
                local gap = 60 / (t.rate * mul)
                local due = 0
                if now >= t.next then
                    -- v-20e (owner: Minigun Turret on Kill Aura fired ~3x slower than holding it, rate 1250 = 0.048 s):
                    -- one shot per frame and Matcha frames are slower than that, so the shots that fell due since the
                    -- last frame are all sent now (at most 10; v-20f: 3 gave 9.2 of 22.9 shots/s, log game42).
                    -- v-21g (log game47: Minigun 1.4 of 22.9 shots/s): frames came ~1 s apart, so the old "after a
                    -- 0.5 s pause send 1" rule sent 1 per frame. Now always catch up (cap 10), and the zombie search
                    -- (the slow part) runs at most every 0.15 s; the frames in between reuse its target.
                    local late = now - t.next
                    due = math.min(10, 1 + math.floor(late / gap))
                    t.next = late > 0.5 and now + gap or t.next + due * gap
                    local o = barrelPos(t) or mp
                    turret.rateC = (turret.rateC or 0) + 1
                    local tg = t.tgt
                    if not tg or now >= (t.pickAt or 0) then
                    t.pickAt = now + 0.15
                    local r2, best, bestD, cands = t.range * t.range, nil, nil, {}
                    -- v-21g (TurretLocal: the server turret turns at TurnSpeed, shots go where the barrel points): keep
                    -- the same zombie while it is alive and in range, so the barrel can settle on it.
                    local keepA, keep, keepD = tg and addrOf(tg.best.model), nil, nil
                    for _, p in pairs(HBX.expandedParts) do
                        local okP, pp = pcall(function() return p.Position end)
                        local okM, m = pcall(function() return p.Parent end)
                        if okP and okM and m and typeof(pp) == "Vector3" then
                            local d = pp - o
                            local d2 = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                            if d2 <= r2 and auraTargetOk(m) then
                                local e = {part = p, pos = pp, model = m}
                                cands[#cands+1] = e
                                if not bestD or d2 < bestD then best, bestD = e, d2 end
                                if keepA and addrOf(m) == keepA and (not keepD or d2 < keepD) then keep, keepD = e, d2 end
                            end
                        end
                    end
                    if keep then best, bestD = keep, keepD end
                    tg = nil
                    if best then
                        -- v-18q (owner: the Advanced Turret pierces, Minigun does not): AttachmentStats.Penetration = zombies
                        -- per bullet in total (like the gun's Stats.Penetration): the nearest, then the ones behind it on the line.
                        local hits = {{HitChar = best.model, HitPos = best.pos, HitPart = best.part}}
                        local dv = best.pos - o
                        local dlen = math.sqrt(dv.X*dv.X + dv.Y*dv.Y + dv.Z*dv.Z)
                        if t.pen > 1 and dlen > 0.1 then
                            local ux, uy, uz, width, onLine = dv.X / dlen, dv.Y / dlen, dv.Z / dlen, cfg.hitboxSize / 2 + 1, {}
                            for _, e in ipairs(cands) do
                                if e ~= best and addrOf(e.model) ~= addrOf(best.model) then
                                    local v = e.pos - o
                                    local along = v.X*ux + v.Y*uy + v.Z*uz
                                    local px, py, pz = v.X - ux*along, v.Y - uy*along, v.Z - uz*along
                                    if along > dlen and px*px + py*py + pz*pz <= width * width then onLine[#onLine+1] = {e = e, t = along} end
                                end
                            end
                            table.sort(onLine, function(x, y) return x.t < y.t end)
                            for _, ol in ipairs(onLine) do
                                if #hits >= t.pen then break end
                                hits[#hits+1] = {HitChar = ol.e.model, HitPos = ol.e.pos, HitPart = ol.e.part}
                            end
                        end
                        tg = {best = best, bestD = bestD, hits = hits}
                    end
                    t.tgt = tg
                    end
                    if tg then
                        local best, bestD, hits = tg.best, tg.bestD, tg.hits
                        if t.aim and t.base and now >= turret.nextAim then
                            turret.nextAim = now + 0.2
                            local okA, lp = pcall(function() return t.base.CFrame:PointToObjectSpace(best.pos) end)
                            if okA and lp then
                                local yaw = math.atan2(-lp.X, -lp.Z)
                                local pitch = math.max(math.atan2(lp.Y, math.sqrt(lp.X*lp.X + lp.Z*lp.Z)), t.minAngle)
                                pcall(function() t.aim:FireServer(yaw, pitch) end)
                            elseif not turret.aimLogged then
                                turret.aimLogged = true
                                log("Kill Aura: turret aim angle not readable (Base.CFrame), shooting without UpdateAim")
                            end
                        end
                        local bullets = {}
                        for i = 1, t.pellets do
                            bullets[i] = {Target = best.pos, HitData = hits, EffectResults = {{Origin = o, End = hits[#hits].HitPos}}}
                        end
                        for _ = 1, due do
                        local ok, err = pcall(function() t.shoot:FireServer(o, bullets) end)
                        if ok then
                            shots, turret.sent = shots + 1, turret.sent + 1
                            -- v-18m test lines: the first 5 shots, what was sent and the result 0.7 s later.
                            if turret.sent <= 5 then
                                local okN, hpn = pcall(function() return best.part:GetFullName() end)
                                log(string.format("Kill Aura: turret shot %d (%s, every %.2f s) at %s %d studs, zombies hit %d of pen %d, HitPart %s, from %s to %s, hp=%s",
                                    turret.sent, t.name, 60 / (t.rate * mul), tostring(best.model.Name), math.floor(math.sqrt(bestD)), #hits, t.pen,
                                    okN and tostring(hpn) or "?", tostring(o), tostring(best.pos), tostring(hpOf(best.model))))
                                turret.checks = turret.checks or {}
                                turret.checks[#turret.checks+1] = {n = turret.sent, model = best.model, hp = hpOf(best.model), at = now + 0.7}
                            end
                        elseif not turret.failLogged then
                            turret.failLogged = true
                            log("Kill Aura: turret Shoot failed: " .. tostring(err))
                        end
                        end
                        -- v-20e test log: shots per second over the first 5 s of firing, against the turret's own rate.
                        turret.rateT = turret.rateT or now
                        turret.rateN = (turret.rateN or 0) + due
                        if not turret.rateLogged and now - turret.rateT >= 5 then
                            turret.rateLogged = true
                            log(string.format("Kill Aura: turret %s sent %.1f shots/s (its rate %.1f/s), loop ran %.1f times/s", t.name,
                                turret.rateN / (now - turret.rateT), 1 / gap, (turret.rateC or 0) / (now - turret.rateT)))
                        end
                    end
                end
            end
        end
    end
    local ck = turret.checks and turret.checks[1]
    if ck and now >= ck.at then
        table.remove(turret.checks, 1)
        local hp1 = hpOf(ck.model)
        log("Kill Aura: turret shot " .. ck.n .. " " .. ((ck.hp and (not hp1 or hp1 < ck.hp)) and "did damage" or "did NO damage")
            .. " (hp " .. tostring(ck.hp) .. " > " .. tostring(hp1) .. ")")
    end
    turret.status = (nGun > 0 and (nGun .. " turret(s) firing, " .. turret.sent .. " shots"))
        or (nNear > 0 and "turret near: sit in the driver or front passenger seat") or nil
    return shots
end
local function killFrame()
    local now = os.clock()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then turretStep(now, h.Position) end
    if now >= kill.nextGun then kill.nextGun = now + 0.25; kill.gun = gunInHand() end
    if not kill.gun then
        kill.status = turret.status and ("Kill Aura: " .. turret.status .. ", no gun in hand")
            or "Kill Aura: ON, waiting for a gun in hand (or a vehicle with a turret)"
        return
    end
    return auraStep(kill.gun, now)
end
-- Owner 2026-11-25: in toggle mode the Kill Aura switch in the menu, the quick button and the key are one setting:
-- the key flips the menu switch itself, so all three always show the same. Hold mode: the switch arms it, the key
-- runs it while held. setKillOn is filled in once the menu ids exist (further down).
local setKillOn = function() end
local function aimOrKill()
    local down = cfg.aimKey ~= 0 and iskeypressed(cfg.aimKey)
    local press = down and not kill.wasDown
    kill.wasDown = down
    if press and cfg.aimMode == 1 and IS_PRO then
        cfg.killOn = not cfg.killOn
        setKillOn(cfg.killOn)
        log("Kill Aura " .. (cfg.killOn and "ON" or "OFF") .. " (key)")
    end
    -- v-15u (owner): while Kill Aura runs, the Apocalypse helper switches to combat mode (no ESP, only food / ammo /
    -- meds picked up). It reads this flag; the helper alone (no hitbox script) never sees it set.
    -- Owner 2026-11-18: on Regular Kill Aura never runs, but the saved "armed" setting is kept for when Pro is back.
    kill.active = (IS_PRO and cfg.killOn and (cfg.aimMode == 1 or down)) and true or false
    _G.HBX_AURA_ON = kill.active
    if not kill.active then
        local st = (IS_PRO and cfg.killOn) and "Kill Aura: hold the key to fire" or "Kill Aura: off"
        if kill.status ~= st then killRelease(); kill.status = st end
        return
    end
    return killFrame()
end

-- Owner: in toggle mode nothing showed whether the aim was on. Small Drawing text under the cursor while it is on.
local aimLabel
-- v-14s (owner): Kill Aura reach as a green ring on the ground around you (Drawing lines, like the owner's sample).
-- v-15a (owner's drawing): plus a red ring of radius auraBounce around the zombie the aura is aiming at (the group zone:
-- zombies inside it can take the first bounce; later bounces measure from each bounced zombie), and a red line to it.
local RING_SEGS = 24  -- v-15s: was 32 (owner: drawing slowed Matcha)
local ring, bounceRing = {}, {}
local function ringHide(lines)
    for _, l in ipairs(lines) do if l.Visible then l.Visible = false end end
end
local function ringDraw(lines, center, r, color)
    if #lines == 0 then
        for i = 1, RING_SEGS do
            local l = Drawing.new("Line")
            l.Thickness, l.Color, l.Visible = 1.5, color, false
            lines[i] = l
        end
    end
    local prev, prevOn = WorldToScreen(Vector3.new(center.X + r, center.Y, center.Z))
    for i = 1, RING_SEGS do
        local a = i * 2 * math.pi / RING_SEGS
        local sp, on = WorldToScreen(Vector3.new(center.X + math.cos(a) * r, center.Y, center.Z + math.sin(a) * r))
        local l = lines[i]
        if on and prevOn then
            l.From, l.To = Vector2.new(prev.X, prev.Y), Vector2.new(sp.X, sp.Y)
            if not l.Visible then l.Visible = true end
        elseif l.Visible then
            l.Visible = false
        end
        prev, prevOn = sp, on
    end
end
local focusLine
local ringNext = 0
local function auraRingFrame()
    -- v-15s: redrawn 20 times a second, not every frame (Drawing lines keep their place in between).
    local now = os.clock()
    if now < ringNext then return end
    ringNext = now + 0.05
    local on = IS_PRO and cfg.killOn and kill.active and cfg.auraGuide
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local f = aura.focus
    local showFocus = on and h and f and os.clock() - f.t < 1
    if not on or not h then ringHide(ring) else
        local hp = h.Position
        ringDraw(ring, Vector3.new(hp.X, hp.Y - 3, hp.Z), cfg.auraRange, Color3.fromRGB(80, 255, 80))
    end
    if not showFocus then
        ringHide(bounceRing)
        if focusLine and focusLine.Visible then focusLine.Visible = false end
        return
    end
    ringDraw(bounceRing, Vector3.new(f.pos.X, f.pos.Y - 2, f.pos.Z), cfg.auraBounce, Color3.fromRGB(255, 70, 70))
    if not focusLine then
        focusLine = Drawing.new("Line")
        focusLine.Thickness, focusLine.Color = 1.5, Color3.fromRGB(255, 70, 70)
    end
    local a, onA = WorldToScreen(h.Position)
    local b, onB = WorldToScreen(f.pos)
    local vis = onA and onB
    if vis then focusLine.From, focusLine.To = Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y) end
    if focusLine.Visible ~= vis then focusLine.Visible = vis end
end
-- v-14q (owner): green "KILL AURA ON" / "AUTO KILL ON" there while Auto Kill is switched on.
local aimLabelText
local function aimLabelFrame()
    local killing = IS_PRO and cfg.killOn and kill.active
    local show = killing
    if not aimLabel then
        if not show then return end
        aimLabel = Drawing.new("Text")
        aimLabel.Center, aimLabel.Outline, aimLabel.Size = true, true, 14
    end
    -- v-18n (owner: does it see me in the vehicle?): says so on screen when turrets near you are found.
    local text = (turret.status and string.find(turret.status, "firing", 1, true)) and "KILL AURA ON + TURRET" or "KILL AURA ON"
    if text ~= aimLabelText then
        aimLabelText = text
        aimLabel.Text = text
        aimLabel.Color = killing and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    end
    if show then
        local m = LocalPlayer:GetMouse()
        aimLabel.Position = Vector2.new(m.X, m.Y + 28)
    end
    if aimLabel.Visible ~= show then aimLabel.Visible = show end
end

-- ===== Apocalypse Helper (built in from ApocalypseHelper.lua by build_apoc_aio.py) ========
-- Own function scope: its locals stay apart from the hitbox's. Returns nil outside the game.
local function startApocHelper()
-- Apocalypse Helper (Matcha Pro) - Survive the Apocalypse (GameId 9098570654): auto pickup of ammo, gems and fuel.
-- Sends the game's own messages (Hybrid mode FireServer), so it never moves the mouse or presses keys:
--   take an item:      ReplicatedStorage.Remotes.Interaction.PickUpItem:FireServer(itemModel)   (what E does)
--   store fuel in bag: ReplicatedStorage.Remotes.Tools.AdjustBackpack:FireServer(itemModel)      (what F does)
-- Found in the game's ItemInteractClient / BackpackClient (dump\9098570654). AdjustBackpack with nil = UNSTORE (drops
-- the bag's contents), so it is only ever called with an item. Log: C:\matcha\workspace\apoc_log.txt.
-- Notes for Claude: D:\NPCHitBoxExpander\Documentation.md.
local VERSION = "2026-11-25zzx"  -- bump on every edit so the log shows which copy ran
local GAME_ID = 9098570654

local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===== Log file ==============================================================
-- In the All-in-One: the hitbox half's per-run file in SurviveTheApocalypse/logs (v-14g, owner).
local LOG_FILE = _G.APOC_LOG_FILE or "apoc_log.txt"
pcall(function()
    local s = not string.find(LOG_FILE, "/", 1, true) and isfile(LOG_FILE) and readfile(LOG_FILE) or ""
    if #s > 300000 then
        s = s:sub(-300000)
        writefile(LOG_FILE, s:sub((s:find("\n") or 0) + 1))  -- drop the cut-off first line
    end
end)
local function log(msg)
    if NO_LOGS then return end  -- set only by the public release header of the All-in-One
    local ok, t = pcall(os.date, "%H:%M:%S")
    pcall(appendfile, LOG_FILE, (ok and t or tostring(tick())) .. " " .. msg .. "\n")
end
local function say(msg) if not NO_LOGS then print("[APOC] " .. msg) end; log(msg) end
-- Errors also pop up in Matcha (notify) once per message, so a broken test is noticed while playing, not only in the log.
local alerted = {}
local function alert(msg)
    say(msg)
    if alerted[msg] then return end
    alerted[msg] = true
    pcall(notify, msg .. (NO_LOGS and "" or " -- please send the logs from C:\\matcha\\workspace to the script author"), "Apocalypse Helper", 10)
end
-- v-17a (owner): one script for Matcha Pro and Regular. Auto Pickup, crates, Auto Join and the badge send the game's
-- remotes (Pro only); on Regular they show "(Pro)" and switch themselves back off.
-- shortcut: only the documented Pro global is checked, not tested on a Regular account yet; owner will test.
local IS_PRO = type(fireproximityprompt) == "function" and (type(ishybridenabled) ~= "function" or select(2, pcall(ishybridenabled)) ~= false)  -- Pro calls also need Hybrid mode on
local PRO_TAG = IS_PRO and "" or " (Pro)"
local function needsPro(what) pcall(notify, what .. " needs Matcha Pro", "Apocalypse Helper", 5) end
-- Same as the hitbox script: an xpcall handler can still read the failing line with debug.info.
local function try(fn)
    if type(xpcall) ~= "function" then return pcall(fn) end
    return xpcall(fn, function(e)
        local line
        if type(debug) == "table" and type(debug.info) == "function" then
            for level = 2, 5 do
                local l = debug.info(level, "l")
                if type(l) == "number" and l > 0 then line = l; break end
            end
        end
        return tostring(e) .. (line and (" (line " .. line .. ")") or "")
    end)
end
-- The all-in-one build sees the hitbox's crumb() (freeze hunt, crumb_<GameId>.txt); run alone it does nothing.
local crumb = crumb or function() end
local DEBUG_LOG = DEBUG_LOG == true  -- the hitbox script's switch in the all-in-one, else off
pcall(function() log("==== Run started (v" .. VERSION .. "): " .. tostring(getgamename()) .. " (place " .. tostring(game.PlaceId) .. ")") end)

if game.GameId ~= GAME_ID then
    say("Not Survive the Apocalypse (GameId " .. tostring(game.GameId) .. "), stopping.")
    return
end
-- ===== Config + saved settings ===============================================
local cfg = {
    enabled = true,
    range   = 12,                  -- studs; v-14a: no longer capped at 12 + DragRange (owner: mouse reaches further)
    mask    = true,                -- take a Gas Mask once when none is worn (character attribute WearingGasMask)
    fuelStopDay = 50,              -- from this day on: no fuel storing, no fuel ESP (0 = never stop)
    pick    = {},                  -- item kind key -> take it (ITEM_KINDS below; menu toggles)
    -- comma list, menu "Other items": an item is also taken when its name contains one of these
    extra   = "",
    fuel    = true,                -- store Fuel in the backpack
    scrap   = true,                -- store scrap, screws... (ItemType "Resource", not batteries) in the backpack
    batt    = true,                -- store Batteries (Tier 1, ItemType Resource) in the backpack
    battPack = true,               -- store Battery Packs (the higher tier) in the backpack
    food    = true,                -- eat food (ItemType "Food") when the whole meal fits in the hunger bar
    armor   = true,                -- wear dropped armor with a higher Tier than the worn one
    weapon  = true,                -- take a higher-Tier melee weapon and drop the old one
    bagUp   = true,                -- take a higher-Tier backpack (the old one vanishes, its items stay: owner)
    weaponBag = true,              -- v-14e (owner): store every gun / melee weapon in the backpack, never equip it
    -- v-14f (owner): Good scrap ESP = these names only (2+ scrap each). Tier is not the scrap amount: Bucket and
    -- Dumbell are Tier 2 but give 1 scrap (owner), and Stats.Scrap in the scan looked mixed up.
    goodScrap = "tv, aircon, air con, watch, satellite dish, ac",  -- owner: TV 2, Aircon 3, Watch 2, Dish 2, AC 3 scrap
    mreBag2 = false,               -- v-14k (owner changed mind): MREs not stored; new key so the old saved "on" is dropped
    crates  = true,                -- open crates within reach (Default, Super, Emerald, Reactor)
    espOn   = true,                -- text ESP for the kinds in `esp` (ESP_KINDS), within espDist studs
    esp     = {},                  -- ESP kind key -> shown
    espColor = {},                 -- ESP kind key -> {r, g, b} (0-1) picked in the menu; none = the kind's default
    espDist = 300,
    badge   = "",                  -- lobby: badge to show off (name as in the Badges menu), "" = leave it alone
    farmMode  = 0,                 -- Auto Farm game mode: 0 = Endless (normal map: later)
    farmMin   = 91,                -- Auto Farm: leave for the lobby after this many minutes on the pad (owner: 91)
    autoFarm  = false,             -- executor copy: Endless solo farm (Auto Farm below); remembered across teleports
    joinMode  = 0,                 -- lobby Auto Join: 0 off, 1 create my own room, 2 join others' rooms
    partySize = 1,                 -- lobby: party size set on a room the script created (1-5)
    joinMin   = 1,                 -- lobby, join others: only join rooms that already have at least this many players
    leaveAt   = 1,                 -- lobby, join others: leave when the room has this many players or fewer, 0 = never
    hotkey  = 0,                   -- old Keybind widget value, no longer used (v-15k: the L key toggles Auto Pickup)
    espAmmo = 0,                   -- v-15k: ESP "chosen ammo" kind, index into AMMO_NAMES (0 = Pistol)
    espVehicle = 0,                -- v-19a: ESP vehicle pick, index into VEHICLE_NAMES (0 = Truck)
    crateMinTier = 3,              -- v-24e: crate ESP only from this rarity up, index into CRATE_RARITY (3 = Epic, owner v-24f)
    antiAfk = true,                -- tap Space every 4 min without input (Roblox focused) so Roblox's 20 min idle kick never comes
}
local SETTINGS_FILE = "SurviveTheApocalypse/pickup_settings.json"
-- v-16d (owner: Auto Pickup is always off after a restart): "enabled" is not saved, so every start is ON. Logs
-- game41/43: only "enabled" flipped to false mid-game (L key or the toggle), and that saved "off" carried over.
local SAVED_KEYS    = {"range", "pick", "extra", "fuel", "scrap", "batt", "battPack", "food", "armor", "weapon", "bagUp", "crates", "espOn", "esp", "espColor", "espDist", "badge",
    "joinMode", "partySize", "joinMin", "leaveAt", "hotkey", "mask", "fuelStopDay", "weaponBag", "mreBag2", "goodScrap", "espAmmo", "espVehicle", "crateMinTier", "antiAfk", "autoFarm", "farmMode", "farmMin"}
do
    local ok, data = pcall(function()
        return isfile(SETTINGS_FILE) and HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if ok and type(data) == "table" then
        for _, k in ipairs(SAVED_KEYS) do
            if (k == "pick" or k == "esp" or k == "espColor") and type(data[k]) == "table" then
                for kind, on in pairs(data[k]) do
                    if type(on) == (k == "espColor" and "table" or "boolean") then cfg[k][kind] = on end
                end
            elseif type(data[k]) == type(cfg[k]) then
                -- v-14g: a saved list still equal to the old default gets the new default names (TV, Aircon).
                -- v-14j: any older default (a start of the new default list) gets the new names too.
                local oldDef = k == "goodScrap" and data[k] ~= "" and string.find(cfg[k], data[k], 1, true) == 1
                if not oldDef then cfg[k] = data[k] end
            end
        end
        -- v-23a (owner): Exhaust Pipe is not good scrap any more; drop it from a saved list too.
        cfg.goodScrap = string.gsub(cfg.goodScrap, "%s*[Ee]xhaust [Pp]ipe%s*,?", "")
    end
end

cfg.joinMode  = math.clamp(math.floor(cfg.joinMode), 0, 2)
cfg.partySize = math.clamp(math.floor(cfg.partySize), 1, 5)
cfg.joinMin   = math.clamp(math.floor(cfg.joinMin), 1, 4)
cfg.leaveAt   = math.clamp(math.floor(cfg.leaveAt), 0, cfg.joinMin)

-- The lobby has no loot and no PickUpItem remote (autoexec there popped "remote not found"): there the script only
-- does the lobby part (badge show-off, Auto Join) and the menu shows the "Lobby" section instead of Auto Pickup.
local LOBBY = (game.PlaceId == 90148635862803 or game.PlaceId == 80046280333935)  -- normal lobby, Endless Night event lobby
if LOBBY then say("Lobby: Auto Pickup starts in the match (run the script again there if it does not start by itself).") end

-- ===== Item filter ===========================================================
-- Item kinds, one menu toggle each (owner: toggles instead of typing names). Names from the 03:14 scan of
-- DroppedItems (2026-11-04). `top` = on the main page: turn Bandages/Medkits off to drop one for a teammate without
-- the script taking it back. A kind matches by ItemType, ToolType or a name part (lower case).
local ITEM_KINDS = {
    {key = "bandage",   label = "Take Bandages",  on = true,  top = true, names = {"bandage"}},
    {key = "medkit",    label = "Take Medkits",   on = true,  top = true, names = {"medkit"}},
    {key = "ammo",      label = "Ammo (pistol, medium, long, shells)", on = true, itemType = "Ammo"},
    {key = "compound",  label = "Compound (medical drinks)", on = true, names = {"compound"}},
    -- v-24i (owner): every other healing item (ToolType Medical); Bandages / Medkits keep their own toggles.
    {key = "medical",   label = "Other healing items", on = true, toolType = "Medical", notNames = {"bandage", "medkit"}},
    {key = "emerald",   label = "Emeralds / Gems", on = true, names = {"emerald", "gem"}},
    {key = "keycard",   label = "Keycards",       on = true,  names = {"card"}},
    {key = "throwable", label = "Throwables (grenades, molotovs, flashbangs, tear gas)", on = false, toolType = "Throwable"},
    {key = "gun",       label = "Guns (any)",     on = false, toolType = "Gun"},
    {key = "blueprint", label = "Blueprints (traps, wire)", on = false, toolType = "Blueprint"},
    {key = "car",       label = "Car parts (turrets, plating)", on = false, toolType = "CarAttachment"},
    {key = "gasmask",   label = "Gas Masks",      on = false, itemType = "GasMask"},
    -- v-14i (owner): the Wrench (Tool, ToolType ProgressionItem, Tier 5) repairs the Upgrade Station; one is enough.
    -- v-16a: matched by name, because Military Keycard is a ProgressionItem too (Tier 4, apoc_scan) and a held
    -- keycard counted as "already has a Wrench", so the Wrench was never taken.
    {key = "wrench",    label = "Wrench (one, for the Upgrade Station)", on = true, names = {"wrench"}},
    -- v-16a (owner): Military Turret into the inventory like Medkits (not the bag).
    {key = "turret",    label = "Military Turret", on = true, names = {"military turret"}},
}
for _, k in ipairs(ITEM_KINDS) do
    if cfg.pick[k.key] == nil then cfg.pick[k.key] = k.on end
end
local wanted = {}
local function setItems(text)
    wanted = {}
    for w in string.gmatch(text, "[^,]+") do
        w = string.lower(string.match(w, "^%s*(.-)%s*$"))
        if w ~= "" then wanted[#wanted+1] = w end
    end
end
local function matches(lowerName)
    for _, w in ipairs(wanted) do
        if string.find(lowerName, w, 1, true) then return true end
    end
    return false
end
-- Fuel never comes through here (it has ToolType Throwable too): the caller handles it.
local function wants(lowerName, info, pick)
    for _, k in ipairs(ITEM_KINDS) do
        local skip = false
        for _, w in ipairs(k.notNames or {}) do skip = skip or string.find(lowerName, w, 1, true) ~= nil end
        if pick[k.key] and not skip then
            if (k.itemType and info.type == k.itemType) or (k.toolType and info.toolType == k.toolType) then return true end
            for _, w in ipairs(k.names or {}) do
                if string.find(lowerName, w, 1, true) then return true end
            end
        end
    end
    return matches(lowerName)
end
-- Self-check of the filter (logged; never stops the script).
do
    local ok = try(function()
        setItems(" Ammo ,gem,, ")
        assert(matches("pistol ammo") and matches("blue gem") and not matches("fuel") and not matches("beans"))
        setItems("")
        local pick = {medkit = false, ammo = true, throwable = true}
        assert(wants("shells", {type = "Ammo"}, pick) and wants("grenade", {toolType = "Throwable"}, pick))
        assert(not wants("medkit", {toolType = "Medical"}, pick) and not wants("bandage", {toolType = "Medical"}, pick))
        assert(wants("medkit", {}, {medkit = true}))
        assert(wants("pills", {toolType = "Medical"}, {medical = true}) and not wants("medkit", {toolType = "Medical"}, {medical = true}))
        assert(wants("military turret", {}, {turret = true}) and wants("wrench", {}, {wrench = true}))
        assert(not wants("military keycard", {toolType = "ProgressionItem"}, {wrench = true}))
    end)
    if not ok then alert("Filter self-check failed") end
    setItems(cfg.extra)
end

-- ===== Helpers ===============================================================
local PART_CLASSES = {Part=true, MeshPart=true, UnionOperation=true, WedgePart=true}
local function partPos(p)
    local ok, pos = pcall(function() return p.Position end)
    if ok and typeof(pos) == "Vector3" then return pos end
    return nil
end
-- Item addr -> part used for its position. No PrimaryPart: in Matcha its Position read as nil (test of v-a).
local partCache = {}
local function itemPart(it)
    local a = it.Address
    local p = partCache[a]
    if p and partPos(p) then return p end
    p = nil
    local h = it.ClassName == "Tool" and it:FindFirstChild("Handle")
    if h and partPos(h) then
        p = h
    else
        -- Dropped Bandage tools have no Handle, only "FakeHandle" / "Mesh" (scan 01:13): any part will do.
        for _, c in ipairs(it:GetChildren()) do
            if PART_CLASSES[c.ClassName] and partPos(c) then p = c; break end
        end
    end
    partCache[a] = p
    return p
end

-- The game's remotes, looked up once and again if they go missing.
local remotes = {}
local function remote(group, name)
    local key = group .. "." .. name
    local r = remotes[key]
    if r and r.Parent then return r end
    local ok, found = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes[group][name]
    end)
    remotes[key] = ok and found or nil
    return remotes[key]
end

-- Fuel lying on a generator's striped zone was unstored there on purpose: leave it. Zones = Structures.Generator*.
-- FuelZone, refreshed every 5 s: {pos, r2}. No margin since v-04d: the old +4 studs also blocked fuel spawning next
-- to the generator (owner report), and the 3 s "yours" wait already stops a race with the generator eating it.
local zones, zonesTime = {}, -math.huge
local function fuelZones()
    local now = os.clock()
    if now - zonesTime < 5.0 then return zones end
    zonesTime = now
    zones = {}
    local s = workspace:FindFirstChild("Structures")
    if s then
        for _, g in ipairs(s:GetChildren()) do
            local z = string.find(g.Name, "Generator", 1, true) and g:FindFirstChild("FuelZone")
            local pos = z and partPos(z)
            if pos then
                local ok, size = pcall(function() return z.Size end)
                local r = (ok and typeof(size) == "Vector3") and math.max(size.X, size.Z) / 2 or 11
                zones[#zones+1] = {pos = pos, r2 = r * r}
            end
        end
    end
    return zones
end
local function inFuelZone(pos)
    for _, z in ipairs(fuelZones()) do
        local d = pos - z.pos
        if d.X*d.X + d.Z*d.Z <= z.r2 then return true end  -- flat distance: the zone is a floor area
    end
    return false
end

-- ===== Pickup ================================================================
local tries   = {}   -- item addr -> {n = attempts, skipUntil = os.clock()}
local lootState = nil  -- Auto Loot on/off + Kill Aura on/off, last tick (a change clears tries and pending)
local pending = {}   -- item addr -> {item, fuel, sent = os.clock()}: counted once the item leaves DroppedItems
local picked, stored, failed, fuelHintShown, ate = 0, 0, 0, false, 0

-- What the game itself allows to take with E: Tools and models with the CanPickUp attribute (ItemInteractClient).
local function canTake(it)
    if it.ClassName == "Tool" then return true end
    local ok, v = pcall(function() return it:GetAttribute("CanPickUp") end)
    return ok and v ~= nil and v ~= false
end
local noTakeLogged = {}
-- v-21i (owner: game kept saying "you have a better backpack equipped"): a tick that misses the bag read 0 and grabbed a
-- worse bag. A 0 read now falls back to the last real tier seen on this character (cleared on respawn).
local bagSeen = {char = nil, tier = 0}
local function bagTierOf(char, readTier)
    if bagSeen.char ~= char then bagSeen.char, bagSeen.tier = char, 0 end
    if readTier > 0 then bagSeen.tier = readTier end
    return readTier > 0 and readTier or bagSeen.tier
end
do
    local a, b = {}, {}
    assert(bagTierOf(a, 4) == 4 and bagTierOf(a, 0) == 4 and bagTierOf(a, 2) == 2 and bagTierOf(b, 0) == 0)
    bagSeen.char, bagSeen.tier = nil, 0
end

-- Food is eaten on the spot (E shows "Eat" for ItemType "Food"), so it is only sent when the whole meal fits:
-- character Hunger + the food's Stats.Hunger <= MAX_HUNGER.
-- shortcut: MAX_HUNGER = 100 guessed (the game draws one icon per 20 hunger), check it against the "Ate:" log lines.
-- In v-04a Matcha read every food's Stats.Hunger as nil (logged food=0.0, beans eaten at hunger 98.9), so an unread
-- value counts as FOOD_UNKNOWN: eaten only at hunger <= 70.
local MAX_HUNGER, FOOD_UNKNOWN = 100, 30
-- Item addr -> {type = ItemType attribute or false, toolType, tier, hunger}; dropped when the item is gone.
-- ItemType "Resource" = scrap, batteries, screws... (Stats Scrap/Batteries/Hearts): stored in the bag like fuel.
-- Scan 01:17: dropped armor = Model ItemType "Armor" + Tier; weapons = Tool ToolType "Melee"/"Gun" + Tier.
local infoCache = {}
local function attr(inst, name)
    local ok, v = pcall(function() return inst:GetAttribute(name) end)
    if ok then return v end
    return nil
end
local function itemInfo(it)
    local a = it.Address
    local v = infoCache[a]
    if not v or (v.retryAt and os.clock() >= v.retryAt) then
        v = {type = attr(it, "ItemType") or false, toolType = attr(it, "ToolType"), tier = tonumber(attr(it, "Tier")) or 0}
        if v.type == "Food" then
            -- The scan reads Stats.Hunger fine through GetChildren (Beans 40, Chips 30, MRE 60), FindFirstChild gave nil.
            -- v-18v (owner: Bloxy Cola never eaten): the scan shows its Stats with no Hunger at all. v-18w: owner says it
            -- gives about 10-15, so a Stats without Hunger counts as 15; only a missing Stats counts as FOOD_UNKNOWN.
            local h, stats
            local okC, kids = pcall(function() return it:GetChildren() end)
            for _, c in ipairs(okC and kids or {}) do
                if c.Name == "Stats" then stats = true; h = tonumber(attr(c, "Hunger")) or 15; break end
            end
            v.hunger = h or FOOD_UNKNOWN
            if not stats then v.retryAt = os.clock() + 5 end  -- just spawned: Stats may not be there yet
        end
        infoCache[a] = v
    end
    return v
end

-- Upgrades (owner: only better ones). Armor: E on dropped armor wears it; worn = Model "Armor" in the character with
-- a Tier (character attribute Armor = its name). Melee: pick up a higher-Tier melee Tool, then drop the old best melee
-- with the game's DropTool:InvokeServer(tool, cframe) (what the drop key sends). Backpacks are not swapped: what happens
-- to the bag's contents is unknown. Equal tiers never swap.
local function wornArmorTier(char)
    local m = char:FindFirstChild("Armor")
    return m and (tonumber(attr(m, "Tier")) or 0) or 0
end
local function bestTool(char, toolType)
    local best, bestTier = nil, 0
    for _, holder in ipairs({LocalPlayer:FindFirstChild("Backpack"), char}) do
        for _, t in ipairs(holder and holder:GetChildren() or {}) do
            if t.ClassName == "Tool" and attr(t, "ToolType") == toolType then
                local tier = tonumber(attr(t, "Tier")) or 0
                if tier > bestTier then best, bestTier = t, tier end
            end
        end
    end
    return best, bestTier
end
-- Bandage / Medkit limit removed (owner, 2026-11-18): Matcha could not read stack sizes, so the count was wrong.
-- Every Bandage / Medkit in reach is now taken whenever its toggle is on.
local function medOf(lowerName)
    return (string.find(lowerName, "bandage", 1, true) and "bandage") or (string.find(lowerName, "medkit", 1, true) and "medkit") or nil
end
-- Workspace attribute CurrentDay (logged as "Event: CurrentDay=N").
local function lateGame()
    if cfg.fuelStopDay <= 0 then return false end
    local ok, d = pcall(function() return workspace:GetAttribute("CurrentDay") end)
    return ok and tonumber(d) ~= nil and tonumber(d) >= cfg.fuelStopDay
end
local swap = nil  -- {old = Tool, oldTier, name, until}: melee to drop once the better one is in the inventory
local maskWait = 0  -- next Gas Mask try
local foodWait = 0  -- after eating, wait for the server to update Hunger before the next meal

-- Items you drop yourself (F with the bag = Unstore) wait 3 s before going back into the bag: the generator eats fuel
-- and the Scrap Resources shredder eats scrap within that time, and whatever is still lying there (fuel at the
-- shredder, scrap at the generator, a scrap that spawned as you switched to the bag) is stored again (owner's wish).
-- "Yours" = an item this script stored that shows up again, or a bag item first seen within 8 studs with the bag in hand
-- whose LastBackpack attribute is your UserId (v-14g).
local MINE_WAIT = 3.0
local seen, storedBefore, seeded = {}, {}, false

local function nearbyItems(kids, hrpPos, reach2, bagInHand, wearingMask)
    local list, now = {}, os.clock()
    local fuelOn = cfg.fuel and not lateGame()
    local eternal = attr(workspace, "EternalNight") == true
    for _, it in ipairs(kids) do
        local a = it.Address
        local fresh = not seen[a]
        seen[a] = true
        storedBefore[a] = nil  -- v-14h (owner): no wait for items you drop yourself, everything is stored at once
        local n = string.lower(it.Name)
        local info = itemInfo(it)
        -- "Refined Fuel" and other fuel kinds (owner: also a nuclear one): the game's own ItemType "Fuel", or the name.
        local isFuel = info.type == "Fuel" or string.find(n, "fuel", 1, true) ~= nil
        -- v-20i (owner): nuclear fuel always goes into the backpack, even from the "Stop Fuel from day" day on.
        local nukeFuel = isFuel and cfg.fuel and (string.find(n, "nuclear", 1, true) or string.find(n, "uranium", 1, true)
            or string.find(n, "reactor", 1, true) or string.find(n, "radioactive", 1, true)) ~= nil
        -- Resources: Battery Pack / Battery / the rest (scrap, screws...) each have a toggle (owner, v-04zf).
        local isBatt = info.type == "Resource" and string.find(n, "battery", 1, true) ~= nil
        local battOn = cfg.batt
        if isBatt and string.find(n, "pack", 1, true) then battOn = cfg.battPack end
        local med = medOf(n)
        -- Endless Night (owner, 2026-11-22): no shredder or workbench, so stored weapons are dead weight there; better
        -- melee is still swapped in as an upgrade.
        local weaponBag = cfg.weaponBag and not eternal and (info.toolType == "Gun" or info.toolType == "Melee")
        -- v-24t (owner: MREs placed beside you for Auto Eat): stored only while the Backpack is in hand, else eaten as food.
        local mreBag = cfg.mreBag2 and bagInHand and info.type == "Food" and string.find(n, "mre", 1, true) ~= nil
        -- Endless Night (workspace EternalNight, ItemInteractClient): E claims Resources (scrap, batteries) straight
        -- into the inventory, no backpack needed. Same toggles as storing them.
        local claim = eternal and info.type == "Resource" and ((isBatt and battOn) or (not isBatt and cfg.scrap))
        -- Endless Night (owner, 2026-11-22): no generator, fuel only drives the cars, so it is left on the ground there.
        local bag = not claim and ((isFuel and not eternal and (fuelOn or nukeFuel)) or (isBatt and battOn)
            or (info.type == "Resource" and not isBatt and cfg.scrap) or weaponBag or mreBag)
        local food = info.type == "Food" and cfg.food and not mreBag and info.hunger or nil
        local upgrade = (info.type == "Armor" and cfg.armor and "armor")
            or (info.toolType == "Melee" and cfg.weapon and not weaponBag and "melee")
            or ((info.toolType == "Backpack" or string.find(n, "backpack", 1, true)) and cfg.bagUp and "backpack")
            or (info.type == "GasMask" and cfg.mask and not wearingMask and "mask")
            or (string.find(n, "wrench", 1, true) and cfg.pick.wrench and "wrench") or nil
        -- v-24h..24s (owner): Kill Aura no longer limits pickup; bag items wait for the Backpack in hand (send code).
        if (bag or claim or food or upgrade or (not isFuel and wants(n, info, cfg.pick))) then
            local t = tries[a]
            if not (t and now < t.skipUntil) then
                local p = itemPart(it)
                local pos = p and partPos(p)
                if pos and not (isFuel and inFuelZone(pos)) then
                    local d = pos - hrpPos
                    local d2 = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                    if d2 <= reach2 then
                        list[#list+1] = {item = it, bag = bag, claim = claim, fuel = isFuel, food = food, upgrade = upgrade, med = med,
                            tier = info.tier, name = n, dist = math.sqrt(d2), pos = pos}
                    end
                end
            end
        end
    end
    seeded = true
    table.sort(list, function(x, y) return x.dist < y.dist end)
    return list
end

-- The backpack Tool in hand (the game binds F to storing only while it is equipped).
local function backpackInHand(char)
    -- Owner 2026-11-18: label said "Hold your Backpack" while it was held; also ask by name in case the list missed it.
    -- Owner: a held tool sits in Workspace.Characters.<name>, an unequipped one in Players.<name>.Backpack.
    local chars = workspace:FindFirstChild("Characters")
    for _, model in ipairs({char, chars and chars:FindFirstChild(LocalPlayer.Name)}) do
        local direct = model and model:FindFirstChild("Backpack")
        if direct and direct.ClassName == "Tool" then return true end
    end
    for _, c in ipairs(char:GetChildren()) do
        if c.ClassName == "Tool" then
            local ok, t = pcall(function() return c:GetAttribute("ToolType") end)
            if (ok and t == "Backpack") or string.find(string.lower(c.Name), "backpack", 1, true) then return true end
        end
    end
    return false
end
local function speedOf(hrp)
    local ok, v = pcall(function() return hrp.AssemblyLinearVelocity end)
    if not (ok and typeof(v) == "Vector3") then return 0 end
    return math.sqrt(v.X*v.X + v.Z*v.Z)
end
local function fmt(x) return string.format("%.1f", x) end
local diagLogged = 0

-- Game events for the freeze hunt (owner: freezes seem to come with map expansion / big waves): workspace attributes
-- the game's own scripts watch, logged as "Event:" when they change (first line = all of them), checked once a second.
local EVENT_ATTRS = {"CurrentDay", "Night", "WaveActive", "BloodMoon", "GeneratorLevel", "ForcefieldRadius",
    "LastStand", "BanditRaid", "HostileBrainwash", "Infection", "EmeraldRain", "Blizzard", "Raining", "GameOver"}
local lastEvents, eventTime = {}, 0
local function logEvents()
    local now = os.clock()
    if now - eventTime < 1.0 then return end
    eventTime = now
    local changed = {}
    for _, k in ipairs(EVENT_ATTRS) do
        local ok, v = pcall(function() return workspace:GetAttribute(k) end)
        if ok and type(v) == "number" then v = math.floor(v + 0.5) end  -- ForcefieldRadius may tween: whole studs
        v = ok and tostring(v) or "?"
        if v ~= lastEvents[k] then lastEvents[k] = v; changed[#changed+1] = k .. "=" .. v end
    end
    if #changed > 0 then log("Event: " .. table.concat(changed, " ")) end
end

-- ===== Crates ================================================================
-- Workspace.Map.Crates holds Models named Default / Super / Emerald (attribute Rarity) with a ProximityPrompt "Prompt"
-- ("Opening Crate...", hold). Opening = that prompt (server side); Logic.CrateOpened:FireServer() in the Remote Spy is
-- only CrateClient asking for the lid state at load (decompiled 2026-11-04). The game marks each crate with an
-- attribute named after the UserId of every player who opened it, so "mine" = GetAttribute(tostring(UserId)).
-- fireproximityprompt skips the hold and the distance, so the script keeps to a player's reach itself.
local CRATE_REACH, crateTime, cratePos, crateDone, crateTry, opened = 9, 0, {}, {}, {}, 0
-- Crate kinds seen (Remote Spy 2026-11-04), all free to open (owner). Unknown new kinds are never opened.
local CRATE_KINDS = {Default = true, Super = true, Emerald = true, Reactor = true}
local MY_KEY = tostring(LocalPlayer.UserId)
-- True once the game marked the crate as opened by you (logs the ones this script opened).
local function crateIsDone(c, a)
    if crateDone[a] then return true end
    if attr(c, MY_KEY) == true then
        crateDone[a] = true
        if crateTry[a] then opened = opened + 1; if DEBUG_LOG then log("Crate opened: " .. tostring(c.Name)) end end
        return true
    end
    return false
end
-- Crates never move: the position is kept once read. Far crates have no MainPart yet (streaming, MCP probe
-- 2026-11-04), so a missing one is looked up again next time instead of being remembered as "no position".
local function cratePosOf(c, a)
    if not cratePos[a] then
        -- v-19a (owner: Emerald crate sometimes had no ESP): Hitbox / Lid when MainPart has not streamed in yet.
        local p
        for _, n in ipairs({"MainPart", "Hitbox", "Lid"}) do
            local ch = c:FindFirstChild(n)
            p = ch and partPos(ch)
            if p then break end
        end
        cratePos[a] = p
    end
    return cratePos[a]
end
-- " @Tier=2 @ToolType=Melee ...": tiers, tool types and Stats values (Hunger, Scrap...) live in attributes.
local function attrs(inst)
    local ok, a = pcall(function() return inst:GetAttributes() end)
    if not (ok and type(a) == "table") then return "" end
    -- Matcha returns a list of attribute NAMES ({"Tier", "ToolType", ...}, scan 01:13), not name -> value: read each.
    local s, done = {}, {}
    for k, v in pairs(a) do
        local name = type(k) == "number" and v or k
        if type(name) == "string" and not done[name] then
            done[name] = true
            local okV, val = pcall(function() return inst:GetAttribute(name) end)
            if okV and val ~= nil then s[#s+1] = "@" .. name .. "=" .. tostring(val) end  -- nil = junk name
        end
    end
    table.sort(s)
    return #s > 0 and (" " .. table.concat(s, " ")) or ""
end
local function crateStep(hrpPos)
    local now = os.clock()
    if now - crateTime < 0.2 then return end  -- 5 checks a second (owner, 2026-11-18: once a second walked past crates)
    crateTime = now
    local map = workspace:FindFirstChild("Map")
    local folder = map and map:FindFirstChild("Crates")
    if not folder then return end
    if type(fireproximityprompt) ~= "function" then alert("fireproximityprompt missing (Pro / Hybrid mode?)"); return end
    local reach = math.min(cfg.range, CRATE_REACH)
    for _, c in ipairs(folder:GetChildren()) do
        local a = tostring(c.Address) .. c.Name  -- v-20g: see the crate ESP loop
        if not crateIsDone(c, a) and CRATE_KINDS[c.Name] then
            local pos, t = cratePosOf(c, a), crateTry[a] or {n = 0, at = 0}
            local d = pos and (pos - hrpPos)
            -- Owner 2026-11-18: never give up on a crate (was 3 tries, 3 s apart, then never again); try every 0.5 s in reach.
            if d and d.X*d.X + d.Y*d.Y + d.Z*d.Z <= reach * reach and now - t.at >= 0.5 then
                local prompt = c:FindFirstChild("Prompt")
                if prompt then
                    t.n, t.at = t.n + 1, now
                    crateTry[a] = t
                    local ok, err = pcall(fireproximityprompt, prompt)
                    if not ok then alert("fireproximityprompt failed: " .. tostring(err)); return end
                    if t.n == 3 then log("Crate not opened after 3 tries (still trying): " .. tostring(c.Name)) end
                end
            end
        end
    end
end

-- ===== Power Armor parts =====================================================
-- Owner: 2 "Power Armor Arm" + 1 "Power Armor Core" (DroppedItems, ItemType "QuestItem", drag only) carried to the
-- "Military Lab" map tile unlock Power Armor. The ESP labels the parts; carrying stays by hand (moving them across the
-- map would be an item teleport). Removed on the owner's word: the "<n> studs <direction>" menu text (v-04za) and the
-- lab label (v-04zb: the map already shows the lab).
local questTime, questSeen = 0, {}
local function questStep(kids)
    local now = os.clock()
    if now - questTime < 1.0 then return end
    questTime = now
    for _, it in ipairs(kids) do
        if not questSeen[it.Address] and itemInfo(it).type == "QuestItem" then
            questSeen[it.Address] = true
            log("Quest item spotted: " .. tostring(it.Name))
        end
    end
end

-- ===== Item ESP ==============================================================
-- Owner: text labels instead of the finder pop-up, only for the kinds chosen on the menu's ESP page and within a
-- distance (Matcha's own NPC ESP config can filter neither "crates I have not opened" nor distance). The step
-- refreshes positions every 0.5 s; RenderStepped only projects them (WorldToScreen) and moves the labels.
-- Item kinds (v-04y, owner: "anything on the ground, selectable, weapons too, nuclear stuff"): an item gets the first
-- kind it matches (itemType / toolType / name part); "other" takes every item no kind above matched.
-- Colors by name (v-04zc, owner: color per kind, Super / gem crates, Refined Fuel and the quest parts green). One
-- Color3 per name, so the label code's "color changed?" check compares the same object.
local ESP_COLORS = {
    {"Green", 60, 255, 90}, {"Lime", 200, 255, 40}, {"Yellow", 255, 230, 60}, {"Orange", 255, 150, 40},
    {"Red", 255, 70, 70}, {"Pink", 255, 140, 200}, {"Purple", 200, 110, 255}, {"Blue", 80, 150, 255},
    {"Light blue", 110, 220, 255}, {"White", 255, 255, 255}, {"Grey", 170, 170, 170}, {"Violet", 150, 60, 255},
}
local ESP_COLOR_BY = {}  -- default colors by name
for _, c in ipairs(ESP_COLORS) do ESP_COLOR_BY[c[1]] = Color3.fromRGB(c[2], c[3], c[4]) end
-- v-15k (owner: organise the ESP page): kinds sorted into groups; `group` = the header shown above that kind in the menu.
-- Order still matters (first match wins): nuclear and refined before fuel, chosen ammo before other ammo, Battery
-- Packs before good scrap, bandage / medkit before other medical.
local AMMO_NAMES = {"Pistol Ammo", "Medium Ammo", "Long Ammo", "Shells"}  -- names seen in apoc_scan.txt
local ESP_KINDS = {
    {key = "armor", label = "Power Armor parts (Arms, Core)", on = true,  color = "Green", itemType = "QuestItem", group = "Places & quests"},
    -- v-15e (owner): ONE crate toggle for every kind (Default, Super, Emerald, Reactor...), any distance, not opened yet.
    {key = "crate", label = "Crates (not opened yet)", on = true, color = "Yellow"},
    -- v-20h (owner): Emerald crates hold the currency, so they get their own toggle, apart from other crates.
    {key = "emeraldcrate", label = "Emerald Crates (not opened yet, any distance)", on = true, color = "Green"},
    {key = "upgrader", label = "Weapon Upgrader (any distance)", on = true, color = "Orange"},
    -- v-15k (owner): "Blood Trial", world name unknown (only PlayerGui.Main.BloodTrial and the player attribute
    -- BloodTrialEligible were scanned). Any Map / Map.Tiles / workspace child whose name has "blood" gets the dot.
    {key = "bloodtrial", label = "Blood Trial (any distance)", on = true, color = "Red"},
    -- v-21a (owner): the game's top-of-screen message says when these can be raided; the label keeps it on screen.
    {key = "military", label = "Military Base (when raidable, any distance)", on = true, color = "Pink"},
    {key = "nuclearraid", label = "Nuclear Reactor (text, any distance)", on = true, color = "Violet"},
    -- v-19a (owner): broken vehicles (Structures.<name>, attribute Dead = true until repaired) and survivors not
    -- rescued yet, as text, any distance. A repaired vehicle / rescued survivor loses its label.
    {key = "vehicle", label = "Broken vehicles (pick below, any distance)", on = true, color = "Orange"},
    {key = "survivor", label = "Survivors (not rescued yet, any distance)", on = true, color = "Light blue"},
    -- v-22r (owner): the Military Turret ITEM on the ground (blueprint you pick up with E), not placed turrets.
    -- Endless and normal games, violet, any distance while loaded.
    {key = "milturret", label = "Military Turret item (text, any distance)", on = true, color = "Violet", exact = "military turret"},
    -- v-20c (owner: admins run events where gems rain from the sky): gems on the ground, off by default. Not hidden
    -- while Auto Pickup takes gems, since raining gems land far outside pickup reach.
    {key = "gem",   label = "Gems / Emeralds (on the ground)",  on = false, color = "Green",  names = {"emerald", "gem"}, group = "Gems"},
    {key = "gun",   label = "Guns",                           on = false, color = "Red",    toolType = "Gun", group = "Weapons"},
    {key = "melee", label = "Melee weapons",                  on = false, color = "Orange", toolType = "Melee"},
    {key = "throw", label = "Throwables (grenades, molotovs, flashbangs)", on = false, color = "Orange", toolType = "Throwable"},
    -- v-15k (owner): the old "Pistol ammo" kind; the menu's dropdown picks which ammo (saved key stays pistolammo).
    {key = "pistolammo", label = "Chosen ammo (dropdown below)", on = true, color = "Yellow", names = {"pistol ammo"}, group = "Ammo"},
    {key = "ammo",  label = "Ammo (other kinds)",             on = false, color = "Yellow", itemType = "Ammo"},
    -- v-14a: split (owner). Bandage / Medkit show only while you hold fewer than the limit, and not while Auto Pickup
    -- takes them.
    {key = "bandage", label = "Bandages (when you have less than the limit)", on = true, color = "Pink", names = {"bandage"}, group = "Medical"},
    {key = "medkit",  label = "Medkits (when you have less than the limit)",  on = true, color = "Red",  names = {"medkit"}},
    {key = "compound", label = "Compounds",                   on = false, color = "Purple", names = {"compound"}},
    {key = "med",   label = "Other medical",                  on = false, color = "Pink",   toolType = "Medical"},
    {key = "nuclear", label = "Nuclear (rods, nuclear fuel, reactor parts)", on = true, color = "Lime",
        names = {"nuclear", "reactor", "uranium", "radioactive"}, group = "Fuel & power"},
    {key = "refined", label = "Refined Fuel",                 on = true,  color = "Green", names = {"refined"}},
    {key = "fuel",  label = "Fuel (other kinds)",             on = false, color = "Blue",   itemType = "Fuel"},
    {key = "battpack", label = "Battery Packs",              on = false, color = "Orange", names = {"battery pack"}},
    {key = "battery", label = "Batteries",                    on = false, color = "Yellow", names = {"battery"}},
    -- v-14a: Tier 2+ resources (Bucket, Dumbell...) give more metal; scan: Scrap / Tray / Spatula are Tier 1.
    -- v-16f (owner: AC = Aircon model, 3 scrap, "epic" scrap; wants it violet). Exact name, so "Stack" never matches.
    {key = "epicscrap", label = "Epic scrap (AC, 3 scrap, any distance)", on = true, color = "Violet", exact = "ac", group = "Scrap"},
    {key = "goodscrap", label = "Good scrap (2+ scrap: the names in the box above)", on = true, color = "Green",
        itemType = "Resource", goodScrap = true},
    {key = "scrap", label = "Scrap",                          on = false, color = "Grey",   names = {"scrap"}},
    {key = "res",   label = "Other resources (Screws, Tray...)", on = false, color = "White", itemType = "Resource"},
    {key = "wear",  label = "Wearables (armor, gas masks, backpacks)",    on = false, color = "Purple",
        itemType = "Armor", itemType2 = "GasMask", names = {"backpack"}, group = "Gear, food, other"},
    {key = "food",  label = "Food & drinks",                  on = false, color = "Light blue", itemType = "Food"},
    {key = "other", label = "Everything else (car parts, blueprints, keycards...)", on = false, color = "White"},
}
-- v-04zd: Matcha's ColorPicker (a swatch on the toggle's line; owner: the color dropdowns made the page too long).
local espColor3 = {}  -- kind key -> Color3 in use, rebuilt when the picker changes it
local function espColorOf(kind)
    local c = espColor3[kind.key]
    if not c then
        local v = cfg.espColor[kind.key]
        c = (type(v) == "table" and tonumber(v[1]) and Color3.new(v[1], v[2], v[3])) or ESP_COLOR_BY[kind.color]
        espColor3[kind.key] = c
    end
    return c
end
-- v-18u (owner: colour still would not change): read a picker value without trusting typeof. Accepts a Color3-like
-- object (.R .G .B), a {r, g, b} table or three numbers; 0-255 values are scaled to 0-1.
local function pickerRGB(v, g, b)
    local r
    if type(v) == "number" then r = v
    elseif type(v) == "table" and tonumber(v[1]) then r, g, b = v[1], v[2], v[3]
    elseif v ~= nil then
        local ok, R, G, B = pcall(function() return v.R, v.G, v.B end)
        if ok then r, g, b = R, G, B end
    end
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if not (r and g and b) then return nil end
    if r > 1 or g > 1 or b > 1 then r, g, b = r / 255, g / 255, b / 255 end
    return r, g, b
end
local function setEspColor(key, r, g, b)
    cfg.espColor[key] = {r, g, b}
    espColor3[key] = Color3.new(r, g, b)
end
-- Kind of a dropped item, or nil for crates-only kinds; never nil for an item ("other" is the catch-all).
local function isGoodScrap(lower)
    for w in string.gmatch(string.lower(cfg.goodScrap or ""), "[^,]+") do
        w = string.match(w, "^%s*(.-)%s*$")
        -- Names of 1-2 letters ("ac", "tv") must be a whole word, or "ac" would match "Stack" or "Rack".
        if #w > 2 and string.find(lower, w, 1, true) then return true end
        if w ~= "" and #w <= 2 and string.find(" " .. lower .. " ", "[^%w]" .. w:gsub("%p", "%%%0") .. "[^%w]") then
            return true
        end
    end
    return false
end
local function espKindOf(it, info)
    local lower = string.lower(tostring(it.Name))
    for _, k in ipairs(ESP_KINDS) do
        if k.exact then
            if lower == k.exact then return k end
        elseif k.goodScrap then
            if info.type == k.itemType and isGoodScrap(lower) then return k end
        elseif k.itemType or k.toolType or k.names then
            if (k.itemType and (info.type == k.itemType or (k.itemType2 and info.type == k.itemType2)))
                or (k.toolType and info.toolType == k.toolType) then return k end
            for _, n in ipairs(k.names or {}) do
                if string.find(lower, n, 1, true) then return k end
            end
        end
    end
    return ESP_KINDS[#ESP_KINDS]
end
do
    local ok = try(function()
        local function k(name, t, tt, tier) return espKindOf({Name = name}, {type = t, toolType = tt, tier = tier or 1}).key end
        assert(k("Bandage", nil, "Medical") == "bandage" and k("Medkit", nil, "Medical") == "medkit")
        assert(k("Military Turret", "Structure") == "milturret" and k("Turret", "Structure") ~= "milturret")
        assert(k("Exhaust Pipe", "Resource", nil, 2) == "res" and k("Battery Pack", "Resource", nil, 2) == "battpack")
        assert(k("Bucket", "Resource", nil, 2) == "res" and k("Dumbell", "Resource", nil, 2) == "res")
        assert(k("AC", "Resource", nil, 3) == "epicscrap" and k("TV", "Resource", nil, 2) == "goodscrap")
        assert(k("Stack", "Resource", nil, 1) == "res")
        assert(k("Nuclear Rod") == "nuclear" and k("nuclear fuel", "Fuel") == "nuclear" and k("Fuel", "Fuel") == "fuel")
        assert(k("Refined Fuel", "Fuel") == "refined")
        assert(k("Pistol Ammo", "Ammo") == "pistolammo" and k("Long Ammo", "Ammo") == "ammo")
        assert(k("Uranium Fuel", "Fuel") == "nuclear" and k("Medkit", nil, "Medical") ~= "med")
        assert(k("Battery Pack", "Resource") == "battpack" and k("Battery", "Resource") == "battery")
        assert(k("Scrap", "Resource") == "scrap" and k("Screws", "Resource") == "res")
        assert(k("AK-47", nil, "Gun") == "gun" and k("Good Backpack") == "wear" and k("Compound I") == "compound")
        assert(k("Power Armor Arm", "QuestItem") == "armor" and k("Bear Trap", nil, "Blueprint") == "other")
    end)
    if not ok then alert("ESP self-check failed") end
end
-- v-24e (owner, game79 by eye): crate @Tier = rarity and outline colour. T5 Legendary (yellow) is a guess, not seen yet.
local CRATE_RARITY = {
    {key = "crate_t1", name = "Common",    color = "White"},
    {key = "crate_t2", name = "Uncommon",  color = "Green"},
    {key = "crate_t3", name = "Rare",      color = "Blue"},
    {key = "crate_t4", name = "Epic",      color = "Violet"},
    {key = "crate_t5", name = "Legendary", color = "Yellow"},
}
local CRATE_RARITY_NAMES = {}
for i, r in ipairs(CRATE_RARITY) do CRATE_RARITY_NAMES[i] = r.name end
local ESP_BY = {}
local function setEspAmmo(i)
    cfg.espAmmo = math.clamp(math.floor(tonumber(i) or 0), 0, #AMMO_NAMES - 1)
    for _, k in ipairs(ESP_KINDS) do
        if k.key == "pistolammo" then k.names = {string.lower(AMMO_NAMES[cfg.espAmmo + 1])} end
    end
end
for _, k in ipairs(ESP_KINDS) do
    ESP_BY[k.key] = k
    if cfg.esp[k.key] == nil then cfg.esp[k.key] = k.on end
end
setEspAmmo(cfg.espAmmo)
-- v-19a: names seen in Workspace.Structures (vehicle dump 2026-11-18); the last entry = every one of them.
local VEHICLE_NAMES = {"Truck", "Car1", "Car2", "All vehicles"}
local function vehicleWanted(name)
    local pick = VEHICLE_NAMES[(cfg.espVehicle or 0) + 1] or "Truck"
    if pick == "All vehicles" then
        for i = 1, #VEHICLE_NAMES - 1 do if VEHICLE_NAMES[i] == name then return true end end
        return false
    end
    return name == pick
end
do
    local saved = cfg.espVehicle
    local ok = try(function()
        cfg.espVehicle = 0; assert(vehicleWanted("Truck") and not vehicleWanted("Car1") and not vehicleWanted("Fence"))
        cfg.espVehicle = 3; assert(vehicleWanted("Car2") and not vehicleWanted("All vehicles"))
    end)
    cfg.espVehicle = saved
    if not ok then alert("Vehicle ESP self-check failed") end
end
-- v-20b (owner, Explorer screenshot): survivors waiting to be recruited are the Models in Workspace.Map.Survivors
-- (each has a TakeZone where you drop what it asks for); a recruited one leaves that folder for Characters.
-- v-15d: the Upgrader is at a known path (owner's Remote Spy: Map.Tiles.Upgrader.WeaponUpgrader.Use). Label on the
-- WeaponUpgrader machine, plus an orange 3D box around the whole Upgrader building (axis-aligned, from its parts).
-- v-15c found the Model but no part position, so a diagnostic line is logged once if it has no readable part.
local upBox = {next = 0, min = nil, max = nil, label = nil, machine = nil, diag = false, lines = {}}
local function isPartClass(cn) return PART_CLASSES[cn] or (type(cn) == "string" and string.find(cn, "Part", 1, true) ~= nil) end
local function upgraderRefresh()
    local now = os.clock()
    if now < upBox.next then return end
    upBox.next = now + (upBox.min and 30 or 2)  -- v-15e: the building does not move; re-read rarely once found
    local map = workspace:FindFirstChild("Map")
    local tiles = map and map:FindFirstChild("Tiles")
    local up = tiles and tiles:FindFirstChild("Upgrader")
    -- v-15h (owner: no Upgrader box; logs game34/35 "0 parts (Folder=1)"): the building's parts exist on the client only
    -- while the game streams them in (you nearby). The building never moves, so once seen it is kept for the whole
    -- match, and every later read only grows the box (parts stream in a few at a time).
    if not up then return end
    local ok, all = pcall(function() return up:GetDescendants() end)
    local mn, mx, classes, n = upBox.min, upBox.max, {}, 0
    local had = upBox.min ~= nil
    for _, d in ipairs(ok and all or {}) do
        local okC, cn = pcall(function() return d.ClassName end)
        if okC then classes[tostring(cn)] = (classes[tostring(cn)] or 0) + 1 end
        if okC and isPartClass(cn) then
            local okP, pos, size = pcall(function() return d.Position, d.Size end)
            if okP and typeof(pos) == "Vector3" and typeof(size) == "Vector3" then
                n = n + 1
                -- component math only: Vector3 arithmetic is not proven in Matcha
                local lo = Vector3.new(pos.X - size.X / 2, pos.Y - size.Y / 2, pos.Z - size.Z / 2)
                local hi = Vector3.new(pos.X + size.X / 2, pos.Y + size.Y / 2, pos.Z + size.Z / 2)
                mn = mn and Vector3.new(math.min(mn.X, lo.X), math.min(mn.Y, lo.Y), math.min(mn.Z, lo.Z)) or lo
                mx = mx and Vector3.new(math.max(mx.X, hi.X), math.max(mx.Y, hi.Y), math.max(mx.Z, hi.Z)) or hi
                if not upBox.machine then
                    local okA, anc = pcall(function() return d.Parent.Name end)
                    if okA and anc == "WeaponUpgrader" then upBox.machine = pos end
                end
            end
        end
    end
    upBox.min, upBox.max = mn, mx
    -- Label on the machine once it exists (it may only appear after the wrench repair), else above the building.
    upBox.label = upBox.machine or (mn and Vector3.new((mn.X + mx.X) / 2, mx.Y + 2, (mn.Z + mx.Z) / 2))
    if mn and not had then
        log("Weapon Upgrader building found: " .. n .. " parts, centre " .. fmt(upBox.label.X) .. ", " .. fmt(upBox.label.Z))
    end
    if not upBox.diag then
        upBox.diag = true
        local list = {}
        for k, v in pairs(classes) do list[#list+1] = k .. "=" .. v end
        log("Weapon Upgrader: " .. n .. " parts with a position (" .. table.concat(list, " ") .. ")")
    end
end
-- v-15k: Blood Trial finder. Every 5 s: children of workspace, Map and Map.Tiles whose name has "blood" (not
-- BloodMoon); the dot goes on the first part found in it. Each new name is logged once, so the next log tells us the
-- real name. shortcut: name guess only, swap for the exact path once a log shows it.
local blood = {next = 0, list = {}}
local function bloodRefresh()
    local now = os.clock()
    if now < blood.next then return blood.list end
    blood.next = now + 5
    local list, map = {}, workspace:FindFirstChild("Map")
    local tiles = map and map:FindFirstChild("Tiles")
    for _, parent in ipairs({workspace, map, tiles}) do
        local okK, kids = pcall(function() return parent:GetChildren() end)
        for _, ch in ipairs(okK and kids or {}) do
            local name = tostring(ch.Name)
            local lower = string.lower(name)
            -- v-16c (owner screenshot = dark obelisk with red runes; scan 01:33 button): the Blood Trial is the
            -- Map.Tiles model "Cursed Totem".
            if lower == "cursed totem" or (string.find(lower, "blood", 1, true) and not string.find(lower, "moon", 1, true)) then
                local pos
                local okD, all = pcall(function() return ch:GetDescendants() end)
                for _, d in ipairs({ch, table.unpack(okD and all or {}, 1, 200)}) do
                    local okC, cn = pcall(function() return d.ClassName end)
                    if okC and isPartClass(cn) then
                        local okP, pp = pcall(function() return d.Position end)
                        if okP and typeof(pp) == "Vector3" then pos = pp; break end
                    end
                end
                if pos then list[#list+1] = pos end
            end
        end
    end
    blood.list = list
    return list
end
-- v-21a (owner): Military Base / Nuclear Reactor raid labels. The game's Popup and SmallPopup scripts (dump 101 / 140)
-- make one TextLabel per message, NAMED after its text, in PlayerGui.Popups.Popups / PlayerGui.MainUI.SmallPopups, for
-- 7-10 s. Every 0.5 s we read those names. "raidable/available" turns the label on; a done word turns it off.
-- shortcut: done words are guesses; every message naming a place is logged once, so the next log gives the real ones.
local RAID_PLACES = {
    {key = "military", tile = "Military Base", text = "MILITARY RAIDABLE", match = function(s)
        return string.find(s, "military", 1, true) and not string.find(s, "lab", 1, true)
            and not string.find(s, "keycard", 1, true) end},  -- "+ Military Keycard" is a pickup (log game45)
    {key = "nuclearraid", tile = "Nuclear Reactor", text = "NUCLEAR AVAILABLE", match = function(s)
        return string.find(s, "nuclear", 1, true) or string.find(s, "reactor", 1, true) end},
}
local RAID_ON = {"raidable", "available", "can be raided", "is open", "is ready"}
-- v-21b real messages (log game44): "<name> has opened the nuclear reactor!", "The nuclear reactor has been cleared!
-- It will open again in 15m!". The owner wants no label while it is opened, so "opened" is an OFF word.
local RAID_OFF = {"raided", "complete", "cleared", "closed", "cooldown", "destroyed", "looted", "unavailable", "captured", "opened", "started"}  -- v-21f log game46: "<name> has started the Military Base raid!"
-- v-21e (owner): messages only. The door-sign reader (v-21b..d) was removed after it misread "2m 21s" as open.
local raid = {open = {}, logged = {}, pos = {}, posNext = 0, reopenAt = {}}
local function hasAny(s, words)
    for _, w in ipairs(words) do if string.find(s, w, 1, true) then return true end end
    return false
end
-- Returns true / false / nil (nil = message names the place but says neither).
local function raidMessage(place, s)
    if not place.match(s) then return nil end
    -- v-21h (log game48: "The Military Base can be raided again!" read as OFF via "raided"): these phrases win first.
    if hasAny(s, {"can be raided", "is ready", "raidable"}) then return true end
    if hasAny(s, RAID_OFF) then return false end  -- before ON: "unavailable" holds "available"
    if hasAny(s, RAID_ON) then return true end
    return nil
end
local function raidRefresh()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local p1 = pg and pg:FindFirstChild("Popups")
    local m1 = pg and pg:FindFirstChild("MainUI")
    for _, holder in ipairs({p1 and p1:FindFirstChild("Popups"), m1 and m1:FindFirstChild("SmallPopups")}) do
        local okK, kids = pcall(function() return holder:GetChildren() end)
        for _, c in ipairs(okK and kids or {}) do
            local s = string.lower(tostring(c.Name))
            for _, place in ipairs(RAID_PLACES) do
                if place.match(s) then
                    local v = raidMessage(place, s)
                    if v ~= nil then raid.open[place.key] = v end
                    if v then raid.reopenAt[place.key] = nil end
                    local mins = tonumber(string.match(s, "again in (%d+)%s*m"))
                    if mins and not raid.reopenAt[place.key] then raid.reopenAt[place.key] = os.clock() + mins * 60 end
                    if not raid.logged[s] then
                        raid.logged[s] = true
                        log("Raid message: \"" .. tostring(c.Name) .. "\" -> " .. place.tile .. " " .. (v == nil and "unknown" or v and "ON" or "OFF"))
                    end
                end
            end
        end
    end
    -- "open again in 15m" countdown ends = open again.
    local now = os.clock()
    for _, place in ipairs(RAID_PLACES) do
        local k = place.key
        if raid.reopenAt[k] and now >= raid.reopenAt[k] then raid.reopenAt[k] = nil; raid.open[k] = true end
    end
    -- Tile spots every 5 s (tiles can stream in late); first part in the tile, like the Blood Trial dot.
    if now < raid.posNext then return end
    raid.posNext = now + 5
    local map = workspace:FindFirstChild("Map")
    local tiles = map and map:FindFirstChild("Tiles")
    for _, place in ipairs(RAID_PLACES) do
        local t = not raid.pos[place.key] and tiles and tiles:FindFirstChild(place.tile)
        local okD, all = pcall(function() return t:GetDescendants() end)
        for _, d in ipairs(okD and all or {}) do
            local okC, cn = pcall(function() return d.ClassName end)
            if okC and isPartClass(cn) then
                local okP, pp = pcall(function() return d.Position end)
                if okP and typeof(pp) == "Vector3" then raid.pos[place.key] = pp; break end
            end
        end
    end
end
do
    local ok = try(function()
        local m, n = RAID_PLACES[1], RAID_PLACES[2]
        assert(raidMessage(m, "military base is raidable!") == true and raidMessage(n, "nuclear reactor is available") == true)
        assert(raidMessage(n, "nuclear reactor is unavailable") == false and raidMessage(m, "military base has been raided") == false)
        assert(raidMessage(m, "military lab unlocked") == nil and raidMessage(n, "military base is raidable") == nil)
        assert(raidMessage(n, "deadeyezjhin has opened the nuclear reactor!") == false)
        assert(raidMessage(n, "the nuclear reactor is ready!") == true)
        assert(raidMessage(m, "deadeyezjhin opened the military zone!") == false)
        assert(raidMessage(m, "the military base can be raided again!") == true)
        assert(raidMessage(m, "deadeyezjhin has started the military base raid!") == false)
        assert(raidMessage(n, "the nuclear reactor has been cleared! it will open again in 15m!") == false)
        assert(tonumber(string.match("it will open again in 15m!", "again in (%d+)%s*m")) == 15)
    end)
    if not ok then alert("Raid ESP self-check failed") end
end
-- v-15i (owner: dots only, optimise): the 12-line 3D box is gone; the Upgrader is one dot like every other kind.
local ESP_MAX = 60   -- labels at most, nearest first
local espList, espTime = {}, 0
local function raidText(place)
    local k = place.key
    local name = string.match(place.text, "^%S+")
    return (raid.open[k] and place.text)
        or (raid.reopenAt[k] and (name .. " in " .. math.ceil((raid.reopenAt[k] - os.clock()) / 60) .. "m"))
end
local function espRefresh(kids, hrpPos)
    local now = os.clock()
    if now - espTime < 0.5 then return end
    espTime = now
    local list, max2, on = {}, cfg.espDist * cfg.espDist, cfg.esp
    local function add(pos, text, kind, always, anyDist)
        local dx, dy, dz = pos.X - hrpPos.X, pos.Y - hrpPos.Y, pos.Z - hrpPos.Z
        local d2 = dx*dx + dy*dy + dz*dz
        if always or anyDist or d2 <= max2 then
            list[#list+1] = {pos = pos, text = text, color = espColorOf(kind), d2 = always and 0 or d2}
        end
    end
    local anyItem = true  -- Battery Packs are always labelled (owner, v-14e), so the item pass always runs
    for _, k in ipairs(ESP_KINDS) do
        if on[k.key] and k.key ~= "crate" then anyItem = true end
    end
    -- v-14a hide rules (owner): what Auto Pickup takes or stores gets no label (not fuel); fuel none from fuelStopDay on;
    -- Power Armor parts none once Power Armor is worn (character attribute Armor).
    local auto = cfg.enabled
    local late = lateGame()
    local c = LocalPlayer.Character
    local powerOn = c and attr(c, "Armor") == "Power Armor"
    local hide = {
        armor = powerOn, fuel = late, refined = late,  -- fuel (v-14b) and batteries (v-14h) show even while stored (owner)
        bandage = auto and cfg.pick.bandage,
        medkit = auto and cfg.pick.medkit,
        scrap = auto and cfg.scrap, res = auto and cfg.scrap,
    }
    if anyItem then
        for _, it in ipairs(kids) do
            local info = itemInfo(it)
            info.esp = info.esp or espKindOf(it, info)
            local kind = info.esp
            local hidden = hide[kind.key]  -- v-20i: nuclear fuel keeps its label on late days (it is still collected)
            local always = kind.key == "battpack"  -- owner: Battery Packs any time, any distance
            if (on[kind.key] or always) and not hidden then
                local p = itemPart(it)
                local pos = p and partPos(p)
                -- v-22q (owner): AC at any distance while loaded, and kept even when 60 nearer labels fill the list.
                local mt = kind.key == "milturret"
                -- v-24n (owner): Battery Packs get text too, like the Military Turret.
                local txt = (mt and "MILITARY TURRET") or (always and "BATTERY PACK") or nil
                if pos then add(pos, txt, kind, always or kind.key == "epicscrap" or mt) end
            end
        end
    end
    if on.upgrader then
        upgraderRefresh()
        if upBox.label then add(upBox.label, nil, ESP_BY.upgrader, true) end
    end
    if on.bloodtrial then
        for _, pos in ipairs(bloodRefresh()) do add(pos, nil, ESP_BY.bloodtrial, true) end
    end
    if on.military or on.nuclearraid then
        raidRefresh()
        for _, place in ipairs(RAID_PLACES) do
            local k, pos = place.key, raid.pos[place.key]
            -- v-23a (owner): the Nuclear Reactor always has a text label; its raid state replaces it when known.
            local text = raidText(place) or (k == "nuclearraid" and "NUCLEAR REACTOR")
            if on[k] and text and pos then add(pos, text, ESP_BY[k], true); list[#list].raid = place end
        end
    end
    if on.crate or on.emeraldcrate then
        local map = workspace:FindFirstChild("Map")
        local folder = map and map:FindFirstChild("Crates")
        for _, c in ipairs(folder and folder:GetChildren() or {}) do
            -- v-20g (owner: "Emerald Crate" text never showed): the key was the memory address alone, so a new
            -- Emerald crate reusing an opened crate's address was taken as already opened. Name is part of the key now.
            local a = tostring(c.Address) .. c.Name
            local emerald = c.Name == "Emerald"
            if (emerald and on.emeraldcrate or not emerald and on.crate) and not crateDone[a] and not crateIsDone(c, a) then
                local pos = cratePosOf(c, a)  -- only crates the game streamed in have a position
                -- v-19a (owner): Emerald = text "Emerald Crate", never cut by the label cap; other crates stay dots.
                -- v-24e (owner): rarity name + outline colour from @Tier ("Epic Crate", "Rare Super Crate").
                local tier = tonumber(attr(c, "Tier"))
                local rar = tier and CRATE_RARITY[tier]
                local kindName = c.Name == "Default" and "Crate" or (tostring(c.Name) .. " Crate")
                -- v-24g (owner): a Super crate drops like a T4 whatever its own tier, so no rarity word, Epic colour.
                local super = c.Name == "Super"
                if super then rar = CRATE_RARITY[4] end
                local txt = emerald and "Emerald Crate" or (super and "Super Crate")
                    or (rar and (rar.name .. " " .. kindName)) or (kindName .. " T" .. tostring(tier))
                -- v-24f (owner): Super crates always show, whatever their tier.
                local wanted = emerald or super or not rar or tier > (cfg.crateMinTier or 0)
                if pos and wanted then
                    add(pos, txt, emerald and ESP_BY.emeraldcrate or rar or ESP_BY.crate, emerald, true)
                end
            end
        end
    end
    if on.vehicle then
        local st = workspace:FindFirstChild("Structures")
        for _, v in ipairs(st and st:GetChildren() or {}) do
            if vehicleWanted(v.Name) and attr(v, "Dead") == true then
                local p = v:FindFirstChild("MainHitbox") or v:FindFirstChild("DriveSeat") or v:FindFirstChild("Body")
                local pos = p and partPos(p)
                if pos then add(pos, string.upper(tostring(v.Name)), ESP_BY.vehicle, true) end
            end
        end
    end
    if on.survivor then
        local map = workspace:FindFirstChild("Map")
        local folder = map and map:FindFirstChild("Survivors")
        for _, m in ipairs(folder and folder:GetChildren() or {}) do
            local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChild("TakeZone")
            local pos = p and partPos(p)
            if pos then add(pos, "SURVIVOR", ESP_BY.survivor, true) end
        end
    end
    table.sort(list, function(x, y) return x.d2 < y.d2 end)
    for i = ESP_MAX + 1, #list do list[i] = nil end
    espList = list
end

local DOT = 6
local espDraw = {}   -- slot -> {d = Drawing Square dot, color, vis}: properties are written only when they change
local espText = {}   -- v-19a: slot -> {d = Drawing Text, text, color, vis}, same rule
-- v-15e (owner: ESP made Auto Pickup slow and Matcha's CPU / RAM high): labels and the Upgrader box are redrawn 30
-- times a second instead of every frame, and a label's Position is written only when it moved a pixel or more.
local espRenderNext = 0
local offLabel = nil  -- v-15k: "Auto Loot is Off" under the crosshair (screen centre) while Auto Pickup is off
-- v-17b (owner: "why is auto loot not working?"): while on, the same label says why loot is waiting (pickupStep sets it).
local lootHint = nil
local labelLogged = {}
local function offLabelRender()
    local text = (not cfg.enabled and "Auto Loot is Off") or lootHint
    local show = text ~= nil and not LOBBY and IS_PRO
    if show and not offLabel then
        offLabel = Drawing.new("Text")
        offLabel.Center, offLabel.Outline, offLabel.Size = true, true, 16
    end
    if not offLabel then return end
    if show then
        if offLabel.Text ~= text then
            offLabel.Text = text
            -- v-17d: each text logged once per run (names flipping between two bag items wrote a line each time)
            if not labelLogged[text] then labelLogged[text] = true; log("Loot label: " .. text) end
            offLabel.Color = cfg.enabled and Color3.fromRGB(255, 200, 60) or Color3.fromRGB(255, 70, 70)
        end
        local cam = workspace.CurrentCamera
        local vs = cam and cam.ViewportSize
        if vs then offLabel.Position = Vector2.new(vs.X / 2, vs.Y / 2 + 40) end
    end
    if offLabel.Visible ~= show then offLabel.Visible = show end
end
local function espRender()
    local now = os.clock()
    if now < espRenderNext then return end
    espRenderNext = now + 1 / 30
    pcall(offLabelRender)
    local shown, shownT = 0, 0
    if cfg.espOn then  -- v-22h (owner): ESP shows during Kill Aura too
        for _, e in ipairs(espList) do
            local sp, onScreen = WorldToScreen(e.pos)
            if onScreen and e.text then
                -- v-19a (owner): plain text instead of the dot for Emerald crates, vehicles and survivors.
                shownT = shownT + 1
                local s = espText[shownT]
                if not s then
                    local d = Drawing.new("Text")
                    d.Center, d.Outline, d.Size = true, true, 15
                    s = {d = d}
                    espText[shownT] = s
                end
                if s.text ~= e.text then s.text = e.text; s.d.Text = e.text end
                if s.color ~= e.color then s.color = e.color; s.d.Color = e.color end
                if not s.x or math.abs(sp.X - s.x) >= 1 or math.abs(sp.Y - s.y) >= 1 then
                    s.x, s.y = sp.X, sp.Y
                    s.d.Position = Vector2.new(sp.X, sp.Y - 8)
                end
                if not s.vis then s.vis = true; s.d.Visible = true end
            elseif onScreen then
                shown = shown + 1
                local s = espDraw[shown]
                if not s then
                    -- v-15i (owner): a filled 6 px Square dot per item, colour = its kind; no name, no distance (cheaper
                    -- than Text). Square, not Circle: Matcha's docs list Square's Size / Filled, not Circle's props.
                    local d = Drawing.new("Square")
                    d.Size, d.Filled = Vector2.new(DOT, DOT), true
                    s = {d = d}
                    espDraw[shown] = s
                end
                if s.color ~= e.color then s.color = e.color; s.d.Color = e.color end
                if not s.x or math.abs(sp.X - s.x) >= 1 or math.abs(sp.Y - s.y) >= 1 then
                    s.x, s.y = sp.X, sp.Y
                    s.d.Position = Vector2.new(sp.X - DOT / 2, sp.Y - DOT / 2)  -- Square Position = top-left
                end
                if not s.vis then s.vis = true; s.d.Visible = true end
            end
        end
    end
    for i = shown + 1, #espDraw do
        local s = espDraw[i]
        if s.vis then s.vis = false; s.d.Visible = false end
    end
    for i = shownT + 1, #espText do
        local s = espText[i]
        if s.vis then s.vis = false; s.d.Visible = false end
    end
end

local lastKids = 0  -- DroppedItems count, for the Status line
-- Test log (owner 2026-11-18: loot refused near hordes / other players): what was within 8 studs of a refused item,
-- and whether the item was still moving (loot flying out of a crate is refused until it lands).
local function blockersAt(it)
    local p = itemPart(it)
    local pos = p and partPos(p)
    if not pos then return " (no item position)" end
    local mine, playerChars = LocalPlayer.Character, {}
    local players = 0
    local function near(m)
        local r = m and m:FindFirstChild("HumanoidRootPart")
        local q = r and partPos(r)
        if not q then return false end
        local d = q - pos
        return d.X*d.X + d.Y*d.Y + d.Z*d.Z <= 64
    end
    for _, pl in ipairs(Players:GetPlayers()) do
        local c = pl.Character
        if c then
            playerChars[c.Address] = true
            if c ~= mine and near(c) then players = players + 1 end
        end
    end
    local zombies = 0
    local folder = workspace:FindFirstChild("Characters")
    for _, m in ipairs(folder and folder:GetChildren() or {}) do
        if not playerChars[m.Address] and near(m) then zombies = zombies + 1 end
    end
    local okV, v = pcall(function() return p.AssemblyLinearVelocity end)
    local itemSpeed = (okV and typeof(v) == "Vector3") and math.sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z) or 0
    local h = mine and mine:FindFirstChild("HumanoidRootPart")
    local hp = h and partPos(h)
    return " zombiesNear=" .. zombies .. " playersNear=" .. players .. " itemSpeed=" .. fmt(itemSpeed)
        .. " heightDiff=" .. (hp and fmt(pos.Y - hp.Y) or "?")
end

local function pickupStep()
    crumb("main", "pickup events")
    if DEBUG_LOG then logEvents() end  -- owner 2026-11-18: routine, debug only (also skips the 14 attribute reads a second)
    crumb("main", "pickup list items")
    local folder = workspace:FindFirstChild("DroppedItems")
    if not folder then return end
    local kids = folder:GetChildren()
    lastKids = #kids
    crumb("main", "pickup results")
    -- Results of the last messages: an item gone from DroppedItems was taken / stored. Checked by address, so a
    -- stored (destroyed) item is never read again: reading gone items is the main suspect for the Matcha freezes
    -- (big waves = lots of loot destroyed; the hitbox alone ran 200+ zombies fine, owner).
    local present = {}
    for _, it in ipairs(kids) do present[it.Address] = true end
    -- Forget everything about items that are gone, every tick: an unstored item can come back at the same address, and
    -- its old cached part then gave the old position, so it was only taken after walking away (cache pruned per 10 s).
    for a in pairs(partCache) do if not present[a] then partCache[a] = nil end end
    for a in pairs(infoCache) do if not present[a] then infoCache[a] = nil end end
    for a in pairs(seen) do if not present[a] then seen[a] = nil end end
    for a, p in pairs(pending) do
        if not present[a] then
            -- v-24a (owner): log every Military Turret pickup, to learn where they drop (Endless).
            if p.name == "military turret" then
                log("Military Turret picked up at " .. (p.pos and (fmt(p.pos.X) .. ", " .. fmt(p.pos.Y) .. ", " .. fmt(p.pos.Z)) or "?")
                    .. " dist=" .. fmt(p.dist) .. " try=" .. p.try)
            end
            if p.bag then stored = stored + 1; storedBefore[a] = true
            elseif p.food then ate = ate + 1 else picked = picked + 1 end
            if p.food then
                if DEBUG_LOG then log("Ate: " .. p.name .. " food=" .. fmt(p.food) .. " hunger before=" .. fmt(p.hunger)) end
            elseif p.up then
                log("Upgrade taken: " .. p.name .. " (" .. p.up .. ")")
            elseif diagLogged < 30 then
                diagLogged = diagLogged + 1
                if DEBUG_LOG then log("Taken: " .. p.name .. " dist=" .. fmt(p.dist) .. " speed=" .. fmt(p.speed) .. " try=" .. p.try) end
            end
            tries[a] = nil
            pending[a] = nil
        elseif os.clock() - p.sent > 3 then
            pending[a] = nil  -- still on the ground long after the last message: not taken
        end
    end

    do
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        -- Logs "Quest item spotted" once per Power Armor part.
        if h and cfg.espOn and cfg.esp.armor then
            crumb("main", "pickup finder"); questStep(kids)
        end
        if h and cfg.espOn then crumb("main", "pickup esp"); espRefresh(kids, h.Position) end
    end

    -- v-17b (owner): switching Auto Loot or Kill Aura starts the pickup fresh: items it gave up on are tried again.
    local state = tostring(cfg.enabled) .. tostring(_G.HBX_AURA_ON == true)
    if state ~= lootState then
        lootState = state
        tries, pending = {}, {}
        log("Auto Loot fresh start: on=" .. tostring(cfg.enabled) .. " killAura=" .. tostring(_G.HBX_AURA_ON == true))
    end
    lootHint = nil
    if not cfg.enabled then return end
    local char   = LocalPlayer.Character
    local hrp    = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- v-14a: the range slider alone (was capped at 12 + DragRange; owner: the mouse grabs from further and through
    -- walls). Too far for the server shows as "Not taken after 3 tries" in the log.
    local reach = cfg.range

    -- No shrink while moving: v-f test, 21 fuel + 5 ammo all taken on the 1st try, incl. speed 28.6 (the shrink to
    -- 4 studs only made running pickups slow). Speed is still logged in case items far out fail while running.
    local speed = speedOf(hrp)
    local bagInHand = backpackInHand(char)
    if IS_PRO and cfg.crates then  -- v-22f (owner): crates open during Kill Aura too
        crumb("main", "pickup crates")
        crateStep(hrp.Position)
    end

    local now = os.clock()
    -- Second half of a melee upgrade: once the better one is in the inventory (the game never lets you drop your last
    -- weapon, owner), drop the old one next to you. It is a lower tier, so this script never takes it back. While the
    -- old one is in your hand it waits and drops it as soon as you switch slot: Matcha has no EquipTool (docs), and
    -- pressing a hotbar key for you is the kind of input takeover the owner rejected.
    if swap then
        local _, tierNow = bestTool(char, "Melee")
        local okP, par = pcall(function() return swap.old.Parent end)
        if tierNow > swap.oldTier and okP and par == char then
            if not swap.waitLogged then
                swap.waitLogged = true
                log("Old melee " .. swap.oldName .. " is in your hand: it drops as soon as you switch slot")
            end
        elseif tierNow > swap.oldTier then
            local old, oldName = swap.old, swap.oldName
            swap = nil
            local rf = remote("Interaction", "DropTool")
            if okP and par == LocalPlayer:FindFirstChild("Backpack") and attr(old, "Droppable") ~= false and rf then
                local at = hrp.CFrame * CFrame.new(2, 0, -2)
                task.spawn(function()
                    local okD, err = pcall(function() rf:InvokeServer(old, at) end)
                    log(okD and ("Dropped old melee: " .. oldName) or ("Drop of old melee failed: " .. tostring(err)))
                end)
            else
                log("Old melee kept (already gone, not droppable, or no DropTool remote): " .. oldName)
            end
        elseif now > swap.untilT then
            swap = nil  -- the better one was not taken (inventory full?): keep the old one
        end
    end

    local sent = 0
    crumb("main", "pickup nearby items")
    local list = nearbyItems(kids, hrp.Position, reach * reach, bagInHand, attr(char, "WearingGasMask") == true)
    crumb("main", "pickup send")
    local armorTier, meleeTool, meleeTier, bagTier, hasWrench  -- read once per tick, only when a candidate is in reach
    for _, e in ipairs(list) do
        if sent >= 6 then break end  -- v-14h (owner: loot faster): at most 6 items per tick
        local r, hunger
        if e.upgrade == "armor" then
            armorTier = armorTier or wornArmorTier(char)
            if e.tier > armorTier and canTake(e.item) then
                r = remote("Interaction", "PickUpItem")
                armorTier = e.tier  -- one armor per tick
            end
        elseif e.upgrade == "backpack" then
            -- Owner test 2026-11-04: picking up a better bag replaces the old one, nothing drops.
            if not bagTier then local _, t = bestTool(char, "Backpack"); bagTier = bagTierOf(char, t) end
            if e.tier > bagTier and canTake(e.item) then
                r = remote("Interaction", "PickUpItem")
                bagTier = e.tier
            elseif not noTakeLogged["bag:" .. e.name] then
                -- Owner 2026-11-18: a Great Backpack (over a Good one) was never taken and nothing said why.
                noTakeLogged["bag:" .. e.name] = true
                log("Better Backpack skipped: " .. e.name .. " tier=" .. tostring(e.tier) .. " yours=" .. tostring(bagTier)
                    .. " takeable=" .. tostring(canTake(e.item)))
            end
        elseif e.upgrade == "wrench" then
            if hasWrench == nil then
                -- The Wrench is the top ProgressionItem (Tier 5 over the keycard's 4), so the best one is it if held.
                local t = bestTool(char, "ProgressionItem")
                local okN, nm = pcall(function() return t and t.Name end)
                hasWrench = okN and nm ~= nil and string.find(string.lower(tostring(nm)), "wrench", 1, true) ~= nil
            end
            if not hasWrench then
                r = remote("Interaction", "PickUpItem")
                hasWrench = true  -- one per tick, and none while one is held
            end
        elseif e.upgrade == "mask" then
            -- One try per 5 s until WearingGasMask turns true. Untested: E on a mask may only put it in the inventory.
            if now >= maskWait and canTake(e.item) then
                r = remote("Interaction", "PickUpItem")
                maskWait = now + 5
            end
        elseif e.upgrade == "melee" then
            if not meleeTier then meleeTool, meleeTier = bestTool(char, "Melee") end
            if not swap and e.tier > meleeTier then
                r = remote("Interaction", "PickUpItem")
                if meleeTool then
                    local okN, nm = pcall(function() return meleeTool.Name end)
                    swap = {old = meleeTool, oldName = okN and tostring(nm) or "?", oldTier = meleeTier, untilT = now + 3}
                end
                meleeTier = e.tier
            end
        elseif e.food then
            local okH, h = pcall(function() return char:GetAttribute("Hunger") end)
            hunger = okH and tonumber(h)
            if hunger and hunger + e.food <= MAX_HUNGER and now >= foodWait and canTake(e.item) then
                r = remote("Interaction", "PickUpItem")
                foodWait = now + 0.5  -- owner 2026-11-18: was 1 s
            end
        elseif e.claim then
            r = remote("Interaction", "PickUpItem")
        elseif e.bag then
            -- v-24s (owner: no message spam, low CPU while idle): bag items are sent only while the Backpack is in hand,
            -- no "Hold your Backpack" text.
            if bagInHand then r = remote("Tools", "AdjustBackpack") end
        elseif canTake(e.item) then
            r = remote("Interaction", "PickUpItem")
        elseif not noTakeLogged[e.name] then
            noTakeLogged[e.name] = true
            log("Not takeable with E (no CanPickUp attribute), skipped: " .. e.name)
        end
        if r then
            -- e.item is never nil here: AdjustBackpack(nil) would unstore the bag.
            local ok, err = pcall(function() r:FireServer(e.item) end)
            if not ok then alert("FireServer failed (is Hybrid mode on?): " .. tostring(err)); return end
            sent = sent + 1
            local a = e.item.Address
            local t = tries[a] or {n = 0}
            t.n = t.n + 1
            -- Owner 2026-11-18: no pause after refusals (was 3 s after the 3rd try); a refused item is sent again every
            -- 0.2 s for as long as it is in reach, so it is taken as soon as the game allows it.
            t.skipUntil = now + 0.2
            if t.n == 3 then  -- logged once per item
                failed = failed + 1
                if failed <= 40 then
                    local okB, around = pcall(blockersAt, e.item)
                    log("Not taken after 3 tries: " .. e.name .. " dist=" .. fmt(e.dist) .. " speed=" .. fmt(speed)
                        .. " bagInHand=" .. tostring(bagInHand) .. (okB and around or " (blockers: " .. tostring(around) .. ")"))
                end
                if e.bag and not fuelHintShown then
                    fuelHintShown = true
                    say("Not stored in the backpack: it may be full (10)")
                end
            end
            tries[a] = t
            pending[a] = {item = e.item, bag = e.bag, food = e.food, hunger = hunger, sent = now, name = e.name,
                dist = e.dist, speed = speed, try = t.n, up = e.upgrade and (e.upgrade .. " tier " .. e.tier),
                pos = e.pos}
        end
    end
end

-- ===== Scan for Claude =======================================================
-- C:\matcha\workspace\apoc_scan.txt: what is needed to tune this script and the hitbox's ally skip: the backpack
-- tool's name, item names and their Stats values, and how NPCs in Characters differ (allies, merchant).
local SCAN_FILE = "apoc_scan.txt"
local function valueOf(c)
    local ok, s = pcall(function()
        local v = c.Value
        if typeof(v) == "Instance" then return v:GetFullName() end
        return tostring(v)
    end)
    -- GetFullName failed on one value in the first scan ("concatenate string with nil"), probably an unparented one.
    if not ok then
        local okN, n = pcall(function() return "(" .. c.Value.Name .. ")" end)
        return okN and n or "?"
    end
    return tostring(s)  -- GetFullName can also come back nil without an error (scan failed at 01:11)
end
local function describe(inst, indent, out, depth)
    for _, c in ipairs(inst:GetChildren()) do
        local line = indent .. tostring(c.ClassName) .. " " .. tostring(c.Name) .. attrs(c)
        if string.sub(tostring(c.ClassName), -5) == "Value" then line = line .. " = " .. valueOf(c) end
        out[#out+1] = line
        if depth > 1 and #out < 3000 then describe(c, indent .. "  ", out, depth - 1) end
    end
end
local function scan()
    local out = {}
    local function add(s) out[#out+1] = s end
    local okT, t = pcall(os.date, "%H:%M:%S")
    add("Scan " .. tostring(okT and t or "") .. "  v" .. VERSION .. "  place " .. tostring(game.PlaceId))

    add("\n== Backpack (inventory tools) ==")
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then describe(bp, "  ", out, 1) else add("  (no Backpack)") end
    add("\n== Character (attributes: armor? backpack size?) and tool in hand ==")
    local char = LocalPlayer.Character
    if char then
        add("  Character" .. attrs(char))
        for _, c in ipairs(char:GetChildren()) do
            if tostring(c.ClassName) == "Tool" then add("  Tool " .. tostring(c.Name) .. attrs(c)); describe(c, "    ", out, 1)
            elseif tostring(c.ClassName) == "Accessory" or tostring(c.ClassName) == "Model" then add("  " .. tostring(c.ClassName) .. " " .. tostring(c.Name) .. attrs(c)) end
        end
    end
    add("  Player" .. attrs(LocalPlayer))

    add("\n== DroppedItems: one of each name, with its children and Stats values ==")
    local folder = workspace:FindFirstChild("DroppedItems")
    local seen = {}
    if folder then
        for _, it in ipairs(folder:GetChildren()) do
            if not seen[tostring(it.Name)] then
                seen[tostring(it.Name)] = true
                add(tostring(it.ClassName) .. " " .. tostring(it.Name) .. attrs(it))
                describe(it, "  ", out, 2)
            end
        end
    end

    add("\n== Characters: NPC kinds (same name + same children = one kind) ==")
    local chars = workspace:FindFirstChild("Characters")
    local kinds, order = {}, {}
    if chars then
        for _, m in ipairs(chars:GetChildren()) do
            if not Players:FindFirstChild(tostring(m.Name)) then
                local names = {}
                for _, c in ipairs(m:GetChildren()) do names[#names+1] = tostring(c.ClassName) .. " " .. tostring(c.Name) end
                table.sort(names)
                local key = tostring(m.Name) .. " | " .. table.concat(names, ", ")
                if not kinds[key] then kinds[key] = {n = 0, model = m}; order[#order+1] = key end
                kinds[key].n = kinds[key].n + 1
            end
        end
    end
    for _, key in ipairs(order) do
        local k = kinds[key]
        add(tostring(k.model.Name) .. " x" .. k.n)
        describe(k.model, "  ", out, 1)
        local ok, attrs = pcall(function() return k.model:GetAttributes() end)
        if ok and type(attrs) == "table" then
            -- v-14l: Matcha's GetAttributes gives a list of names (1 = "Bandit"...), not name = value: read each value.
            for name, v in pairs(attrs) do
                if type(name) == "number" then name = v; v = attr(k.model, tostring(v)) end
                add("  @" .. tostring(name) .. " = " .. tostring(v))
            end
        end
    end

    add("\n== PlayerGui (2 levels) ==")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then describe(pg, "  ", out, 2) end
    -- List every remote so a moved one (game update, new mode) can be found.
    add("\n== ReplicatedStorage (3 levels) ==")
    describe(game:GetService("ReplicatedStorage"), "  ", out, 3)

    writefile(SCAN_FILE, table.concat(out, "\n"))
    say("Scan written to " .. SCAN_FILE)
end

-- ===== Lobby: badge show-off + Auto Join =====================================
-- Remotes from the lobby dump (LobbyClient, BadgeUI) and the owner's Remote Spy, tested by Claude on 2026-11-04:
--   Remotes.Lobby.JoinLobby:InvokeServer("1"/"2"/"3")  the server moves you onto that pad (what walking onto it does)
--   Remotes.Lobby.SetPartySize:InvokeServer(1-5)      the room's creator picks the size, then a ~20 s countdown runs
--   Remotes.Lobby.LeaveLobby:InvokeServer()           the server puts you back next to the pad
--   Remotes.Badges.EquipBadge:FireServer(name)        Equip button; with no name it UNEQUIPS, so only names are sent
-- Pads = workspace.Lobbies["1".."3"], each with a BillboardGui: Count "n/m", Status "Start Game" (empty),
-- "Creating..." (creator picking the size) or a countdown "00:16". In a room = standing on its pad.
local JOIN_MODES = {"Off", "Create my own room", "Join others' rooms"}
local NO_BADGE   = "(leave it alone)"
local badgeNames = {}        -- Show Off Badge combo: NO_BADGE + the Badges menu's names
local badgesLoaded = false   -- false while badgeNames is empty or only the fallback below
local badgeSent  = nil
local badgeResync = false  -- the badge list changed: point the menu at the saved badge again (readMenu does it)
local lobbyStatus = "Auto Join: off"
local function loadBadges()
    -- BadgeUI names each button after its badge. Owned ones cannot be told apart (ImageColor3 reads nil in Matcha),
    -- so all are listed.
    local ok, sf = pcall(function() return LocalPlayer.PlayerGui.Main.Badges.ScrollingFrame end)
    if not ok or not sf then return end
    local names = {}
    for _, c in ipairs(sf:GetChildren()) do
        local n = c.Name
        if type(n) == "string" and c:FindFirstChild("Icon") then names[#names+1] = n end
    end
    if #names == 0 then return end
    table.sort(names)
    table.insert(names, 1, NO_BADGE)
    if cfg.badge ~= "" and not table.find(names, cfg.badge) then names[#names+1] = cfg.badge end
    badgeNames, badgesLoaded = names, true
    -- Owner 2026-11-25: the menu keeps a position in the list; a new list moves names around, so it is pointed at the
    -- saved badge again (else the saved badge silently became another one).
    badgeResync = true
    log("Lobby: badge list loaded (" .. (#names - 1) .. " badges)")
end

local function lobbyRooms()
    local rooms = {}
    local folder = workspace:FindFirstChild("Lobbies")
    if not folder then return rooms end
    for _, pad in ipairs(folder:GetChildren()) do
        -- Whole pad, not only the first BillboardGui: 2026-11-04 14:30 a live read found Status but no Count there.
        local count, status
        for _, d in ipairs(pad:GetDescendants()) do
            if d.Name == "Count" then count = d.Text elseif d.Name == "Status" then status = d.Text end
        end
        local n, m = string.match(tostring(count), "^(%d+)/(%d+)$")
        local pos, size = partPos(pad), pad.Size
        if n and pos and typeof(size) == "Vector3" then
            rooms[#rooms+1] = {name = tostring(pad.Name), n = tonumber(n), m = tonumber(m), status = tostring(status),
                pos = pos, half = size / 2}
        end
    end
    table.sort(rooms, function(a, b) return a.name < b.name end)
    return rooms
end

local function lobbyCall(name, arg)
    local ok, err = pcall(function() return remote("Lobby", name):InvokeServer(arg) end)
    if not ok then say("Lobby: " .. name .. " failed: " .. tostring(err)) end
    return ok
end

-- The badge being shown = the character's BadgeDisplay.BadgeName text (above the head). Sending the shown badge again
-- took it off (owner, re-execute 2026-11-04), so it is only sent when another one (or none) is shown.
local function shownBadge()
    local ch = LocalPlayer.Character
    local bd = ch and ch:FindFirstChild("BadgeDisplay")
    local label = bd and bd:FindFirstChild("BadgeName")
    return label and label.Text
end

-- Log what the join check saw, on change only, so a missed join can be explained from apoc_log.txt.
local lobbySeen = nil
local function logLobby(rooms, nPads)
    if not DEBUG_LOG then return end  -- owner 2026-11-18: routine, debug only
    local parts = {}
    for _, r in ipairs(rooms) do parts[#parts+1] = r.name .. " " .. r.n .. "/" .. r.m .. " " .. (string.gsub(r.status, "^%d+:%d+$", "counting")) end
    local s = lobbyStatus .. " | pads " .. nPads .. ", readable: " .. (#parts > 0 and table.concat(parts, ", ") or "none")
    if s ~= lobbySeen then lobbySeen = s; log("Lobby: " .. s) end
end
local lobbyStart = os.clock()
local lobbyTime, nextJoin, joinedAt, sizeSentFor, leftRoom, leftUntil = 0, 0, 0, nil, nil, 0
-- v-22g (owner): normal lobby -> teleporter -> Endless lobby; the run did not hand over (no run in the Endless lobby).
-- v-22j: it is workspace.Lobby.EternalPortal (18 parts, log lobby43); pressing it sends
-- Remotes.Misc.EternalNightTravel:InvokeServer() (owner's Remote Spy). Looked up again every 10 s until found.
local tpParts, tpNext = nil, 0
local function findTeleporters()
    local lobby = workspace:FindFirstChild("Lobby")
    local portal = lobby and lobby:FindFirstChild("EternalPortal")
    if not portal then return end
    tpParts = {}
    for _, d in ipairs(portal:GetDescendants()) do
        if partPos(d) then tpParts[#tpParts+1] = d end
    end
    log("Lobby: Eternal Night portal found (" .. #tpParts .. " parts)")
end
local farmTravelAt = 0
local function lobbyStep()
    local now = os.clock()
    if now - lobbyTime < 1.0 then return end
    lobbyTime = now
    -- Auto Farm (owner 2026-11-25): normal lobby -> Endless lobby (portal remote), there a solo room (Auto Join 1, size 1).
    local farm = EXEC_COPY and cfg.autoFarm
    local jm, ps = farm and 1 or cfg.joinMode, farm and 1 or cfg.partySize
    if farm and game.PlaceId == 90148635862803 then
        lobbyStatus = "Auto Farm: going to the Endless lobby"
        if now >= farmTravelAt then
            farmTravelAt = now + 15
            task.spawn(function()
                local ok, err = pcall(function() return remote("Misc", "EternalNightTravel"):InvokeServer() end)
                say("Auto Farm: Endless travel sent (" .. (ok and "ok" or tostring(err)) .. ")")
            end)
        end
        return
    end
    if not badgesLoaded then
        loadBadges()
        -- Owner 2026-11-04 17:33: stuck on "loading the badge list". After 10 s show the saved badge alone (keeps
        -- looking for the full list); the log says the game's badge menu was not found.
        if not badgesLoaded and #badgeNames == 0 and now - lobbyStart > 10 then
            badgeNames = {NO_BADGE}
            if cfg.badge ~= "" then badgeNames[2] = cfg.badge end
            badgeResync = true
            log("Lobby: the game's badge menu (PlayerGui.Main.Badges) was not found; showing the saved badge only")
        end
    end
    -- 5 s after start: the head display of a just-loaded character may not be there yet.
    if IS_PRO and cfg.badge ~= "" and cfg.badge ~= badgeSent and now - lobbyStart > 5 and LocalPlayer.Character then
        badgeSent = cfg.badge
        if shownBadge() == cfg.badge then
            say("Lobby: badge " .. cfg.badge .. " is already shown")
        else
            local ok, err = pcall(function() remote("Badges", "EquipBadge"):FireServer(cfg.badge) end)
            say(ok and ("Lobby: showing off badge " .. cfg.badge) or ("Badge show-off failed: " .. tostring(err)))
        end
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local me = hrp and partPos(hrp)
    local rooms, mine = lobbyRooms(), nil
    for _, r in ipairs(rooms) do
        if me and math.abs(me.X - r.pos.X) <= r.half.X and math.abs(me.Z - r.pos.Z) <= r.half.Z then mine = r end
    end
    if not mine then sizeSentFor = nil end
    if me and not tpParts and now >= tpNext then tpNext = now + 10; pcall(findTeleporters) end
    for _, p in ipairs(me and tpParts or {}) do
        local q = partPos(p)
        local d = q and (q - me)
        if not EXEC_COPY and d and d.X*d.X + d.Y*d.Y + d.Z*d.Z <= 144 then  -- 12 studs; EXEC_COPY: other executors keep running
            say("Lobby: at the teleporter (" .. tostring(p.Name) .. "), the script stops here; it starts again after the teleport")
            _G.APOC_RUN, _G.HBX_RUN = "teleport", "teleport"
            pcall(function() UI.RemoveTab("Apocalypse") end)
            return
        end
    end
    local where = mine and ("room " .. mine.name .. " " .. mine.n .. "/" .. mine.m .. " " .. mine.status) or ""
    -- Stop BEFORE the teleport, whatever the Auto Join mode: 14:50 Matcha closed and 17:03 it hung (Run did nothing,
    -- last crumb 17:03:14 "pickup menu/status") while this run still read the lobby as it was being unloaded. At 4 s
    -- left on our room's countdown (this step runs once a second) or "Teleporting...", every loop of this run stops
    -- and its tab goes; autoexec (or Run) starts a fresh run in the match. If the countdown is cancelled, the script
    -- stays stopped in the lobby: Run it again.
    local cm, cs = string.match(mine and mine.status or "", "^(%d+):(%d+)$")
    if not EXEC_COPY and mine and (string.find(mine.status, "Teleport", 1, true) or (cm and tonumber(cm) * 60 + tonumber(cs) <= 4)) then
        say("Lobby: match starts in a moment, the script stops here; it starts again in the match"
            .. " (if it does not, press Run there)")
        _G.APOC_RUN, _G.HBX_RUN = "teleport", "teleport"
        pcall(function() UI.RemoveTab("Apocalypse") end)
        return
    end
    if jm == 0 or not IS_PRO then
        lobbyStatus = "Auto Join: off" .. (mine and (" (in " .. where .. ")") or "")
        return
    end

    if mine then
        lobbyStatus = "In " .. where
        if jm == 1 then
            if mine.status == "Creating..." and sizeSentFor ~= mine.name then
                sizeSentFor = mine.name
                if lobbyCall("SetPartySize", ps) then
                    say("Lobby: created room " .. mine.name .. ", party size " .. ps)
                end
            end
        -- Join others: leave when too few players are left, or when the room emptied and we became its creator.
        -- 3 s grace after joining: the pad's count can still show the old number.
        elseif now - joinedAt > 3 and (mine.status == "Creating..." or (cfg.leaveAt > 0 and mine.n <= cfg.leaveAt)) then
            if lobbyCall("LeaveLobby") then
                say("Lobby: left " .. where)
                leftRoom, leftUntil, nextJoin = mine.name, now + 15, now + 3
            end
        end
        return
    end

    if now < nextJoin then return end
    local pick
    if jm == 1 then
        for _, r in ipairs(rooms) do
            if r.n == 0 and r.status == "Start Game" then pick = r; break end
        end
        lobbyStatus = pick and "Creating a room..." or "Waiting for a free pad"
    else
        -- Rooms counting down with space left and at least joinMin players; also more than leaveAt, or we would
        -- leave right away (join at 2/5 with "leave at 2" = 3/5 after joining). Fullest first.
        for _, r in ipairs(rooms) do
            local open = string.match(r.status, "^%d+:%d+$") and r.n < r.m and r.n >= math.max(cfg.joinMin, cfg.leaveAt)
            if open and not (r.name == leftRoom and now < leftUntil) and (not pick or r.n > pick.n) then pick = r end
        end
        lobbyStatus = pick and "Joining a room..." or "Waiting for someone's room"
        local f = workspace:FindFirstChild("Lobbies")
        logLobby(rooms, f and #f:GetChildren() or 0)
    end
    if pick then
        nextJoin, joinedAt = now + 3, now
        lobbySeen = nil
        if lobbyCall("JoinLobby", pick.name) then
            say("Lobby: joining room " .. pick.name .. " (" .. pick.n .. "/" .. pick.m .. " " .. pick.status .. ")")
        end
    end
end

-- ===== Menu ==================================================================
-- Unique widget ids per run (Matcha keeps old ids until ejected); _G.APOC_RUN stops loops of older runs.
local RUN = tostring(math.floor(tick() * 1000))
_G.APOC_RUN = RUN
local function id(name) return "apoc_" .. name .. "_" .. RUN end
local menuErrorShown = false
-- Item toggles drawn at least once: a toggle on a page never opened is not read (its value may not exist yet).
local drawnPick = {}
local function pickToggle(sec, k)
    sec:Toggle(id("pick_" .. k.key), k.label, cfg.pick[k.key])
    drawnPick[k.key] = true
end
local espDrawn = false
local pickKeyDown = false  -- L key held last step (v-15k)
local espPickSeen, espPickLogged = {}, false  -- v-18u: last picker value read per kind; callback type logged once
local function espMenu(sec)
    -- Distance first: with the slider last (v-04w) the owner could not see it under the toggles.
    sec:Toggle(id("espOn"), "Show ESP (text)", cfg.espOn)
    sec:SliderInt(id("espDist"), "ESP distance (studs)", 50, 1000, cfg.espDist)
    sec:InputText(id("goodScrap"), "Good scrap names (2+ scrap, comma list)", cfg.goodScrap)
    for _, k in ipairs(ESP_KINDS) do
        if k.group then sec:Spacing(); sec:Text("-- " .. k.group .. " --") end
        sec:Toggle(id("esp_" .. k.key), k.label, cfg.esp[k.key])
        local cur = espColorOf(k)
        sec:ColorPicker(id("espc_" .. k.key), cur.R, cur.G, cur.B, 1, function(c, ...)
            if not espPickLogged then espPickLogged = true; log("ESP colour picker callback: " .. typeof(c)) end
            local r, g, b = pickerRGB(c, ...)
            if r then setEspColor(k.key, r, g, b) end
        end)
        if k.key == "pistolammo" then sec:Combo(id("espAmmo"), "Chosen ammo", AMMO_NAMES, cfg.espAmmo) end
        if k.key == "vehicle" then sec:Combo(id("espVehicle"), "Vehicle", VEHICLE_NAMES, cfg.espVehicle) end
        if k.key == "crate" then sec:Combo(id("crateMinTier"), "Crates from rarity", CRATE_RARITY_NAMES, cfg.crateMinTier) end
    end
    espDrawn = true
end
local function lobbyMenu(sec)
    -- Owner 2026-11-18: Regular (no Pro / Hybrid off) does not see Pro-only options at all.
    if not IS_PRO then sec:Text(lobbyStatus); return end
    if #badgeNames > 0 then
        local i = table.find(badgeNames, cfg.badge ~= "" and cfg.badge or NO_BADGE) or 1
        sec:Combo(id("badgeList"), "Show Off Badge" .. PRO_TAG, badgeNames, i - 1)
    else
        sec:Text("Show Off Badge: loading the badge list...")
    end
    sec:Combo(id("join"), "Auto Join" .. PRO_TAG, JOIN_MODES, cfg.joinMode)
    sec:SliderInt(id("size"), "Party Size (own room)", 1, 5, cfg.partySize)
    sec:SliderInt(id("min"), "Min players (join rooms with at least this many)", 1, 4, cfg.joinMin)
    sec:SliderInt(id("leave"), "Leave at (leave when the room drops to this many players, 0 = never)", 0, 4, cfg.leaveAt)
    sec:Text(lobbyStatus)
end
local function drawMenu(tab)
    local ok, err = try(function()
        -- Owner 2026-11-18: in the lobby every page is there too, so settings can be set before the match.
        -- Owner 2026-11-18: Regular only sees what works without Pro: Main (Anti AFK) and ESP.
        local names = {}
        if LOBBY and IS_PRO then names[#names+1] = "Lobby" end
        names[#names+1] = "Main"
        if IS_PRO then names[#names+1] = "Items" end
        names[#names+1] = "ESP"
        -- Owner 2026-11-25: Auto Farm has its own (foldable) section with its settings. Executor copy only.
        if EXEC_COPY and IS_PRO then
            local fs = tab:Section("Auto Farm", "Right")
            fs:Toggle(id("farm"), "Auto Farm (Endless solo: loot until a Healing Pad crafts, place it at the map edge,"
                .. " stay, back to lobby on a horde or the time below, repeat)", cfg.autoFarm)
            fs:Combo(id("farmMode"), "Game mode (normal map: coming later)", {"Endless"}, cfg.farmMode)
            fs:SliderInt(id("farmMin"), "Leave after (minutes of Survived)", 5, 180, cfg.farmMin)
            -- Owner: show the game's own Survived clock (player EternalNightSurvived) so it can be checked against the
            -- screen, and how long until Auto Farm leaves.
            local surv = tonumber(attr(LocalPlayer, "EternalNightSurvived"))
            local function mmss(t) t = math.max(0, math.floor(t)); return string.format("%02d:%02d", math.floor(t / 60), t % 60) end
            local function hm(m)  -- owner: "1 hour 31 minutes"
                m = math.floor(tonumber(m) or 0)
                local h, r = math.floor(m / 60), m % 60
                local hs = h > 0 and (h .. (h == 1 and " hour" or " hours")) or ""
                local ms = (r > 0 or h == 0) and (r .. (r == 1 and " minute" or " minutes")) or ""
                return hs .. (hs ~= "" and ms ~= "" and " " or "") .. ms
            end
            if surv then
                fs:Text("Survived: " .. mmss(surv))
                local left = math.max(0, math.floor((tonumber(cfg.farmMin) or 91) * 60 - surv))
                fs:Text("Leaving in: " .. hm(left / 60) .. " " .. (left % 60) .. " s")
                fs:Text("Doing: " .. tostring(_G.APOC_FARM_DOING or "-"))
            else
                fs:Text("Survived: -- (only in an Endless match)")
            end
        end
        local sec = tab:Section(LOBBY and "Lobby" or "Auto Pickup", "Right", names)
        -- sec.page = 0-based index of the shown page; nil (no pages) shows all.
        local page = sec.page and names[sec.page + 1]
        if page == "Lobby" then lobbyMenu(sec); return end
        if page == nil and LOBBY then lobbyMenu(sec) end
        if page == "ESP" then espMenu(sec); return end
        if page == "Items" then
            for _, k in ipairs(ITEM_KINDS) do
                if not k.top then pickToggle(sec, k) end
            end
            sec:InputText(id("extra"), "Other items (name contains, comma list)", cfg.extra)
            return
        end
        sec:Toggle(id("antiAfk"), "Anti AFK (no 20 min idle kick)", cfg.antiAfk)
        if not IS_PRO then
            if page == nil then espMenu(sec) end
            return
        end
        sec:Toggle(id("on"), "Auto Pickup (L key switches it)", cfg.enabled)
        for _, k in ipairs(ITEM_KINDS) do
            if k.top then pickToggle(sec, k) end
        end
        sec:Toggle(id("mask"), "Gas Mask (take one when not wearing one)", cfg.mask)
        sec:SliderInt(id("range"), "Range (12 = safe, higher = test)", 4, 30, cfg.range)
        sec:Toggle(id("fuel"), "Store Fuel (in Backpack)", cfg.fuel)
        sec:SliderInt(id("fuelStopDay"), "Stop Fuel from day (store + ESP, 0 = never)", 0, 150, cfg.fuelStopDay)
        sec:Toggle(id("scrap"), "Store Scrap (and other resources, in Backpack)", cfg.scrap)
        sec:Toggle(id("batt"), "Store Batteries (in Backpack)", cfg.batt)
        sec:Toggle(id("battPack"), "Store Battery Packs (in Backpack)", cfg.battPack)
        sec:Toggle(id("weaponBag"), "Store weapons (every weapon in Backpack, never equip)", cfg.weaponBag)
        sec:Toggle(id("mreBag2"), "Store MREs (in Backpack, not eaten)", cfg.mreBag2)
        sec:Toggle(id("food"), "Auto eat (eat food when hungry)", cfg.food)
        sec:Toggle(id("armor"), "Better Armor only", cfg.armor)
        sec:Toggle(id("weapon"), "Better Melee (drops old)", cfg.weapon)
        sec:Toggle(id("bagUp"), "Better Backpack", cfg.bagUp)
        sec:Toggle(id("crates"), "Open Crates in reach", cfg.crates)
        if page == nil then
            for _, k in ipairs(ITEM_KINDS) do
                if not k.top then pickToggle(sec, k) end
            end
            sec:InputText(id("extra"), "Other items (name contains, comma list)", cfg.extra)
            espMenu(sec)
        end
        sec:Button("Scan Items & Inventory (debug)", function()
            task.spawn(function()
                local okS, e = try(scan)
                if not okS then alert("Scan failed: " .. tostring(e)) end
            end)
        end)
        -- Owner 2026-11-25: back to the lobby of this mode (Endless match -> Endless lobby, else the normal lobby).
        if EXEC_COPY and not LOBBY then
            sec:Button("Teleport to Lobby", function()
                local to = game.PlaceId == 80541014082159 and 80046280333935 or 90148635862803
                log("Teleport to Lobby button: place " .. to)
                pcall(function() game:GetService("TeleportService"):Teleport(to, LocalPlayer) end)
            end)
        end
    end)
    if not ok and not menuErrorShown then
        menuErrorShown = true
        alert("Menu error: " .. tostring(err))
    end
end

local function readMenu()
    -- Owner 2026-11-18: on Regular the Pro options are hidden and skipped where they run, but their saved values are
    -- kept, so turning Hybrid back on brings them back. Auto Pickup itself is not saved (always on at start).
    if not IS_PRO then cfg.enabled = false end
    -- Widgets never drawn read as nil and are skipped, so unseen settings are never touched.
    if LOBBY then
        if badgeResync then
            badgeResync = false
            pcall(UI.SetValue, id("badgeList"), (table.find(badgeNames, cfg.badge ~= "" and cfg.badge or NO_BADGE) or 1) - 1)
        end
        local v = UI.GetValue(id("badgeList"))  -- 0-based index
        if type(v) == "number" and badgeNames[v + 1] then
            cfg.badge = badgeNames[v + 1] == NO_BADGE and "" or badgeNames[v + 1]
        end
        v = UI.GetValue(id("join"));    if type(v) == "number" then cfg.joinMode = math.clamp(v, 0, 2) end
        v = UI.GetValue(id("size"));    if type(v) == "number" then cfg.partySize = v end
        -- Linked: "leave at" can never be above "join at least" (joining at N makes N+1, leaving at more than N
        -- would leave right away). The slider that moved pushes the other one.
        local min, leave = UI.GetValue(id("min")), UI.GetValue(id("leave"))
        if type(min) == "number" and type(leave) == "number" then
            if leave > min then
                if leave ~= cfg.leaveAt then min = leave else leave = min end
                UI.SetValue(id("min"), min)
                UI.SetValue(id("leave"), leave)
            end
            cfg.joinMin, cfg.leaveAt = min, leave
        end
    end
    local v = UI.GetValue(id("on"));    if type(v) == "boolean" then cfg.enabled = v end
    if not IS_PRO and cfg.enabled then
        cfg.enabled = false; pcall(UI.SetValue, id("on"), false); needsPro("Auto Pickup")
    end
    v = UI.GetValue(id("antiAfk"));     if type(v) == "boolean" then cfg.antiAfk = v end
    v = UI.GetValue(id("farm"));        if type(v) == "boolean" then cfg.autoFarm = v end
    v = UI.GetValue(id("farmMode"));    if type(v) == "number" then cfg.farmMode = v end
    v = UI.GetValue(id("farmMin"));     if type(v) == "number" then cfg.farmMin = v end
    v = UI.GetValue(id("range"));       if type(v) == "number" then cfg.range = v end
    v = UI.GetValue(id("fuel"));        if type(v) == "boolean" then cfg.fuel = v end
    v = UI.GetValue(id("mask"));        if type(v) == "boolean" then cfg.mask = v end
    v = UI.GetValue(id("fuelStopDay")); if type(v) == "number" then cfg.fuelStopDay = v end
    v = UI.GetValue(id("food"));        if type(v) == "boolean" then cfg.food = v end
    v = UI.GetValue(id("scrap"));       if type(v) == "boolean" then cfg.scrap = v end
    v = UI.GetValue(id("batt"));        if type(v) == "boolean" then cfg.batt = v end
    v = UI.GetValue(id("battPack"));    if type(v) == "boolean" then cfg.battPack = v end
    v = UI.GetValue(id("weaponBag"));   if type(v) == "boolean" then cfg.weaponBag = v end
    v = UI.GetValue(id("mreBag2"));      if type(v) == "boolean" then cfg.mreBag2 = v end
    v = UI.GetValue(id("armor"));       if type(v) == "boolean" then cfg.armor = v end
    v = UI.GetValue(id("weapon"));      if type(v) == "boolean" then cfg.weapon = v end
    v = UI.GetValue(id("bagUp"));       if type(v) == "boolean" then cfg.bagUp = v end
    v = UI.GetValue(id("crates"));      if type(v) == "boolean" then cfg.crates = v end
    if espDrawn then
        v = UI.GetValue(id("espOn"));   if type(v) == "boolean" then cfg.espOn = v end
        v = UI.GetValue(id("espDist")); if type(v) == "number" then cfg.espDist = v end
        v = UI.GetValue(id("goodScrap"))
        if type(v) == "string" and v ~= cfg.goodScrap then  -- names changed: sort every item again
            cfg.goodScrap = v
            for _, info in pairs(infoCache) do info.esp = nil end
        end
        v = UI.GetValue(id("espAmmo"))
        if type(v) == "number" and v ~= cfg.espAmmo then  -- other ammo picked: sort every item again
            setEspAmmo(v)
            for _, info in pairs(infoCache) do info.esp = nil end
        end
        v = UI.GetValue(id("espVehicle")); if type(v) == "number" then cfg.espVehicle = v end
        v = UI.GetValue(id("crateMinTier")); if type(v) == "number" then cfg.crateMinTier = v end
        for _, k in ipairs(ESP_KINDS) do
            v = UI.GetValue(id("esp_" .. k.key)); if type(v) == "boolean" then cfg.esp[k.key] = v end
            -- v-15j (owner: Upgrader colour did not change): the picker's own value too, in case its callback never
            -- fires. Color3 or {r, g, b}; written only when it differs from the colour in use.
            -- v-18u: apply the picker's value only when IT changed since the last read. Comparing it with the colour in
            -- use let a stale GetValue undo every pick the callback had just made.
            local r, g, b = pickerRGB(UI.GetValue(id("espc_" .. k.key)))
            if r then
                local seen = string.format("%.3f %.3f %.3f", r, g, b)
                if espPickSeen[k.key] and espPickSeen[k.key] ~= seen then setEspColor(k.key, r, g, b) end
                espPickSeen[k.key] = seen
            end
        end
    end
    for _, k in ipairs(ITEM_KINDS) do
        if drawnPick[k.key] then
            v = UI.GetValue(id("pick_" .. k.key)); if type(v) == "boolean" then cfg.pick[k.key] = v end
        end
    end
    v = UI.GetValue(id("extra"))
    if type(v) == "string" and v ~= cfg.extra then cfg.extra = v; setItems(v) end
end

local saveTime, lastSaved = os.clock(), nil
local function saveSettings()
    local now = os.clock()
    if now - saveTime < 3.0 then return end
    saveTime = now
    local data = {}
    for _, k in ipairs(SAVED_KEYS) do data[k] = cfg[k] end
    local ok, text = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and type(text) == "string" and text ~= lastSaved then
        lastSaved = text
        pcall(writefile, SETTINGS_FILE, text)
        log("Settings: " .. text)
    end
end

local statusTime, lastStatus = 0, nil
local function logStatus()
    local now = os.clock()
    if now - statusTime < 10.0 then return end
    statusTime = now
    local chars = workspace:FindFirstChild("Characters")
    local s = "Status: picked=" .. picked .. " bagStored=" .. stored .. " ate=" .. ate .. " crates=" .. opened .. " gaveUp=" .. failed
        .. " | world: items=" .. lastKids .. " characters=" .. (chars and #chars:GetChildren() or 0)
    if DEBUG_LOG and s ~= lastStatus then lastStatus = s; log(s) end
    -- Forget expired attempts and parts of items that are gone, so the tables do not grow all game.
    for a, t in pairs(tries) do
        if now >= t.skipUntil then tries[a] = nil end
    end
end

-- One pass: menu, settings, then the lobby part or the match part (the all-in-one build calls it from its loop).
-- v-15k Anti AFK (owner): Roblox kicks after 20 min without input. Any key or mouse button resets the timer; after
-- 14 min without one, Space is tapped once (a jump: no teleport, no speed change). Only while Roblox has focus, so the
-- key never lands in another window.
-- Owner 2026-11-18 (still kicked while AFK in the lobby): keys only count while Roblox has focus (clicks and WASD in
-- another window reset the timer before, but Roblox never saw them); wall clock (os.time) instead of os.clock; a tap
-- every 4 min (was once at 14 min). Roblox in the background cannot be helped: the tap waits until it has focus.
local afkClock = type(os.time) == "function" and os.time or os.clock
local afk = {last = afkClock(), warned = false}
local AFK_KEYS = {0x01, 0x02, 0x57, 0x41, 0x53, 0x44, 0x20}  -- mouse L / R, W A S D, Space
-- Lobby test 2026-11-18: focus is read right; the tap fires the moment Roblox is focused again; Roblox in the
-- background for 20 min WAS kicked (no way to press keys into an unfocused window).
local function antiAfkStep()
    local now = afkClock()
    _G.APOC_ANTIAFK = cfg.antiAfk  -- the other-executor copy's background Anti AFK follows the same toggle
    local focused = not isrbxactive or isrbxactive()
    if focused then
        for _, k in ipairs(AFK_KEYS) do
            if iskeypressed(k) then afk.last = now; afk.warned = false; return end
        end
    end
    if not cfg.antiAfk or now - afk.last < 240 then return end
    if not focused then
        if not afk.warned and now - afk.last >= 900 and not EXEC_COPY then  -- EXEC_COPY clicks in the background
            afk.warned = true
            log("Anti AFK: Roblox is not the focused window for 15 min, so no key can be pressed; Roblox kicks at 20 min")
        end
        return
    end
    afk.last, afk.warned = now, false
    keypress(0x20); task.wait(0.1); keyrelease(0x20)
    if DEBUG_LOG then log("Anti AFK: tapped Space (Roblox focused)") end
end
local menuTime = -1
local function stepOnce()
    -- Owner 2026-11-18: the menu is read 4 times a second (was every 0.05 s tick); looting itself still runs every tick.
    local now = os.clock()
    if now - menuTime >= 0.25 then menuTime = now; readMenu() end
    saveSettings()
    pcall(antiAfkStep)
    if LOBBY then lobbyStep(); return end
    logStatus()
    pickupStep()
end

-- ===== ESP drawing ===========================================================
-- Every frame; a newer run (_G.APOC_RUN) disconnects it and removes the labels. Without RenderStepped the step draws.
local espConn
pcall(function()
    espConn = RunService.RenderStepped:Connect(function()
        if _G.APOC_RUN ~= RUN then
            pcall(function() espConn:Disconnect() end)
            for _, s in ipairs(espDraw) do pcall(function() s.d:Remove() end) end
            for _, s in ipairs(espText) do pcall(function() s.d:Remove() end) end
            if offLabel then pcall(function() offLabel:Remove() end); offLabel = nil end
            espDraw, espText = {}, {}
            return
        end
        pcall(espRender)
    end)
end)
if not espConn then
    local oldStep = stepOnce
    stepOnce = function() oldStep(); pcall(espRender) end
end

-- v-15k (owner): L switches Auto Pickup; "Auto Loot is Off" shows under the crosshair while it is off.
-- Owner 2026-11-18: L was missed while moving (read only 4 times a second, a quick tap fell between two reads).
-- Now its own thread checks it every frame, whatever other keys are held.
task.spawn(function()
    while _G.APOC_RUN == RUN do
        local lDown = iskeypressed(0x4C)
        if IS_PRO and lDown and not pickKeyDown and (not isrbxactive or isrbxactive()) then
            cfg.enabled = not cfg.enabled
            pcall(UI.SetValue, id("on"), cfg.enabled)
        end
        pickKeyDown = lDown
        task.wait()
    end
end)

-- ===== Auto Farm (executor copy, owner 2026-11-25) ===========================
-- Endless match: walk to scrap / batteries (Auto Pickup claims them) and try Craft "Healing Pad" every few seconds until
-- it is in hand, walk to the map edge, place the pad (remotes from the owner's Remote Spy), stand on it 90 min, then
-- teleport back to the normal lobby; the lobby part goes to Endless and makes a solo room again. Walking only
-- (Humanoid:MoveTo in straight lines), never a position teleport.
-- Owner: while it runs it keeps Speed, Noclip and "through the map border" on, Kill Aura on, Heavy Revolver in hand.
-- Map (game20, v-25y): MapRadius 29 tiles; the owner's pad was at 560, 1824, so the map is a SQUARE of tiles (60 studs)
-- centred on 0,0: edge at |x| or |z| = (MapRadius + 0.5) * 60. Far ground is not loaded (streaming), so the edge walk
-- goes 30 studs at a time and stops where the next step has no ground under it.
if EXEC_COPY and not LOBBY then task.spawn(function()
    local PAD, GUN = "Healing Pad", "Heavy Revolver"
    -- Owner (v-25zk): leaving went to the normal lobby, then the portal, then the Endless lobby. Now straight to the
    -- Endless lobby (80046280333935); if this match is still running 20 s later, the normal lobby (old way) instead.
    local function toLobby()
        local TS = game:GetService("TeleportService")
        -- Owner: never give up. Endless lobby, then the normal lobby, again and again every 20 s until you are out.
        task.spawn(function()
            local n = 0
            while _G.APOC_RUN == RUN do
                n = n + 1
                local to = n % 2 == 1 and 80046280333935 or 90148635862803
                if n > 1 then log("Auto Farm: still in the match, teleport try " .. n .. " (place " .. to .. ")") end
                pcall(function() TS:Teleport(to, LocalPlayer) end)
                task.wait(20)
            end
        end)
    end
    local placing = false  -- the pad is in hand on purpose: do not swap the revolver back in
    local leaving = false  -- set by the leave watcher below; stops every walk
    local function active() return not leaving and _G.APOC_RUN == RUN and cfg.autoFarm and attr(workspace, "EternalNight") == true end
    local function body()
        local ch = LocalPlayer.Character
        local hum, hrp = ch and ch:FindFirstChildOfClass("Humanoid"), ch and ch:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and hrp then return ch, hum, hrp end
    end
    -- Owner: the menu shows what Auto Farm is doing now (under "Leaving in").
    local function doing(t) _G.APOC_FARM_DOING = t end
    doing("starting")
    local function padTool()
        local ch = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        return (ch and ch:FindFirstChild(PAD)) or (bp and bp:FindFirstChild(PAD))
    end
    local function flat(v) return Vector3.new(v.X, 0, v.Z) end
    local function edgeHalf() return ((tonumber(attr(workspace, "MapRadius")) or 0) + 0.5) * 60 end
    local function wallDist(p)  -- flat distance to the nearest Border part's box, and that part
        local map = workspace:FindFirstChild("Map")
        local b = map and map:FindFirstChild("Border")
        local best, bestP = nil, nil
        for _, part in ipairs(b and b:GetDescendants() or {}) do
            if part:IsA("BasePart") then
                local lp = part.CFrame:PointToObjectSpace(p)
                local hs = part.Size / 2
                local cl = part.CFrame:PointToWorldSpace(Vector3.new(math.clamp(lp.X, -hs.X, hs.X), math.clamp(lp.Y, -hs.Y, hs.Y),
                    math.clamp(lp.Z, -hs.Z, hs.Z)))
                local d = flat(cl - p).Magnitude
                if not best or d < best then best, bestP = d, part end
            end
        end
        return best, bestP
    end
    -- game60 survey: the border wall is a CIRCLE of 36 straight pieces (295 wide, 15 thick), centre line 1679.8 studs
    -- from the map centre (MapRadius 29). Outside it is a ring of ground 50-180 studs wide that ends in a cliff. The
    -- radius is read from the loaded Border parts; before they load: MapRadius x 60 + 30 - 90 (fits game60), logged.
    local borderRad
    local function borderR()
        if borderRad then return borderRad end
        local map = workspace:FindFirstChild("Map")
        local b = map and map:FindFirstChild("Border")
        local sum, n = 0, 0
        for _, part in ipairs(b and b:GetChildren() or {}) do
            if part:IsA("BasePart") and part.Name == "Border" then sum, n = sum + flat(part.Position).Magnitude, n + 1 end
        end
        if n > 0 then
            borderRad = sum / n
            log("Auto Farm: border wall radius " .. fmt(borderRad) .. " (" .. n .. " pieces), MapRadius "
                .. tostring(attr(workspace, "MapRadius")) .. " (x60 = " .. fmt(edgeHalf() - 30) .. ")")
            return borderRad
        end
        return edgeHalf() - 90
    end
    local seenLogAt = 0
    local function where(p)
        local g = flat(p).Magnitude - borderR()
        return fmt(p.X) .. ", " .. fmt(p.Y) .. ", " .. fmt(p.Z) .. " (" .. (g >= 0 and (fmt(g) .. " studs past the wall")
            or (fmt(-g) .. " studs inside the wall")) .. ")"
    end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local function ground(pos)  -- ground hit under pos, ignoring you and the border walls
        local map = workspace:FindFirstChild("Map")
        local ch = LocalPlayer.Character
        rp.FilterDescendantsInstances = {ch or workspace.Terrain, map and map:FindFirstChild("Border") or workspace.Terrain}
        return workspace:Raycast(Vector3.new(pos.X, pos.Y + 60, pos.Z), Vector3.new(0, -160, 0), rp)
    end

    -- Scan log (owner: where do the scrap / battery counts live, how does the script know it is at the edge).
    -- Remove once the counts are found and the edge works.
    local function scan()
        log("Auto Farm scan: workspace" .. attrs(workspace))
        log("Auto Farm scan: player" .. attrs(LocalPlayer))
        log("Auto Farm scan: character" .. attrs(LocalPlayer.Character or workspace))
        for _, c in ipairs(LocalPlayer:GetChildren()) do
            if c.Name ~= "PlayerGui" and c.Name ~= "PlayerScripts" then
                local kids = {}
                for i, k in ipairs(c:GetChildren()) do
                    if i > 30 then kids[#kids + 1] = "..."; break end
                    local okV, v = pcall(function() return k.Value end)
                    kids[#kids + 1] = k.Name .. (okV and v ~= nil and ("=" .. tostring(v)) or "") .. attrs(k)
                end
                log("Auto Farm scan: player." .. c.Name .. " (" .. c.ClassName .. ")" .. attrs(c) .. ": " .. table.concat(kids, ", "))
            end
        end
        local n = 0
        local okG, gui = pcall(function() return LocalPlayer.PlayerGui:GetDescendants() end)
        for _, d in ipairs(okG and gui or {}) do
            if n >= 40 then break end
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local t, path = tostring(d.Text), d:GetFullName()
                local low = string.lower(path .. " " .. t)
                if string.find(low, "scrap", 1, true) or string.find(low, "batter", 1, true) or string.find(low, "resource", 1, true) then
                    n = n + 1
                    log("Auto Farm scan: gui " .. path .. " = \"" .. t .. "\"")
                end
            end
        end
        local map = workspace:FindFirstChild("Map")
        local b = map and map:FindFirstChild("Border")
        local m = 0
        for _, p in ipairs(b and b:GetDescendants() or {}) do
            if p:IsA("BasePart") and m < 20 then
                m = m + 1
                log("Auto Farm scan: border " .. p:GetFullName() .. " at " .. fmt(p.Position.X) .. ", " .. fmt(p.Position.Y) .. ", "
                    .. fmt(p.Position.Z) .. " size " .. fmt(p.Size.X) .. " x " .. fmt(p.Size.Y) .. " x " .. fmt(p.Size.Z))
            end
        end
        log("Auto Farm scan: " .. (b and (m .. " border parts logged") or "no workspace.Map.Border"))
        -- Find-out (owner: died in "the air is radioactive"; the radioactive area is unknown). Remove once known.
        local k = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if k >= 40 then break end
            local n = string.lower(d.Name)
            for _, w in ipairs({"radi", "toxic", "fog", "gas", "nuclear", "reactor", "hazard", "contamin"}) do
                if string.find(n, w, 1, true) then
                    k = k + 1
                    local pos = d:IsA("BasePart") and d.Position
                    log("Auto Farm radiation scan: " .. d:GetFullName() .. " (" .. d.ClassName .. ")" .. attrs(d)
                        .. (pos and (" at " .. fmt(pos.X) .. ", " .. fmt(pos.Y) .. ", " .. fmt(pos.Z) .. " size "
                        .. fmt(d.Size.X) .. " x " .. fmt(d.Size.Y) .. " x " .. fmt(d.Size.Z)) or ""))
                    break
                end
            end
        end
        log("Auto Farm radiation scan: " .. k .. " objects named like radiation / fog / gas (40 max)")
    end

    -- v-25zc fell under the map (y -103) with Noclip on all the time: now Noclip only for the edge walk and the
    -- straight-line fallback; the border parts alone stay passable (move_border).
    local noclipNow, onPad, padWall = false, false, nil
    -- Owner: not everyone has the Heavy Revolver (Outlaw class). Any gun you own (Tool with ToolType "Gun") is held:
    -- the Heavy Revolver first, else the highest Tier.
    local function bestGun(ch)
        local best, bestS
        for _, holder in ipairs({ch, LocalPlayer:FindFirstChild("Backpack")}) do
            for _, t in ipairs(holder and holder:GetChildren() or {}) do
                if t:IsA("Tool") and attr(t, "ToolType") == "Gun" then
                    local sc = (t.Name == GUN and 100 or 0) + (tonumber(attr(t, "Tier")) or 0)
                    if not bestS or sc > bestS then best, bestS = t, sc end
                end
            end
        end
        return best
    end
    local function gear(ch, hum)
        for _, k in ipairs({"move_speedOn", "move_border"}) do pcall(UI.SetValue, k, true) end
        -- owner: always on while farming; off on the pad so the safety wall at the cliff holds you
        pcall(UI.SetValue, "move_noclip", not onPad)
        -- Owner (v-25zu): "back to the future" = the server pulled you back while zombies hit your server spot. The
        -- player has KM_MAX_PLAYER_SPEED (28.5 in the scan) and Speed was 34: while farming the shim caps WalkSpeed
        -- just under it (the menu value is not changed). Unconfirmed: the pull-back log below tells.
        local km = tonumber(attr(LocalPlayer, "KM_MAX_PLAYER_SPEED"))
        _G.APOC_SPEED_CAP = km and (km - 0.5) or nil
        if _G.HBX_RUN then pcall(UI.SetValue, "hbx_killOn_" .. tostring(_G.HBX_RUN), true) end
        local gun = bestGun(ch)
        if not placing and gun and gun.Parent ~= ch then pcall(function() hum:EquipTool(gun) end) end
    end
    -- One leg of a walk; jumps when stuck for a second. True when within 3 studs (flat).
    local stuckLogged = 0
    -- Radiation (game57 log): the character gets CurrentBiome = "Irradiated" inside it (health 100 -> 5 in 40 s without a
    -- gas mask). The guessed tile names never matched and are gone. Every spot where it shows is remembered; items,
    -- edge steps and pad spots within 90 studs of one are avoided (90 is a guess at the zone size, the biome log tells).
    local badSpots, lastSafe, lastBiome, escaping, irrTiles, irrAt = {}, nil, nil, false, {}, 0
    local tileUnder  -- defined below
    local function radNow()
        local ch = LocalPlayer.Character
        return ch ~= nil and attr(ch, "CurrentBiome") == "Irradiated" and attr(ch, "WearingGasMask") ~= true
    end
    local function hot(pos)
        if not pos then return false end
        -- game62 tile dump: radioactive tiles carry the attribute Irradiated = true, so it is known before walking in.
        local _, tile = tileUnder(pos)
        if tile and attr(tile, "Irradiated") == true then return true end
        -- game63: a step clipped the corner of an Irradiated tile. Within 60 studs of one's centre counts too.
        for _, c in ipairs(irrTiles) do
            if flat(c - pos).Magnitude < 60 then return true end
        end
        for _, b in ipairs(badSpots) do
            if flat(b - pos).Magnitude < 45 then return true end  -- game63: 90 blocked all 8 ways out after an escape
        end
        return false
    end
    task.spawn(function()
        while _G.APOC_RUN == RUN do
            task.wait(0.5)
            if os.clock() >= irrAt then  -- centres of the Irradiated tiles, every 5 s (tiles load as you move)
                irrAt = os.clock() + 5
                local m = workspace:FindFirstChild("Map")
                local tl = m and m:FindFirstChild("Tiles")
                local list = {}
                for _, t in ipairs(tl and tl:GetChildren() or {}) do
                    if attr(t, "Irradiated") == true then
                        local okP, pv = pcall(function() return t:GetPivot().Position end)
                        if okP and pv then list[#list + 1] = pv end
                    end
                end
                irrTiles = list
            end
            local ch = LocalPlayer.Character
            local r = ch and ch:FindFirstChild("HumanoidRootPart")
            if r then
                local b = tostring(attr(ch, "CurrentBiome"))
                if b ~= lastBiome then
                    lastBiome = b
                    log("Auto Farm find-out: biome " .. b .. " at " .. where(r.Position) .. " (tile " .. tostring(tileUnder(r.Position)) .. ")")
                end
                if radNow() then
                    local new = true
                    for _, s0 in ipairs(badSpots) do if flat(s0 - r.Position).Magnitude < 30 then new = false; break end end
                    if new then badSpots[#badSpots + 1] = r.Position end
                elseif r.Position.Y > -40 then
                    lastSafe = r.Position
                end
            end
        end
    end)
    -- Find-out (owner: rubber-banding): a jump of 8+ studs in one 0.2 s step = the server put you back. Logged with
    -- speed and Noclip, 30 per match. Remove once the cause is known.
    -- Tile under a point (workspace.Map.Tiles.<name>). Zombie spawn log v-24m: ~87% on road tiles (StraightRoad,
    -- Corner, TSection), some Market, almost none on filler tiles: the pad goes on a non-road tile.
    function tileUnder(pos)
        local map = workspace:FindFirstChild("Map")
        local tiles = map and map:FindFirstChild("Tiles")
        if not tiles then return nil end
        local mp = RaycastParams.new()
        mp.FilterType, mp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {tiles}
        local hit = workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -30, 0), mp)
        local inst = hit and hit.Instance
        while inst and inst.Parent ~= tiles do inst = inst.Parent end
        return inst and inst.Name, inst
    end
    local function leg(pos, untilT, quick)  -- quick: give up after 2 s stuck (then go() finds a path)
        local lastPos, lastT, stuckFor = nil, os.clock(), 0
        -- Rubber-band (game48: always at walls with Noclip, WalkSpeed under the game's max) = the server puts you back.
        -- Owner's trick: small walk, stop, small walk. It ends as soon as you are past the spot you were pulled back
        -- from. Owner (game51): never a sideways detour ("random path"), always straight through.
        local prev, pulseUntil, pulseN, best = nil, 0, 0, math.huge
        while active() and os.clock() < untilT do
            local ch, hum, hrp = body()
            if not hum then return false end
            if radNow() and not escaping and lastSafe then
                escaping = true
                log("Auto Farm: radiation (no gas mask) at " .. where(hrp.Position) .. ", walking back out to " .. where(lastSafe))
                doing("radiation! walking back out")
                leg(lastSafe, os.clock() + 20)
                escaping = false
                return false
            end
            if hrp.Position.Y < -40 or hrp.AssemblyLinearVelocity.Y < -80 then
                log("Auto Farm: falling (y " .. fmt(hrp.Position.Y) .. ") at " .. where(hrp.Position) .. ", stopping the walk")
                return false
            end
            gear(ch, hum)
            local now = hrp.Position
            local d = flat(pos - now).Magnitude
            if prev and d > flat(pos - prev).Magnitude + 2 then
                pulseUntil = os.clock() + 4
            end
            if d < best - 2 then best, pulseUntil = d, 0 end  -- past the wall: back to a normal walk
            prev = now
            if d < 3 then return true end
            if os.clock() < pulseUntil then
                pulseN = pulseN + 1
                hum:MoveTo(pulseN % 3 == 0 and pos or hrp.Position)
            else
                hum:MoveTo(pos)
            end
            if not lastPos or (hrp.Position - lastPos).Magnitude > 1 then lastPos, lastT, stuckFor = hrp.Position, os.clock(), 0
            elseif os.clock() - lastT > 1 then
                hum.Jump, lastT, stuckFor = true, os.clock(), stuckFor + 1
                if quick and stuckFor >= 2 then return false end
                if stuckFor == 3 and stuckLogged < 30 then
                    stuckLogged = stuckLogged + 1
                    log("Auto Farm: stuck 3 s at " .. where(hrp.Position) .. ", walking to " .. fmt(pos.X) .. ", " .. fmt(pos.Z)
                        .. " (WalkSpeed " .. fmt(hum.WalkSpeed) .. ")")
                end
            end
            task.wait(0.2)
        end
        return false
    end
    -- Owner (v-25zs): "pathing is worst, Noclip at all times". Every walk is a straight line with Noclip on (no
    -- pathfinding); leg() still stops a walk when you drop below y -5 (v-25zc fell under the map with Noclip).
    -- Owner (after game54): it walked diagonally through buildings while an empty street was right there. Before each
    -- 60-stud piece of a walk, a few routes are checked with flat rays at chest height and the one through the fewest
    -- walls is walked, in straight pieces: straight, L-shaped (X then Z, Z then X), and lanes 30 / 60 studs to each
    -- side. Shorter wins a tie. Only loaded buildings are seen, so it checks again every 60 studs.
    local function wallHits(a, b)
        local ex = {}
        for _, n in ipairs({"Characters", "DroppedItems"}) do
            local f = workspace:FindFirstChild(n)
            if f then ex[#ex + 1] = f end
        end
        if LocalPlayer.Character then ex[#ex + 1] = LocalPlayer.Character end
        local map = workspace:FindFirstChild("Map")
        local bd = map and map:FindFirstChild("Border")
        if bd then ex[#ex + 1] = bd end
        local rq = RaycastParams.new()
        rq.FilterType, rq.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, ex
        local from, to = a + Vector3.new(0, 3, 0), b + Vector3.new(0, 3, 0)
        local n = 0
        for _ = 1, 15 do
            local d = to - from
            if d.Magnitude < 1 then break end
            local hit = workspace:Raycast(from, d, rq)
            if not hit then break end
            n = n + 1
            from = hit.Position + d.Unit * 4  -- past this wall, look for the next one
        end
        return n
    end
    local function route(p, q)
        local f = flat(q - p)
        if f.Magnitude < 8 then return {q} end
        local perp = Vector3.new(-f.Unit.Z, 0, f.Unit.X)
        local list = {{q}, {Vector3.new(q.X, p.Y, p.Z), q}, {Vector3.new(p.X, p.Y, q.Z), q}}
        for _, o in ipairs({30, -30, 60, -60}) do list[#list + 1] = {p + perp * o, q + perp * o, q} end
        local best, bestS
        for _, pts in ipairs(list) do
            local sc, prev, len = 0, p, 0
            for _, w in ipairs(pts) do
                -- game56: a route ran out over the cliff at the edge and you fell. No ground under it = not taken.
                local seg = flat(w - prev).Magnitude
                for k = 10, seg, 10 do
                    local q = prev + (w - prev) * (k / seg)
                    if not ground(q) then sc = sc + 1000; break end
                    if hot(q) then sc = sc + 1000; break end  -- game63: never through radiation
                end
                sc = sc + wallHits(prev, w)
                len = len + flat(w - prev).Magnitude
                prev = w
            end
            sc = sc + len / 1000
            if not bestS or sc < bestS then best, bestS = pts, sc end
        end
        return best
    end
    local function go(pos, secs)
        local untilT = os.clock() + secs
        while active() and os.clock() < untilT do
            local _, _, r = body()
            if not r then break end
            local f = flat(pos - r.Position)
            if f.Magnitude < 3 then break end
            local piece = f.Magnitude > 60 and (r.Position + f.Unit * 60) or pos
            local okW = true
            for _, w in ipairs(route(r.Position, piece)) do
                if not leg(w, untilT) then okW = false; break end
            end
            if not okW then break end  -- timed out, fell, died or the farm stopped
        end
        local _, _, h2 = body()
        return h2 ~= nil and flat(pos - h2.Position).Magnitude < 4
    end
    local function isRoad(name)
        local n = string.lower(tostring(name))
        for _, w in ipairs({"road", "corner", "tsection", "straight", "market", "intersection", "cross"}) do
            if string.find(n, w, 1, true) then return true end
        end
        return false
    end
    -- Walk out to the nearest edge in 30-stud steps; stop at the edge line or where the next step has no ground.
    local toEdgeInner
    -- axis: walk that way (unit vector, flat).
    local function toEdge(axis)
        noclipNow = true
        local ok, why = toEdgeInner(axis)
        noclipNow = false
        return ok, why
    end
    function toEdgeInner(axis)
        local _, _, hrp = body()
        if not hrp then return false, "no character" end
        local step, lastTile, fails = axis * 30, nil, 0
        local untilT = os.clock() + 300
        while active() and os.clock() < untilT do
            local _, _, r = body()
            if not r then return false, "died" end
            local c = r.Position
            -- game60: stop once you are 25 studs past the (circular) border wall.
            if flat(c).Magnitude >= borderR() + 25 then return true, "past the wall" end
            -- Owner (game51): straight out only. The old road shift (up to 60 studs sideways) walked diagonally into
            -- walls and back through walls already passed.
            -- Owner (game57): it walked through buildings next to empty ground. The next 30-stud step is the one with
            -- the fewest walls on the way: straight, or 30 / 60 studs to a side (straight wins a tie). No ground
            -- straight ahead = the edge.
            local side, nxt, bestW = Vector3.new(-axis.Z, 0, axis.X), nil, nil
            for _, o in ipairs({0, 30, -30, 60, -60}) do
                local q = c + step + side * o
                if ground(q) and not hot(q) and not hot((c + q) / 2) then
                    local w = wallHits(c, q) + math.abs(o) / 100
                    if not bestW or w < bestW then nxt, bestW = q, w end
                end
            end
            if not nxt then return false, "no ground or radiation on all 5 next steps" end
            local t = tileUnder(nxt)
            if t ~= lastTile then lastTile = t; log("Auto Farm: edge walk enters tile " .. tostring(t) .. " at " .. where(nxt)) end
            -- A failed step (20 s) just goes on straight from where you are; the direction is dropped after 6 in a row.
            if go(nxt, 20) then fails = 0 else
                fails = fails + 1
                log("Auto Farm: edge step " .. fails .. " failed at " .. where(r.Position) .. " (tile " .. tostring(t) .. "), going on")
                task.wait(0.5)
                if fails >= 6 then return false, "6 failed steps (tile " .. tostring(t) .. ")" end
            end
        end
        return false, "timed out"
    end

    -- Owner (game50): the pad sat next to a building / the border and the horde came; "there are a lot of other
    -- edges". At the edge, every spot 15 studs inside it, up to 240 studs left and right (30-stud steps), gets a
    -- "room" score: the shortest of 8 flat rays (40 studs, 6 studs up) to anything solid. The roomiest spot wins
    -- (nearer one on a tie); unloaded ground has no hit and is skipped.
    local function room(p)
        local ex = {}
        for _, n in ipairs({"Characters", "DroppedItems"}) do
            local f = workspace:FindFirstChild(n)
            if f then ex[#ex + 1] = f end
        end
        if LocalPlayer.Character then ex[#ex + 1] = LocalPlayer.Character end
        local rq = RaycastParams.new()
        rq.FilterType, rq.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, ex
        local o, m = p + Vector3.new(0, 6, 0), 40
        for i = 0, 7 do
            local a = i * math.pi / 4
            local hit = workspace:Raycast(o, Vector3.new(math.cos(a), 0, math.sin(a)) * 40, rq)
            if hit then m = math.min(m, (hit.Position - o).Magnitude) end
        end
        return m
    end
    local function outAxis(p)  -- straight out from the map centre (the border is a circle)
        local f = flat(p)
        return f.Magnitude > 1 and f.Unit or Vector3.new(1, 0, 0)
    end
    -- Owner's plan (game60): the pad goes OUTSIDE the wall, about 15 studs before the cliff, on flat ground, never in
    -- radiation, at least 60 studs from the wall. Checked at your angle and 150 studs to each side along the ring; the
    -- one farthest from the wall wins. None = walk 150 studs along the ring (same way round each time) and look again,
    -- forever. Ground not loaded counts as cliff.
    local ringDir = 1
    local function spotAt(ang, y)
        local R = borderR()
        local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
        local cliff
        for d = R + 15, R + 400, 5 do
            local g = ground(Vector3.new(dir.X * d, y, dir.Z * d))
            if not g or g.Position.Y < y - 20 then cliff = d; break end
        end
        if not cliff then cliff = R + 400 end
        local rs = cliff - 15
        local q = Vector3.new(dir.X * rs, y, dir.Z * rs)
        local g = ground(q)
        local wd = wallDist(q) or (rs - R - 7.5)
        local isFlat = g ~= nil and g.Normal.Y > 0.97
        local ok = isFlat and wd >= 60 and not hot(g.Position)
        return ok, g and g.Position or q, wd, cliff - R, isFlat
    end
    local function ringSpot()
        while active() do
            local _, _, r = body()
            if not r then return false end
            local p = r.Position
            local rr = math.max(flat(p).Magnitude, 1)
            local a0 = math.atan2(p.Z, p.X)
            local dA = 150 / rr
            local best, bestWd, seen = nil, nil, {}
            for _, k in ipairs({0, -1, 1}) do
                local ok, q, wd, ring, isFlat = spotAt(a0 + k * dA, p.Y)
                seen[#seen + 1] = (k * 150) .. ": ground " .. math.floor(ring) .. " past the wall, spot " .. math.floor(wd)
                    .. " from the wall" .. (isFlat and "" or ", slope") .. (ok and " OK" or "")
                if ok and (not bestWd or wd > bestWd) then best, bestWd = q, wd end
            end
            log("Auto Farm: ring spots (along: result) " .. table.concat(seen, "; ") .. (best and (" -> " .. where(best)) or " -> none"))
            if best then
                doing("walking to a flat spot near the cliff, " .. math.floor(bestWd) .. " studs from the wall")
                noclipNow = true
                local walkR = borderR() + 30
                local ba = math.atan2(best.Z, best.X)
                go(Vector3.new(math.cos(ba) * walkR, p.Y, math.sin(ba) * walkR), 40)  -- along the ring, wall side
                go(best, 30)                                                         -- then straight out to the spot
                noclipNow = false
                local _, _, h2 = body()
                if h2 and flat(best - h2.Position).Magnitude < 6 then return true end
                log("Auto Farm: did not reach the spot, looking again")
            else
                doing("no flat spot far from the wall here, moving 150 studs along the ring")
                local walkR = borderR() + 30
                local na = a0 + ringDir * dA
                noclipNow = true
                go(Vector3.new(math.cos(na) * walkR, p.Y, math.sin(na) * walkR), 30)
                noclipNow = false
            end
        end
        return false
    end
    -- Owner: a wall so you cannot fall off the cliff. Only on your screen (the game never sees it), no ray hits it
    -- (Kill Aura shoots through), 1 stud thick, 80 wide, 30 high, where the ground ends past the pad (max 60 studs).
    local function buildWall(at)
        if padWall and padWall.Parent then return end
        local axis = outAxis(at)
        local edgeAt = at + axis * 60
        for d = 3, 60, 3 do
            if not ground(at + axis * d) then edgeAt = at + axis * (d - 2); break end
        end
        local w = Instance.new("Part")
        w.Name, w.Anchored, w.CanCollide, w.CanQuery, w.CanTouch = "AutoFarmWall", true, true, false, false
        w.Transparency, w.Color, w.Material = 0.7, Color3.fromRGB(120, 90, 220), Enum.Material.ForceField
        w.Size = Vector3.new(80, 30, 1)  -- thin side faces the cliff (the edge is round)
        local c0 = Vector3.new(edgeAt.X, at.Y + 12, edgeAt.Z)
        w.CFrame = CFrame.lookAt(c0, c0 + axis)
        w.Parent = workspace
        padWall = w
        log("Auto Farm: safety wall at " .. where(w.Position) .. " (" .. math.floor((edgeAt - at).Magnitude) .. " studs past the pad)")
    end

    -- Find-out (owner): log the game's OWN PlaceStructure call when a pad is placed by hand, to copy what works.
    -- The hook is installed once per game session; each run points _G.APOC_PLACE_LOG at its own log.
    _G.APOC_PLACE_LOG = log
    if not _G.APOC_PLACE_HOOK and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
        _G.APOC_PLACE_HOOK = true
        pcall(function()
            local old
            old = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() == "InvokeServer" and not (checkcaller and checkcaller()) then
                    local okN, n = pcall(function() return self.Name end)
                    if okN and n == "PlaceStructure" then
                        local a = {...}
                        task.spawn(function()
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            pcall(_G.APOC_PLACE_LOG, "Auto Farm: GAME placed: " .. tostring(a[1] and a[1]:GetFullName()) .. " | "
                                .. tostring(a[2]) .. " | " .. tostring(a[3]) .. " | you at " .. tostring(hrp and hrp.Position))
                        end)
                    end
                end
                return old(self, ...)
            end)
        end)
    end
    local skipUntil, lastHave = {}, nil  -- item -> time it is left alone until
    -- Leave watcher, its own loop every second (game34: a horde came during a 3-minute edge search and the old
    -- check, which ran between farm steps, never got a turn).
    -- Owner rules: leave ONLY when (1) a horde really spawned: the Survived clock (player EternalNightSurvived, it
    -- pauses while a horde lives) stood still 6 s, or 3+ zombies with Horde = true; (2) Survived reached "Leave
    -- after" minutes; (3) you died. Never because of the countdown: no horde spawns at the map edge.
    -- Find-out (owner): what hurts you with no zombie near (radiation?). Logs tile, position, attributes and any
    -- on-screen "radioactive" text, at most once per 10 s, 30 times per match. Remove once the area is known.
    local hurtLogs, hurtAt, lastHp = 0, 0, nil
    local function hurtCheck(c, h)
        local hp = h and h.Health
        if hp and lastHp and hp < lastHp - 0.5 and hurtLogs < 30 and os.clock() - hurtAt > 10 then
            local me = c:FindFirstChild("HumanoidRootPart")
            local chars, near = workspace:FindFirstChild("Characters"), false
            for _, z in ipairs(me and chars and chars:GetChildren() or {}) do
                local zp = z ~= c and z:FindFirstChild("HumanoidRootPart")
                if zp and (zp.Position - me.Position).Magnitude < 25 then near = true; break end
            end
            if me and not near then
                hurtLogs, hurtAt = hurtLogs + 1, os.clock()
                local texts = {}
                pcall(function()
                    for _, d in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if (d:IsA("TextLabel") or d:IsA("TextButton")) and string.find(string.lower(d.Text), "radioactiv", 1, true) then
                            texts[#texts + 1] = d:GetFullName() .. (d.Visible and "" or " (hidden)")
                        end
                    end
                end)
                local se = LocalPlayer:FindFirstChild("StatusEffectTimers")
                log("Auto Farm find-out: hurt " .. fmt(lastHp) .. " -> " .. fmt(hp) .. " with no zombie within 25 studs, at "
                    .. where(me.Position) .. ", tile " .. tostring(tileUnder(me.Position)) .. " | character" .. attrs(c)
                    .. " | status" .. (se and attrs(se) or " none") .. " | radioactive text: "
                    .. (#texts > 0 and table.concat(texts, ", ") or "none"))
            end
        end
        lastHp = hp
    end
    task.spawn(function()
        local lastSurv, survMovedAt, gotLoot = nil, nil, false
        while _G.APOC_RUN == RUN and not leaving do
            task.wait(1)
            if cfg.autoFarm and attr(workspace, "EternalNight") == true then
                local surv = tonumber(attr(LocalPlayer, "EternalNightSurvived"))
                if surv and surv ~= lastSurv then lastSurv, survMovedAt = surv, os.clock() end
                -- horde zombies within 250 studs only: one far away on the map is not coming for you
                local c = LocalPlayer.Character
                local me = c and c:FindFirstChild("HumanoidRootPart")
                if c then pcall(hurtCheck, c, c:FindFirstChildOfClass("Humanoid")) end
                local chars, horde = workspace:FindFirstChild("Characters"), 0
                for _, z in ipairs(me and chars and chars:GetChildren() or {}) do
                    local zp = attr(z, "Horde") == true and z:FindFirstChild("HumanoidRootPart")
                    if zp and (zp.Position - me.Position).Magnitude < 250 then horde = horde + 1 end
                end
                -- Owner: Survived 0:30 and nothing looted yet (no scrap, no battery, no pad) = a bad start, leave.
                -- Only between 0:30 and 1:00, so an Execute later in the match (scrap spent on the pad) never trips it.
                if not gotLoot then
                    local st = workspace:FindFirstChild("Structures")
                    gotLoot = (tonumber(attr(workspace, "Scrap")) or 0) > 0 or (tonumber(attr(workspace, "Batteries")) or 0) > 0
                        or padTool() ~= nil or (st ~= nil and st:FindFirstChild(PAD) ~= nil)
                end
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local why = (h and h.Health <= 0 and "you died")
                    or (surv and surv >= 30 and surv < 60 and not gotLoot and "nothing looted by Survived 0:30")
                    -- surv >= 60: at the match start the clock sits at 1-3 s for a while (game36/37 left by mistake);
                    -- the first horde comes at 4:00.
                    or (surv and survMovedAt and surv >= 60 and os.clock() - survMovedAt > 6 and ("Survived clock stopped at " .. surv .. " s (horde)"))
                    or (horde >= 3 and (horde .. " horde zombies seen"))
                    or (surv and surv >= (tonumber(cfg.farmMin) or 91) * 60 and ("Survived " .. math.floor(surv / 60) .. " min, leave after " .. tostring(cfg.farmMin)))
                if why then
                    leaving = true
                    doing("leaving: " .. why)
                    log("Auto Farm: leaving (" .. why .. "), teleporting to the Endless lobby to start over")
                    toLobby()
                end
            end
        end
    end)
    -- Find-out (owner 2026-11-25, game58: the real border wall stood ~60 studs before the MapRadius line, so "60 inside"
    -- was AT the wall). Edge survey: the owner runs along the map edge by hand (Auto Farm on or off) and every 20 studs
    -- moved within 400 studs of the edge one line is logged. Each workspace.Map.Border part is logged once (name,
    -- size, position, turn). Remove once the farm measures the real wall.
    task.spawn(function()
        if NO_LOGS then return end  -- find-out only (owner's copy)
        local lastAt, seenParts, borderMissingLogged = nil, {}, false
        while _G.APOC_RUN == RUN do
            task.wait(0.5)
            local ch = LocalPlayer.Character
            local r = ch and ch:FindFirstChild("HumanoidRootPart")
            if r and attr(workspace, "EternalNight") == true then
                local map = workspace:FindFirstChild("Map")
                local bf = map and map:FindFirstChild("Border")
                if not bf and not borderMissingLogged then
                    borderMissingLogged = true
                    log("Auto Farm survey: workspace.Map.Border is not there (not loaded yet?)")
                end
                for _, part in ipairs(bf and bf:GetDescendants() or {}) do
                    if part:IsA("BasePart") and not seenParts[part] then
                        seenParts[part] = true
                        local rx, ry, rz = part.CFrame:ToOrientation()
                        log("Auto Farm survey: border part " .. part:GetFullName() .. " size " .. fmt(part.Size.X) .. " x "
                            .. fmt(part.Size.Y) .. " x " .. fmt(part.Size.Z) .. " at " .. where(part.Position) .. " turn "
                            .. math.floor(math.deg(ry)) .. ", CanCollide " .. tostring(part.CanCollide) .. ", see-through "
                            .. fmt(part.Transparency))
                    end
                end
                local p = r.Position
                local inside = borderR() - flat(p).Magnitude
                if inside < 400 and (not lastAt or flat(p - lastAt).Magnitude >= 20) then
                    lastAt = p
                    local wd, wp = wallDist(p)
                    local axis = outAxis(p)
                    local cliff = "200+"
                    for d = 5, 200, 5 do
                        local g = ground(p + axis * d)
                        if not g or g.Position.Y < p.Y - 20 then cliff = tostring(d); break end
                    end
                    local g0 = ground(p)
                    log("Auto Farm survey: at " .. where(p) .. " | wall " .. (wd and (math.floor(wd) .. " studs (" .. wp.Name .. ")") or "none loaded")
                        .. " | ground ends " .. cliff .. " studs further out | tile " .. tostring(tileUnder(p)) .. " | biome "
                        .. tostring(attr(ch, "CurrentBiome")) .. " | flat " .. tostring(g0 and g0.Normal.Y > 0.97)
                        .. " | room " .. math.floor(room(p)))
                end
            end
        end
    end)
    -- Find-out (owner 2026-11-25: "how do they generate the map / structures?"). The server's own code cannot be read;
    -- this saves what the game sends us, into SurviveTheApocalypse/mapgen/: (1) attributes of workspace, Map and
    -- Map.Tiles + what Map holds (log); (2) every tile as it loads: name, position, size, distance from the centre and
    -- the wall, angle, attributes (tiles_<time>.txt, added to every 15 s); (3) the game's client code and folders whose
    -- names mention map / tile / generation / biome / border / radiation / zone / spawn / horde, decompiled to
    -- code/*.txt (40 max). Remove once the generation is understood.
    task.spawn(function()
        if NO_LOGS then return end  -- find-out only: the public copy writes and decompiles nothing
        task.wait(5)
        pcall(function() if not isfolder("SurviveTheApocalypse/mapgen") then makefolder("SurviveTheApocalypse/mapgen") end end)
        pcall(function() if not isfolder("SurviveTheApocalypse/mapgen/code") then makefolder("SurviveTheApocalypse/mapgen/code") end end)
        local map = workspace:FindFirstChild("Map")
        log("Auto Farm mapgen: workspace" .. attrs(workspace))
        if map then
            log("Auto Farm mapgen: Map" .. attrs(map))
            local kids = {}
            for _, c in ipairs(map:GetChildren()) do kids[#kids + 1] = c.Name .. " (" .. c.ClassName .. ", " .. #c:GetChildren() .. ")" .. attrs(c) end
            log("Auto Farm mapgen: Map holds " .. table.concat(kids, "; "))
        end
        -- (3) the game's client code
        local KEYS = {"map", "tile", "gen", "biome", "border", "radiat", "zone", "spawn", "horde", "terrain", "chunk", "world"}
        local function wanted(n)
            n = string.lower(n)
            for _, k in ipairs(KEYS) do if string.find(n, k, 1, true) then return true end end
            return false
        end
        local roots = {game:GetService("ReplicatedStorage"), game:GetService("ReplicatedFirst")}
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then roots[#roots + 1] = ps end
        local saved, folders = 0, {}
        for _, root in ipairs(roots) do
            for _, x in ipairs(root:GetDescendants()) do
                local okN, full = pcall(function() return x:GetFullName() end)
                if okN and wanted(x.Name) then
                    if (x:IsA("ModuleScript") or x:IsA("LocalScript")) and saved < 40 then
                        saved = saved + 1
                        local okD, src = false, "this executor has no decompile"
                        if type(decompile) == "function" then okD, src = pcall(decompile, x) end
                        local fname = "SurviveTheApocalypse/mapgen/code/" .. string.gsub(full, "[^%w%._-]", "_") .. ".txt"
                        pcall(writefile, fname, "-- " .. full .. " (" .. x.ClassName .. ")\n" .. tostring(src))
                        log("Auto Farm mapgen: saved code " .. full .. " (" .. tostring(okD) .. ")")
                    elseif not x:IsA("LuaSourceContainer") and #folders < 60 and #x:GetChildren() > 0 then
                        local names, seenN = {}, {}
                        for _, c in ipairs(x:GetChildren()) do
                            if not seenN[c.Name] and #names < 25 then seenN[c.Name] = true; names[#names + 1] = c.Name end
                        end
                        folders[#folders + 1] = full
                        log("Auto Farm mapgen: folder " .. full .. " (" .. x.ClassName .. ", " .. #x:GetChildren() .. " inside)"
                            .. attrs(x) .. ": " .. table.concat(names, ", "))
                    end
                end
            end
        end
        log("Auto Farm mapgen: " .. saved .. " code files saved, " .. #folders .. " folders listed")
        -- (2) every tile, as it loads
        local file = "SurviveTheApocalypse/mapgen/tiles_" .. os.time() .. ".txt"
        local buf, seenT = {"name | x | z | size x | size z | from centre | from wall (+ = past it) | angle | attributes"}, {}
        while _G.APOC_RUN == RUN do
            local m = workspace:FindFirstChild("Map")
            local tiles = m and m:FindFirstChild("Tiles")
            local added = 0
            for _, t in ipairs(tiles and tiles:GetChildren() or {}) do
                if not seenT[t] then
                    local okB, cf, size = pcall(function() return t:GetBoundingBox() end)
                    if okB and cf then
                        seenT[t] = true
                        added = added + 1
                        local pos = cf.Position
                        local r = flat(pos).Magnitude
                        buf[#buf + 1] = t.Name .. " | " .. fmt(pos.X) .. " | " .. fmt(pos.Z) .. " | " .. fmt(size.X) .. " | " .. fmt(size.Z)
                            .. " | " .. fmt(r) .. " | " .. fmt(r - borderR()) .. " | " .. math.floor(math.deg(math.atan2(pos.Z, pos.X)))
                            .. " |" .. attrs(t)
                    end
                end
            end
            if added > 0 then
                pcall(writefile, file, table.concat(buf, "\n"))
                log("Auto Farm mapgen: " .. added .. " more tiles saved (" .. (#buf - 1) .. " in " .. file .. ")")
            end
            task.wait(15)
        end
    end)
    local placedAt, padPos, lastCraft, craftAt, lastState, scanned, fails, statusAt = nil, nil, nil, 0, nil, false, 0, 0
    local padMissing, gunWas = nil, nil
    while _G.APOC_RUN == RUN do
        task.wait(0.2)  -- was 1 s: a stop after every item (owner: walk-stop-walk-stop)
        local okLoop, errLoop = pcall(function()
        local ch, hum, hrp = body()
        local act = active()
        local state = not cfg.autoFarm and "off" or attr(workspace, "EternalNight") ~= true and "not Endless"
            or not hum and "no character" or placedAt and "on the pad" or padTool() and "pad in hand" or "looting"
        if state ~= lastState then
            lastState = state
            log("Auto Farm: state " .. state .. (hrp and (" at " .. where(hrp.Position)) or ""))
        end
        if not act then
            _G.APOC_SPEED_CAP = nil
            if not leaving then doing(not cfg.autoFarm and "off" or "waiting (not an Endless match)") end
        end  -- your own Speed value again when not farming
        if act and hum then
            if not scanned then scanned = true; pcall(scan) end
            gear(ch, hum)
            if os.clock() >= statusAt then
                statusAt = os.clock() + 60
                log("Auto Farm: status " .. state .. " at " .. where(hrp.Position) .. ", holding "
                    .. tostring((ch:FindFirstChildOfClass("Tool") or {}).Name))
            end
            -- Owner (v-25ze): Execute again walked away from the placed pad and made a new one. A new run first looks
            -- for a placed Healing Pad (workspace.Structures; solo, so it is yours) and goes back on it.
            -- shortcut: the 90 min count starts again from this run; keep the place time in a file if that matters.
            if not placedAt and not padTool() then
                local st = workspace:FindFirstChild("Structures")
                for _, m in ipairs(st and st:GetChildren() or {}) do
                    if m.Name == PAD then
                        local okP, piv = pcall(function() return m:GetPivot().Position end)
                        if okP and piv then
                            placedAt, padPos = os.clock(), piv
                            log("Auto Farm: found my placed pad at " .. where(piv) .. ", going back on it")
                            break
                        end
                    end
                end
            end
            -- Owner: start looting / walking only once the Survived timer runs (loot is not loaded before that).
            if not placedAt and not padTool() and (tonumber(attr(LocalPlayer, "EternalNightSurvived")) or 0) <= 0 then
                doing("waiting for the Survived timer to start")
            elseif not placedAt and not padTool() then
                -- Phase 1: loot (Auto Pickup with scrap + batteries on) and try to craft.
                for _, k in ipairs({"on", "scrap", "batt"}) do pcall(UI.SetValue, id(k), true) end
                -- Owner: no gun at all = grab one to defend yourself. "Guns (any)" is switched on until you have one,
                -- then put back the way it was.
                local needGun = bestGun(ch) == nil
                if needGun and gunWas == nil then
                    gunWas = UI.GetValue(id("pick_gun")) == true
                    pcall(UI.SetValue, id("pick_gun"), true)
                    log("Auto Farm: you have no gun, taking the first one found")
                elseif not needGun and gunWas ~= nil then
                    pcall(UI.SetValue, id("pick_gun"), gunWas)
                    log("Auto Farm: got a gun (" .. tostring((bestGun(ch) or {}).Name) .. ")")
                    gunWas = nil
                end
                noclipNow = false
                -- Owner: Healing Pad = 60 scrap + 4 batteries. The totals are workspace attributes Scrap / Batteries
                -- (scan v-25z); only what is still missing is walked to, and Craft is sent once both are enough.
                local sc, bt = tonumber(attr(workspace, "Scrap")), tonumber(attr(workspace, "Batteries"))
                local needScrap, needBatt = not sc or sc < 60, not bt or bt < 4
                local have = "scrap " .. tostring(sc) .. "/60, batteries " .. tostring(bt) .. "/4"
                if have ~= lastHave then lastHave = have; log("Auto Farm: have " .. have) end
                if not (needScrap or needBatt) then doing("enough scrap and batteries, crafting the Healing Pad") end
                if os.clock() >= craftAt and (not sc or not bt or not (needScrap or needBatt)) then
                    craftAt = os.clock() + 5
                    local okC, res = pcall(function() return remote("Crafting", "Craft"):InvokeServer(PAD) end)
                    local r = tostring(okC) .. " " .. tostring(res)
                    if r ~= lastCraft then lastCraft = r; log("Auto Farm: craft " .. PAD .. " -> " .. r) end
                end
                if not padTool() and (needScrap or needBatt or needGun) then
                    local folder, best, bestD = workspace:FindFirstChild("DroppedItems"), nil, math.huge
                    local masked = attr(ch, "WearingGasMask") == true
                    local bestIt
                    for _, it in ipairs(folder and folder:GetChildren() or {}) do
                        local n = string.lower(it.Name)
                        local batt = string.find(n, "battery", 1, true) ~= nil
                        local inf = itemInfo(it)
                        local isGun = needGun and inf.toolType == "Gun"
                        if (isGun or inf.type == "Resource" and (batt and needBatt or not batt and needScrap))
                            and not (skipUntil[it] and os.clock() < skipUntil[it]) then
                            local p = itemPart(it)
                            local pos = p and partPos(p)
                            local d = pos and (pos - hrp.Position).Magnitude
                            if d and isGun then d = d / 3 end  -- a gun first, unless it is 3x farther than the loot
                            if d and d < bestD then best, bestD, bestIt = pos, d, it end
                        end
                    end
                    -- Owner: died in the radioactive zone. Items on a nuclear / reactor / radio tile are skipped without a mask.
                    local tile = best and tileUnder(best)
                    if best and not masked and hot(best) then
                        skipUntil[bestIt] = os.clock() + 600
                        log("Auto Farm: skipped " .. bestIt.Name .. " on tile " .. tostring(tile) .. " (near a radiation spot, no gas mask)")
                    elseif best then
                        -- Owner: it kept walking into a building's small window. Not reached = left alone for 60 s.
                        doing("walking to " .. bestIt.Name .. " (" .. math.floor(bestD) .. " studs)")
                        if not go(best, 25) then
                            skipUntil[bestIt] = os.clock() + 60
                            log("Auto Farm: could not reach " .. bestIt.Name .. " on tile " .. tostring(tile) .. ", skipped 60 s")
                        else
                            -- game43: it stood still after reaching an item that was never taken (picked the same one
                            -- again and again). Reached but still there 3 s later = skipped 60 s, logged to find out why.
                            doing("waiting for Auto Pickup to take " .. bestIt.Name)
                            local t0 = os.clock()
                            while bestIt.Parent and os.clock() - t0 < 3 do task.wait(0.2) end
                            if bestIt.Parent then
                                -- backup: step right onto it and jump (game47: items 3-10 studs below you were not taken)
                                local ip0 = itemPart(bestIt)
                                local q = ip0 and partPos(ip0)
                                if q then
                                    hum:MoveTo(q)
                                    hum.Jump = true
                                    local t1 = os.clock()
                                    while bestIt.Parent and os.clock() - t1 < 2 do task.wait(0.2) end
                                end
                            end
                            if bestIt.Parent then
                                skipUntil[bestIt] = os.clock() + 60
                                local ip = itemPart(bestIt)
                                local d = ip and partPos(ip) and (partPos(ip) - hrp.Position)
                                log("Auto Farm: reached " .. bestIt.Name .. " but Auto Pickup did not take it (type "
                                    .. tostring(itemInfo(bestIt).type) .. attrs(bestIt) .. ", offset "
                                    .. (d and (fmt(d.X) .. ", " .. fmt(d.Y) .. ", " .. fmt(d.Z)) or "?") .. "), skipped 60 s")
                            end
                        end
                    else
                        doing("no scrap / battery in sight, walking a random way")
                        -- game45: menu said this while ESP showed a BATTERY PACK close by. Find-out log (every 10 s):
                        -- every DroppedItems item with a Resource-ish name or type, its ItemType, part and distance.
                        if os.clock() >= seenLogAt then
                            seenLogAt = os.clock() + 10
                            local all, out = folder and folder:GetChildren() or {}, {}
                            for _, it in ipairs(all) do
                                local n = string.lower(it.Name)
                                local ty = attr(it, "ItemType")
                                if ty == "Resource" or string.find(n, "batt", 1, true) or string.find(n, "scrap", 1, true) then
                                    local p = itemPart(it)
                                    local pos = p and partPos(p)
                                    out[#out + 1] = it.Name .. " [type " .. tostring(ty) .. ", cached " .. tostring(itemInfo(it).type)
                                        .. ", skip " .. tostring(skipUntil[it] ~= nil and os.clock() < skipUntil[it])
                                        .. ", " .. (pos and (math.floor((pos - hrp.Position).Magnitude) .. " studs") or "no part") .. "]"
                                    if #out >= 15 then break end
                                end
                            end
                            log("Auto Farm: none picked; DroppedItems " .. tostring(folder ~= nil) .. " " .. #all .. " items, need scrap "
                                .. tostring(needScrap) .. " batt " .. tostring(needBatt) .. ": " .. (#out > 0 and table.concat(out, "; ") or "no resources"))
                        end
                        -- nothing seen: walk 80 studs a random way, kept 90 studs inside the (round) wall
                        local h = borderR() - 90
                        local a, t = math.random() * math.pi * 2, nil
                        for _ = 1, 8 do  -- not toward a radiation spot
                            t = hrp.Position + Vector3.new(math.cos(a) * 80, 0, math.sin(a) * 80)
                            if not hot(t) then break end
                            a = a + math.pi / 4
                        end
                        if h > 0 and flat(t).Magnitude > h then local u = flat(t).Unit * h; t = Vector3.new(u.X, t.Y, u.Z) end
                        go(t, 20)
                    end
                end
            elseif not placedAt then
                -- Phase 2 + 3: walk out to the edge once, then place the pad 5 studs ahead (never in the middle of the map).
                -- game60 plan: out past the round wall, then a flat spot near the cliff 60+ studs from the wall. A refused
                -- pad = walk 150 studs along the ring and take the next spot (never back inside the wall).
                local okE, why = true, "next ring spot after " .. fails .. " refused tries"
                local _, _, hr0 = body()
                local past = hr0 and flat(hr0.Position).Magnitude >= borderR() + 10
                if fails == 0 and not past then
                    log("Auto Farm: pad in hand, walking out past the wall from " .. where(hrp.Position))
                    doing("pad crafted, walking out past the border wall")
                    -- Straight out from the centre (the wall is a circle). Blocked = the next direction, 45 degrees
                    -- further each time (8 in all); all 8 blocked = walk 100 studs a random way and try again.
                    local a0 = math.atan2(hrp.Position.Z, hrp.Position.X)
                    for _, k in ipairs({0, 1, -1, 2, -2, 3, -3, 4}) do
                        local ax = Vector3.new(math.cos(a0 + k * math.pi / 4), 0, math.sin(a0 + k * math.pi / 4))
                        okE, why = toEdge(ax)
                        if okE or not active() then break end
                        log("Auto Farm: walk out toward " .. tostring(ax) .. " failed (" .. why .. "), trying the next direction")
                    end
                    if not okE and active() then
                        local _, _, r = body()
                        if r then
                            local a = math.random() * math.pi * 2
                            log("Auto Farm: all 8 directions failed, walking 100 studs a random way to start over")
                            doing("blocked every way, moving 100 studs to try again")
                            noclipNow = true
                            go(r.Position + Vector3.new(math.cos(a) * 100, 0, math.sin(a) * 100), 15)
                            noclipNow = false
                        end
                    end
                elseif fails > 0 then
                    -- refused here: walk 150 studs along the ring, then the next spot
                    local p = hrp.Position
                    local na = math.atan2(p.Z, p.X) + ringDir * 150 / math.max(flat(p).Magnitude, 1)
                    local walkR = borderR() + 30
                    noclipNow = true
                    go(Vector3.new(math.cos(na) * walkR, p.Y, math.sin(na) * walkR), 30)
                    noclipNow = false
                end
                if okE and active() then okE = ringSpot() end
                ch, hum, hrp = body()
                log("Auto Farm: edge walk " .. (okE and "done" or "FAILED") .. " (" .. why .. ")" .. (hrp and (" at " .. where(hrp.Position)) or ""))
                local tool = padTool()
                local gap = hrp and (flat(hrp.Position).Magnitude - borderR())
                if okE and hum and tool and gap and gap < 30 then
                    -- game56: fell off the cliff, the game put you in the middle (0, 0) and the pad went there.
                    log("Auto Farm: not past the wall (" .. math.floor(gap) .. "), fell and got put back? Walking out again")
                    fails = 0
                elseif okE and hum and tool then
                    placing = true
                    doing("placing the Healing Pad")
                    pcall(function() hum:EquipTool(tool) end)
                    task.wait(1.5)  -- let the game's BlueprintClient start
                    -- Same as the game's BlueprintClient (saved v-25za): 8 studs ahead of the root part, a ray down 15
                    -- that only sees workspace.Map, pad exactly ON the hit point, turned like you. In Endless it has no
                    -- distance limit. v-25z sent hit + 0.63 (and once a zombie's head): every try was refused.
                    -- Owner: no walking around on a refusal; turn and try again, in this order: the void (out), front-
                    -- right, front-left, right, left, back (toward the map). Sloped ground ahead is skipped.
                    local mp = RaycastParams.new()
                    mp.FilterType, mp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {workspace:FindFirstChild("Map") or workspace}
                    local out, tries = outAxis(hrp.Position), {}
                    for _, deg in ipairs({0, -45, 45, -90, 90, 180}) do
                        if not padTool() then break end
                        local dir = CFrame.Angles(0, math.rad(deg), 0):VectorToWorldSpace(out)
                        pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir) end)
                        task.wait(0.3)
                        local ahead = (hrp.CFrame * CFrame.new(0, 0, -8)).Position
                        local hit = workspace:Raycast(ahead, Vector3.new(0, -15, 0), mp)
                        if not hit then
                            tries[#tries + 1] = deg .. ": no ground"
                        elseif hit.Normal.Y < 0.97 then
                            tries[#tries + 1] = deg .. ": slope"
                        else
                            local cf = CFrame.new(hit.Position) * hrp.CFrame.Rotation
                            local held = ch:FindFirstChild(PAD)
                            local okP, res = pcall(function()
                                return remote("Building", "PlaceStructure"):InvokeServer(held or tool, cf, 1)
                            end)
                            task.wait(1)
                            tries[#tries + 1] = deg .. ": " .. tostring(okP) .. " " .. tostring(res) .. (padTool() and "" or " PLACED")
                        end
                    end
                    placing = false
                    local cf = CFrame.new((hrp.CFrame * CFrame.new(0, 0, -8)).Position)
                    log("Auto Farm: place pad from " .. where(hrp.Position) .. " (turn degrees: result) " .. table.concat(tries, "; ")
                        .. ", pad still in hand " .. tostring(padTool() ~= nil))
                    if not padTool() then
                        placedAt, padPos, fails, noclipNow = os.clock(), cf.Position, 0, false
                        go(padPos, 10)
                        onPad = true
                    else
                        fails = fails + 1
                        -- Find-out: the pad's own placement script, saved once if this executor can decompile.
                        if fails == 1 and not NO_LOGS and type(decompile) == "function" and not isfile("SurviveTheApocalypse/BlueprintClient.txt") then
                            local okD, src = pcall(decompile, tool:FindFirstChild("BlueprintClient"))
                            pcall(writefile, "SurviveTheApocalypse/BlueprintClient.txt", tostring(okD and src or ("decompile failed: " .. tostring(src))))
                            log("Auto Farm: BlueprintClient source saved (" .. tostring(okD) .. ")")
                        end
                        task.wait(1)
                    end
                else
                    task.wait(5)
                end
            else
                doing("standing on the Healing Pad")
                -- backup: the pad can break. No Healing Pad within 8 studs of padPos for 3 s = loot and craft a new one.
                local seenPad = false
                local st = workspace:FindFirstChild("Structures")
                for _, m in ipairs(st and st:GetChildren() or {}) do
                    if m.Name == PAD then
                        local okP, piv = pcall(function() return m:GetPivot().Position end)
                        if okP and piv and (piv - padPos).Magnitude < 8 then seenPad = true; break end
                    end
                end
                if seenPad then padMissing = nil else padMissing = padMissing or os.clock() end
                if padMissing and os.clock() - padMissing > 3 then
                    log("Auto Farm: the pad at " .. where(padPos) .. " is gone, starting over (loot, craft, place)")
                    placedAt, padPos, padMissing, onPad = nil, nil, nil, false
                    if padWall then pcall(function() padWall:Destroy() end); padWall = nil end
                    return
                end
                onPad = true
                pcall(buildWall, padPos)
                -- Phase 4: stay on the pad (walk back after a respawn), then back to the lobby.
                if flat(padPos - hrp.Position).Magnitude > 4 then go(padPos, 60) end
            end
        end
        end)
        if not okLoop then log("Auto Farm ERROR (farm goes on): " .. tostring(errLoop)); task.wait(1) end
    end
end) end

-- ===== Main loop =============================================================
if not LOBBY and not remote("Interaction", "PickUpItem") then alert("PickUpItem remote not found (game update?)") end
local lastError = nil
task.spawn(function()
    task.wait(0.3)
    local lastTick, stallLogged, ownStep = os.clock(), 0, 0
    while true do
        -- v-15g (owner: running + turning the camera left loot behind): 0.05 s ticks (was 0.15); lobby stays slow.
        task.wait(LOBBY and 0.5 or 0.05)
        if _G.APOC_RUN ~= RUN then return end  -- a newer run took over
        -- v-20d test log (owner: loot lags at the Military Base raid): a tick that came over 1 s late = loop starved.
        local gap = os.clock() - lastTick
        lastTick = os.clock()
        if gap > 1 and not LOBBY and stallLogged < 20 then
            stallLogged = stallLogged + 1
            -- v-20j: "own step" = how long the last loot step itself took; the rest of the gap = other loops held it up.
            log("Loot loop stalled " .. fmt(gap) .. " s, own step " .. fmt(ownStep) .. " s (zombies listed by hitbox: "
                .. tostring(_G.HBX_NPC_COUNT or "?") .. ")")
        end
        local t0 = os.clock()
        local ok, err = try(stepOnce)
        ownStep = os.clock() - t0
        if not ok and tostring(err) ~= lastError then
            lastError = tostring(err)
            alert("Error: " .. lastError)
        end
    end
end)

say("Loaded (all-in-one). Auto Pickup is on the right side of the 'Apocalypse' tab.")
return {menu = drawMenu}
end
local apoc = startApocHelper()
-- Other games (owner, 2026-11-22): hitbox only, no loot part.
if not apoc then say("Not Survive the Apocalypse: hitbox only here.") end

-- ===== Menu (Matcha's own UI tab) ===========================================
-- Matcha draws and handles this menu itself, so no custom panel, dragging or key input is needed.
-- Re-running the script would otherwise stack a second tab with the same name and widget ids.
pcall(UI.RemoveTab, "NPC Hitbox"); pcall(UI.RemoveTab, "Apocalypse")
-- Matcha keeps widget ids from earlier runs until it is ejected, and re-creating the same ids left
-- the tab blank except "Enable". Each run therefore gets its own ids. _G.HBX_RUN also tells loops
-- from earlier runs (still running after a re-execute) to stop.
local RUN = tostring(math.floor(tick() * 1000))
setKillOn = function(v) pcall(UI.SetValue, "hbx_killOn_" .. RUN, v) end
_G.HBX_RUN = RUN
local function id(name) return "hbx_" .. name .. "_" .. RUN end
local menuErrorShown = false
UI.AddTab("Apocalypse", function(tab)
    -- Errors inside this callback are silent and cut the tab off after the failing widget; print the first one.
    local ok, err = try(function()
        local sec = tab:Section("NPC Hitbox", "Left")
        sec:Toggle(id("on"), "Enable", cfg.enabled)
        -- Own pcall: if Matcha lacks AddToHotkey, the rest of the tab must still draw.
        pcall(function()
            local kb = sec:Keybind(id("key"), cfg.hotkey, "toggle")
            kb:AddToHotkey("NPC Hitbox", id("on"))
            local k = kb:GetKey()
            if type(k) == "number" then cfg.hotkey = k end
        end)
        sec:Toggle(id("noplr"), "Ignore Players", cfg.ignorePlayers)
        sec:Toggle(id("corpse"), "Hide Dead NPCs", cfg.hideCorpses)
        if GAME_ID == "9098570654" then
            sec:Text("Hide Dead NPCs: does nothing in this game (Matcha cannot hide Bloaters)")
        end
        sec:InputText(id("folder"), "NPC Folder", cfg.folderName)
        sec:InputText(id("skip"), "Skip NPC Names", cfg.skipNames)
        sec:Combo(id("part"), "Hitbox Part", PARTS, cfg.partIndex - 1)
        sec:SliderFloat(id("size"), "Hitbox Size", 1, 25, cfg.hitboxSize, "%.1f")
        sec:SliderInt(id("dist"), "Max Distance", 1, 5000, cfg.maxDistance)
        sec:Toggle(id("fovOn"), "Camera Field Of View", cfg.fovOn)
        sec:SliderInt(id("fov"), "FOV Amount", 70, 120, cfg.fov)
        sec:Button("Scan World (debug)", function() task.spawn(function() scanWorld("button") end) end)
        if IS_PRO then  -- Owner 2026-11-18: Kill Aura is Pro-only, hidden on Regular
            sec = tab:Section("Kill Aura", "Left")  -- owner 2026-11-25: its own section with its own title
            sec:Toggle(id("killOn"), "Kill Aura (key switches it on/off)", cfg.killOn)
            sec:Combo(id("aimKey"), "Aura key", AIM_KEY_NAMES, aimKeyIndex(cfg.aimKey) - 1)
            sec:Combo(id("aimMode"), "Key mode", AIM_MODES, cfg.aimMode)
            sec:SliderInt(id("auraRange"), "Range (studs, green circle)", 10, 300, cfg.auraRange)
            sec:Toggle(id("auraSleep"), "Sleeping zombies (also shoot them)", cfg.auraSleep)
            sec:Toggle(id("auraGuide"), "Guide (circles and line)", cfg.auraGuide)
            sec:SliderInt(id("auraBounce"), "Bounce distance (studs)", 5, 150, cfg.auraBounce)
            sec:Combo(id("auraMode"), "Target", AURA_MODES, cfg.auraMode)
            sec:SliderInt(id("auraMin"), "Group size (Group Priority: shoot only if it reaches N zombies)", 1, 7, cfg.auraMin)
            sec:SliderInt(id("auraWait"), "Group wait (Group Priority: or shoot when a zombie stayed in the circle this many seconds, 0 = never)", 0, 15, cfg.auraWait)
            sec:Toggle(id("auraCraft"), "Craft ammo (at an Ammo Crate)", cfg.auraCraft)
            sec:SliderInt(id("auraCraftAt"), "Craft below (when reserve ammo is below this)", 1, 300, cfg.auraCraftAt)
            sec:Toggle(id("auraTurret"), "Vehicle turrets (fire your vehicle's turrets)", cfg.auraTurret)
            sec:Text(kill.status)
        end
    end)
    if not ok and not menuErrorShown then
        menuErrorShown = true
        alert("Menu error: " .. tostring(err))
    end
    if apoc then apoc.menu(tab) end
end)

local lastMenuFolder = cfg.folderName
local folderManual   = IS_APOC or folderFromFile
local redetectTime   = -math.huge  -- first folder scan on the first loop tick
local lastScan       = nil

-- One log line every 10 s, only when something in it changed.
local statusTime, lastStatus = 0, nil
local lastSettings = nil
local function logStatus()
    local now = os.clock()
    if now - statusTime < 10.0 then return end
    statusTime = now
    local expanded = 0
    for _ in pairs(HBX.expandedParts) do expanded = expanded + 1 end
    local set = "Settings: on=" .. tostring(cfg.enabled) .. " folder=" .. cfg.folderName
        .. " typed=" .. tostring(folderManual) .. " part=" .. tostring(PARTS[cfg.partIndex]) .. " size=" .. cfg.hitboxSize
        .. " dist=" .. cfg.maxDistance .. " ignorePlayers=" .. tostring(cfg.ignorePlayers) .. " hideDead=" .. tostring(cfg.hideCorpses)
        .. " skip=" .. cfg.skipNames
    if set ~= lastSettings then lastSettings = set; log(set) end
    local s = "Status: targets=" .. #HBX.cachedModels .. " expanded=" .. expanded .. " dead=" .. HBX.deaths
    if DEBUG_LOG and s ~= lastStatus then lastStatus = s; log(s) end
end

-- Write the settings file when something changed, at most every 3 s.
local saveTime, lastSaved = os.clock(), nil
local function saveSettings()
    local now = os.clock()
    if now - saveTime < 3.0 then return end
    saveTime = now
    local data = {folder = folderManual and cfg.folderName or ""}
    for _, k in ipairs(SAVED_KEYS) do data[k] = cfg[k] end
    local ok, text = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and type(text) == "string" and text ~= lastSaved then
        lastSaved = text
        if not pcall(writefile, SETTINGS_FILE, text) then say("Could not save " .. SETTINGS_FILE) end
    end
end

-- Every 10 s, in its own thread (a whole-map walk yields, and hitboxes must keep being rewritten meanwhile):
-- switch to the folder name with the most NPCs unless the user typed one, and refresh the list of folders
-- with the current name. Also runs for a typed name, so a nested folder with that name is found too.
local detecting, firstScanLogged = false, false
local function redetectFolder()
    local now = os.clock()
    if detecting or now - redetectTime < 10.0 then return end
    redetectTime = now
    -- A typed folder right under Workspace needs no map walk: GetNPCModels reads it directly. The walk over every
    -- descendant got slow on a grown map (Survive the Apocalypse, 2026-11-04: 3-6.5 s per scan, every 10 s), the
    -- main suspect for the Matcha freezes.
    if folderManual and not string.find(cfg.folderName, ",", 1, true) and (workspace:FindFirstChild(cfg.folderName) or (game.PlaceId == 90148635862803 or game.PlaceId == 80046280333935)) then
        HBX.containers = {}
        return
    end
    detecting = true
    task.spawn(function()
        crumb("scan", "folder scan")
        local ok, err = try(function()
            local t0 = os.clock()
            local name, count, containers, seen = detectNPCFolder()
            if not firstScanLogged then
                firstScanLogged = true
                log("Folder scan took " .. math.floor((os.clock() - t0) * 1000) .. " ms")
            end
            if seen ~= lastScan then lastScan = seen; log("Folder peaks: " .. seen) end
            if not folderManual and count > 0 and name ~= cfg.folderName then
                cfg.folderName = name
                pcall(UI.SetValue, id("folder"), name)
                say("NPC folder changed to: " .. name .. " (peak " .. count .. " NPCs)")
            end
            -- The folder box may hold several names ("NightEnemies, Zombies"), auto-picked or typed.
            local list = {}
            for name in string.gmatch(cfg.folderName, "[^,]+") do
                name = string.match(name, "^%s*(.-)%s*$")
                for _, c in ipairs(containers[name] or {}) do list[#list+1] = c end
            end
            HBX.containers = list
            HBX.cacheTime  = 0
        end)
        if not ok then alert("Folder scan error: " .. tostring(err)) end
        crumb("scan", "wait")
        detecting = false
    end)
end

-- Copy menu values into cfg. GetValue can be nil before the tab is first drawn, so keep cfg then.
local function readMenu()
    local on = UI.GetValue(id("on"))
    if type(on) == "boolean" then cfg.enabled = on end

    local noplr = UI.GetValue(id("noplr"))
    if type(noplr) == "boolean" and noplr ~= cfg.ignorePlayers then
        cfg.ignorePlayers = noplr
        HBX.cacheTime     = 0  -- rebuild the target list now, not in 2 s
    end

    local corpse = UI.GetValue(id("corpse"))
    if type(corpse) == "boolean" then cfg.hideCorpses = corpse end

    local skip = UI.GetValue(id("skip"))
    if type(skip) == "string" and skip ~= cfg.skipNames then
        cfg.skipNames = skip
        setSkipNames(skip)
        HBX.cacheTime = 0  -- rebuild the target list now; dropped NPCs shrink back via the restore pass
    end

    -- A new menu value that differs from cfg is the user's choice. Auto-detect's own SetValue shows up
    -- here as a value equal to cfg, so it does not lock the folder.
    local folder = UI.GetValue(id("folder"))
    if type(folder) == "string" and folder ~= lastMenuFolder then
        lastMenuFolder = folder
        if folder ~= cfg.folderName then
            folderManual   = folder ~= ""  -- clearing the box hands the folder back to auto-detect
            cfg.folderName = folder
            HBX.cacheTime  = 0
            HBX.containers = {}            -- they belong to the old name; rescan now
            redetectTime   = -math.huge
        end
    end

    local part = UI.GetValue(id("part"))  -- 0-based index
    if type(part) == "number" and PARTS[part + 1] and part + 1 ~= cfg.partIndex then
        cfg.partIndex     = part + 1
        HBX.partTypeCache = {}
    end

    local size = UI.GetValue(id("size"))
    if type(size) == "number" then cfg.hitboxSize = size end

    local dist = UI.GetValue(id("dist"))
    if type(dist) == "number" then cfg.maxDistance = dist end

    local k = UI.GetValue(id("aimKey"))  -- 0-based index
    if type(k) == "number" and AIM_KEYS[k + 1] then cfg.aimKey = AIM_KEYS[k + 1][2] end
    local mode = UI.GetValue(id("aimMode"))
    if type(mode) == "number" and AIM_MODES[mode + 1] then cfg.aimMode = mode end
    local ko = UI.GetValue(id("killOn"))
    if ko == true and not IS_PRO then
        ko = false
        pcall(UI.SetValue, id("killOn"), false)
        pcall(notify, "Kill Aura needs Matcha Pro", "NPC Hitbox", 5)
    end
    if type(ko) == "boolean" then
        if ko and not cfg.killOn then log("Kill Aura armed") end
        cfg.killOn = ko
    end
    local ar = UI.GetValue(id("auraRange"))
    if type(ar) == "number" then cfg.auraRange = ar end
    local asl = UI.GetValue(id("auraSleep"))
    if type(asl) == "boolean" then cfg.auraSleep = asl end
    local agd = UI.GetValue(id("auraGuide"))
    if type(agd) == "boolean" then cfg.auraGuide = agd end
    local ab = UI.GetValue(id("auraBounce"))
    if type(ab) == "number" then cfg.auraBounce = ab end
    local amn = UI.GetValue(id("auraMin"))
    if type(amn) == "number" then cfg.auraMin = amn end
    local amd = UI.GetValue(id("auraMode"))
    if type(amd) == "number" then cfg.auraMode = math.clamp(math.floor(amd), 0, #AURA_MODES - 1) end
    local aw = UI.GetValue(id("auraWait"))
    if type(aw) == "number" then cfg.auraWait = aw end
    local acr = UI.GetValue(id("auraCraft"))
    if type(acr) == "boolean" then cfg.auraCraft = acr end
    local aca = UI.GetValue(id("auraCraftAt"))
    if type(aca) == "number" then cfg.auraCraftAt = aca end
    local atu = UI.GetValue(id("auraTurret"))
    if type(atu) == "boolean" then cfg.auraTurret = atu end

    local fovOn = UI.GetValue(id("fovOn"))
    if type(fovOn) == "boolean" then cfg.fovOn = fovOn end
    local fov = UI.GetValue(id("fov"))
    if type(fov) == "number" then cfg.fov = fov end
end

-- ===== Camera field of view ==================================================
-- Owner: the FOV is their sign the script is running; it must never be removed again (v-14b removed it, v-14c is the
-- original v-04j code back). Switching it off writes the game's FOV back once.
-- Runs in the Apocalypse lobby too (owner's choice, v-14d), although both Roblox crashes (2026-11-14 17:17, 17:22)
-- came right after FOV writes there. If the lobby crashes again, that is the known risk, not a new bug.
-- v-14e: the "normal" FOV is the game's 70 (its sniper scope goes 15 and back to 70), not the first value read: the
-- match intro cutscene tweens the camera (likely cause), so v-04j could note a wrong base in matches and never write.
local GAME_FOV = 70
-- Value to write, or nil. Replaces only the game's normal FOV or our own last write, so a scope / Unleash zoom stays.
local function fovTarget(cur, want, last)
    if math.abs(cur - want) < 0.5 then return nil end
    if math.abs(cur - GAME_FOV) < 0.5 or (last and math.abs(cur - last) < 0.5) then return want end
    return nil
end
assert(fovTarget(70, 120) == 120 and fovTarget(15, 120) == nil and fovTarget(120, 70, 120) == 70
    and fovTarget(84, 70, 120) == nil and fovTarget(100, 120, 100) == 120 and fovTarget(70, 70) == nil)
local fovState = {last = nil, want = nil, since = 0, nextT = 0, logged = 0}
local function fovStep()
    local now = os.clock()
    if now < fovState.nextT then return end
    fovState.nextT = now + 0.2
    -- Act only once the switch / slider has been still for 1 s: fast on/off writes crashed Roblox (2026-11-14 17:38).
    local want = cfg.fovOn and cfg.fov or GAME_FOV
    if want ~= fovState.want then fovState.want, fovState.since = want, now; return end
    if now - fovState.since < 1 then return end
    local cam = workspace.CurrentCamera
    local ok, cur = pcall(function() return cam.FieldOfView end)
    if not ok or type(cur) ~= "number" then return end
    local v = fovTarget(cur, want, fovState.last)
    if not v then return end
    local wok = pcall(function() cam.FieldOfView = v end)
    fovState.last = cfg.fovOn and v or nil
    if fovState.logged < 5 then
        fovState.logged = fovState.logged + 1
        local _, back = pcall(function() return cam.FieldOfView end)
        log("FOV: camera showed " .. math.floor(cur + 0.5) .. ", wrote " .. v .. " (ok " .. tostring(wok) .. "), reads back "
            .. tostring(back))
    end
end

-- ===== Line-up aim, every frame ==============================================
-- Own RenderStepped connection: the main loop can stall for a second in big waves. A newer run disconnects it.
local RunService = game:GetService("RunService")
local IN_LOBBY = (game.PlaceId == 90148635862803 or game.PlaceId == 80046280333935)
local aimConn, aimErrorShown, fovErrorShown = nil, false, false
pcall(function()
    aimConn = RunService.RenderStepped:Connect(function()
        if _G.HBX_RUN ~= RUN then
            pcall(function() aimConn:Disconnect() end)
            _G.HBX_AURA_ON = false
            -- Give the next run the game's own FOV, or it would note ours as "normal".
            if fovState.last and _G.HBX_RUN ~= "teleport" then pcall(function() workspace.CurrentCamera.FieldOfView = GAME_FOV end) end
            if aimLabel then pcall(function() aimLabel:Remove() end); aimLabel = nil end
            for _, l in ipairs(ring) do pcall(function() l:Remove() end) end
            for _, l in ipairs(bounceRing) do pcall(function() l:Remove() end) end
            if focusLine then pcall(function() focusLine:Remove() end) end
            killRelease()
            return
        end
        local ok, err = try(aimOrKill)
        if ok then ok, err = try(aimLabelFrame) end
        if ok then ok, err = try(auraRingFrame) end
        if not ok and not aimErrorShown then aimErrorShown = true; alert("Aim error: " .. tostring(err)) end
        ok, err = try(fovStep)
        if not ok and not fovErrorShown then fovErrorShown = true; alert("FOV error: " .. tostring(err)) end
    end)
end)
if not aimConn then say("Line-up Aim is off: RenderStepped is not available") end

-- ===== Main loop =============================================================
-- v-14f: a teleport has started. A run that keeps working on the old world froze Matcha (2026-11-14 17:43:22 and
-- 17:46:57, a few s after "missing method 'GetPlayers'"), and then autoexec never started the next run.
local START_PLACE = game.PlaceId
local function teleportSign()
    if not pcall(function() return Players:GetPlayers() end) then return "player list gone" end
    local ok, lp = pcall(function() return Players.LocalPlayer end)
    if not ok or not lp then return "local player gone" end
    local okP, place = pcall(function() return game.PlaceId end)
    if okP and place ~= START_PLACE then return "place changed" end
    return nil
end
local tpNext = 0
local lastError = nil
task.spawn(function()
    task.wait(0.3)  -- let a loop from an earlier run notice HBX_RUN and restore its parts first
    while true do
        crumb("main", "wait")
        task.wait(IN_LOBBY and 0.5 or 0.05)
        if _G.HBX_RUN ~= RUN then
            HBX:RestoreAll()  -- a newer run took over; give it the parts back at normal size
            return
        end
        if os.clock() >= tpNext then
            tpNext = os.clock() + 0.5
            local why = not EXEC_COPY and teleportSign()  -- EXEC_COPY: other-executor copy keeps running (owner)
            if why then
                log("Teleport started (" .. why .. "): the script stops here so Matcha does not freeze;"
                    .. " autoexec should start it again (if not, press Run)")
                _G.HBX_RUN, _G.APOC_RUN = "teleport", "teleport"  -- stops every loop; FOV and parts are not touched
                pcall(function() UI.RemoveTab("Apocalypse") end)
                pcall(function() UI.RemoveTab("NPC Hitbox") end)
                return  -- no RestoreAll: the old world's parts are gone with the teleport
            end
        end
        -- pcall: an uncaught error would end this loop silently; log each new error message once instead.
        local ok, err = try(function()
            crumb("main", "hitbox menu/status")
            readMenu()
            redetectFolder()
            saveSettings()
            logStatus()
            -- No automatic World Scan (owner, 2026-11-18): only the "Scan World (debug)" button runs it.

            if cfg.enabled and not IN_LOBBY then
                crumb("main", "hitbox expand")
                HBX:ExpandHitboxes()
                crumb("main", "hitbox dead clones")
                if cfg.hideCorpses then HBX:FixDeadClones() end
                crumb("main", "hitbox cleanup")
                HBX:Cleanup()
                crumb("main", "hitbox corpses")
                HBX:UpdateCorpses()
            elseif HBX.wasEnabled then
                HBX:RestoreAll()
            end
            HBX.wasEnabled = cfg.enabled
        end)
        if not ok and tostring(err) ~= lastError then
            lastError = tostring(err)
            alert("Error: " .. lastError)
        end
    end
end)

say("Loaded. Open the Matcha menu and use the 'Apocalypse' tab.")
