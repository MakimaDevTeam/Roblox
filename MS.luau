-- This file was generated at discord.gg/syncrypt

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
pcall(function()
    if CoreGui:FindFirstChild("PrincesinhoAutoJJS") then
        CoreGui.PrincesinhoAutoJJS:Destroy()
    end
end)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrincesinhoAutoJJS"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 260, 0, 185)
Frame.Position = UDim2.new(0.5, -130, 0.5, -92)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 18)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = Frame
UIStroke.Color = Color3.fromRGB(35, 35, 35)
UIStroke.Thickness = 1.3
local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Parent = Frame
ImageLabel.BackgroundTransparency = 1
ImageLabel.Size = UDim2.new(1, 40, 1, 40)
ImageLabel.Position = UDim2.new(0, -20, 0, -20)
ImageLabel.Image = "rbxassetid://5028857084"
ImageLabel.ImageTransparency = 0.45
ImageLabel.ScaleType = Enum.ScaleType.Slice
ImageLabel.SliceCenter = Rect.new(24, 24, 276, 276)
local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "KeepVisible"
TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 15, 0, 10)
TextLabel.Size = UDim2.new(1, -30, 0, 25)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "Auto JJs"
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextSize = 24
TextLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
local TextButton = Instance.new("TextButton")
TextButton.Name = "KeepVisible"
TextButton.Parent = Frame
TextButton.Size = UDim2.new(0, 28, 0, 28)
TextButton.Position = UDim2.new(1, -35, 0, 8)
TextButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextButton.BorderSizePixel = 0
TextButton.Text = "-"
TextButton.Font = Enum.Font.GothamBold
TextButton.TextSize = 22
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 8)
local TextBox = Instance.new("TextBox")
TextBox.Parent = Frame
TextBox.Size = UDim2.new(0, 105, 0, 38)
TextBox.Position = UDim2.new(0, 15, 0, 55)
TextBox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TextBox.BorderSizePixel = 0
TextBox.Font = Enum.Font.GothamBold
TextBox.PlaceholderText = "Rec: 0.53s"
TextBox.Text = "0.53"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 16
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 10)
local TextLabel2 = Instance.new("TextLabel")
TextLabel2.Parent = Frame
TextLabel2.Size = UDim2.new(0, 120, 0, 38)
TextLabel2.Position = UDim2.new(0, 125, 0, 55)
TextLabel2.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
TextLabel2.BorderSizePixel = 0
TextLabel2.Font = Enum.Font.GothamBold
TextLabel2.Text = "Recomendado"
TextLabel2.TextColor3 = Color3.fromRGB(0, 210, 100)
TextLabel2.TextSize = 14
Instance.new("UICorner", TextLabel2).CornerRadius = UDim.new(0, 10)
local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Parent = TextLabel2
UIStroke2.Color = Color3.fromRGB(30, 55, 35)
UIStroke2.Thickness = 1
local TextButton2 = Instance.new("TextButton")
TextButton2.Parent = Frame
TextButton2.Size = UDim2.new(0, 230, 0, 48)
TextButton2.Position = UDim2.new(0.5, -115, 0, 110)
TextButton2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextButton2.BorderSizePixel = 0
TextButton2.Font = Enum.Font.GothamBold
TextButton2.Text = "OFF"
TextButton2.TextColor3 = Color3.fromRGB(255, 70, 70)
TextButton2.TextSize = 25
Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 12)
local TextLabel3 = Instance.new("TextLabel")
TextLabel3.Parent = Frame
TextLabel3.BackgroundTransparency = 1
TextLabel3.Position = UDim2.new(0, 0, 1, -22)
TextLabel3.Size = UDim2.new(1, 0, 0, 18)
TextLabel3.Font = Enum.Font.Gotham
TextLabel3.Text = "By princesinho/ YT princesinho0004"
TextLabel3.TextColor3 = Color3.fromRGB(110, 110, 110)
TextLabel3.TextSize = 11
local u19 = false
local FrameSize = Frame.Size
TextButton.MouseButton1Click:Connect(function()
    u19 = not u19

    if u19 then
        for _, child in pairs(Frame:GetChildren()) do
            local v34 = child:IsA("GuiObject")

            if v34 then
                v34 = child.Name ~= "KeepVisible"
            end

            if v34 then
                child.Visible = false
            end
        end

        TweenService:Create(Frame, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 260, 0, 40)
		}):Play()
        TextButton.Text = "+"

        return
    end

    TweenService:Create(Frame, TweenInfo.new(0.2), {
		Size = FrameSize
	}):Play()

    for _, child in pairs(Frame:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = true
        end
    end

    TextButton.Visible = true
    TextLabel.Visible = true
    TextButton.Text = "-"
end)
local u21
local u22
local inputPosition
local FramePosition
Frame.InputBegan:Connect(function(input)
    local v38 = input.UserInputType == Enum.UserInputType.MouseButton1

    if not v38 then
        v38 = input.UserInputType == Enum.UserInputType.Touch
    end

    if v38 then
        u21 = true
        inputPosition = input.Position
        FramePosition = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                u21 = false
            end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    local v40 = input.UserInputType == Enum.UserInputType.MouseMovement

    if not v40 then
        v40 = input.UserInputType == Enum.UserInputType.Touch
    end

    if v40 then
        u22 = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == u22 and u21 then
        local v42 = input.Position - inputPosition

        Frame.Position = UDim2.new(FramePosition.X.Scale, FramePosition.X.Offset + v42.X, FramePosition.Y.Scale, FramePosition.Y.Offset + v42.Y)
    end
end)
local u25 = false
local n1 = 0.53
local Q = Enum.KeyCode.Q
local E = Enum.KeyCode.E
local t1 = {
	Q = Q,
	E = E
}
local function v30()
    local v43 = TextBox.Text:gsub("%s+", "")

    if v43 == "" then
        n1 = 0.53

        return
    end

    local num = tonumber(v43)

    if num and num >= 0 then
        n1 = num
    end
end
TextBox.FocusLost:Connect(v30)
local function v31()
    u25 = false
    TextButton2.Text = "OFF"
    TextButton2.TextColor3 = Color3.fromRGB(255, 70, 70)
    TweenService:Create(TextButton2, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	}):Play()
end
TextButton2.MouseButton1Click:Connect(function()
    u25 = not u25

    if u25 then
        v30()
        TextButton2.Text = "ON"
        TextButton2.TextColor3 = Color3.fromRGB(0, 255, 120)
        TweenService:Create(TextButton2, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(30, 40, 30)
		}):Play()

        return
    end

    v31()
end)
task.spawn(function()
    local t2 = {}

    while true do
        if n1 > 0 then
            task.wait(0.01)
        else
            task.wait()
        end

        if u25 then
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

                if PlayerGui then
                    PlayerGui = PlayerGui:FindFirstChild("Polichinelos")
                end

                if PlayerGui then
                    PlayerGui = PlayerGui:FindFirstChild("Screen")
                end

                if PlayerGui and u25 then
                    for _, child in ipairs(PlayerGui:GetChildren()) do
                        local v56 = child:IsA("ImageButton")

                        if v56 then
                            v56 = child.Visible and not t2[child]
                        end

                        if not v56 or child:GetAttribute("Completed") then
                            continue
                        end

                        local TextLabel4 = child:FindFirstChildWhichIsA("TextLabel")
                        local v58 = TextLabel4

                        if TextLabel4 then
                            v58 = TextLabel4.Text

                            if v58 then
                                v58 = TextLabel4.Text ~= ""
                            end
                        end

                        if v58 then
                            local v59 = tostring(TextLabel4.Text):upper():gsub("%s+", "")

                            t2[child] = true

                            if not UserInputService.TouchEnabled and t1[v59] then
                                local v60 = t1[v59]

                                pcall(function()
                                    VirtualInputManager:SendKeyEvent(true, v60, false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, v60, false, game)
                                end)
                            elseif child then
                                pcall(function()
                                    firesignal(child.MouseButton1Down)
                                    firesignal(child.MouseButton1Click)
                                    firesignal(child.TouchTap)
                                    child:Activate()

                                    local AbsolutePositionX = child.AbsolutePosition.X
                                    local AbsoluteSizeX = child.AbsoluteSize.X
                                    local v64 = child
                                    local v65 = AbsolutePositionX + AbsoluteSizeX / 2
                                    local v66 = v64.AbsolutePosition.Y + child.AbsoluteSize.Y / 2

                                    VirtualInputManager:SendMouseButtonEvent(v65, v66, 0, true, game, 1)
                                    task.wait(0.01)
                                    VirtualInputManager:SendMouseButtonEvent(v65, v66, 0, false, game, 1)
                                end)
                            end

                            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

                            if Remotes then
                                Remotes = ReplicatedStorage.Remotes:FindFirstChild("Polichinelos")
                            end

                            if Remotes then
                                Remotes:FireServer("Add", 1)
                            end

                            if not (n1 > 0) then
                                return
                            end

                            task.wait(n1)

                            return
                        end
                    end
                end
            end)

            if #t2 > 15 then
                table.clear(t2)
            end
        end
    end
end)
