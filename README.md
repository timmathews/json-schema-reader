# JSON Schema Reader
Currently contains one script, `json_tree.rb` which takes a JSON schema and prints a pretty tree.

Each property is printed in the form `[!]<name>[:type][:units]`.

The optional `!` indicates that the property is required, `type` is the property type, typically `object`, `string` or
`number`, but could be any of the valid JSON Schema types, and if the property has an associated unit it is printed in
the `units` place.

## Usage
```sh
$ ./json_tree.rb <path_to_json>
```

## Example
Taken from part of the [Signal K](http://signalk.org) schema.
```
navigation
├courseOverGroundMagnetic:rad
│ ├value:number
│ ├timestamp:string:ISO-8601 (UTC)
│ ├source:object
│ │ ├!label:string
│ │ ├!type:string
│ │ ├src:string
│ │ ├pgn:number
│ │ ├sentence:string
│ │ └talker:string
│ ├_attr:object
│ │ ├_mode:integer
│ │ ├_owner:string
│ │ └_group:string
│ └meta:object
│   ├displayName:string
│   ├longName:string
│   ├shortName:string
│   ├gaugeType:string
│   ├units:string
│   ├timeout:number
│   ├warnMethod:string
│   ├alarmMethod:string
│   └zones:array
├courseOverGroundTrue:rad
```
