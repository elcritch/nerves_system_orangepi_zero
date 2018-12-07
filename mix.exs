defmodule NervesSystemRpi3.Mixfile do
  use Mix.Project

  @app :nerves_system_orangepi_zero
  @version Path.join(__DIR__, "VERSION")
    |> File.read!
    |> String.strip

  def project do
    [app: @app,
     version: @version,
     elixir: "~> 1.6",
     compilers: Mix.compilers ++ [:nerves_package],
     description: description(),
     package: package(),
     deps: deps(),
     # aliases: ["deps.precompile": ["nerves.env", "deps.precompile"]]
     aliases: [loadconfig: [&bootstrap/1], docs: ["docs", &copy_images/1]],
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
     {:nerves, "~> 1.3", runtime: false},
     {:nerves_system_br, "~> 1.6", runtime: false },
     {:nerves_toolchain_arm_unknown_linux_gnueabihf, "~> 1.1", runtime: false}
    ]
  end

  defp description do
   """
   Nerves System - NanoPi Neo
   """
  end

  defp package do
    [maintainers: [ "Jaremy Creechley <creechley@gmail.com>" ],
    files: [
        "rootfs-additions",
        "LICENSE",
        "mix.exs",
        "nerves_defconfig",
        "nerves.exs",
        "README.md",
        "VERSION",
        "fwup.conf",
        "post-createfs.sh",
        "uboot-script.cmd",
        "linux",
        ],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/elcritch/nerves_system_orangepi_zero"}]
  end
end
