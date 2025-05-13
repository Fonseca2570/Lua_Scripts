local API = require("api")

local unstableProteanBars = 56652


while API.Read_LoopyLoop() do 
    if API.isProcessing() then 
        goto continue
    end


    if API.VB_FindPSett(2874, -1, 0).state ~= 0 then 
        API.KeyboardPress2(0x20, 0, 50) -- presses spacebar
        goto continue
    end

    if API.InvItemcount_1(unstableProteanBars) > 0 then 
        API.DoAction_Object1(0x3f,API.OFF_ACT_GeneralObject_route0,{ 113262 },50);
        goto continue
    end

    API.Write_LoopyLoop(false)

    ::continue::
    API.RandomSleep2(600,200,400)
end