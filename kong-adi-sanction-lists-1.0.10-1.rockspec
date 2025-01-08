local plugin_name = "adi-sanction-lists"
local package_name = "kong-" .. plugin_name
local package_version = "1.0.10"
local rockspec_revision = "1"
local execon_page = "https://www.execon.pl/abee-digital-id"

local github_account_name = "ExeconOne"
local github_repo_name = package_name
local git_checkout = package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }


description = {
  summary = "Abee Digital ID Sanction Lists Kong plugin.",
  detailed = [[
    This plugin integrates with Kong to provide functionality for checking
    Abee Digital ID sanction lists (Fraud, AML) as part of the request processing pipeline.
  ]],
  homepage = execon_page,
  license = "Apache 2.0",
  maintainer = "Maciej Grula <maciej.grula@execon.pl>"
}

source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}

dependencies = {
    "kong = 3.7.0",
    "lua-cjson",
}


build = {
  type = "builtin",
  modules = {
    -- TODO: add any additional code files added to the plugin
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
  }
}