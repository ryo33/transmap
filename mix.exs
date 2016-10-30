defmodule Transmap.Mixfile do
  use Mix.Project

  def project do
    [app: :transmap,
     version: "0.4.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, github: "elixir-lang/ex_doc", only: :dev}]
  end

  defp description do
    """
    Transforms a map.
    """
  end

  defp package do
    [name: :transmap,
     files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Ryo Hashiguchi"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/ryo33/transmap"}]
  end
end
