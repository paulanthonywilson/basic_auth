defmodule BasicAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :basic_auth,
     description: "Basic Authentication Plug",
     package: package,
     version: "1.2.0-rc",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:plug, "~> 0.14 or ~> 1.0"}]
  end

  defp package do
    [contributors: ["Mark Connell", "Paul Wilson"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/cultivatehq/basic_auth"},
     files: ~w(lib LICENSE.md mix.exs README.md)]
  end
end
