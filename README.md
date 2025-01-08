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

## Kong plugins

See more about custom plugin development for Kong at https://docs.konghq.com/gateway/3.9.x/plugin-development/