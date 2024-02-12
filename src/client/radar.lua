local screenW, screenH = guiGetScreenSize()

local panelWidth, panelHeight = 420, 200
local panelX, panelY = screenW - (panelWidth + 10), screenH - (panelHeight + 15)
local panelState = false
local toOpen = false

local inter_bold10 = dxCreateFont("src/client/assets/fonts/inter_bold.ttf", 10)
local inter_bold8 = dxCreateFont("src/client/assets/fonts/inter_bold.ttf", 8)
local digital_font30 = dxCreateFont("src/client/assets/fonts/digital_font.ttf", 30)
local digital_font15 = dxCreateFont("src/client/assets/fonts/digital_font.ttf", 15)

local fastSpeed = 0
local BWD_Speed = 0
local FWD_Speed = 0
local FWD_plate = "XXXX XXX"
local BWD_plate = "XXXX XXX"

local vehicles = {}
local collisions = {}

local function render()
    if panelState then
        local radarVehicles = vehicles[localPlayer]
        drawRoundedRectangle("radar", panelX, panelY, panelWidth, panelHeight, tocolor(15, 15, 15), 10)

        dxDrawText("FRONT ANTENNA", panelX + (panelWidth / 2 - 60), panelY, 0, 0, tocolor(255, 255, 255), 1, inter_bold10)
        dxDrawText("REAR ANTENNA", panelX + (panelWidth / 2 - 50), panelY + (panelHeight - 20), 0, 0, tocolor(255, 255, 255), 1, inter_bold10)

        dxDrawImage(panelX + (152), panelY + (35), 16, 15, "src/client/assets/images/arrow.png", -90, 0, 0, tocolor(0, 0, 0))
        dxDrawImage(panelX + (152), panelY + (65), 16, 15, "src/client/assets/images/arrow.png", 90, 0, 0, tocolor(0, 0, 0))

        dxDrawImage(panelX + (152), panelY + (70 * 2 - 30), 16, 15, "src/client/assets/images/arrow.png", -90, 0, 0, tocolor(0, 0, 0))
        dxDrawImage(panelX + (152), panelY + (70 * 2), 16, 15, "src/client/assets/images/arrow.png", 90, 0, 0, tocolor(0, 0, 0))
    
        -- PLATE
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 + 40), 100, 15, tocolor(0, 0, 0))
        dxDrawText("PLATE FWD", panelX + panelWidth - (230), panelY + (40 + 38), 0, 0, tocolor(255, 255, 255), 1, inter_bold10)
        if radarVehicles.FWD_wanted then
            dxDrawText(FWD_plate, panelX + panelWidth - (238), panelY + (45), 0, 0, tocolor(0, 0, 0), 1, digital_font15)
        else
            dxDrawText(FWD_plate, panelX + panelWidth - (238), panelY + (45), 0, 0, tocolor(255, 255, 255), 1, digital_font15)
        end

        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 * 2 + 20), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + panelWidth - (240), panelY + (40 + 40 * 2 + 20), 100, 15, tocolor(0, 0, 0))
        dxDrawText("PLATE BWD", panelX + panelWidth - (230), panelY + (40 + 38 * 2 + 22), 0, 0, tocolor(255, 255, 255), 1, inter_bold10)
        if radarVehicles.BWD_wanted then
            dxDrawText(BWD_plate, panelX + panelWidth - (238), panelY + (45 * 2 + 20), 0, 0, tocolor(0, 0, 0), 1, digital_font15)
        else
            dxDrawText(BWD_plate, panelX + panelWidth - (238), panelY + (45 * 2 + 20), 0, 0, tocolor(255, 255, 255), 1, digital_font15)
        end

        -- SPEED
        dxDrawRectangle(panelX + (40), panelY + (20), 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + (40), panelY + (70), 100, 15, tocolor(0, 0, 0))
        dxDrawText("FWD", panelX + (75), panelY + (68), 0, 0, tocolor(255, 255, 255), 1, inter_bold10)
        dxDrawText(string.format("%03d", FWD_Speed), panelX + (50), panelY + (22), 0, 0, tocolor(255, 255, 255), 1, digital_font30)


        dxDrawRectangle(panelX + (40), panelY + (20 + 70) + 10, 100, 50, tocolor(160, 0, 0))
        dxDrawRectangle(panelX + (40), panelY + (70 + 70) + 10, 100, 15, tocolor(0, 0, 0))
        dxDrawText("BWD", panelX + (75), panelY + (68 + 70) + 10, 0, 0, tocolor(255, 255, 255), 1, inter_bold10)
        dxDrawText(string.format("%03d", BWD_Speed), panelX + (50), panelY + (68 + 30), 0, 0, tocolor(255, 255, 255), 1, digital_font30)
        if radarVehicles.FWD or radarVehicles.BWD then
            local FWD = radarVehicles.FWD
            local BWD = radarVehicles.BWD
            if FWD and not radarVehicles.FWD_last then
                local FWDx, FWDy, FWDz = getElementVelocity(FWD)
                local speed = math.floor((FWDx^2 + FWDy^2 + FWDz^2)^(0.5) * 180)
                FWD_Speed = speed
                FWD_plate = radarVehicles.FWD_plate
            end
            if BWD and not radarVehicles.BWD_last then
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
        dxDrawText("PATROL SPEED", panelX + panelWidth - (114), panelY + (68 + 32) + 10, 0, 0, tocolor(255, 255, 255), 1, inter_bold8)
        dxDrawText(tostring(patrolSpeed), panelX + panelWidth - (110), panelY + (55) + 10, 0, 0, tocolor(255, 255, 255), 1, digital_font30)
    end
end

local function enterCol(theElement, matchingDimension)
    if getElementType(theElement) == "vehicle" and theElement ~= vehicles[localPlayer].patrol and matchingDimension == true then
        if getElementData(theElement, "police") then
            if source == collisions[localPlayer].FWD then
                vehicles[localPlayer].FWD = theElement
                vehicles[localPlayer].FWD_last = false
                vehicles[localPlayer].FWD_plate = getVehiclePlateText(theElement)
                vehicles[localPlayer].FWD_wanted = getElementData(theElement, main_settings.wanted)
                if vehicles[localPlayer].FWD_wanted then
                    playSound(main_settings.sound, false)
                end
            elseif source == collisions[localPlayer].BWD then
                vehicles[localPlayer].BWD = theElement
                vehicles[localPlayer].BWD_last = false
                vehicles[localPlayer].BWD_plate = getVehiclePlateText(theElement)
                vehicles[localPlayer].BWD_wanted = getElementData(theElement, main_settings.wanted)
                if vehicles[localPlayer].BWD_wanted then
                    playSound(main_settings.sound, false)
                end
            end
        end
    end
end

local function leaveCol(theElement, matchingDimension)
    if getElementType(theElement) == "vehicle" and theElement ~= vehicles[localPlayer].patrol and matchingDimension == true then
        if source == collisions[localPlayer].FWD then
            vehicles[localPlayer].FWD_last = true
        elseif source == collisions[localPlayer].BWD then
            vehicles[localPlayer].BWD_last = true
        end
    end
end

local function openRadar()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle and getElementData(vehicle, main_settings.patrol) then
        if toOpen then
            if not panelState then
                if not collisions[localPlayer] then collisions[localPlayer] = {} end
                if not vehicles[localPlayer] then vehicles[localPlayer] = {} end
                panelState = true
                addEventHandler("onClientRender", root, render)
                vehicles[localPlayer].patrol = vehicle
                collisions[localPlayer].FWD = createColSphere(Vector3(getElementPosition(localPlayer)), main_settings.range)
                attachElements(collisions[localPlayer].FWD, vehicle, 0, tonumber(main_settings.range) + 2)
                collisions[localPlayer].BWD = createColSphere(Vector3(getElementPosition(localPlayer)), main_settings.range)
                attachElements(collisions[localPlayer].BWD, vehicle, 0, -(tonumber(main_settings.range) + 2))
                addEventHandler("onClientColShapeHit", root, enterCol)
                addEventHandler("onClientColShapeLeave", root, leaveCol)
            else
                panelState = false
                removeEventHandler("onClientRender", root, render)
                destroyElement(collisions[localPlayer].FWD)
                destroyElement(collisions[localPlayer].BWD)
                removeEventHandler("onClientColShapeHit", root, enterCol)
                removeEventHandler("onClientColShapeLeave", root, leaveCol)
            end
        end
    end
end
addCommandHandler("Abrir radar policial", openRadar)
bindKey(main_settings.bindToOpen, "down", "Abrir radar policial")

local function enterVehicle(player, seat)
    if not toOpen and seat == 0 then
        toOpen = true
    end
end
addEventHandler("onClientVehicleEnter", root, enterVehicle)

local function leaveVehicle()
    if panelState then
        panelState = false
        removeEventHandler("onClientRender", root, render)
        destroyElement(collisions[localPlayer].FWD)
        destroyElement(collisions[localPlayer].BWD)
        removeEventHandler("onClientColShapeHit", root, enterCol)
        removeEventHandler("onClientColShapeLeave", root, leaveCol)
    end
end
addEventHandler("onClientVehicleExit", root, leaveVehicle)

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