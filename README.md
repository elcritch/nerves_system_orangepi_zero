# Orange Pi Zero Black

[![Build Status](https://travis-ci.org/BrightAgrotech/nerves_system_orangepi_zero.png?branch=master)](https://travis-ci.org/BrightAgrotech/nerves_system_orangepi_zero)

This is the base Nerves System configuration for the [Orange P Zero](http://www.orangepi.org/orangepizero/).

![Orange Pi Zero Black image](assets/images/orangepizero_info.jpg)
<br><sup>[Image credit](#orangepi)</sup>

| Feature        | Description                                                               |
|:---------------|:--------------------------------------------------------------------------|
| CPU            | H2 Quad-core Cortex-A7 H.265/HEVC 1080P.                                  |
| GPU            | Mali400MP2 GPU @600MHz (OpenGL ES 2.0)                                    |
| Memory         | 256MB/512MB DDR3 SDRAM(Share with GPU)(256MB version is Standard version) |
| Storage        | TF card (Max. 64GB)                                                       |
| Linux kernel   | 4.10 w/ sun8i emac patches                                                |
| IEx terminal   | ttyS0 via the FTDI connector                                              |
| GPIO, I2C, SPI | Yes - Elixir ALE                                                          |
| ADC            | Yes                                                                       |
| PWM            | WIP - Yes, but no Elixir support                                          |
| UART           | ttyS0 + more via device tree overlay                                      |
| Camera         | None                                                                      |
| Ethernet       | Yes                                                                       |
| WiFi           | WIP - Linux mainline driver support is poor for the XR819 chipset         |


## Preparing your Orange Pi Zero

The Orange Pi Zero does not have built in eMMC memory. Booting simply requires writing a Nerves firmware image to an SD card and inserting it.

## Console access

The console is configured to output to `ttyS0` by default. This is the
UART output accessible by the 4 pin header (labeled "Debug Serial Port" above). A 3.3V FTDI
cable is needed to access the output.

The Orange Pi Zero does not support HDMI output.

## Linux / Driver Support

### Device tree overlays

Both the SPI and I2C devices have been enabled in the default in-kernel DTS via a kernel patch. Supporting runtime configuration of I2C/SPI is less straightforward than RPi's which have many tools available for apply DTS fragments. If you need to enable or disable these ports, please feel free to submit a pull request with the appropriate tooling support. Future work may involve porting over the `configfs` patches from the Armbian project for this purpose.

### Supported USB WiFi devices

The kernel driver for the XRadio chip has _not_ been included due to instability issues. It is possible to port it to recent 4.x kernels, but the implementation quality is low. Until the driver improves or mainline linux driver is added, this repo isn't likely to support wifi.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add nerves_system_orangepi_zero to your list of dependencies in `mix.exs`:

        def deps do
          [{:nerves_system_orangepi_zero, "~> 0.2.4"}]
        end

  2. Ensure nerves_system_orangepi_zero is started before your application:

        def application do
          [applications: [:nerves_system_orangepi_zero]]
        end


[Image credit](#orangepi): This image is from the [Orange Pi Website](http://www.orangepi.org/).
