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
#PREFIX="/hpc/${CLUSTER}/python"
PREFIX="$HOME/env_testing/${CLUSTER}/python"

echo "Install prefix: ${PREFIX}"

# loop over the configs
for config in config/*.json; do
  echo "processing config: ${config}"
  PYTHON_VERSIONS=$(python parse_config.py ${config} --versions)
  NAME=$(python parse_config.py ${config} --name)
  DESCRIPTION=$(python parse_config.py ${config} --description)
  EXTRA_URLS=$(python parse_config.py ${config} --urls)
  CONDA_PKGS=$(python parse_config.py ${config} --conda)
  CHANNELS=$(python parse_config.py ${config} --channels)
  MODULES=$(python parse_config.py ${config} --modules)
  # loop over python versions
  for version in ${PYTHON_VERSIONS//,/ }; do
    echo "PYTHON VERSION: ${version}"

    mkdir -p "logs/${CLUSTER}/${version}/${DATE}"

    # ensure we have a trivial installation requested python version
    BASE_ENV="${PREFIX}/${version}/minimal"
    echo "  Base environment: $BASE_ENV"
    if [ ! -d "$BASE_ENV" ]; then
      echo "  ${BASE_ENV} does not exist, creating one"
      output_log="logs/${CLUSTER}/${version}/${DATE}/mamba_minimal.log"
      mamba create -p ${BASE_ENV} python=${version} -y >> ${output_log} 2>&1
    fi

    # create the requested env
    ENV_PATH="${PREFIX}/${version}/${NAME}-${DATE}"

    # create a conda env with the python version and any other request packages
    echo "  creating mamba env"
    echo "  cmd: 'mamba create -p ${ENV_PATH} ${CHANNELS} python=${version} ${CONDA_PKGS} -y  >> ${output_log} 2>&1'"

    output_log="logs/${CLUSTER}/${version}/${DATE}/mamba_${NAME}.log"
    mamba create -p ${ENV_PATH} ${CHANNELS} python=${version} ${CONDA_PKGS} -y  >> ${output_log} 2>&1

    # load env and install pip-tools, then generate a requirements.txt
    mamba activate ${ENV_PATH}
    pip install pip-tools

    echo "  running pip-compile"
    filename=$(basename -- "$config")
    filename="requirements/${filename%.*}.in"
    outfile="logs/${CLUSTER}/${version}/${DATE}/requirments_${NAME}.txt"
    output_log="logs/${CLUSTER}/${version}/${DATE}/pip_compile_${NAME}.log"
    pip-compile ${EXTRA_URLS} ${filename} --output-file=${outfile} >> ${output_log} 2>&1

    # install the pip packages
    echo "  installing pip packages"
    output_log="logs/${CLUSTER}/${version}/${DATE}/pip_install_${NAME}.log"
    pip install ${EXTRA_URLS} -r ${outfile} >> ${output_log} 2>&1
  done
done

