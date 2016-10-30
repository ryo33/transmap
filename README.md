# Transmap

Transforms a map with a rule which has the same shape.

## Installation

```elixir
def deps do
  [{:transmap, "~> 0.2.0"}]
end
```

## Examples

```elixir
# Basic transformation:

map = %{a: 1, b: 2, c: 3}
rule = %{a: true}
Transmap.transform(map, rule)
== %{a: 1}

map = %{a: %{b: 1, c: 2}, d: %{e: 3, f: 4}, g: %{h: 5}}
rule = %{a: %{c: true}, d: true, g: %{i: true}}
Transmap.transform(map, rule)
== %{a: %{c: 2}, d: %{e: 3, f: 4}, g: %{}}
Transmap.transform(map, rule, diff: true)
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
== %{b: 1, c: 2, d: %{}, f: 3}
Transmap.transform(map, rule, diff: true)
== %{b: 1, c: 2, f: 3}

map = %{a: %{b: %{c: 1, d: 2}}}
rule = %{_spread: [[:a, :b]], a: %{b: %{_default: true, c: :C}}}
Transmap.transform(map, rule)
== %{C: 1, d: 2, a: %{}}
Transmap.transform(map, rule, diff: true)
== %{C: 1, d: 2}

# Transformation with renaming:

map = %{a: 1, b: 2, c: %{d: 3, e: 4}, f: %{g: 5}}
rule = %{_spread: [[:f]], a: {"A", true}, b: "B", c: {:C, %{d: 6}}, f: %{g: "G"}}
Transmap.transform(map, rule)
== %{"A" => 1, "B" => 2, :C => %{6 => 3}, "G" => 5}

map = %{a: 1, b: %{a: 2}, c: %{a: 3}}
rule = %{_spread: [[:b], [:c]], a: true, b: %{a: :b}, c: %{a: {:c, true}}}
Transmap.transform(map, rule)
== %{a: 1, b: 2, c: 3}
```

## API

[hexdocs.pm/transmap/Transmap.html](https://hexdocs.pm/transmap/Transmap.html)

## Using with

This works well with [olafura/json_diff_ex](https://github.com/olafura/json_diff_ex) and [benjamine/jsondiffpatch](https://github.com/benjamine/jsondiffpatch).

## License

MIT
