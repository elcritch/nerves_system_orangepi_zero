use Mix.Config

version =
  Path.join(__DIR__, "VERSION")
  |> File.read!
  |> String.strip

pkg = :nerves_system_npn

config pkg, :nerves_env,
  type: :system,
  version: version,
  compiler: :nerves_package,
  artifact_url: [
    # "https://github.com/nerves-project/#{pkg}/releases/download/v#{version}/#{pkg}-v#{version}.tar.gz",
    "http://appenv.brights.tech:5984/build-files/nerves_system_npn-0.1.0/v0-7d5dddaaf560743cf375b362f2714f0c.tar.gz",
  ],
  platform: Nerves.System.BR,
  platform_config: [
    defconfig: "nerves_defconfig",
  ],
  checksum: [
    "linux",
    "rootfs-additions",
    "npn-busybox.config",
    "fwup.conf",
    "nerves_defconfig",
    "nerves.exs",
    "post-createfs.sh",
    "uboot-script.cmd",
    "VERSION"
  ]
