-- Discord Logger for Minetest (Debug Version)
-- Author: Jole
-- Features: Config-based webhook, join/leave/place/break/command/start/shutdown logs, debug logging

local http = minetest.request_http_api()
if not http then
    minetest.log("error", "[discord_logger] HTTP API not available. Add this mod to 'secure.trusted_mods' in minetest.conf.")
    return
end

-- ======= Load Webhook from Config =======
local webhook_url = minetest.settings:get("discord_relay") -- using your existing setting

if not webhook_url or webhook_url == "" then
    minetest.log("error", "[discord_logger] Missing 'discord_relay' in minetest.conf!")
else
    minetest.log("action", "[discord_logger] Webhook loaded from config: " .. webhook_url)
end

-- ======= Helper Function: Send Message to Discord =======
local function send_to_discord(message)
    minetest.log("action", "[discord_logger] Attempting to send: " .. message)

    if not webhook_url or webhook_url == "" then
        minetest.log("warning", "[discord_logger] No webhook configured, skipping message.")
        return
    end

    http:fetch({
        url = webhook_url,
        method = "POST",
        data = minetest.write_json({ content = message }),
        extra_headers = { "Content-Type: application/json" },
        timeout = 5,
    }, function(res)
        if res.succeeded then
            minetest.log("action", "[discord_logger] Message sent successfully!")
        else
            minetest.log("error", "[discord_logger] Failed to send message. HTTP code: " .. tostring(res.code or "unknown") .. ", error: " .. tostring(res.error or "none"))
        end
    end)
end

-- ======= Server Start / Shutdown =======
minetest.register_on_mods_loaded(function()
    send_to_discord(":green_circle: **Server Started**")
end)

minetest.register_on_shutdown(function()
    send_to_discord(":red_circle: **Server Shutting Down**")
end)

-- ======= Player Join / Leave =======
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    send_to_discord(":arrow_right: **" .. name .. "** joined the game.")
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    local reason = timed_out and " (timed out)" or " (left)"
    send_to_discord(":arrow_left: **" .. name .. "** left the game" .. reason .. ".")
end)

-- ======= Command Execution =======
minetest.register_on_chatcommand(function(name, command, params)
    if not name or name == "" then return end
    send_to_discord(":keyboard: **" .. name .. "** executed `/" .. command .. " " .. (params or "") .. "`")
end)

-- ======= Block Placement =======
minetest.register_on_placenode(function(pos, newnode, placer)
    if not placer then return end
    local name = placer:get_player_name()
    local nodename = newnode.name or "unknown"
    local position = minetest.pos_to_string(pos)
    send_to_discord(":bricks: **" .. name .. "** placed `" .. nodename .. "` at " .. position)
end)

-- ======= Block Digging =======
minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger then return end
    local name = digger:get_player_name()
    local nodename = oldnode.name or "unknown"
    local position = minetest.pos_to_string(pos)
    send_to_discord(":pick: **" .. name .. "** broke `" .. nodename .. "` at " .. position)
end)
