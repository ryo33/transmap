# Transmap

Transforms a map.

## Installation

```elixir
def deps do
[{:transmap, "~> 0.1.0"}]
end
```

## Examples

```elixir
# Basic transformation:

map = %{a: 1, b: 2, c: 3}
rule = %{a: true}
Transmap.transform(map, rule)
== %{a: 1}

map = %{a: %{b: 1, c: 2}, d: %{e: 3, f: 4}}
rule = %{a: %{c: true}, d: true}
Transmap.transform(map, rule)
== %{a: %{c: 2}, d: %{e: 3, f: 4}}

# Transfomation with _default:

map = %{a: 1, b: 2, c: %{d: 3, e: 4}}
rule = %{_default: true, b: false, c: %{_default: true}}
Transmap.transform(map, rule)
== %{a: 1, c: %{d: 3, e: 4}}

# Transformation with _spread:

map = %{a: %{b: 1, c: 2}, d: %{e: %{f: 3, g: 4}, h: 5}}
rule = %{_spread: [[:a], [:d, :e]], a: true, d: %{e: %{f: true}}}
Transmap.transform(map, rule)
== %{b: 1, c: 2, f: 3}

# Transformation with renaming:

map = %{a: 1, b: 2, c: %{d: 3, e: 4}, f: %{g: 5}}
rule = %{_spread: [[:f]], a: {"A", true}, b: "B", c: {:C, %{d: 6}}, f: %{g: "G"}}
Transmap.transform(map, rule)
== %{"A" => 1, "B" => 2, :C => %{6 => 3}, "G" => 5}
```

## Rules

`rule_map` is a map has elements `key => rule`.  
```elixir
case {key, rule} do
  {:_default, rule} -> # Change the default rule for the map from false to the given rule
  {:_spread, targets} -> # Pop the maps for specific keys and merge it into the result map
  {key, true} -> # Put the value for a specific key to the result map.
  {key, false} -> # Don't put the value for a specific key to the result map.
  {key, rule} when is_map(rule) -> # Transform the value for a specific key with this rule
  {key, {new_key, rule}} -> # Rename the key to new_key
  {key, new_key} -> # Shorthand for {new_key, true}
end
```

## Using with

This works well with [olafura/json_diff_ex](https://github.com/olafura/json_diff_ex) and [benjamine/jsondiffpatch](https://github.com/benjamine/jsondiffpatch).

## License

MIT
