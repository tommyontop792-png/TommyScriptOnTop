--==================== UI REDISEÑADA ====================
local TweenService = game:GetService("TweenService")

-- ================= PALETA DE COLORES =================
local THEMES = {
    Purple = {main = Color3.fromRGB(168, 85, 247), glow = Color3.fromRGB(216, 180, 254)},
    Blue   = {main = Color3.fromRGB(59, 130, 246), glow = Color3.fromRGB(147, 197, 253)},
    Red    = {main = Color3.fromRGB(239, 68, 68),  glow = Color3.fromRGB(252, 165, 165)},
    Green  = {main = Color3.fromRGB(34, 197, 94),  glow = Color3.fromRGB(134, 239, 172)},
    Pink   = {main = Color3.fromRGB(236, 72, 153), glow = Color3.fromRGB(249, 168, 212)},
    Gold   = {main = Color3.fromRGB(245, 158, 11), glow = Color3.fromRGB(253, 224, 71)},
    Cyan   = {main = Color3.fromRGB(6, 182, 212),  glow = Color3.fromRGB(103, 232, 249)},
}
local THEME_LIST = {"Purple", "Blue", "Red", "Green", "Pink", "Gold", "Cyan"}

local ACCENT      = THEMES.Purple.main
local ACCENT_GLOW = THEMES.Purple.glow

-- Colores base (dark mode elegante)
local C_BG_MAIN    = Color3.fromRGB(15, 15, 22)
local C_BG_PANEL   = Color3.fromRGB(22, 22, 33)
local C_BG_ITEM    = Color3.fromRGB(30, 30, 44)
local C_BG_HOVER   = Color3.fromRGB(38, 38, 56)
local C_BORDER     = Color3.fromRGB(45, 45, 65)
local C_TEXT       = Color3.fromRGB(240, 240, 250)
local C_TEXT_MUTED = Color3.fromRGB(140, 140, 165)
local C_OFF        = Color3.fromRGB(55, 55, 75)
local C_DANGER     = Color3.fromRGB(239, 68, 68)

local FONT_TITLE  = Enum.Font.GothamBlack
local FONT_BOLD   = Enum.Font.GothamBold
local FONT_MED    = Enum.Font.GothamMedium
local FONT_REG    = Enum.Font.Gotham

-- ================= HELPERS =================
local themed = {}
local function lighten(c, a) return c:Lerp(Color3.new(1,1,1), a) end
local function darken(c, a) return c:Lerp(Color3.new(0,0,0), a) end

local function acc(inst, prop, mix)
    table.insert(themed, {inst, prop, mix})
    inst[prop] = mix and mix(ACCENT) or ACCENT
    return inst
end

local function mk(class, parent, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) return mk("UICorner", o, {CornerRadius = UDim.new(0, r)}) end
local function stroke(o, c, t, tr) return mk("UIStroke", o, {Color = c, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}) end
local function padding(o, t, b, l, r)
    return mk("UIPadding", o, {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
    })
end
local function tween(o, t, props, style, dir)
    local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(o, info, props); tw:Play(); return tw
end

-- ================= SCREEN GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "TommyHub67_UI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

-- ================= VENTANA PRINCIPAL =================
local WIN_W, WIN_H = 560, 400
local main = mk("Frame", gui, {
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C_BG_MAIN,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
})
corner(main, 16)
local mainStroke = acc(stroke(main, ACCENT, 1.5, 0.5), "Color")
mk("UIGradient", main, {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 25, 45)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 20)),
    })
})

-- Efecto glow en el borde superior
local topGlow = mk("Frame", main, {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
})
acc(topGlow, "BackgroundColor3")
mk("UIGradient", topGlow, {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
})

-- Animación de apertura
main.Size = UDim2.new(0, 0, 0, 0)
tween(main, 0.4, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ================= HEADER =================
local header = mk("Frame", main, {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
})

-- Logo animado
local logoFrame = mk("Frame", header, {
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, 16, 0, 11),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
})
corner(logoFrame, 11)
acc(logoFrame, "BackgroundColor3")
local logoGradient = mk("UIGradient", logoFrame, {
    Rotation = 45,
    Color = ColorSequence.new(ACCENT, lighten(ACCENT, 0.4))
})
acc(logoGradient, "Color", function(c) return ColorSequence.new(c, lighten(c, 0.4)) end)
mk("TextLabel", logoFrame, {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "T",
    Font = FONT_TITLE,
    TextSize = 20,
    TextColor3 = Color3.new(1,1,1),
})

-- Título
local titleLbl = mk("TextLabel", header, {
    Text = "TOMMY HUB 67",
    Font = FONT_TITLE,
    TextSize = 17,
    TextColor3 = Color3.new(1,1,1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 220, 0, 20),
    Position = UDim2.new(0, 62, 0, 8),
    TextXAlignment = Enum.TextXAlignment.Left,
})
local titleGrad = mk("UIGradient", titleLbl, {
    Color = ColorSequence.new(ACCENT, lighten(ACCENT, 0.6))
})
acc(titleGrad, "Color", function(c) return ColorSequence.new(c, lighten(c, 0.6)) end)

mk("TextLabel", header, {
    Text = "@accountxz  ·  Blox Fruits  ·  v67",
    Font = FONT_MED,
    TextSize = 10,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 220, 0, 14),
    Position = UDim2.new(0, 62, 0, 30),
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Botones de la ventana
local function topBtn(txt, x, col, cb)
    local b = mk("TextButton", header, {
        Text = txt, Font = FONT_BOLD, TextSize = 14, TextColor3 = col,
        BackgroundColor3 = C_BG_ITEM,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, x, 0, 15),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    corner(b, 9)
    local st = stroke(b, C_BORDER, 1, 0.6)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = C_BG_HOVER})
        tween(st, 0.15, {Color = col, Transparency = 0.3})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = C_BG_ITEM})
        tween(st, 0.15, {Color = C_BORDER, Transparency = 0.6})
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- Divider bajo el header
local divider = mk("Frame", main, {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 58),
    BackgroundColor3 = C_BORDER,
    BorderSizePixel = 0,
    BackgroundTransparency = 0.4,
})

-- ================= SIDEBAR =================
local sidebar = mk("Frame", main, {
    Size = UDim2.new(0, 140, 1, -74),
    Position = UDim2.new(0, 12, 0, 66),
    BackgroundColor3 = C_BG_PANEL,
    BorderSizePixel = 0,
})
corner(sidebar, 12)
stroke(sidebar, C_BORDER, 1, 0.7)

local tabsHolder = mk("ScrollingFrame", sidebar, {
    Size = UDim2.new(1, -12, 1, -40),
    Position = UDim2.new(0, 6, 0, 6),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})
mk("UIListLayout", tabsHolder, {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Footer del sidebar
mk("TextLabel", sidebar, {
    Text = "F4  ·  Mostrar / Ocultar",
    Font = FONT_MED,
    TextSize = 9,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -20),
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- ================= CONTENIDO =================
local content = mk("Frame", main, {
    Size = UDim2.new(1, -164, 1, -74),
    Position = UDim2.new(0, 156, 0, 66),
    BackgroundColor3 = C_BG_PANEL,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
corner(content, 12)
stroke(content, C_BORDER, 1, 0.7)

-- Barra de búsqueda arriba del contenido
local searchBar = mk("Frame", content, {
    Size = UDim2.new(1, -16, 0, 32),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = C_BG_ITEM,
    BorderSizePixel = 0,
})
corner(searchBar, 9)
stroke(searchBar, C_BORDER, 1, 0.6)

mk("TextLabel", searchBar, {
    Text = "🔍",
    Font = FONT_MED,
    TextSize = 13,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 1, 0),
    Position = UDim2.new(0, 4, 0, 0),
})

local searchBox = mk("TextBox", searchBar, {
    Size = UDim2.new(1, -32, 1, 0),
    Position = UDim2.new(0, 28, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT_MED,
    TextSize = 11,
    TextColor3 = C_TEXT,
    PlaceholderText = "Buscar función...",
    PlaceholderColor3 = C_TEXT_MUTED,
    Text = "",
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
})

-- ================= PÁGINAS =================
local ICONS = {
    Combat   = "⚔",
    Glitches = "✨",
    Soru     = "⚡",
    ESP      = "👁",
    Dungeons = "🏰",
    Misc     = "⚙",
}

local pages, tabObjs, currentPage, tabCount = {}, {}, nil, 0

local function showPage(name)
    if currentPage == name then return end
    currentPage = name
    for n, p in pairs(pages) do
        if n == name then
            p.Visible = true
            p.Position = UDim2.new(0, 8, 0, 48)
            tween(p, 0.2, {Position = UDim2.new(0, 8, 0, 48)})
        else
            p.Visible = false
        end
    end
    for n, t in pairs(tabObjs) do
        local on = (n == name)
        tween(t.bar, 0.25, {Size = on and UDim2.new(0, 3, 0, 20) or UDim2.new(0, 3, 0, 0)})
        tween(t.btn, 0.2, {
            BackgroundColor3 = on and ACCENT or C_BG_ITEM,
            BackgroundTransparency = on and 0.15 or 0,
        })
        tween(t.icon, 0.2, {TextColor3 = on and Color3.new(1,1,1) or C_TEXT_MUTED})
        tween(t.lbl, 0.2, {TextColor3 = on and Color3.new(1,1,1) or C_TEXT})
    end
end

local function newPage(name)
    local sf = mk("ScrollingFrame", content, {
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ACCENT,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ClipsDescendants = true,
    })
    acc(sf, "ScrollBarImageColor3")
    mk("UIListLayout", sf, {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    padding(sf, 0, 12, 0, 8)
    pages[name] = sf
    tabCount = tabCount + 1

    -- Botón de tab
    local btn = mk("TextButton", tabsHolder, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C_BG_ITEM,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = tabCount,
    })
    corner(btn, 9)
    local btnStroke = stroke(btn, C_BORDER, 1, 0.7)
    local bar = mk("Frame", btn, {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    })
    acc(bar, "BackgroundColor3")
    corner(bar, 2)

    local icon = mk("TextLabel", btn, {
        Text = ICONS[name] or "•",
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = C_TEXT_MUTED,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
    })

    local lbl = mk("TextLabel", btn, {
        Text = name,
        Font = FONT_BOLD,
        TextSize = 11,
        TextColor3 = C_TEXT,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundColor3 = C_BG_HOVER})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundColor3 = C_BG_ITEM})
        end
    end)
    btn.MouseButton1Click:Connect(function() showPage(name) end)

    tabObjs[name] = {btn = btn, bar = bar, icon = icon, lbl = lbl}
    return sf
end

-- ================= COMPONENTES =================
local orderN = {}
local function nextOrder(page) orderN[page] = (orderN[page] or 0) + 1; return orderN[page] end
local reg = {}

local function section(page, text)
    local f = mk("Frame", page, {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(page),
    })
    local l = mk("TextLabel", f, {
        Text = string.upper(text),
        Font = FONT_TITLE,
        TextSize = 10,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 4, 0, 2),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    acc(l, "TextColor3")
    local line = mk("Frame", f, {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C_BORDER,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.5,
    })
end

local function row(page, h)
    local f = mk("Frame", page, {
        Size = UDim2.new(1, 0, 0, h or 36),
        BackgroundColor3 = C_BG_ITEM,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(page),
    })
    corner(f, 9)
    local st = stroke(f, C_BORDER, 1, 0.7)
    f.MouseEnter:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = C_BG_HOVER})
        tween(st, 0.15, {Color = ACCENT, Transparency = 0.6})
    end)
    f.MouseLeave:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = C_BG_ITEM})
        tween(st, 0.15, {Color = C_BORDER, Transparency = 0.7})
    end)
    return f, st
end

local function rowLabel(f, text, rightPad)
    return mk("TextLabel", f, {
        Text = text,
        Font = FONT_MED,
        TextSize = 11,
        TextColor3 = C_TEXT,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(rightPad or 66), 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

-- Toggle mejorado
local function toggle(page, text, key, cb)
    local f = row(page, 36); rowLabel(f, text, 76)
    local trackF = mk("Frame", f, {
        Size = UDim2.new(0, 46, 0, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = C_OFF,
        BorderSizePixel = 0,
    })
    corner(trackF, 11)
    local trackStroke = stroke(trackF, C_BORDER, 1, 0.5)
    local knob = mk("Frame", trackF, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
    })
    corner(knob, 8)
    local hit = mk("TextButton", f, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    })

    local function refresh(instant)
        local on = S[key]
        local col = on and ACCENT or C_OFF
        local pos = on and UDim2.new(0, 27, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        if instant then
            trackF.BackgroundColor3 = col
            knob.Position = pos
            trackStroke.Transparency = on and 0.2 or 0.5
        else
            tween(trackF, 0.2, {BackgroundColor3 = col})
            tween(knob, 0.25, {Position = pos}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(trackStroke, 0.2, {Transparency = on and 0.2 or 0.5})
        end
    end
    refresh(true)
    reg[key] = {refresh = refresh, cb = cb}
    hit.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        refresh()
        if cb then pcall(cb, S[key]) end
    end)
end

-- Stepper mejorado
local function stepper(page, text, key, minV, maxV, step, suffix)
    local f = row(page, 42)
    local lbl = rowLabel(f, text, 130)
    lbl.Size = UDim2.new(1, -130, 1, -10)
    local function fmt(v)
        v = math.floor(v * 100 + 0.5) / 100
        if v == math.floor(v) then v = math.floor(v) end
        return tostring(v) .. (suffix or "")
    end
    local function mkBtn(txt, x)
        local b = mk("TextButton", f, {
            Text = txt,
            Font = FONT_TITLE,
            TextSize = 14,
            TextColor3 = Color3.new(1,1,1),
            BackgroundColor3 = darken(ACCENT, 0.3),
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, x, 0, 8),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        corner(b, 7)
        acc(b, "BackgroundColor3", function(c) return darken(c, 0.3) end)
        b.MouseEnter:Connect(function() tween(b, 0.1, {BackgroundColor3 = ACCENT}) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = darken(ACCENT, 0.3)}) end)
        return b
    end
    local minus = mkBtn("−", -122)
    local val = mk("TextLabel", f, {
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -92, 0, 8),
        BackgroundTransparency = 1,
        Font = FONT_BOLD,
        TextSize = 12,
        TextColor3 = C_TEXT,
    })
    local plus = mkBtn("+", -28)
    local barBG = mk("Frame", f, {
        Size = UDim2.new(1, -28, 0, 3),
        Position = UDim2.new(0, 14, 1, -8),
        BackgroundColor3 = C_OFF,
        BorderSizePixel = 0,
    })
    corner(barBG, 2)
    local fill = mk("Frame", barBG, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    })
    acc(fill, "BackgroundColor3")
    corner(fill, 2)

    local function update()
        val.Text = fmt(S[key])
        local frac = (S[key] - minV) / math.max(maxV - minV, 1e-9)
        tween(fill, 0.2, {Size = UDim2.new(math.clamp(frac, 0, 1), 0, 1, 0)})
    end
    update()
    reg[key] = {update = update}
    minus.MouseButton1Click:Connect(function()
        S[key] = math.max(minV, math.floor((S[key] - step) * 100 + 0.5) / 100); update()
    end)
    plus.MouseButton1Click:Connect(function()
        S[key] = math.min(maxV, math.floor((S[key] + step) * 100 + 0.5) / 100); update()
    end)
end

-- Botón mejorado
local function button(page, text, cb)
    local f, st = row(page, 36)
    st.Transparency = 0.5
    acc(st, "Color")
    local b = mk("TextButton", f, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = FONT_BOLD,
        TextSize = 11,
        AutoButtonColor = false,
        TextColor3 = C_TEXT,
    })
    b.MouseEnter:Connect(function() tween(b, 0.15, {TextColor3 = lighten(ACCENT, 0.5)}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {TextColor3 = C_TEXT}) end)
    b.MouseButton1Click:Connect(function()
        tween(f, 0.08, {BackgroundColor3 = darken(ACCENT, 0.5)})
        task.delay(0.1, function() tween(f, 0.2, {BackgroundColor3 = C_BG_ITEM}) end)
        cb(b)
    end)
    return b
end

-- Ciclo mejorado
local function cycle(page, prefix, key, options, cb)
    local btn = button(page, prefix .. tostring(S[key]), function(b)
        local idx = table.find(options, S[key]) or 0
        S[key] = options[(idx % #options) + 1]
        b.Text = prefix .. tostring(S[key])
        if cb then cb(S[key]) end
    end)
    reg[key] = {update = function() btn.Text = prefix .. tostring(S[key]) end}
end

-- Aplicar tema
local function applyTheme(name)
    local theme = THEMES[name] or THEMES.Purple
    ACCENT = theme.main
    ACCENT_GLOW = theme.glow
    for _, t in ipairs(themed) do
        pcall(function() t[1][t[2]] = t[3] and t[3](ACCENT) or ACCENT end)
    end
    for _, e in pairs(reg) do if e.refresh then e.refresh(true) end end
    if currentPage then
        local cp = currentPage
        currentPage = nil
        showPage(cp)
    end
end

-- ================= BOTÓN FLOTANTE =================
local openBtn = mk("TextButton", gui, {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 18, 0, 18),
    Text = "T",
    Font = FONT_TITLE,
    TextSize = 22,
    TextColor3 = Color3.new(1,1,1),
    BackgroundColor3 = ACCENT,
    Visible = false,
    AutoButtonColor = false,
    BorderSizePixel = 0,
})
corner(openBtn, 26)
acc(openBtn, "BackgroundColor3")
local openStroke = mk("UIStroke", openBtn, {Color = ACCENT_GLOW, Thickness = 2, Transparency = 0.3})
acc(openStroke, "Color", function(c) return lighten(c, 0.4) end)
local openCorner = mk("UICorner", openBtn, {CornerRadius = UDim.new(1, 0)})

-- Animación pulsante del botón flotante
task.spawn(function()
    while gui.Parent do
        if openBtn.Visible then
            tween(openBtn, 1.2, {Size = UDim2.new(0, 56, 0, 56)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tween(openBtn, 1.2, {Size = UDim2.new(0, 52, 0, 52)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
end)

-- ================= SISTEMA DE NOTIFICACIONES =================
local notifHolder = mk("Frame", gui, {
    Size = UDim2.new(0, 260, 1, -40),
    Position = UDim2.new(1, -270, 0, 20),
    BackgroundTransparency = 1,
})
mk("UIListLayout", notifHolder, {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local notifCount = 0
local function notify(title, msg, color)
    notifCount = notifCount + 1
    color = color or ACCENT
    local n = mk("Frame", notifHolder, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C_BG_PANEL,
        BorderSizePixel = 0,
        LayoutOrder = -notifCount,
        ClipsDescendants = true,
    })
    corner(n, 10)
    stroke(n, color, 1.5, 0.4)
    local accentBar = mk("Frame", n, {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    corner(accentBar, 2)
    mk("TextLabel", n, {
        Text = title,
        Font = FONT_BOLD,
        TextSize = 11,
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -22, 0, 16),
        Position = UDim2.new(0, 16, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    mk("TextLabel", n, {
        Text = msg,
        Font = FONT_MED,
        TextSize = 10,
        TextColor3 = C_TEXT_MUTED,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -22, 0, 14),
        Position = UDim2.new(0, 16, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })
    tween(n, 0.35, {Size = UDim2.new(1, 0, 0, 50)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(3, function()
        if n and n.Parent then
            tween(n, 0.3, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            task.wait(0.3)
            if n then n:Destroy() end
        end
    end)
end

-- ================= FUNCIONES VENTANA =================
local function setOpen(v)
    if v then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        tween(main, 0.35, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        openBtn.Visible = false
    else
        tween(main, 0.25, {Size = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.25)
        main.Visible = false
        openBtn.Visible = true
    end
end

openBtn.MouseButton1Click:Connect(function() setOpen(true) end)

-- Botones de ventana
topBtn("−", -78, C_TEXT_MUTED, function() setOpen(false) end)
topBtn("✕", -42, C_DANGER, function()
    notify("Tommy Hub 67", "Cerrando script...", C_DANGER)
    task.wait(0.4)
    cleanup()
end)

-- Arrastrar ventana
do
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

-- Hotkey F4
track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.F4 then
        if main.Visible then setOpen(false) else setOpen(true) end
    end
end))

-- Búsqueda funcional
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(searchBox.Text)
    local page = pages[currentPage]
    if not page then return end
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("Frame") then
            local found = false
            for _, c in ipairs(child:GetDescendants()) do
                if c:IsA("TextLabel") and string.find(string.lower(c.Text), q) then
                    found = true; break
                end
            end
            child.Visible = (q == "" or found)
        end
    end
end)

-- ================= FIN DE UI =================--==================== UI REDISEÑADA ====================
local TweenService = game:GetService("TweenService")

-- ================= PALETA DE COLORES =================
local THEMES = {
    Purple = {main = Color3.fromRGB(168, 85, 247), glow = Color3.fromRGB(216, 180, 254)},
    Blue   = {main = Color3.fromRGB(59, 130, 246), glow = Color3.fromRGB(147, 197, 253)},
    Red    = {main = Color3.fromRGB(239, 68, 68),  glow = Color3.fromRGB(252, 165, 165)},
    Green  = {main = Color3.fromRGB(34, 197, 94),  glow = Color3.fromRGB(134, 239, 172)},
    Pink   = {main = Color3.fromRGB(236, 72, 153), glow = Color3.fromRGB(249, 168, 212)},
    Gold   = {main = Color3.fromRGB(245, 158, 11), glow = Color3.fromRGB(253, 224, 71)},
    Cyan   = {main = Color3.fromRGB(6, 182, 212),  glow = Color3.fromRGB(103, 232, 249)},
}
local THEME_LIST = {"Purple", "Blue", "Red", "Green", "Pink", "Gold", "Cyan"}

local ACCENT      = THEMES.Purple.main
local ACCENT_GLOW = THEMES.Purple.glow

-- Colores base (dark mode elegante)
local C_BG_MAIN    = Color3.fromRGB(15, 15, 22)
local C_BG_PANEL   = Color3.fromRGB(22, 22, 33)
local C_BG_ITEM    = Color3.fromRGB(30, 30, 44)
local C_BG_HOVER   = Color3.fromRGB(38, 38, 56)
local C_BORDER     = Color3.fromRGB(45, 45, 65)
local C_TEXT       = Color3.fromRGB(240, 240, 250)
local C_TEXT_MUTED = Color3.fromRGB(140, 140, 165)
local C_OFF        = Color3.fromRGB(55, 55, 75)
local C_DANGER     = Color3.fromRGB(239, 68, 68)

local FONT_TITLE  = Enum.Font.GothamBlack
local FONT_BOLD   = Enum.Font.GothamBold
local FONT_MED    = Enum.Font.GothamMedium
local FONT_REG    = Enum.Font.Gotham

-- ================= HELPERS =================
local themed = {}
local function lighten(c, a) return c:Lerp(Color3.new(1,1,1), a) end
local function darken(c, a) return c:Lerp(Color3.new(0,0,0), a) end

local function acc(inst, prop, mix)
    table.insert(themed, {inst, prop, mix})
    inst[prop] = mix and mix(ACCENT) or ACCENT
    return inst
end

local function mk(class, parent, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) return mk("UICorner", o, {CornerRadius = UDim.new(0, r)}) end
local function stroke(o, c, t, tr) return mk("UIStroke", o, {Color = c, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}) end
local function padding(o, t, b, l, r)
    return mk("UIPadding", o, {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
    })
end
local function tween(o, t, props, style, dir)
    local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(o, info, props); tw:Play(); return tw
end

-- ================= SCREEN GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "TommyHub67_UI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

-- ================= VENTANA PRINCIPAL =================
local WIN_W, WIN_H = 560, 400
local main = mk("Frame", gui, {
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C_BG_MAIN,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
})
corner(main, 16)
local mainStroke = acc(stroke(main, ACCENT, 1.5, 0.5), "Color")
mk("UIGradient", main, {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 25, 45)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 20)),
    })
})

-- Efecto glow en el borde superior
local topGlow = mk("Frame", main, {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
})
acc(topGlow, "BackgroundColor3")
mk("UIGradient", topGlow, {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
})

-- Animación de apertura
main.Size = UDim2.new(0, 0, 0, 0)
tween(main, 0.4, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ================= HEADER =================
local header = mk("Frame", main, {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
})

-- Logo animado
local logoFrame = mk("Frame", header, {
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, 16, 0, 11),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
})
corner(logoFrame, 11)
acc(logoFrame, "BackgroundColor3")
local logoGradient = mk("UIGradient", logoFrame, {
    Rotation = 45,
    Color = ColorSequence.new(ACCENT, lighten(ACCENT, 0.4))
})
acc(logoGradient, "Color", function(c) return ColorSequence.new(c, lighten(c, 0.4)) end)
mk("TextLabel", logoFrame, {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "T",
    Font = FONT_TITLE,
    TextSize = 20,
    TextColor3 = Color3.new(1,1,1),
})

-- Título
local titleLbl = mk("TextLabel", header, {
    Text = "TOMMY HUB 67",
    Font = FONT_TITLE,
    TextSize = 17,
    TextColor3 = Color3.new(1,1,1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 220, 0, 20),
    Position = UDim2.new(0, 62, 0, 8),
    TextXAlignment = Enum.TextXAlignment.Left,
})
local titleGrad = mk("UIGradient", titleLbl, {
    Color = ColorSequence.new(ACCENT, lighten(ACCENT, 0.6))
})
acc(titleGrad, "Color", function(c) return ColorSequence.new(c, lighten(c, 0.6)) end)

mk("TextLabel", header, {
    Text = "@accountxz  ·  Blox Fruits  ·  v67",
    Font = FONT_MED,
    TextSize = 10,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 220, 0, 14),
    Position = UDim2.new(0, 62, 0, 30),
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Botones de la ventana
local function topBtn(txt, x, col, cb)
    local b = mk("TextButton", header, {
        Text = txt, Font = FONT_BOLD, TextSize = 14, TextColor3 = col,
        BackgroundColor3 = C_BG_ITEM,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, x, 0, 15),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    corner(b, 9)
    local st = stroke(b, C_BORDER, 1, 0.6)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = C_BG_HOVER})
        tween(st, 0.15, {Color = col, Transparency = 0.3})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = C_BG_ITEM})
        tween(st, 0.15, {Color = C_BORDER, Transparency = 0.6})
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- Divider bajo el header
local divider = mk("Frame", main, {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 58),
    BackgroundColor3 = C_BORDER,
    BorderSizePixel = 0,
    BackgroundTransparency = 0.4,
})

-- ================= SIDEBAR =================
local sidebar = mk("Frame", main, {
    Size = UDim2.new(0, 140, 1, -74),
    Position = UDim2.new(0, 12, 0, 66),
    BackgroundColor3 = C_BG_PANEL,
    BorderSizePixel = 0,
})
corner(sidebar, 12)
stroke(sidebar, C_BORDER, 1, 0.7)

local tabsHolder = mk("ScrollingFrame", sidebar, {
    Size = UDim2.new(1, -12, 1, -40),
    Position = UDim2.new(0, 6, 0, 6),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})
mk("UIListLayout", tabsHolder, {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Footer del sidebar
mk("TextLabel", sidebar, {
    Text = "F4  ·  Mostrar / Ocultar",
    Font = FONT_MED,
    TextSize = 9,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -20),
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- ================= CONTENIDO =================
local content = mk("Frame", main, {
    Size = UDim2.new(1, -164, 1, -74),
    Position = UDim2.new(0, 156, 0, 66),
    BackgroundColor3 = C_BG_PANEL,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
corner(content, 12)
stroke(content, C_BORDER, 1, 0.7)

-- Barra de búsqueda arriba del contenido
local searchBar = mk("Frame", content, {
    Size = UDim2.new(1, -16, 0, 32),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = C_BG_ITEM,
    BorderSizePixel = 0,
})
corner(searchBar, 9)
stroke(searchBar, C_BORDER, 1, 0.6)

mk("TextLabel", searchBar, {
    Text = "🔍",
    Font = FONT_MED,
    TextSize = 13,
    TextColor3 = C_TEXT_MUTED,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 1, 0),
    Position = UDim2.new(0, 4, 0, 0),
})

local searchBox = mk("TextBox", searchBar, {
    Size = UDim2.new(1, -32, 1, 0),
    Position = UDim2.new(0, 28, 0, 0),
    BackgroundTransparency = 1,
    Font = FONT_MED,
    TextSize = 11,
    TextColor3 = C_TEXT,
    PlaceholderText = "Buscar función...",
    PlaceholderColor3 = C_TEXT_MUTED,
    Text = "",
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
})

-- ================= PÁGINAS =================
local ICONS = {
    Combat   = "⚔",
    Glitches = "✨",
    Soru     = "⚡",
    ESP      = "👁",
    Dungeons = "🏰",
    Misc     = "⚙",
}

local pages, tabObjs, currentPage, tabCount = {}, {}, nil, 0

local function showPage(name)
    if currentPage == name then return end
    currentPage = name
    for n, p in pairs(pages) do
        if n == name then
            p.Visible = true
            p.Position = UDim2.new(0, 8, 0, 48)
            tween(p, 0.2, {Position = UDim2.new(0, 8, 0, 48)})
        else
            p.Visible = false
        end
    end
    for n, t in pairs(tabObjs) do
        local on = (n == name)
        tween(t.bar, 0.25, {Size = on and UDim2.new(0, 3, 0, 20) or UDim2.new(0, 3, 0, 0)})
        tween(t.btn, 0.2, {
            BackgroundColor3 = on and ACCENT or C_BG_ITEM,
            BackgroundTransparency = on and 0.15 or 0,
        })
        tween(t.icon, 0.2, {TextColor3 = on and Color3.new(1,1,1) or C_TEXT_MUTED})
        tween(t.lbl, 0.2, {TextColor3 = on and Color3.new(1,1,1) or C_TEXT})
    end
end

local function newPage(name)
    local sf = mk("ScrollingFrame", content, {
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ACCENT,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ClipsDescendants = true,
    })
    acc(sf, "ScrollBarImageColor3")
    mk("UIListLayout", sf, {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    padding(sf, 0, 12, 0, 8)
    pages[name] = sf
    tabCount = tabCount + 1

    -- Botón de tab
    local btn = mk("TextButton", tabsHolder, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C_BG_ITEM,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = tabCount,
    })
    corner(btn, 9)
    local btnStroke = stroke(btn, C_BORDER, 1, 0.7)
    local bar = mk("Frame", btn, {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    })
    acc(bar, "BackgroundColor3")
    corner(bar, 2)

    local icon = mk("TextLabel", btn, {
        Text = ICONS[name] or "•",
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = C_TEXT_MUTED,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
    })

    local lbl = mk("TextLabel", btn, {
        Text = name,
        Font = FONT_BOLD,
        TextSize = 11,
        TextColor3 = C_TEXT,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundColor3 = C_BG_HOVER})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundColor3 = C_BG_ITEM})
        end
    end)
    btn.MouseButton1Click:Connect(function() showPage(name) end)

    tabObjs[name] = {btn = btn, bar = bar, icon = icon, lbl = lbl}
    return sf
end

-- ================= COMPONENTES =================
local orderN = {}
local function nextOrder(page) orderN[page] = (orderN[page] or 0) + 1; return orderN[page] end
local reg = {}

local function section(page, text)
    local f = mk("Frame", page, {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(page),
    })
    local l = mk("TextLabel", f, {
        Text = string.upper(text),
        Font = FONT_TITLE,
        TextSize = 10,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 4, 0, 2),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    acc(l, "TextColor3")
    local line = mk("Frame", f, {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C_BORDER,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.5,
    })
end

local function row(page, h)
    local f = mk("Frame", page, {
        Size = UDim2.new(1, 0, 0, h or 36),
        BackgroundColor3 = C_BG_ITEM,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(page),
    })
    corner(f, 9)
    local st = stroke(f, C_BORDER, 1, 0.7)
    f.MouseEnter:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = C_BG_HOVER})
        tween(st, 0.15, {Color = ACCENT, Transparency = 0.6})
    end)
    f.MouseLeave:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = C_BG_ITEM})
        tween(st, 0.15, {Color = C_BORDER, Transparency = 0.7})
    end)
    return f, st
end

local function rowLabel(f, text, rightPad)
    return mk("TextLabel", f, {
        Text = text,
        Font = FONT_MED,
        TextSize = 11,
        TextColor3 = C_TEXT,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(rightPad or 66), 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

-- Toggle mejorado
local function toggle(page, text, key, cb)
    local f = row(page, 36); rowLabel(f, text, 76)
    local trackF = mk("Frame", f, {
        Size = UDim2.new(0, 46, 0, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = C_OFF,
        BorderSizePixel = 0,
    })
    corner(trackF, 11)
    local trackStroke = stroke(trackF, C_BORDER, 1, 0.5)
    local knob = mk("Frame", trackF, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
    })
    corner(knob, 8)
    local hit = mk("TextButton", f, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    })

    local function refresh(instant)
        local on = S[key]
        local col = on and ACCENT or C_OFF
        local pos = on and UDim2.new(0, 27, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        if instant then
            trackF.BackgroundColor3 = col
            knob.Position = pos
            trackStroke.Transparency = on and 0.2 or 0.5
        else
            tween(trackF, 0.2, {BackgroundColor3 = col})
            tween(knob, 0.25, {Position = pos}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(trackStroke, 0.2, {Transparency = on and 0.2 or 0.5})
        end
    end
    refresh(true)
    reg[key] = {refresh = refresh, cb = cb}
    hit.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        refresh()
        if cb then pcall(cb, S[key]) end
    end)
end

-- Stepper mejorado
local function stepper(page, text, key, minV, maxV, step, suffix)
    local f = row(page, 42)
    local lbl = rowLabel(f, text, 130)
    lbl.Size = UDim2.new(1, -130, 1, -10)
    local function fmt(v)
        v = math.floor(v * 100 + 0.5) / 100
        if v == math.floor(v) then v = math.floor(v) end
        return tostring(v) .. (suffix or "")
    end
    local function mkBtn(txt, x)
        local b = mk("TextButton", f, {
            Text = txt,
            Font = FONT_TITLE,
            TextSize = 14,
            TextColor3 = Color3.new(1,1,1),
            BackgroundColor3 = darken(ACCENT, 0.3),
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, x, 0, 8),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        corner(b, 7)
        acc(b, "BackgroundColor3", function(c) return darken(c, 0.3) end)
        b.MouseEnter:Connect(function() tween(b, 0.1, {BackgroundColor3 = ACCENT}) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = darken(ACCENT, 0.3)}) end)
        return b
    end
    local minus = mkBtn("−", -122)
    local val = mk("TextLabel", f, {
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -92, 0, 8),
        BackgroundTransparency = 1,
        Font = FONT_BOLD,
        TextSize = 12,
        TextColor3 = C_TEXT,
    })
    local plus = mkBtn("+", -28)
    local barBG = mk("Frame", f, {
        Size = UDim2.new(1, -28, 0, 3),
        Position = UDim2.new(0, 14, 1, -8),
        BackgroundColor3 = C_OFF,
        BorderSizePixel = 0,
    })
    corner(barBG, 2)
    local fill = mk("Frame", barBG, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    })
    acc(fill, "BackgroundColor3")
    corner(fill, 2)

    local function update()
        val.Text = fmt(S[key])
        local frac = (S[key] - minV) / math.max(maxV - minV, 1e-9)
        tween(fill, 0.2, {Size = UDim2.new(math.clamp(frac, 0, 1), 0, 1, 0)})
    end
    update()
    reg[key] = {update = update}
    minus.MouseButton1Click:Connect(function()
        S[key] = math.max(minV, math.floor((S[key] - step) * 100 + 0.5) / 100); update()
    end)
    plus.MouseButton1Click:Connect(function()
        S[key] = math.min(maxV, math.floor((S[key] + step) * 100 + 0.5) / 100); update()
    end)
end

-- Botón mejorado
local function button(page, text, cb)
    local f, st = row(page, 36)
    st.Transparency = 0.5
    acc(st, "Color")
    local b = mk("TextButton", f, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = FONT_BOLD,
        TextSize = 11,
        AutoButtonColor = false,
        TextColor3 = C_TEXT,
    })
    b.MouseEnter:Connect(function() tween(b, 0.15, {TextColor3 = lighten(ACCENT, 0.5)}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {TextColor3 = C_TEXT}) end)
    b.MouseButton1Click:Connect(function()
        tween(f, 0.08, {BackgroundColor3 = darken(ACCENT, 0.5)})
        task.delay(0.1, function() tween(f, 0.2, {BackgroundColor3 = C_BG_ITEM}) end)
        cb(b)
    end)
    return b
end

-- Ciclo mejorado
local function cycle(page, prefix, key, options, cb)
    local btn = button(page, prefix .. tostring(S[key]), function(b)
        local idx = table.find(options, S[key]) or 0
        S[key] = options[(idx % #options) + 1]
        b.Text = prefix .. tostring(S[key])
        if cb then cb(S[key]) end
    end)
    reg[key] = {update = function() btn.Text = prefix .. tostring(S[key]) end}
end

-- Aplicar tema
local function applyTheme(name)
    local theme = THEMES[name] or THEMES.Purple
    ACCENT = theme.main
    ACCENT_GLOW = theme.glow
    for _, t in ipairs(themed) do
        pcall(function() t[1][t[2]] = t[3] and t[3](ACCENT) or ACCENT end)
    end
    for _, e in pairs(reg) do if e.refresh then e.refresh(true) end end
    if currentPage then
        local cp = currentPage
        currentPage = nil
        showPage(cp)
    end
end

-- ================= BOTÓN FLOTANTE =================
local openBtn = mk("TextButton", gui, {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 18, 0, 18),
    Text = "T",
    Font = FONT_TITLE,
    TextSize = 22,
    TextColor3 = Color3.new(1,1,1),
    BackgroundColor3 = ACCENT,
    Visible = false,
    AutoButtonColor = false,
    BorderSizePixel = 0,
})
corner(openBtn, 26)
acc(openBtn, "BackgroundColor3")
local openStroke = mk("UIStroke", openBtn, {Color = ACCENT_GLOW, Thickness = 2, Transparency = 0.3})
acc(openStroke, "Color", function(c) return lighten(c, 0.4) end)
local openCorner = mk("UICorner", openBtn, {CornerRadius = UDim.new(1, 0)})

-- Animación pulsante del botón flotante
task.spawn(function()
    while gui.Parent do
        if openBtn.Visible then
            tween(openBtn, 1.2, {Size = UDim2.new(0, 56, 0, 56)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tween(openBtn, 1.2, {Size = UDim2.new(0, 52, 0, 52)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
end)

-- ================= SISTEMA DE NOTIFICACIONES =================
local notifHolder = mk("Frame", gui, {
    Size = UDim2.new(0, 260, 1, -40),
    Position = UDim2.new(1, -270, 0, 20),
    BackgroundTransparency = 1,
})
mk("UIListLayout", notifHolder, {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local notifCount = 0
local function notify(title, msg, color)
    notifCount = notifCount + 1
    color = color or ACCENT
    local n = mk("Frame", notifHolder, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C_BG_PANEL,
        BorderSizePixel = 0,
        LayoutOrder = -notifCount,
        ClipsDescendants = true,
    })
    corner(n, 10)
    stroke(n, color, 1.5, 0.4)
    local accentBar = mk("Frame", n, {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    corner(accentBar, 2)
    mk("TextLabel", n, {
        Text = title,
        Font = FONT_BOLD,
        TextSize = 11,
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -22, 0, 16),
        Position = UDim2.new(0, 16, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    mk("TextLabel", n, {
        Text = msg,
        Font = FONT_MED,
        TextSize = 10,
        TextColor3 = C_TEXT_MUTED,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -22, 0, 14),
        Position = UDim2.new(0, 16, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })
    tween(n, 0.35, {Size = UDim2.new(1, 0, 0, 50)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(3, function()
        if n and n.Parent then
            tween(n, 0.3, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            task.wait(0.3)
            if n then n:Destroy() end
        end
    end)
end

-- ================= FUNCIONES VENTANA =================
local function setOpen(v)
    if v then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        tween(main, 0.35, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        openBtn.Visible = false
    else
        tween(main, 0.25, {Size = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.25)
        main.Visible = false
        openBtn.Visible = true
    end
end

openBtn.MouseButton1Click:Connect(function() setOpen(true) end)

-- Botones de ventana
topBtn("−", -78, C_TEXT_MUTED, function() setOpen(false) end)
topBtn("✕", -42, C_DANGER, function()
    notify("Tommy Hub 67", "Cerrando script...", C_DANGER)
    task.wait(0.4)
    cleanup()
end)

-- Arrastrar ventana
do
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

-- Hotkey F4
track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.F4 then
        if main.Visible then setOpen(false) else setOpen(true) end
    end
end))

-- Búsqueda funcional
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(searchBox.Text)
    local page = pages[currentPage]
    if not page then return end
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("Frame") then
            local found = false
            for _, c in ipairs(child:GetDescendants()) do
                if c:IsA("TextLabel") and string.find(string.lower(c.Text), q) then
                    found = true; break
                end
            end
            child.Visible = (q == "" or found)
        end
    end
end)

-- ================= FIN DE UI =================
