local targetPlayer = "dexterity"
local worldname = "lf"

local bfgx = 31
local bfgy = 4
local consumeitems = {528, 4604}
local loop_delay = 1801000
local bfgequip = 17694
local bfgmag = 5640
local bfgmagx = 0
local bfgmagy = 2

local afkx = 97
local afky = 2
local delaypt = 40
local delayht = 265
local harvestid = 17715
local stopitemid = 17715
local pthtequip = 6840
local pthtmag = 5640
local pthtmagx = 1
local pthtmagy = 55
local ex = 99
local sy = 6
local ey = 58
local ptht = "ptht"
local useuws = true
local mode = 2

local delayrepeat = 300000

local is_running = false
local uwscount = 0
local bglbought = 0
local lastconsumetime = 0
local starttime = os.time()
local lastdelaytime = os.time()
local depositingbgl = false
local isreconnecting = false
local botmode = "bfg"

function getuptime()
    local elapsed = os.time() - starttime
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = elapsed % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

function showoverview()
    sendVariant({v1 = "OnDialogRequest", v2 = "set_default_color|`o\nadd_label_with_icon|big|`bScript by Dexterity``|left|7188|\nadd_spacer|small|\nadd_label|small|`wUptime : ``" .. getuptime() .. "|left\nadd_label|small|`wBGL Bought : ``" .. bglbought .. "|left\nadd_spacer|small|\nadd_label|small|`ohttps://novascript.site|left\nadd_spacer|small|\nend_dialog|bfg_overview|Close||"})
end

function useitem(id)
    local player = getLocal()
    if not player then return end
    local pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = math.floor(player.posX / 32)
    pkt.py = math.floor(player.posY / 32)
    pkt.x = player.posX
    pkt.y = player.posY
    sendPacketRaw(false, pkt)
    lastconsumetime = os.time()
end

function consume_all()
    for i = 1, #consumeitems do
        useitem(consumeitems[i])
        if i < #consumeitems then
            sleep(500)
        end
    end
end

function wearitem(id)
    local pkt = {}
    pkt.type = 10
    pkt.value = id
    sendPacketRaw(false, pkt)
end

function path(x, y, s)
    sendPacketRaw(false, {state = s, px = x, py = y, x = x * 32, y = y * 32})
end

function h2(x, y, i)
    sendPacketRaw(false, {type = 3, value = i, px = x, py = y, x = x * 32, y = y * 32})
end

function gettree()
    local c = 0
    for x = 0, ex do 
        for y = sy, ey do 
            local t, a = getTile(x, y), getTile(x, y + 1)
            if t and a and t.fg == 0 and a.fg ~= 0 and a.fg % 2 == 0 then 
                c = c + 1 
            end 
        end 
    end
    return c 
end

function getready()
    local r = 0
    for x = 0, ex do 
        for y = sy, ey do 
            local t = getTile(x, y)
            if t and t.fg == harvestid and t.readyharvest then 
                r = r + 1 
            end 
        end 
    end
    return r 
end

function uws()
    uwscount = uwscount + 1
    sendPacket(2, "action|input\n|text|`w[ (grow) ] [`3Dexterity`w] : UWS Consumed : " .. uwscount)
    sleep(200)
    sendPacket(2, "action|dialog_return\ndialog_name|uw_spray")
    sleep(1000)
end

function isinwrongworld()
    local success, currentworld = pcall(GetWorldName)
    if not success or not currentworld or currentworld == "" or currentworld == "EXIT" or currentworld:lower() ~= worldname:lower() then
        return true
    end
    return false
end

function reconnect()
    if isreconnecting then return end
    isreconnecting = true
    
    sendPacket(3, "action|join_request\nname|" .. worldname .. "\ninvitedWorld|0")
    sleep(6000)
    
    if not isinwrongworld() then
        if botmode == "bfg" then
            findPath(bfgx, bfgy)
            sleep(1000)
            wearitem(bfgequip)
            sleep(500)
            if os.time() - lastconsumetime >= (loop_delay / 1000) then
                consume_all()
                sleep(1000)
            end
            sendPacket(2, "action|dialog_return\ndialog_name|itemsucker\ntilex|" .. bfgmagx .. "|\ntiley|" .. bfgmagy .. "|\nbuttonClicked|getplantationdevice")
            sleep(500)
            sendPacket(2, "action|dialog_return\ndialog_name|cheat_dialog\nselect_farm_id|" .. bfgmag .. "\nbuttonClicked|OK!")
            sleep(500)
            sendPacket(2, "action|dialog_return\ndialog_name|cheat_dialog\ncheat_nocollect|1\ncheat_autobfg|1\ncheat_autofarm|1\nbuttonClicked|OK!")
            lastdelaytime = os.time()
            is_running = true
            sendVariant({v1 = "OnConsoleMessage", v2 = "`l`2[CONTROL] BFG otomatis berjalan..."})
        elseif botmode == "ptht" then
            sendPacket(2, "action|dialog_return\ndialog_name|itemsucker\ntilex|" .. pthtmagx .. "|\ntiley|" .. pthtmagy .. "|\nbuttonClicked|getplantationdevice")
            sleep(1000)
            findPath(afkx, afky)
            sleep(2000)
            wearitem(pthtequip)
            sleep(500)
            is_running = true
            sendVariant({v1 = "OnConsoleMessage", v2 = "`l`2[CONTROL] PTHT otomatis berjalan..."})
        end
    end
    
    isreconnecting = false
end

function isitemdropped(id)
    local objs = getObjectList()
    if objs then
        for _, obj in pairs(objs) do
            if obj.itemid == id then
                return true
            end
        end
    end
    return false
end

function checkpause()
    while is_running and not isinwrongworld() and isitemdropped(stopitemid) do
        sleep(500)
    end
end

function plant()
    sendPacket(2, "action|input\n|text|`w[ (grow) ] [`3Dexterity`w] :  Planting Seed")
    sleep(100)
    for x = 0, ex do
        if not is_running or isinwrongworld() then break end
        local planted
        repeat
            if not is_running or isinwrongworld() then break end
            planted = true
            if mode == 1 then
                for y = sy, ey do
                    if not is_running then break end
                    checkpause()
                    local t, a = getTile(x, y), getTile(x, y + 1)
                    if t and a and t.fg == 0 and a.fg ~= 0 and a.fg % 2 == 0 then
                        path(x, y, 32)
                        h2(x, y, pthtmag)
                        sleep(delaypt)
                        planted = false
                    end
                end
            elseif mode == 2 then
                for y = ey, sy, -1 do
                    if not is_running then break end
                    checkpause()
                    local t, a = getTile(x, y), getTile(x, y + 1)
                    if t and a and t.fg == 0 and a.fg ~= 0 and a.fg % 2 == 0 then
                        path(x, y, 32)
                        h2(x, y, pthtmag)
                        sleep(delaypt)
                        planted = false
                    end
                end
            end
        until planted
    end
end

function harvest()
    sendPacket(2, "action|input\n|text|`w[ (punch) ] [`3Dexterity`w] :  Harvesting Tree")
    sleep(100)
    for x = 0, ex do
        if not is_running or isinwrongworld() then break end
        local harvested
        repeat
            if not is_running or isinwrongworld() then break end
            harvested = true
            if mode == 1 then
                for y = sy, ey do
                    if not is_running then break end
                    checkpause()
                    local t = getTile(x, y)
                    if t and t.fg == harvestid and t.readyharvest then
                        path(x, y, pthtmag)
                        h2(x, y, 18)
                        sleep(delayht)
                        harvested = false
                    end
                end
            elseif mode == 2 then
                for y = ey, sy, -1 do
                    if not is_running then break end
                    checkpause()
                    local t = getTile(x, y)
                    if t and t.fg == harvestid and t.readyharvest then
                        path(x, y, pthtmag)
                        h2(x, y, 18)
                        sleep(delayht)
                        harvested = false
                    end
                end
            end
        until harvested
    end
end

function showstatus()
    sendVariant({v1 = "OnConsoleMessage", v2 = "`2[STATUS] `wMode:`^" .. ptht .. "`w,Delay:`^" .. delaypt .. "`w/`^" .. delayht .. "`w,HarvestID:`^" .. harvestid})
    sendVariant({v1 = "OnConsoleMessage", v2 = "`2[STATUS] `wBatas(sy,ey):`^" .. sy .. "," .. ey .. "`w,Status:`^" .. tostring(is_running) .. "`w,UWS:`^" .. tostring(useuws)})
end

function showcommanddialog()
    local cmd_dialog = "add_label_with_icon|big|`2Command & Settings|left|" .. harvestid .. "|\n" ..
    "add_spacer|small|\n" ..
    "add_textbox|`9--- Pengaturan PTHT ---|left|\n" ..
    "add_label_with_icon|small|`0Mode         : `2" .. ptht .. "|left|5638|\n" ..
    "add_label_with_icon|small|`0PTHT Mag ID   : `2" .. pthtmag .. "|left|5640|\n" ..
    "add_label_with_icon|small|`0PTHT Mag X,Y  : `2" .. pthtmagx .. ", " .. pthtmagy .. "|left|5640|\n" ..
    "add_label_with_icon|small|`0Delay Tanam   : `2" .. delaypt .. "|left|1432|\n" ..
    "add_label_with_icon|small|`0Delay Panen   : `2" .. delayht .. "|left|1482|\n" ..
    "add_label_with_icon|small|`0Harvest ID    : `2" .. harvestid .. "|left|16957|\n" ..
    "add_label_with_icon|small|`0Stop Item ID  : `2" .. stopitemid .. "|left|2066|\n" ..
    "add_label_with_icon|small|`0Batas Atas(sy): `2" .. sy .. "|left|242|\n" ..
    "add_label_with_icon|small|`0Batas Bawah(ey): `2" .. ey .. "|left|242|\n" ..
    "add_label_with_icon|small|`0Gunakan UWS   : `2" .. tostring(useuws) .. "|left|10622|\n" ..
    "add_label_with_icon|small|`0UWS Consumed  : `2" .. uwscount .. " kali|left|10622|\n" ..
    "add_label_with_icon|small|`0Arah Gerak    : `2Mode " .. mode .. "|left|1432|\n" ..
    "add_spacer|small|\n" ..
    "add_textbox|`9--- Pengaturan BFG ---|left|\n" ..
    "add_label_with_icon|small|`0BFG Mag ID    : `2" .. bfgmag .. "|left|5640|\n" ..
    "add_label_with_icon|small|`0BFG Mag X,Y   : `2" .. bfgmagx .. ", " .. bfgmagy .. "|left|5640|\n" ..
    "add_label_with_icon|small|`0Consume Items : `2" .. table.concat(consumeitems, ", ") .. "|left|528|\n" ..
    "add_label_with_icon|small|`0Loop Delay    : `2" .. loop_delay .. "|left|1432|\n" ..
    "add_spacer|small|\n" ..
    "add_textbox|`9--- Status Script ---|left|\n" ..
    "add_label_with_icon|small|`0Status Script : `2" .. tostring(is_running) .. "|left|18|\n" ..
    "add_label_with_icon|small|`0Mode Aktif    : `2" .. botmode .. "|left|18|\n" ..
    "add_spacer|small|\n" ..
    "add_textbox|`9Perintah Tersedia:|left|\n" ..
    "add_label_with_icon|small|`0/start, /stop, /status, /cmd|left|10078|\n" ..
    "add_label_with_icon|small|`0/dp, /dh, /hid, /mode, /uws|left|10078|\n" ..
    "add_label_with_icon|small|`0/sy, /ey, /coordatas, /coordbawah|left|10078|\n" ..
    "add_label_with_icon|small|`0/arah|left|10078|\n" ..
    "end_dialog|cmddialog|Close|OK!|"
    sendVariant({v1 = "OnDialogRequest", v2 = cmd_dialog})
end

function handlecommands(packet)
    local text = packet:gsub("action|input\n|text|", ""):lower()
    local cmd, value = text:match("^/([^%s]+)%s*(.*)")
    if not cmd then return false end
    local handled = true
    if cmd == "dp" then delaypt = tonumber(value) or delaypt; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Delay Tanam:`^" .. delaypt})
    elseif cmd == "dh" then delayht = tonumber(value) or delayht; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Delay Panen:`^" .. delayht})
    elseif cmd == "hid" then harvestid = tonumber(value) or harvestid; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Harvest ID:`^" .. harvestid})
    elseif cmd == "mode" then 
        value = value:lower()
        if value == "pt" or value == "ht" or value == "ptht" then ptht = value; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Mode:`^" .. ptht}) else sendVariant({v1 = "OnConsoleMessage", v2 = "`4[ERROR] Mode tidak valid."}) end
    elseif cmd == "arah" then
        local m = tonumber(value)
        if m and (m == 1 or m == 2) then 
            mode = m; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Arah Gerak:`^ Mode " .. mode})
        else
            sendVariant({v1 = "OnConsoleMessage", v2 = "`4[ERROR] Arah tidak valid (1 atau 2)."})
        end
    elseif cmd == "sy" then sy = tonumber(value) or sy; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Batas Atas (sy):`^" .. sy})
    elseif cmd == "ey" then ey = tonumber(value) or ey; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Batas Bawah (ey):`^" .. ey})
    elseif cmd == "coordatas" then local me = getLocal(); if me then sy = math.floor(me.posY / 32); sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Batas Atas(sy):`^" .. sy}) end
    elseif cmd == "coordbawah" then local me = getLocal(); if me then ey = math.floor(me.posY / 32); sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Batas Bawah(ey):`^" .. ey}) end
    elseif cmd == "start" then is_running = true; sendVariant({v1 = "OnConsoleMessage", v2 = "`l`2[CONTROL] Siklus " .. botmode .. " dimulai..."})
    elseif cmd == "stop" then is_running = false; sendVariant({v1 = "OnConsoleMessage", v2 = "`l`4[CONTROL] Siklus dihentikan."})
    elseif cmd == "status" then showstatus()
    elseif cmd == "cmd" then showcommanddialog()
    elseif cmd == "uws" then useuws = not useuws; sendVariant({v1 = "OnConsoleMessage", v2 = "`2[SET] Gunakan UWS:`^" .. tostring(useuws)})
    else handled = false end
    return handled
end

addHook(function(x)
    if x.v1 == "OnStoreRequest" then
        return true
    end
    if x.v1:find("OnDialogRequest") then
        if x.v2:find("GTFY Cheat Menu") then
            return true
        end
        if x.v2:find("`bMy Bank``") then
            if depositingbgl then
                runThread(function()
                    sleep(300)
                    sendPacket(2, "action|dialog_return\ndialog_name|my_bank_account\nbuttonClicked|deposit\n")
                end)
            end
            return true
        end
        if x.v2:find("`bDeposit``") then
            if depositingbgl then
                runThread(function()
                    sleep(300)
                    local bgl_count = 0
                    local inv = getInventory()
                    if inv then
                        for _, item in pairs(inv) do
                            if item.id == 7188 then
                                bgl_count = item.amount
                                break
                            end
                        end
                    end
                    if bgl_count > 0 then
                        sendPacket(2, "action|dialog_return\ndialog_name|my_bank_account\nbuttonClicked|depo_true\nbgl_|" .. bgl_count .. "\n")
                        bglbought = bglbought + bgl_count
                        sendPacket(2, "action|input\n|text|`4[`9Dexterity`4] " .. bgl_count .. " BGL Deposited.")
                    end
                    depositingbgl = false
                end)
            end
            return true
        end
        if x.v2:find("my_bank_account") or x.v2:find("Bank") then
            return true
        end
    end
    if x.v1 == "OnConsoleMessage" then
        local msg = x.v2
        local myname = getLocal() and getLocal().name or "unknown"
        if msg:find("-bfg") and not msg:find(myname) then
            botmode = "bfg"
            is_running = false
            runThread(reconnect)
        end
        if msg:find("-ptht") and not msg:find(myname) then
            botmode = "ptht"
            is_running = false
            runThread(reconnect)
        end
        
        if msg:find("!view") and not msg:find(myname) then
            runThread(function()
                sleep(200)
                sendPacket(2, "action|input\n|text|`6[`wnovascript.site`6] `wUptime : " .. getuptime() .. ", BGLs Bought : " .. bglbought)
            end)
        end
        
        local amountStr = msg:match("!tf%s+(%d+)")
        if amountStr and not msg:find(myname) then
            local amount = tonumber(amountStr)
            if amount and amount > 0 then
                runThread(function()
                    local transferPacket = string.format("action|dialog_return\ndialog_name|my_bank_account\nbuttonClicked|tf_true\n\ntf_name|%s\ntf_amount|%d", targetPlayer, amount)
                    sendPacket(2, transferPacket)
                    sleep(500)
                    sendPacket(2, "action|input\n|text|`4[`9Dexterity`4] `9Auto Transfer successful! Sent: `w" .. amount .. " BGL to " .. targetPlayer)
                end)
            end
        end
    end
end, "onvariant")

addHook(function(type, pkt)
    if type == 2 and pkt:find("action|input") then
        if pkt:find("/view") then
            showoverview()
            return true
        end
        if pkt:find("!view") then
            sendVariant({v1 = "OnConsoleMessage", v2 = "`6[`wnovascript.site`6] `wUptime : " .. getuptime() .. ", BGLs Bought : " .. bglbought})
            return true
        end
        return handlecommands(pkt)
    end
end, "onsendpacket")

sendPacket(2, "action|dialog_return\ndialog_name|personalize_profile\nbuttonClicked|save\n\ncheckbox_1hit|0")

local me = getLocal()
local displayname = me and me.name or "player"
local opening_dialog = "add_label_with_icon|big|`2ptht elite global |left|" .. harvestid .. "|\nadd_label_with_icon|small|`0if you buying this script. youre an idiot. this is a free script.|left|9474|\nadd_label_with_icon|small|`01 hit is turned `4off.|left|9474|\nadd_spacer|small|\nadd_textbox|`0credit|\nadd_textbox|`2[-] `9creator `0: `4@dexterity / `c@novascatia `0on discord|\nadd_textbox|`0hello `2" .. displayname .. " `0you're using free version...|left|\nadd_spacer|small|\nadd_textbox|`9script settings:|left|\nadd_label_with_icon|small|`0delay pt:`2" .. delaypt .. "|left|1432|\nadd_label_with_icon|small|`0delay ht:`2" .. delayht .. "|left|1482|\nend_dialog|itro|close|olrait!|"
sendVariant({v1 = "OnDialogRequest", v2 = opening_dialog})
sendVariant({v1 = "OnConsoleMessage", v2 = "`2[INFO] `wskrip berjalan dalam mode idle. ketik -bfg atau -ptht untuk langsung memulai mode."})

runThread(function()
    while true do
        if is_running and not isinwrongworld() then
            local inv = getInventory()
            local bgl_count = 0
            if inv then
                for _, item in pairs(inv) do
                    if item.id == 7188 then
                        bgl_count = item.amount
                        break
                    end
                end
            end
            
            if bgl_count > 0 and not depositingbgl then
                depositingbgl = true
                sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|-1|\nbuttonClicked|my_bank\n")
                sleep(3000)
                if depositingbgl then
                    sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|-1|\nbuttonClicked|my_bank\n")
                    sleep(3000)
                end
                sleep(2000)
                depositingbgl = false
            else
                local gems = getGems()
                if gems and gems >= 100000000 then
                    sendPacket(2, "action|buy\nitem|7188\n")
                    sleep(2000)
                end
            end
        end
        sleep(2000)
    end
end)

runThread(function()
    while true do
        if is_running and botmode == "bfg" and not isinwrongworld() then
            if os.time() - lastconsumetime >= (loop_delay / 1000) then
                consume_all()
            end
        end
        sleep(10000)
    end
end)

runThread(function()
    while true do
        if isinwrongworld() then
            reconnect()
        else
            if is_running then
                if botmode == "bfg" then
                    if os.time() - lastdelaytime >= delayrepeat / 1000 then
                        sleep(1000)
                        lastdelaytime = os.time()
                    end
                elseif botmode == "ptht" then
                    checkpause()
                    if ptht == "pt" then
                        if gettree() > 0 then
                            plant()
                        end
                        checkpause()
                        if is_running and not isinwrongworld() and useuws and gettree() == 0 then uws() end
                    elseif ptht == "ht" then
                        if getready() > 0 then
                            harvest()
                        end
                    elseif ptht == "ptht" then
                        if getready() > 0 then
                            harvest()
                        elseif gettree() > 0 then
                            plant()
                        end
                        if not is_running or isinwrongworld() then goto continue end
                        checkpause()
                        if useuws and getready() == 0 and gettree() == 0 then 
                            uws() 
                        end
                    end
                end
            else
                sleep(500)
            end
        end
        ::continue::
        sleep(100)
    end
end)
