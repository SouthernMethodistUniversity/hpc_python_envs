#!/bin/bash -e

# load miniforge
module purge
module load miniforge

# get full module name
MINIFORGE_MOD=$(module -t list  2>&1)
echo "Using module: ${MINIFORGE_MOD}"

# get cluster name
CLUSTER=$(scontrol show config | grep ClusterName | grep -oP '= \K.+')

# get current date
DATE=$(date +'%Y.%m.%d')

# install prefix
PREFIX="/hpc/${CLUSTER}/python"

echo "Install prefix: ${PREFIX}"

# loop over the configs
for config in config/*.json; do
  echo "processing config: ${config}"
  PYTHON_VERSIONS=$(python parse_config.py ${config} --versions)
  echo "Python versions: ${PYTHON_VERSIONS}"
done
