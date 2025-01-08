# Abee Digital Id Sanction List Kong Plugin

This is a plugin for Kong Gateway that allows to screen each request if person or organization belongs to sanction lists.

## When plugin triggers
Plugin triggers when incoming request has following headers added/set up:
* `X-Adi-Full-Name` - here should be a full name of person or organization provided, i.e. "John Doe"
* `X-Adi-Id` - here should be a document number (passport or personal id) or id of the person (like PESEL or Social Security number) or organization (like KRS number, REGON number)

When these headers are found in the request the plugin will ask ABEE DI platform to check if person/organization with such data is registered on any sort of sanction or pep lists.

When person or organization is marked as sanctioned, the request will be forwarded to upstream service with additional header added:
* `X-Adi-Sanctions` - the header will contain serialized JSON object with list of sanction items that matched provided person or organization

so as a result upstream service can react accordingly to provided sanctions information

## Installation

To use plugin following steps must be completed:
* plugin installation and enablement on each Kong node
* enable plugin on services that should be protected

### Install plugin on Kong nodes
Install the Abee DI Sanction List Kong plugin on each node in your Kong cluster via luarocks. As this plugin source is already hosted in Luarocks.org, please run the below command:
```shell
luarocks install kong-adi-sanction-lists
```

### Enable plugin on Kong nodes
Add to the custom_plugins list in your Kong configuration (on each Kong node):
```
 Path - /etc/kong/kong.conf
 custom_plugins = adi-sanction-lists
```

## Protect your api services call with sanction lists

### Protect services
Enable the plugin on each service that shall be protected against sanction lists
```
 curl -X POST http://localhost:8001/services/mysrv/plugins --data 'config.validation_url=https://api-di.abee.cloud:3443/adi-in-proxy/8/v1/list/scan' --data 'config.api_key=<your api key>' --data 'name=adi-sanction-lists'
```

From this moment on each request that calls the service and contains `X-Adi-Full-Name` and `X-Adi-Id` will be screened agains sanction lists


## Troubleshooting

See more about custom plugin development for Kong at https://docs.konghq.com/gateway/3.9.x/plugin-development/