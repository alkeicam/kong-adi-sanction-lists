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
                    default = "https://api-di.abee.cloud:3443/adi-in-proxy/8/v1/list/scan", -- Default URL
                } },
                { api_key = { type = "string", required = true, default = "162rbo9g" } },
                { api_timeout = { type = "integer", default = 1000, required = true } },  -- Timeout in ms
            },
        } },
    },
}


return schema
