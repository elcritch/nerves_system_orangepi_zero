defmodule NervesSystemRpi3.Mixfile do
  use Mix.Project

  @app :nerves_system_orangepi_zero
  @version Path.join(__DIR__, "VERSION")
    |> File.read!
    |> String.trim

  def project do
    [app: @app,
     version: @version,
     elixir: "~> 1.6",
     compilers: Mix.compilers ++ [:nerves_package],
     nerves_package: nerves_package(),
     description: description(),
     package: package(),
     deps: deps(),
     # aliases: ["deps.precompile": ["nerves.env", "deps.precompile"]]
     aliases: [loadconfig: [&bootstrap/1], docs: ["docs", &copy_images/1]],
     docs: [extras: ["README.md"], main: "readme"],
    ]
  end

  def application do
   []
  end

  defp bootstrap(args) do
    System.put_env("MIX_TARGET", "orangepiz")
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :system,
      artifact_sites: [
        {:github_releases, "elcritch/#{@app}"}
      ],
      platform: Nerves.System.BR,
      platform_config: [
        defconfig: "nerves_defconfig"
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves, "~> 1.5.4 or ~> 1.6.0 or ~> 1.7.4", runtime: false},
      {:nerves_system_br, "1.16.1", runtime: false},
      {:nerves_toolchain_armv7_nerves_linux_gnueabihf, "~> 1.4.3", runtime: false},
      {:nerves_system_linter, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false}
    ]
  end

  defp description do
   """
   Nerves System - Orange Pi Zero
   """
  end

  defp package_files() do
    [
      "fwup_include",
      "rootfs-additions",
      "LICENSE",
      "mix.exs",
      "nerves_defconfig",
      "nerves.exs",
      "README.md",
      "VERSION",
      "fwup.conf",
      "fwup-revert.conf",
      "post-createfs.sh",
      "uboot-script.cmd",
      "linux",
    ]
  end

  defp package do
    [ maintainers: [ "Jaremy Creechley <creechley@gmail.com>" ],
     files: package_files(),
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/elcritch/#{@app}"}]
  end

  # Copy the images referenced by docs, since ex_doc doesn't do this.
  defp copy_images(_) do
    File.cp_r("assets", "doc/assets")
  end

end
