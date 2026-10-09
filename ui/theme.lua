local LithiumTheme = {
    Font = Enum.Font.Gotham,
    TextColor = Color3.fromRGB(220, 220, 220),
    SubTextColor = Color3.fromRGB(150, 150, 160),
    MainColor = Color3.fromRGB(10, 10, 12),
    AccentColor = Color3.fromRGB(0, 200, 140),
    OutlineColor = Color3.fromRGB(40, 40, 45),
    BackgroundColor = Color3.fromRGB(14, 14, 18),
    ButtonColor = Color3.fromRGB(24, 24, 28),
    ButtonOutlineColor = Color3.fromRGB(50, 50, 55),
    ToggleColor = Color3.fromRGB(0, 200, 140),
    ToggleOutlineColor = Color3.fromRGB(0, 160, 110),
    SliderColor = Color3.fromRGB(0, 200, 140),
    DropdownColor = Color3.fromRGB(24, 24, 28),
    TooltipBackground = Color3.fromRGB(20, 20, 24),
}

if ThemeManager and ThemeManager.SetTheme then
    pcall(function() ThemeManager:SetTheme(LithiumTheme) end)
end