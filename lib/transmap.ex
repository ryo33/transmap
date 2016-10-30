defmodule Transmap do
  @default_key :_default
  @spread_key :_spread

  @doc """
  Transforms the given map.

  `rule_map` is a map has elements `key => rule`.

      case {key, rule} do
        {:_default, rule} -> # Change the default rule for the map from false to the given rule
        {:_spread, targets} -> # Pop the maps for specific keys and merge it into the result map
        {key, true} -> # Put the value for a specific key to the result map.
        {key, false} -> # Don't put the value for a specific key to the result map.
        {key, rule_map} when is_map(rule_map) -> # Transform the map for a specific key with the given rule
        {key, {new_key, rule}} -> # Rename the key to new_key
        {key, new_key} -> # Shorthand for {new_key, true}
      end

  If the `:diff` option is `true`, removes empty maps in the result.

  ## Examples

  Basic transformation:

      iex> map = %{a: 1, b: 2, c: 3}
      iex> rule = %{a: true}
      iex> Transmap.transform(map, rule)
      %{a: 1}

      iex> map = %{a: %{b: 1, c: 2}, d: %{e: 3, f: 4}, g: %{h: 5}}
      iex> rule = %{a: %{c: true}, d: true, g: %{i: true}}
      iex> Transmap.transform(map, rule)
      %{a: %{c: 2}, d: %{e: 3, f: 4}, g: %{}}
      iex> Transmap.transform(map, rule, diff: true)
      %{a: %{c: 2}, d: %{e: 3, f: 4}}

  Transfomation with `_default`:

      iex> map = %{a: 1, b: 2, c: %{d: 3, e: 4}}
      iex> rule = %{_default: true, b: false, c: %{_default: true}}
      iex> Transmap.transform(map, rule)
      %{a: 1, c: %{d: 3, e: 4}}

  Transformation with `_spread`:

      iex> map = %{a: %{b: 1, c: 2}, d: %{e: %{f: 3, g: 4}, h: 5}}
      iex> rule = %{_spread: [[:a], [:d, :e]], a: true, d: %{e: %{f: true}}}
      iex> Transmap.transform(map, rule)
      %{b: 1, c: 2, d: %{}, f: 3}
      iex> Transmap.transform(map, rule, diff: true)
      %{b: 1, c: 2, f: 3}

      iex> map = %{a: %{b: %{c: 1, d: 2}}}
      iex> rule = %{_spread: [[:a, :b]], a: %{b: %{_default: true, c: :C}}}
      iex> Transmap.transform(map, rule)
      %{C: 1, d: 2, a: %{}}
      iex> Transmap.transform(map, rule, diff: true)
      %{C: 1, d: 2}

  Transformation with renaming:

      iex> map = %{a: 1, b: 2, c: %{d: 3, e: 4}, f: %{g: 5}}
      iex> rule = %{_spread: [[:f]], a: {"A", true}, b: "B", c: {:C, %{d: 6}}, f: %{g: "G"}}
      iex> Transmap.transform(map, rule)
      %{"A" => 1, "B" => 2, :C => %{6 => 3}, "G" => 5}
  """
  @spec transform(data :: any, rule :: any) :: any
  def transform(data, rule, opts \\ [])
  def transform(data, _, opts) when not is_map(data), do: data
  def transform(data, true, opts), do: data
  def transform(data, rule, opts) when is_map(data) do
    {default, rule} = Map.pop(rule, @default_key, false)
    {spread, rule} = Map.pop(rule, @spread_key, [])
    {data, rule} = apply_spread(data, rule, spread)
    diff = Keyword.get(opts, :diff, false)

    Enum.reduce(data, %{}, fn {key, value}, result ->
      {key, rule_value} = case Map.get(rule, key, default) do
        boolean when is_boolean(boolean) -> {key, boolean}
        {key, rule_value} -> {key, rule_value}
        rule_value when is_map(rule_value) -> {key, rule_value}
        new_key -> {new_key, true}
      end
      if rule_value != false do
        filtered = transform(value, rule_value, opts)
        case {filtered, diff} do
          {map, true} when is_map(map) and map_size(map) == 0 -> result
          {other, _} -> Map.put(result, key, other)
        end
      else
        result
      end
    end)
  end

  defp apply_spread(data, rule, spread) do
    Enum.reduce(spread, {data, rule}, fn keys, {data, rule} ->
      {data_map, data} = pop_in(data, keys)
      {rule_map, rule} = pop_in(rule, keys)
      if is_map(data_map) do
        data = Map.merge(data, data_map)
        rule = if is_map(rule_map) do
          {default, rule_map} = Map.pop(rule_map, @default_key, false)
          rule_map = Enum.reduce(data_map, rule_map, fn {key, _}, rule_map ->
            Map.put_new(rule_map, key, default)
          end)
          Map.merge(rule, rule_map)
        else
          rule_map = for {key, _} <- data_map, into: %{}, do: {key, true}
          Map.merge(rule, rule_map)
        end
        {data, rule}
      else
        {data, rule}
      end
    end)
  end
end
