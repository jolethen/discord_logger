-- Discord Logger for Minetest
-- (Modified version with config-based webhook + join/leave/shutdown logs)

local http = minetest.request_http_api()
if not http then
    minetest.log("error", "[discord_logger] HTTP API not available. Enable with secure.trusted_mods.")
    return
end

-- ======= Load Webhook from Config =======
local webhook_url = minetest.settings:get("discord_logger_webhook")

if not webhook_url or webhook_url == "" then
    minetest.log("error", "[discord_logger] Missing 'discord_logger_webhook' in minetest.conf!")
else
    minetest.log("action", "[discord_logger] Webhook loaded from config.")
end

-- ======= Helper: Send Message to Discord =======
local function send_to_discord(message)
    if not webhook_url or webhook_url == "" then
        minetest.log("warning", "[discord_logger] No webhook configured, skipping message: " .. message)
        return
    end

    http:fetch({
        url = webhook_url,
        method = "POST",
        data = minetest.write_json({ content = message }),
        extra_headers = { "Content-Type: application/json" },
    }, function(result)
        if not result.succeeded then
            minetest.log("error", "[discord_logger] Failed to send message: " .. (result.code or "unknown"))
        end
    end)
end

-- ======= Log Server Startup =======
minetest.register_on_mods_loaded(function()
    send_to_discord(":green_circle: **Server Started**")
end)

-- ======= Log Server Shutdown =======
minetest.register_on_shutdown(function()
    send_to_discord(":red_circle: **Server Shutting Down**")
end)

-- ======= Log Player Join =======
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    send_to_discord(":arrow_right: **" .. name .. "** joined the game.")
end)

-- ======= Log Player Leave =======
minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    local reason = timed_out and " (timed out)" or ""
    send_to_discord(":arrow_left: **" .. name .. "** left the game" .. reason .. ".")
end)

-- ======= Log Commands (optional feature) =======
minetest.register_on_chatcommand(function(name, command, params)
    send_to_discord(":keyboard: **" .. name .. "** executed `/" .. command .. " " .. params .. "`")
end)
