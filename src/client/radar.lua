local screenW, screenH = guiGetScreenSize()

local settings = main_settings
local panelWidth, panelHeight = settings.panelSize.panelWidth, settings.panelSize.panelHeight
local panelX, panelY = screenW - (panelWidth + 10), screenH - (panelHeight + 15)
local panelState, canOpen = false, false

local inter_b10 = dxCreateFont("src/client/assets/fonts/inter_bold.ttf", 10)
local inter_b8 = dxCreateFont("src/client/assets/fonts/inter_bold.ttf", 8)
local digital_30 = dxCreateFont("src/client/assets/fonts/digital.ttf", 30)
local digital_15 = dxCreateFont("src/client/assets/fonts/digital.ttf", 15)

local lastSpeed, FWD_Speed, BWD_Speed = 0, 0, 0
local FWD_Plate, BWD_Plate = "XXXX XXX", "XXXX XXX"

local radar_collision, radar_vehicles = {}, {}
local check_patrol

local function render()
    if panelState then
        local vehiclesData = radar_vehicles[localPlayer]
        drawRoundedRectangle("radar", panelX, panelY, panelWidth, panelHeight, tocolor(15, 15, 15), 10)

        dxDrawText("FRONT ANTENNA", panelX + (panelWidth / 2 - 60), panelY, 0, 0, tocolor(255, 255, 255), 1, inter_b10)
        dxDrawText("REAR ANTENNA", panelX + (panelWidth / 2 - 50), panelY + (panelHeight - 20), 0, 0, tocolor(255, 255, 255), 1, inter_b10)

        dxDrawImage(panelX + (152), panelY + (35), 16, 15, "src/client/assets/images/arrow.png", -90, 0, 0, tocolor(0, 0, 0))
        dxDrawImage(panelX + (152), panelY + (65), 16, 15, "src/client/assets/images/arrow.png", 90, 0, 0, tocolor(0, 0, 0))

        dxDrawImage(panelX + (152), panelY + (70 * 2 - 30), 16, 15, "src/client/assets/images/arrow.png", -90, 0, 0, tocolor(0, 0, 0))
        dxDrawImage(panelX + (152), panelY + (70 * 2), 16, 15, "src/client/assets/images/arrow.png", 90, 0, 0, tocolor(0, 0, 0))
    
        -- PLATE
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 + 40), 100, 15, tocolor(0, 0, 0))
        dxDrawText("PLATE FWD", panelX + panelWidth - (230), panelY + (40 + 38), 0, 0, tocolor(255, 255, 255), 1, inter_b10)
        if vehiclesData.FWD_wanted then
            dxDrawText(FWD_plate, panelX + panelWidth - (238), panelY + (45), 0, 0, tocolor(0, 0, 0), 1, digital_15)
        else
            dxDrawText(FWD_plate, panelX + panelWidth - (238), panelY + (45), 0, 0, tocolor(255, 255, 255), 1, digital_15)
        end

        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 * 2 + 20), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 + 40 * 2 + 20), 100, 15, tocolor(0, 0, 0))
        dxDrawText("PLATE BWD", panelX + panelWidth - (230), panelY + (40 + 38 * 2 + 22), 0, 0, tocolor(255, 255, 255), 1, inter_b10)
        if vehiclesData.BWD_wanted then
            dxDrawText(BWD_plate, panelX + panelWidth - (238), panelY + (45 * 2 + 20), 0, 0, tocolor(0, 0, 0), 1, digital_15)
        else
            dxDrawText(BWD_plate, panelX + panelWidth - (238), panelY + (45 * 2 + 20), 0, 0, tocolor(255, 255, 255), 1, digital_15)
        end

        -- SPEED
        dxDrawRectangle(panelX + (40), panelY + (20), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + (40), panelY + (70), 100, 15, tocolor(0, 0, 0))
        dxDrawText("FWD", panelX + (75), panelY + (68), 0, 0, tocolor(255, 255, 255), 1, inter_b10)
        dxDrawText(string.format("%03d", FWD_Speed), panelX + (50), panelY + (22), 0, 0, tocolor(255, 255, 255), 1, digital_30)


        dxDrawRectangle(panelX + (40), panelY + (20 + 70) + 10, 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + (40), panelY + (70 + 70) + 10, 100, 15, tocolor(0, 0, 0))
        dxDrawText("BWD", panelX + (75), panelY + (68 + 70) + 10, 0, 0, tocolor(255, 255, 255), 1, inter_b10)
        dxDrawText(string.format("%03d", BWD_Speed), panelX + (50), panelY + (68 + 30), 0, 0, tocolor(255, 255, 255), 1, digital_30)
        if vehiclesData.FWD or vehiclesData.BWD then
            local FWD = vehiclesData.FWD
            local BWD = vehiclesData.BWD
            if FWD and not vehiclesData.FWD_last then
                local FWDx, FWDy, FWDz = getElementVelocity(FWD)
                local speed = math.floor((FWDx^2 + FWDy^2 + FWDz^2)^(0.5) * 180)
                FWD_Speed = speed
                FWD_plate = vehiclesData.FWD_plate
            end
            if BWD and not vehiclesData.BWD_last then
                local BWDx, BWDy, BWDz = getElementVelocity(BWD)
                local speed = math.floor((BWDx^2 + BWDy^2 + BWDz^2)^(0.5) * 180)
                BWD_Speed = speed
                BWD_plate = radarVehicles.BWD_plate
            end
        end

        local vehicle = getPedOccupiedVehicle(localPlayer)
        local patrolSpeed = string.format("%03d", 0)
        if vehicle then
            local SpeedX, SpeedY, SpeedZ = getElementVelocity(vehicle)
            patrolSpeed = string.format("%03d", math.floor((SpeedX^2 + SpeedY^2 + SpeedZ^2)^(0.5) * 180))
        end
        dxDrawRectangle(panelX + panelWidth - (120), panelY + (20 + 40) + 10, 100, 50, tocolor(33, 133, 13))
        dxDrawRectangle(panelX + panelWidth - (120), panelY + (70 + 30) + 10, 100, 15, tocolor(0, 0, 0))
        dxDrawText("PATROL SPEED", panelX + panelWidth - (114), panelY + (68 + 32) + 10, 0, 0, tocolor(255, 255, 255), 1, inter_b8)
        dxDrawText(tostring(patrolSpeed), panelX + panelWidth - (110), panelY + (55) + 10, 0, 0, tocolor(255, 255, 255), 1, digital_30)
    end
end

local function enterCol(theElement, matchingDimension)
    local radarData, vehiclesData = radar_collision[localPlayer], radar_vehicles[localPlayer]
    if getElementType(theElement) == "vehicle" and theElement ~= vehiclesData.patrol and matchingDimension == true then
        if getElementData(theElement, "police.vehicle") then
            if source == radarData.FWD then
                vehiclesData.FWD = theElement
                vehiclesData.FWD_last = false
                vehiclesData.FWD_plate = getVehiclePlateText(theElement)
                vehiclesData.FWD_wanted = getElementData(theElement, settings.vehicle_wanted)
                if vehiclesData.FWD_wanted then
                    playSound(settings.soundPath, false)
                end
            elseif source == radarData.BWD then
                vehiclesData.BWD = theElement
                vehiclesData.BWD_last = false
                vehiclesData.BWD_plate = getVehiclePlateText(theElement)
                vehiclesData.BWD_wanted = getElementData(theElement, settings.vehicle_wanted)
                if vehiclesData.BWD_wanted then
                    playSound(settings.soundPath, false)
                end
            end
        end
    end
end

local function leaveCol(theElement, matchingDimension)
    local radarData, vehiclesData = radar_collision[localPlayer], radar_vehicles[localPlayer]
    if getElementType(theElement) == "vehicle" and theElement ~= vehiclesData.patrol and matchingDimension == true then
        if source == radarData.FWD then
            vehiclesData.FWD_last = true
        elseif source == radarData.BWD then
            vehiclesData.BWD_last = true
        end
    end
end

local function toggleRadar()
    local theVehicle = getPedOccupiedVehicle(localPlayer)
    if theVehicle and canOpen then
        if not panelState then
            if not radar_collision[localPlayer] then radar_collision[localPlayer] = {} end
            if not radar_vehiclesData then radar_vehiclesData = {} end
            panelState = true
            addEventHandler("onClientRender", root, render)
            radar_vehiclesData.patrol = theVehicle
            radar_collision[localPlayer].FWD = createColSphere(Vector3(getElementPosition(localPlayer)), settings.range_radar)
            attachElements(radar_collision[localPlayer].FWD, theVehicle, 0, tonumber(settings.range_radar) + 2)
            radar_collision[localPlayer].BWD = createColSphere(Vector3(getElementPosition(localPlayer)), settings.range_radar)
            attachElements(radar_collision[localPlayer].BWD, theVehicle, 0, -(tonumber(settings.range_radar) + 2))
            addEventHandler("onClientColShapeHit", root, enterCol)
            addEventHandler("onClientColShapeLeave", root, leaveCol)
        else
            panelState = false
            removeEventHandler("onClientRender", root, render)
            destroyElement(radar_collision[localPlayer].FWD)
            destroyElement(radar_collision[localPlayer].BWD)
            removeEventHandler("onClientColShapeHit", root, enterCol)
            removeEventHandler("onClientColShapeLeave", root, leaveCol)
        end
    end
end
addCommandHandler("Abrir radar policial", toggleRadar)
bindKey(settings.openPanel, "down", "Abrir radar policial")

local function enterVehicle(player, seat)
    if not canOpen and seat == 0 then
        if check_patrol == 0 then
            if getElementData(source, "police.vehicle") then
                canOpen = true
            end
        else
            local vehicleID = getElementModel(source)
            for index, _ in pairs(patrol_ids) do
                if vehicleID == index then
                    canOpen = true
                    setElementData(source, "police.vehicle", true)
                end
            end
        end
    end
end
addEventHandler("onClientVehicleEnter", root, enterVehicle)

local function leaveVehicle()
    if panelState then
        panelState = false
        removeEventHandler("onClientRender", root, render)
        destroyElement(radar_collision[localPlayer].FWD)
        destroyElement(radar_collision[localPlayer].BWD)
        removeEventHandler("onClientColShapeHit", root, enterCol)
        removeEventHandler("onClientColShapeLeave", root, leaveCol)
    end
end
addEventHandler("onClientVehicleExit", root, leaveVehicle)

function setVehicleWantedState(vehicle, bool)
    if vehicle then
        setElementData(vehicle, settings.vehicle_wanted, bool)
    end
end

function setVehiclePatrolState(vehicle, bool)
    if vehicle then
        setElementData(vehicle, settings.vehicle_patrol, bool)
    end
end

local function initial()
    if settings.patrol == "elementData" then
        check_patrol = 0
    else
        check_patrol = 1
    end
end
addEventHandler("onClientResourceStart", resourceRoot, initial)

--<!-- UTILS -->

local rectangles = {}

function drawRoundedRectangle(id, x, y, width, height, color, radius, borderColor, borderSize, postGUI)
    postGUI = postGUI or false
    borderColor = borderColor or color
    borderSize = borderSize or 0
    if (not rectangles[id]) then
        local rawData = string.format([[
            <svg width="%s" height="%s" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect rx="%s" width="%s" height="%s" fill="#ffffff"/>
            </svg>
        ]], width, height, radius, width, height)
        rectangles[id] = svgCreate(width, height, rawData)
    end
    if (rectangles[id]) then
        dxSetBlendMode('add')
        if borderSize > 0 then
            dxDrawImage(x - (borderSize), y - (borderSize), width + (borderSize * 2), height + (borderSize * 2), rectangles[id], 0, 0, 0, borderColor, postGUI)
        end
        dxDrawImage(x, y, width, height, rectangles[id], 0, 0, 0, color, postGUI)
        dxSetBlendMode('blend')
    end
end 