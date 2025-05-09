local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local NotificationModule = {}
local ActiveNotifications = {}

local NotificationUI = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
NotificationUI.Name = "NotificationUI"
NotificationUI.ResetOnSpawn = false
NotificationUI.IgnoreGuiInset = true
NotificationUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IconAssets = {
    Error = "rbxassetid://122543689043469",
    Warning = "rbxassetid://135418069957730",
    Info = "rbxassetid://96701255295087"
}

local IconColors = {
    Error = Color3.fromRGB(200, 100, 255),
    Warning = Color3.fromRGB(255, 255, 120),
    Info = Color3.fromRGB(255, 255, 255)
}

local NotificationTemplate = Instance.new("Frame")
NotificationTemplate.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotificationTemplate.Size = UDim2.new(0, 300, 0, 40)
NotificationTemplate.BorderSizePixel = 0
NotificationTemplate.BackgroundTransparency = 1
NotificationTemplate.AnchorPoint = Vector2.new(0.5, 1)
NotificationTemplate.Position = UDim2.new(0.5, 0, 0.9, -50)
NotificationTemplate.AutomaticSize = Enum.AutomaticSize.Y
NotificationTemplate.ClipsDescendants = true
NotificationTemplate.Visible = false
NotificationTemplate.ZIndex = 10

local Stroke = Instance.new("UIStroke", NotificationTemplate)
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(80, 80, 80)

local Corner = Instance.new("UICorner", NotificationTemplate)
Corner.CornerRadius = UDim.new(0, 6)

local Icon = Instance.new("ImageLabel", NotificationTemplate)
Icon.Name = "Icon"
Icon.Image = ""
Icon.Size = UDim2.new(0, 24, 0, 24)
Icon.Position = UDim2.new(0, 10, 0.5, -12)
Icon.BackgroundTransparency = 1
Icon.ImageTransparency = 1

local MessageLabel = Instance.new("TextLabel", NotificationTemplate)
MessageLabel.Name = "TextLabel"
MessageLabel.Text = "Notification"
MessageLabel.Font = Enum.Font.GothamSemibold
MessageLabel.TextSize = 15
MessageLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
MessageLabel.BackgroundTransparency = 1
MessageLabel.Position = UDim2.new(0, 40, 0, 0)
MessageLabel.Size = UDim2.new(1, -50, 1, 0)
MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
MessageLabel.TextTransparency = 1

local Scale = Instance.new("UIScale", NotificationTemplate)
Scale.Scale = 0.8

NotificationTemplate.Parent = NotificationUI

local function CreateNotificationFrame()
    local Cloned = NotificationTemplate:Clone()
    Cloned.Visible = true
    Cloned.BackgroundTransparency = 1
    Cloned.TextLabel.TextTransparency = 1
    Cloned.Icon.ImageTransparency = 1
    Cloned.UIScale.Scale = 0.8
    Cloned.Parent = NotificationUI
    return Cloned
end

function NotificationModule:Notify(message, duration, notificationType)
    duration = duration or 3
    notificationType = notificationType or "Info"

    local asset = IconAssets[notificationType] or IconAssets.Info
    local color = IconColors[notificationType] or IconColors.Info

    local notification = CreateNotificationFrame()
    notification.TextLabel.Text = message
    notification.Icon.Image = asset
    notification.Icon.ImageColor3 = color

    table.insert(ActiveNotifications, notification)

    for index, notif in ipairs(ActiveNotifications) do
        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.9, -50 - ((#ActiveNotifications - index) * 55))
        }):Play()
    end

    TweenService:Create(notification.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()
    TweenService:Create(notification, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0.1
    }):Play()
    TweenService:Create(notification.TextLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(notification.Icon, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        ImageTransparency = 0
    }):Play()

    task.delay(duration, function()
        local fadeOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 1
        })
        local textFade = TweenService:Create(notification.TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
            TextTransparency = 1
        })
        local iconFade = TweenService:Create(notification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
            ImageTransparency = 1
        })
        local slideDown = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
            Position = notification.Position + UDim2.new(0, 0, 0, 10)
        })
        local scaleDown = TweenService:Create(notification.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0.8
        })

        fadeOut:Play()
        textFade:Play()
        iconFade:Play()
        slideDown:Play()
        scaleDown:Play()

        slideDown.Completed:Wait()
        notification:Destroy()
        table.remove(ActiveNotifications, table.find(ActiveNotifications, notification))
    end)
end

return NotificationModule
