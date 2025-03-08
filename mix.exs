defmodule MplBubblegum.MixProject do
  use Mix.Project

  def project do
    [
      app: :mpl_bubblegum_nifs,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/ved08/mpl-bubblegum-elixir-nifs",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.36.1"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "mpl_bubblegum_nifs",
      maintainers: ["Ved"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ved08/mpl-bubblegum-elixir-nifs",
        "Docs" => "https://github.com/ved08/mpl-bubblegum-elixir-nifs/blob/main/README.md"
      },
      description:
        "MplBubblegum is an Elixir library for working with Compressed NFTs (cNFTs) on Solana via the Bubblegum program. It allows developers to create Merkle Trees, mint cNFTs, and transfer assets."
    ]
  end
end
