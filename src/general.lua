
main_settings = {
    panelSize = {
        panelWidth = 420, -- Width to radar
        panelHeight = 200 -- Height to radar
    },

    openPanel = "n", -- bindKey to open the radar
    soundPath = "src/client/assets/sounds/beep.mp3", -- The sound for a wanted car

    patrol = "ID", -- To choose whether the patrol will be set with 'elementData' or by 'ID'

    vehicle_wanted = "police.wanted", -- The elementData to set a vehicle wanted
    vehicle_patrol = "police.vehicle", -- The elementData to set a patrol in vehicle

    range_radar = 15
}

patrol_ids = {
    [597] = true,
}