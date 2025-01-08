local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "adi-sanction-lists"

local schema = {
    name = PLUGIN_NAME,
    fields = {
        { config = {
            type = "record",
            fields = {
                { validation_url = typedefs.url {
                    required = true,
                    default = "https://a9f7-91-189-27-101.ngrok-free.app/adi-in-proxy/8/v1/list/scan", -- Default URL
                } },
                { api_key = { type = "string", required = true, default = "wp8bgx4a" } },
                { api_timeout = { type = "integer", default = 1000, required = true } },  -- Timeout in ms
            },
        } },
    },
}


return schema
