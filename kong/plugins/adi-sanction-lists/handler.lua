local http = require "resty.http" -- For making HTTP requests
local cjson = require "cjson"

local ADISanctionLists = {
    PRIORITY = 1000, -- Execution priority
    VERSION = "1.0.4",
}

local function call_external_api(request_body, conf)
    kong.log.debug("Going to call REST API: ".. conf.validation_url .. " with ", request_body)

    -- Make an HTTP request to the external REST API
    local httpc = http.new()
    -- Set the timeout for the REST API call (in milliseconds)
    local timeout = conf.api_timeout

    local res, err = httpc:request_uri(conf.validation_url, {
        method = "POST",
        body = request_body,
        headers = {
            ["Content-Type"] = kong.request.get_header("Content-Type") or "application/json",
            ["X-API-Key"] = conf.api_key -- Include the API key from the plugin configuration
        },
        
        -- query = { clientId = client_id }, -- Pass the client-id as a query parameter
        ssl_verify = false, -- Set to true if SSL certificate verification is required
        timeout = timeout  -- Apply the timeout to the request
    })

    if not res then
        -- Return an error if the REST API call fails
        kong.log.err("Failed to call REST API: ".. conf.validation_url .. " ", err)
        -- return kong.response.exit(500, { message = "Internal Server Error" })
        return nil, err
    end

    if res.status ~= 200 then
        -- Handle non-200 responses from the REST API
        kong.log.err("REST API ".. conf.validation_url .. " responded with status: ", res.status)
        -- return kong.response.exit(500, { message = "Error communicating with validation service" })
        return nil, "Http response " .. res.status
    end

    -- Parse the response body    
    local api_response = cjson.decode(res.body)

    kong.log.debug("Got response from REST API: ".. conf.validation_url .. " ", res.body)
    return api_response, nil
end

local function call_adi_sl_api(name, doc, conf)
    kong.log.debug("Going to call REST API: ".. conf.validation_url .. " with ", name, doc)

    -- Make an HTTP request to the external REST API
    local httpc = http.new()
    -- Set the timeout for the REST API call (in milliseconds)
    local timeout = conf.api_timeout

    -- Build query string
    local query_params = {
        name = name,
        id = doc
    }    
    local query_string = ngx.encode_args(query_params)


    local api_url = conf.validation_url .. "?" .. query_string

    local res, err = httpc:request_uri(api_url, {
        method = "GET",        
        headers = {
            ["Content-Type"] = kong.request.get_header("Content-Type") or "application/json",
            ["X-API-Key"] = conf.api_key -- Include the API key from the plugin configuration
        },
        
        -- query = { clientId = client_id }, -- Pass the client-id as a query parameter
        ssl_verify = false, -- Set to true if SSL certificate verification is required
        timeout = timeout  -- Apply the timeout to the request
    })

    if not res then
        -- Return an error if the REST API call fails
        kong.log.err("Failed to call REST API: ".. conf.validation_url .. " ", err)
        -- return kong.response.exit(500, { message = "Internal Server Error" })
        return nil, err
    end

    if res.status ~= 200 then
        -- Handle non-200 responses from the REST API
        kong.log.err("REST API ".. conf.validation_url .. " responded with status: ", res.status)
        -- return kong.response.exit(500, { message = "Error communicating with validation service" })
        return nil, "Http response " .. res.status
    end

    -- Parse the response body    
    local api_response = cjson.decode(res.body)

    kong.log.debug("Got response from REST API: ".. conf.validation_url .. " ", res.body)
    return api_response, nil
end

function ADISanctionLists:access(conf)
    
    -- first check if the request shall be verified agains sanction lists
    local HEADER_1 = "X-Adi-Full-Name"
    local HEADER_2 = "X-Adi-Id"

    -- load customer/prospect information for list check
    local full_name = kong.request.get_header(HEADER_1)
    local entity_id = kong.request.get_header(HEADER_2)

    if not full_name then
        kong.log.debug("ADI headers (".. HEADER_1 .. ", ".. HEADER_2 ..") not provided. Will not check against sanction lists");
        return
    end

    if not entity_id then
        kong.log.debug("ADI headers (".. HEADER_1 .. ", ".. HEADER_2 ..") not provided. Will not check against sanction lists");
        return
    end

    kong.log.debug("ADI headers (".. HEADER_1 .. ", ".. HEADER_2 ..") with values: " .. full_name .. " " .. entity_id .. " ");

    -- kong.log.debug("Going to call REST API: ".. conf.validation_url .. " with ", body)

    -- local adi_request = [[
    -- {
    --     "v": "1",
    --     "c": "A_SL",
    --     "i": false,
    --     "t": ]].. os.time() * 1000 ..[[,    
    --     "p":{
    --         "name": "]].. full_name ..[[",
    --         "documentNo": "]].. entity_id ..[["
    --     },
    --     "u":{
    --         "id": {}
    --     }        
    -- }    
    -- ]]
        

    -- local api_response, err = call_external_api(adi_request, conf)
    local api_response, err = call_adi_sl_api(full_name, entity_id, conf)
    

    if err then
        -- when there was problem connecting to ADI just send request to upstream
        return
    end

    if api_response.count and api_response.count > 0 then
        kong.service.request.set_header("X-Adi-Sanctions", cjson.encode(api_response))
        kong.log.debug("Sanction lists negative, adding X-Adi-Sanctions with " .. cjson.encode(api_response))
        -- -- Return the JSON from the REST API response
        -- kong.response.exit(403, api_response)
    end
    kong.log.debug("Finished, sending to upstream")    
    return    
end

return ADISanctionLists
