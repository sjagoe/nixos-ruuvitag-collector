======================================
 NixOS based ruuvitag data collection
======================================

This is an example configuration for setting up data collection and
display for ruuvitags.

Hardware
========

1. Ruuvitags (https://ruuvi.com/)
2. Raspberry pi 4, 2GB (https://www.raspberrypi.org/products/raspberry-pi-4-model-b/)

Software
========

1. NixOS (https://nixos.org)

   a. Raspberry Pi images built using https://github.com/Robertof/nixos-docker-sd-image-builder

2. ``btuart`` based on https://gist.github.com/whitelynx/9f9bd4cb266b3924c64dfdff14bce2e8
3. ``ruuvitag-listener`` (https://github.com/lautis/ruuvitag-listener)
4. ``telegraf`` (https://docs.influxdata.com/telegraf/v1.17/)
5. ``influxdb 1.8`` (https://docs.influxdata.com/influxdb/v1.8/)
6. ``grafana`` (https://grafana.com/)
7. [todo] ``kapacitor`` (https://docs.influxdata.com/kapacitor/v1.5/)


License
=======

The original contents of this repository are provided under the
3-clause BSD license.  Components that are adapted from other sources
are provided under their own original licenses.


Using this repository
=====================

This is not the canonical repository from which I deploy my own
infrastructure, but rather a public copy of some of that
configuration.  As such, it is not guaranteed to work out of the box.

Layout
------

The ``pkgs`` directory contains nix packages used by this configuration. One for ``ruuvitag-listener``, and one packaging the ``btuart`` script and associated udev rules.

The ``machines`` directory contains all NixOS system configuration.  Common modules are directly in the ``machines`` directory, while machine-specific configuration is contained in a subdirectory named by the host.

Using
-----

1. Fork and edit the configuration as needed (hostnames, domains, etc).
2. Build a basic/barebones NixOs system
3. Clone it to ``~youruser/nix-config``
4. Symlink ``~youruser/nix-config/machines/<hostname>/configuration.nix`` to ``/etc/nixos/configuration.nix``
5. Run ``sudo nixos-rebuild switch`` to activate the new configuration.

Future direction
================

Turn this into a set of generic reusable modules that could be imported easily into any configuration.
