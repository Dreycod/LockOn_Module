local LockOnModule = {}


local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
--// Services
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local MainTexture = Mouse.Icon
local IconTexture = script.LockOn.ImageLabel.Image
local Character =  Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Camera = workspace.CurrentCamera
local LockedOn = false

local Target = nil

local MaxDistance = script:GetAttribute("Distance")
local LockOnTexture = script:WaitForChild("LockOn")

function FindNearestTarget()
	local TargetDistance = MaxDistance
	local Found = nil
	for i,v in pairs(workspace:GetDescendants()) do
		if v:FindFirstChild("Humanoid") == nil then continue end
		if v:IsA("Model") ~= true then continue end 
		if v.Name == Character.Name then continue end 
		
		local Magnitude = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
		if Magnitude < TargetDistance then
			TargetDistance = Magnitude
			Found = v.HumanoidRootPart
		end
	end
	if Found ~= nil then 
		LockOnTexture.Parent = Found
	else 
		LockOnTexture.Parent = script
	end
	return Found
end

function TurnOn()
	if FindNearestTarget() == nil then TurnOff() return end 
	Target = FindNearestTarget()
	LockedOn = true
	Humanoid.AutoRotate = false
	ContextActionService:BindActionAtPriority("DisableM2", function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value,Enum.UserInputType.MouseButton2)
	-- Disables Moving around with the camera
end

function TurnOff()
	LockedOn = false
	LockOnTexture.Parent = script
	Target = nil
	Humanoid.AutoRotate = true
	ContextActionService:BindActionAtPriority("DisableM2", function()
		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value,Enum.UserInputType.MouseButton2)
	--Enables Moving around with the camera
end

function LockOnModule:Lock(value)
	if value == true then TurnOff() return end
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then TurnOff() return end
	if FindNearestTarget() == nil then return end 
	if LockedOn then 
		TurnOff() 
	else
		TurnOn() 
	end
end
local offset = CFrame.new(2.5,0.5,0)
local offset2 = {
	RightVector = 2.5;
	UpVector = 1;
}
local offset3 = {
	RightVector = 0.5;
	UpVector = 0.5;
}

function LockOnModule:StartThread()
	RunService.RenderStepped:Connect(function()
		if Target ~= nil and LockedOn == true then
			if Target.Parent.Humanoid.Health <= 0 then TurnOff() return end

			local Magnitude = (HumanoidRootPart.Position - Target.Position).Magnitude
			local SecondMagnitude = (Vector3.new(HumanoidRootPart.Position.X,0,HumanoidRootPart.Position.Z) - Vector3.new(Target.Position.X,0,Target.Position.Z)).Magnitude
			if Magnitude < MaxDistance then
				if (SecondMagnitude < 5 and (HumanoidRootPart.Position.Y - Target.Position.Y) >= 15) or (SecondMagnitude < 5 and (HumanoidRootPart.Position.Y - Target.Position.Y)  < -10) then  
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position,Target.Position) * offset
				elseif (HumanoidRootPart.Position.Y - Target.Position.Y) > 15 or (HumanoidRootPart.Position.Y - Target.Position.Y) < -10 then 
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position,Target.Position) * offset
					HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position,Vector3.new(Target.Position.X,HumanoidRootPart.CFrame.p.Y,Target.Position.Z))
				elseif  SecondMagnitude < 1 and (HumanoidRootPart.Position.Y - Target.Position.Y) < 15 and (HumanoidRootPart.Position.Y - Target.Position.Y) > -10 then
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position,Vector3.new(Target.Position.X,Camera.CFrame.Position.Y,Target.Position.Z)) * offset
				elseif SecondMagnitude < 10 then
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position,Target.Position) * offset
					HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position,Vector3.new(Target.Position.X,HumanoidRootPart.CFrame.p.Y,Target.Position.Z))
				else 
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position + (HumanoidRootPart.CFrame.RightVector * offset2.RightVector) + (HumanoidRootPart.CFrame.UpVector * offset2.UpVector) ,Vector3.new(Target.Position.X,Camera.CFrame.Position.Y,Target.Position.Z))
					HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position,Vector3.new(Target.Position.X,HumanoidRootPart.CFrame.p.Y,Target.Position.Z))
				end
			else
				TurnOff()
			end
		end
	end)
end
return LockOnModule
