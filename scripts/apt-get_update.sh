#!/usr/bin/env bash
# Runs "sudo apt-get update" twice on Ubuntu.
set -e
export DEBIAN_FRONTEND=noninteractive

echo "First APT update:"
sudo apt-get update

echo "Second APT update:"
sudo apt-get update
