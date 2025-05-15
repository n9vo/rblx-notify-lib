local TweenService   = game:GetService("TweenService")
local Players        = game:GetService("Players")
local LocalPlayer    = Players.LocalPlayer

local NotificationModule = {}
local ActiveNotifications = {}

-- root ScreenGui
local NotificationUI = Instance.new("ScreenGui")
NotificationUI.Name              = "NotificationUI"
NotificationUI.Parent            = LocalPlayer:WaitForChild("PlayerGui")
NotificationUI.ResetOnSpawn      = false
NotificationUI.IgnoreGuiInset    = true
NotificationUI.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
NotificationUI.DisplayOrder      = 1000  -- ensure it renders on top

-- icon & color tables
local IconAssets = {
    Error   = "rbxassetid://122543689043469",
    Warning = "rbxassetid://135418069957730",
    Info    = "rbxassetid://96701255295087",
}
local IconColors = {
    Error   = Color3.fromRGB(200,100,255),
    Warning = Color3.fromRGB(255,255,120),
    Info    = Color3.new(1,1,1),
}

-- base frame template
local NotificationTemplate = Instance.new("Frame")
NotificationTemplate.BackgroundColor3   = Color3.fromRGB(20,20,20)
NotificationTemplate.Size               = UDim2.new(0,300,0,40)
NotificationTemplate.BorderSizePixel     = 0
NotificationTemplate.BackgroundTransparency = 1
NotificationTemplate.AnchorPoint        = Vector2.new(0.5,1)
NotificationTemplate.Position           = UDim2.new(0.5,0,0.9,-50)
NotificationTemplate.AutomaticSize      = Enum.AutomaticSize.Y
NotificationTemplate.ClipsDescendants   = true
NotificationTemplate.Visible            = false
NotificationTemplate.ZIndex             = 10

-- shadow
local Shadow = Instance.new("UIShadow", NotificationTemplate)
Shadow.Color          = Color3.new(0,0,0)
Shadow.Transparency   = 0.7
Shadow.BlurRadius     = 8

-- stroke + corner
local Stroke = Instance.new("UIStroke", NotificationTemplate)
Stroke.Thickness = 1
Stroke.Color     = Color3.fromRGB(80,80,80)
local Corner = Instance.new("UICorner", NotificationTemplate)
Corner.CornerRadius = UDim.new(0,6)

-- icon
local Icon = Instance.new("ImageLabel", NotificationTemplate)
Icon.Name               = "Icon"
Icon.Size               = UDim2.new(0,24,0,24)
Icon.Position           = UDim2.new(0,10,0.5,-12)
Icon.BackgroundTransparency = 1
Icon.ImageTransparency       = 1

-- message
local MessageLabel = Instance.new("TextLabel", NotificationTemplate)
MessageLabel.Name             = "TextLabel"
MessageLabel.Font             = Enum.Font.GothamSemibold
MessageLabel.TextSize         = 15
MessageLabel.TextColor3       = Color3.fromRGB(230,230,230)
MessageLabel.BackgroundTransparency = 1
MessageLabel.Position         = UDim2.new(0,40,0,0)
MessageLabel.Size             = UDim2.new(1,-50,1,0)
MessageLabel.TextXAlignment   = Enum.TextXAlignment.Left
MessageLabel.TextTransparency = 1

-- scale for pop‑in
local Scale = Instance.new("UIScale", NotificationTemplate)
Scale.Scale = 0.8

NotificationTemplate.Parent = NotificationUI

local function cloneNotification()
    local c = NotificationTemplate:Clone()
    c.Visible = true
    c.UIScale.Scale = 0.8
    c.TextLabel.TextTransparency = 1
    c.Icon.ImageTransparency = 1
    c.BackgroundTransparency = 1
    c.Parent = NotificationUI
    return c
end

function NotificationModule:Notify(notitype, msg, duration)
    duration = duration or 3
    local asset = IconAssets[notitype] or IconAssets.Info
    local color = IconColors[notitype] or IconColors.Info

    local notif = cloneNotification()
    notif.TextLabel.Text      = msg
    notif.Icon.Image          = asset
    notif.Icon.ImageColor3    = color
    table.insert(ActiveNotifications, notif)

    -- reposition all
    for i,n in ipairs(ActiveNotifications) do
        TweenService:Create(n, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5,0,0.9,-50 - ((#ActiveNotifications - i)*55))
        }):Play()
    end

    -- animate in
    TweenService:Create(notif.UIScale, TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out), { Scale = 1 }):Play()
    TweenService:Create(notif, TweenInfo.new(0.35,Enum.EasingStyle.Quint), { BackgroundTransparency = 0.1 }):Play()
    TweenService:Create(notif.TextLabel, TweenInfo.new(0.35,Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
    TweenService:Create(notif.Icon, TweenInfo.new(0.35,Enum.EasingStyle.Quint), { ImageTransparency = 0 }):Play()

    -- fade out & cleanup
    task.delay(duration, function()
        local fades = {
            TweenService:Create(notif, TweenInfo.new(0.3,Enum.EasingStyle.Sine), {
                BackgroundTransparency = 1,
                Position = notif.Position + UDim2.new(0,0,0,10)
            }),
            TweenService:Create(notif.TextLabel, TweenInfo.new(0.3,Enum.EasingStyle.Sine), { TextTransparency = 1 }),
            TweenService:Create(notif.Icon, TweenInfo.new(0.3,Enum.EasingStyle.Sine), { ImageTransparency = 1 }),
            TweenService:Create(notif.UIScale, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In), { Scale = 0.8 }),
        }
        for _,t in ipairs(fades) do t:Play() end
        fades[1].Completed:Wait()
        notif:Destroy()
        table.remove(ActiveNotifications, table.find(ActiveNotifications, notif))
    end)
end

return NotificationModule
