--========================================================--
--              ADVANCED AIM LOCK SYSTEM                 --
--        ROBLOX STUDIO - LOCAL SCRIPT VERSION            --
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIG
--========================================================--

local Config = {

	-- Keys
	ToggleKey = Enum.KeyCode.G,
	NextTargetKey = Enum.KeyCode.E,

	-- Target
	MaxDistance = 2000,

	-- Auto nearest
	AutoNearest = true,
	AutoNearestInterval = 0.08,

	-- Camera
	HardLock = true,

	-- Crosshair
	ShowCrosshair = true,

	-- Debug
	ShowDebug = true,

	-- Highlight
	VisibleColor = Color3.fromRGB(0, 255, 0),
	BlockedColor = Color3.fromRGB(255, 0, 0),

	FillTransparency = 0.45,
	OutlineTransparency = 0,

	-- Calibration
	AutoCalibration = true,
	CalibrationGain = 0.35,
	CalibrationDeadzone = 0.35,
	MaxCalibrationPixels = 25,
	CalibrationClamp = 40,
}

--========================================================--
-- STATE
--========================================================--

local Enabled = false
local AutoNearest = Config.AutoNearest

local Target = nil

local CalibrationOffset = Vector2.zero

local LastNearestCheck = 0

-- Những mục tiêu đã bị bỏ qua trong vòng hiện tại
local SkippedTargets = {}

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "AdvancedAimSystem"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--========================================================--
-- MAIN
--========================================================--

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(240, 150)
Main.Position = UDim2.new(0, 20, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(75, 75, 75)
MainStroke.Parent = Main

--========================================================--
-- DEBUG
--========================================================--

local DebugText = Instance.new("TextLabel")
DebugText.Name = "Debug"

DebugText.Size = UDim2.new(1, 0, 0, 45)
DebugText.Position = UDim2.new(0, 0, 0, -50)

DebugText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DebugText.BackgroundTransparency = 0.1
DebugText.BorderSizePixel = 0

DebugText.TextColor3 = Color3.new(1, 1, 1)
DebugText.TextSize = 11
DebugText.Font = Enum.Font.Code

DebugText.TextXAlignment = Enum.TextXAlignment.Center
DebugText.TextYAlignment = Enum.TextYAlignment.Center

DebugText.Visible = Config.ShowDebug
DebugText.Parent = Main

local DebugCorner = Instance.new("UICorner")
DebugCorner.CornerRadius = UDim.new(0, 8)
DebugCorner.Parent = DebugText

--========================================================--
-- TITLE
--========================================================--

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundTransparency = 1

Title.Text = "ADVANCED AIM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

Title.Parent = Main

--========================================================--
-- AIM BUTTON
--========================================================--

local AimButton = Instance.new("TextButton")

AimButton.Size = UDim2.new(1, -20, 0, 34)
AimButton.Position = UDim2.fromOffset(10, 32)

AimButton.BorderSizePixel = 0

AimButton.TextColor3 = Color3.new(1, 1, 1)
AimButton.TextSize = 15
AimButton.Font = Enum.Font.GothamBold

AimButton.Parent = Main

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 8)
AimCorner.Parent = AimButton

--========================================================--
-- AUTO NEAREST BUTTON
--========================================================--

local NearestButton = Instance.new("TextButton")

NearestButton.Size = UDim2.new(1, -20, 0, 30)
NearestButton.Position = UDim2.fromOffset(10, 70)

NearestButton.BorderSizePixel = 0

NearestButton.TextColor3 = Color3.new(1, 1, 1)
NearestButton.TextSize = 13
NearestButton.Font = Enum.Font.GothamBold

NearestButton.Parent = Main

local NearestCorner = Instance.new("UICorner")
NearestCorner.CornerRadius = UDim.new(0, 8)
NearestCorner.Parent = NearestButton

--========================================================--
-- INFO
--========================================================--

local Info = Instance.new("TextLabel")

Info.Size = UDim2.new(1, -10, 0, 30)
Info.Position = UDim2.fromOffset(5, 108)

Info.BackgroundTransparency = 1

Info.TextColor3 = Color3.fromRGB(180, 180, 180)
Info.TextSize = 11
Info.Font = Enum.Font.Gotham

Info.Text = "G: AIM   |   E: NEXT"

Info.Parent = Main

--========================================================--
-- DRAG GUI
--========================================================--

local dragging = false
local dragStart = nil
local startPosition = nil

Main.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

Main.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

--========================================================--
-- BUTTON UPDATE
--========================================================--

local function UpdateButtons()

	if Enabled then

		AimButton.Text = "AIM: ON"

		AimButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 60)

	else

		AimButton.Text = "AIM: OFF"

		AimButton.BackgroundColor3 =
			Color3.fromRGB(145, 40, 40)
	end

	if AutoNearest then

		NearestButton.Text = "AUTO NEAREST: ON"

		NearestButton.BackgroundColor3 =
			Color3.fromRGB(40, 120, 170)

	else

		NearestButton.Text = "AUTO NEAREST: OFF"

		NearestButton.BackgroundColor3 =
			Color3.fromRGB(70, 70, 70)
	end
end

--========================================================--
-- CROSSHAIR
--========================================================--

local Crosshair = Instance.new("TextLabel")

Crosshair.Name = "Crosshair"

Crosshair.Size = UDim2.fromOffset(40, 40)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)

Crosshair.BackgroundTransparency = 1

Crosshair.Text = "+"
Crosshair.TextColor3 = Color3.new(1, 1, 1)

Crosshair.TextSize = 30
Crosshair.Font = Enum.Font.GothamBold

Crosshair.Visible = Config.ShowCrosshair
Crosshair.Parent = Gui

--========================================================--
-- TARGET MARKER
--========================================================--

local TargetMarker = Instance.new("Frame")

TargetMarker.Name = "TargetMarker"

TargetMarker.Size = UDim2.fromOffset(7, 7)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)

TargetMarker.BackgroundColor3 =
	Color3.fromRGB(255, 0, 0)

TargetMarker.BorderSizePixel = 0

TargetMarker.Visible = Config.ShowDebug

TargetMarker.Parent = Gui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetMarker

--========================================================--
-- CALIBRATION MARKER
--========================================================--

local CalibrationMarker = Instance.new("Frame")

CalibrationMarker.Name = "CalibrationMarker"

CalibrationMarker.Size = UDim2.fromOffset(7, 7)
CalibrationMarker.AnchorPoint = Vector2.new(0.5, 0.5)

CalibrationMarker.BackgroundColor3 =
	Color3.fromRGB(0, 255, 255)

CalibrationMarker.BorderSizePixel = 0

CalibrationMarker.Visible = Config.ShowDebug

CalibrationMarker.Parent = Gui

local CalibrationCorner = Instance.new("UICorner")
CalibrationCorner.CornerRadius = UDim.new(1, 0)
CalibrationCorner.Parent = CalibrationMarker

--========================================================--
-- HIGHLIGHT
--========================================================--

local function GetHighlight(character)

	if not character then
		return nil
	end

	local highlight =
		character:FindFirstChild("AdvancedAimHighlight")

	if not highlight then

		highlight = Instance.new("Highlight")

		highlight.Name =
			"AdvancedAimHighlight"

		highlight.Adornee =
			character

		highlight.FillTransparency =
			Config.FillTransparency

		highlight.OutlineTransparency =
			Config.OutlineTransparency

		highlight.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop

		highlight.Parent =
			character
	end

	return highlight
end

--========================================================--
-- SET TARGET COLOR
--========================================================--

local function SetTargetColor(player, visible)

	if not player then
		return
	end

	if not player.Character then
		return
	end

	local highlight =
		GetHighlight(player.Character)

	if not highlight then
		return
	end

	if visible then

		highlight.FillColor =
			Config.VisibleColor

		highlight.OutlineColor =
			Config.VisibleColor

	else

		highlight.FillColor =
			Config.BlockedColor

		highlight.OutlineColor =
			Config.BlockedColor
	end
end

--========================================================--
-- REMOVE HIGHLIGHT
--========================================================--

local function RemoveHighlight(player)

	if not player then
		return
	end

	if not player.Character then
		return
	end

	local highlight =
		player.Character:FindFirstChild(
			"AdvancedAimHighlight"
		)

	if highlight then
		highlight:Destroy()
	end
end

--========================================================--
-- CLEAR HIGHLIGHTS
--========================================================--

local function ClearHighlights()

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then
			RemoveHighlight(player)
		end
	end
end

--========================================================--
-- TEAM CHECK
--========================================================--

local function IsEnemy(player)

	if player == LocalPlayer then
		return false
	end

	if not player.Character then
		return false
	end

	local humanoid =
		player.Character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	if LocalPlayer.Team
		and player.Team then

		if LocalPlayer.Team ==
			player.Team then

			return false
		end
	end

	return true
end

--========================================================--
-- DISTANCE
--========================================================--

local function GetDistance(player)

	if not LocalPlayer.Character then
		return math.huge
	end

	if not player.Character then
		return math.huge
	end

	local myRoot =
		LocalPlayer.Character:FindFirstChild(
			"HumanoidRootPart"
		)

	local enemyRoot =
		player.Character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not myRoot or not enemyRoot then
		return math.huge
	end

	return (
		myRoot.Position -
		enemyRoot.Position
	).Magnitude
end

--========================================================--
-- SKIPPED TARGET SYSTEM
--========================================================--

local function ClearSkippedTargets()

	SkippedTargets = {}
end

local function IsSkipped(player)

	return SkippedTargets[player] == true
end

--========================================================--
-- TARGET LIST
--========================================================--

local function GetTargets()

	local targets = {}

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if IsEnemy(player)
			and not IsSkipped(player) then

			local distance =
				GetDistance(player)

			if distance <=
				Config.MaxDistance then

				table.insert(
					targets,
					player
				)
			end
		end
	end

	table.sort(
		targets,

		function(a, b)

			return GetDistance(a)
				< GetDistance(b)
		end
	)

	return targets
end

--========================================================--
-- NEAREST TARGET
--========================================================--

local function GetNearestTarget()

	local targets =
		GetTargets()

	return targets[1]
end

--========================================================--
-- NEXT TARGET
--========================================================--

local function GetNextTarget()

	local targets =
		GetTargets()

	if #targets == 0 then
		return nil
	end

	if not Target then
		return targets[1]
	end

	local index =
		table.find(
			targets,
			Target
		)

	if not index then
		return targets[1]
	end

	index += 1

	if index > #targets then
		index = 1
	end

	return targets[index]
end

--========================================================--
-- VALID TARGET
--========================================================--

local function IsValidTarget(player)

	if not player then
		return false
	end

	if not player.Parent then
		return false
	end

	if not IsEnemy(player) then
		return false
	end

	if GetDistance(player)
		> Config.MaxDistance then

		return false
	end

	local character =
		player.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	local head =
		character:FindFirstChild(
			"Head"
		)

	if not humanoid
		or humanoid.Health <= 0 then

		return false
	end

	if not head then
		return false
	end

	return true
end

--========================================================--
-- WALL CHECK
--========================================================--

local function CanSeeHead(head)

	if not head then
		return false
	end

	local origin =
		Camera.CFrame.Position

	local direction =
		head.Position - origin

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	local ignore = {}

	if LocalPlayer.Character then

		table.insert(
			ignore,
			LocalPlayer.Character
		)
	end

	params.FilterDescendantsInstances =
		ignore

	params.IgnoreWater = true

	local result =
		workspace:Raycast(
			origin,
			direction,
			params
		)

	if result == nil then
		return true
	end

	if result.Instance
		and result.Instance:IsDescendantOf(
			head.Parent
		) then

		return true
	end

	return false
end

--========================================================--
-- CALIBRATION
--========================================================--

local function UpdateCalibration(head)

	if not Config.AutoCalibration then
		return CalibrationOffset
	end

	local viewport =
		Camera.ViewportSize

	local center =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local screenPosition,
		onScreen =
		Camera:WorldToViewportPoint(
			head.Position
		)

	if not onScreen then
		return CalibrationOffset
	end

	local headScreen =
		Vector2.new(
			screenPosition.X,
			screenPosition.Y
		)

	local error =
		headScreen - center

	if error.Magnitude <=
		Config.CalibrationDeadzone then

		return CalibrationOffset
	end

	if error.Magnitude >
		Config.MaxCalibrationPixels then

		error =
			error.Unit *
			Config.MaxCalibrationPixels
	end

	CalibrationOffset +=
		error *
		Config.CalibrationGain *
		0.01

	CalibrationOffset =
		Vector2.new(

			math.clamp(
				CalibrationOffset.X,
				-Config.CalibrationClamp,
				Config.CalibrationClamp
			),

			math.clamp(
				CalibrationOffset.Y,
				-Config.CalibrationClamp,
				Config.CalibrationClamp
			)
		)

	return CalibrationOffset
end

--========================================================--
-- LOCK CAMERA
--========================================================--

local function LockCamera(player)

	if not IsValidTarget(player) then
		return
	end

	local character =
		player.Character

	local head =
		character:FindFirstChild(
			"Head"
		)

	if not head then
		return
	end

	--====================================================--
	-- TARGET COLOR
	--====================================================--

	local visible =
		CanSeeHead(head)

	SetTargetColor(
		player,
		visible
	)

	--====================================================--
	-- SCREEN POSITION
	--====================================================--

	local viewport =
		Camera.ViewportSize

	local center =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local screenPosition =
		Camera:WorldToViewportPoint(
			head.Position
		)

	local headScreen =
		Vector2.new(
			screenPosition.X,
			screenPosition.Y
		)

	local error =
		headScreen - center

	--====================================================--
	-- CALIBRATION
	--====================================================--

	local calibration =
		UpdateCalibration(head)

	--====================================================--
	-- DEBUG MARKERS
	--====================================================--

	TargetMarker.Position =
		UDim2.fromOffset(
			headScreen.X,
			headScreen.Y
		)

	CalibrationMarker.Position =
		UDim2.fromOffset(
			center.X + calibration.X,
			center.Y + calibration.Y
		)

	--====================================================--
	-- DEBUG TEXT
	--====================================================--

	DebugText.Text =
		"TARGET: " ..
		player.Name ..
		"\n" ..

		"ERR X: " ..
		string.format(
			"%+.1f",
			error.X
		) ..

		"   Y: " ..
		string.format(
			"%+.1f",
			error.Y
		)

	--====================================================--
	-- AIM
	--====================================================--

	if Config.HardLock then

		local cameraPosition =
			Camera.CFrame.Position

		Camera.CFrame =
			CFrame.lookAt(
				cameraPosition,
				head.Position
			)
	end
end

--========================================================--
-- TOGGLE AIM
--========================================================--

local function ToggleAim()

	Enabled =
		not Enabled

	if Enabled then

		-- Bắt đầu vòng mới
		ClearSkippedTargets()

		Target =
			GetNearestTarget()

	else

		Target = nil

		ClearSkippedTargets()

		ClearHighlights()

		TargetMarker.Visible =
			Config.ShowDebug

		CalibrationMarker.Visible =
			Config.ShowDebug
	end

	UpdateButtons()
end

AimButton.MouseButton1Click:Connect(
	ToggleAim
)

--========================================================--
-- AUTO NEAREST TOGGLE
--========================================================--

NearestButton.MouseButton1Click:Connect(

	function()

		AutoNearest =
			not AutoNearest

		if AutoNearest
			and Enabled then

			local nearest =
				GetNearestTarget()

			if nearest then
				Target = nearest
			end
		end

		UpdateButtons()
	end
)

--========================================================--
-- KEYBOARD
--========================================================--

UserInputService.InputBegan:Connect(

	function(input, processed)

		if processed then
			return
		end

		--================================================--
		-- G = TOGGLE
		--================================================--

		if input.KeyCode ==
			Config.ToggleKey then

			ToggleAim()

			return
		end

		--================================================--
		-- E = NEXT TARGET
		--================================================--

		if input.KeyCode ==
			Config.NextTargetKey then

			if not Enabled then
				return
			end

			if not Target then

				Target =
					GetNearestTarget()

				return
			end

			local oldTarget =
				Target

			--================================================--
			-- QUAN TRỌNG:
			-- MỤC TIÊU CŨ BỊ SKIP
			--================================================--

			SkippedTargets[oldTarget] = true

			RemoveHighlight(
				oldTarget
			)

			--================================================--
			-- TÌM MỤC TIÊU TIẾP THEO
			--================================================--

			local nextTarget =
				GetNextTarget()

			if nextTarget then

				Target =
					nextTarget

			else

				--================================================--
				-- ĐÃ ĐI QUA HẾT MỤC TIÊU
				-- BẮT ĐẦU VÒNG MỚI
				--================================================--

				ClearSkippedTargets()

				local allTargets = {}

				for _, player in ipairs(
					Players:GetPlayers()
				) do

					if IsEnemy(player)
						and GetDistance(player)
							<= Config.MaxDistance then

						table.insert(
							allTargets,
							player
						)
					end
				end

				table.sort(
					allTargets,

					function(a, b)

						return GetDistance(a)
							< GetDistance(b)
					end
				)

				-- Ưu tiên người khác trước,
				-- tránh quay lại oldTarget ngay lập tức
				Target = nil

				for _, player in ipairs(
					allTargets
				) do

					if player ~= oldTarget then

						Target =
							player

						break
					end
				end

				-- Nếu chỉ còn đúng oldTarget
				if not Target then
					Target = oldTarget
				end
			end
		end
	end
)

--========================================================--
-- PLAYER REMOVING
--========================================================--

Players.PlayerRemoving:Connect(

	function(player)

		-- Xóa khỏi danh sách skip
		SkippedTargets[player] = nil

		if Target == player then

			Target = nil

			if Enabled then

				Target =
					GetNearestTarget()
			end
		end
	end
)

--========================================================--
-- AUTO NEAREST LOOP
--========================================================--

task.spawn(

	function()

		while true do

			task.wait(
				Config.AutoNearestInterval
			)

			if not Enabled then
				continue
			end

			if not AutoNearest then
				continue
			end

			local now =
				os.clock()

			if now -
				LastNearestCheck
				< Config.AutoNearestInterval then

				continue
			end

			LastNearestCheck =
				now

			local nearest =
				GetNearestTarget()

			if nearest
				and nearest ~= Target then

				if Target then

					RemoveHighlight(
						Target
					)
				end

				Target =
					nearest
			end
		end
	end
)

--========================================================--
-- CAMERA LOOP
--========================================================--

local RenderName =
	"AdvancedAimCameraLock"

RunService:UnbindFromRenderStep(
	RenderName
)

RunService:BindToRenderStep(

	RenderName,

	Enum.RenderPriority.Camera.Value + 1,

	function()

		if not Enabled then
			return
		end

		--================================================--
		-- TARGET KHÔNG CÒN HỢP LỆ
		--================================================--

		if not IsValidTarget(Target) then

			if Target then
				RemoveHighlight(Target)
			end

			Target =
				GetNearestTarget()

			return
		end

		--================================================--
		-- AIM
		--================================================--

		LockCamera(Target)
	end
)

--========================================================--
-- INITIALIZE
--========================================================--

UpdateButtons()

TargetMarker.Visible =
	Config.ShowDebug

CalibrationMarker.Visible =
	Config.ShowDebug