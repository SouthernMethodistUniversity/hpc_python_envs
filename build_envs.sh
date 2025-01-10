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
USER=$(whoami)
if [[ "$USER" == "appmgr" ]]
  PREFIX="/hpc/${CLUSTER}/python"
else
  PREFIX="$HOME/env_testing/${CLUSTER}/python"
fi
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
      mamba create -p ${BASE_ENV} -c conda-forge python=${version} -y >> ${output_log} 2>&1

      # create a module file
      mkdir -p modules/${CLUSTER}/python/${version}/
      MODULE_FILE=modules/${CLUSTER}/python/${version}/minimal.lua
      ACTIVATE_SCRIPT="$(pwd)/activate_env.sh"
      VENV_NAME="auto_python_${version}_minimal"
      CONDA_PATH=${BASE_ENV}
      (
sed 's/^ \{2\}//' > "$MODULE_FILE" << EOL

help([[
Name: Python
Version: ${version}
Website: NA

Minimal installation of Python ${version}

]])
whatis("Name: Python Environment -- ${NAME}")
whatis("Version: ${version}")
whatis("Category: Python")
whatis("Description: ${DESCRIPTION}")
family("Python")

always_load('${MINIFORGE_MOD}')
local home = os.getenv("HOME")
local user_libs = pathJoin(home, '.venv/${VENV_NAME}')
source_sh("bash", "${ACTIVATE_SCRIPT} ${CONDA_PATH} " .. user_libs)

EOL
      )
    fi

    # create the requested env
    ENV_PATH="${PREFIX}/${version}/${NAME}-${DATE}"

    LOG_BASE="logs/${CLUSTER}/${version}/${NAME}/${DATE}"
    mkdir -p ${LOG_BASE}

    # create a conda env with the python version and any other request packages
    echo "  creating mamba env"
    mamba_cmd=

    output_log="${LOG_BASE}/mamba.log"
    mamba_cmd="create -p ${ENV_PATH} -c conda-forge ${CHANNELS} python=${version} ${CONDA_PKGS} -y  >> ${output_log} 2>&1"
    echo "  cmd: 'mamba ${mamba_cmd}'"
    mamba create -p ${ENV_PATH} -c conda-forge ${CHANNELS} python=${version} ${CONDA_PKGS} -y  >> ${output_log} 2>&1

    # load env and install pip-tools, then generate a requirements.txt
    mamba activate ${ENV_PATH}
    output_log="${LOG_BASE}/pip-tools.log"
    echo "which pip: $(which pip)"
    pip install pip-tools setuptools build >> ${output_log} 2>&1

    echo "  running pip-compile"
    filename=$(basename -- "$config")
    filename="requirements/${filename%.*}.in"
    outfile="${LOG_BASE}/requirments.txt"
    output_log="${LOG_BASE}/pip_compile.log"
    pip-compile ${EXTRA_URLS} ${filename} --output-file=${outfile} >> ${output_log} 2>&1

    # install the pip packages
    echo "  installing pip packages"
    output_log="${LOG_BASE}/pip_install.log"
    pip install ${EXTRA_URLS} -r ${outfile} >> ${output_log} 2>&1

    # deactivate
    mamba deactivate

    # create a module file
    mkdir -p modules/${CLUSTER}/python/${version}/${NAME}
    MODULE_FILE=modules/${CLUSTER}/python/${version}/$NAME/${DATE}.lua
    ACTIVATE_SCRIPT="$(pwd)/activate_env.sh"
    VENV_NAME="auto_python_${version}_${NAME}_${DATE}"
    CONDA_PATH=${ENV_PATH}
    (
sed 's/^ \{2\}//' > "$MODULE_FILE" << EOL

help([[
Name: Python Environment ${NAME}
Version: ${version}/${DATE}
Website: NA

${DESCRIPTION}

]])
whatis("Name: Python Environment -- ${NAME}")
whatis("Version: ${version}")
whatis("Category: Python")
whatis("Description: ${DESCRIPTION}")
family("Python")

always_load('${MINIFORGE_MOD}')
local home = os.getenv("HOME")
local user_libs = pathJoin(home, '.venv/${VENV_NAME}')
source_sh("bash", "${ACTIVATE_SCRIPT} ${CONDA_PATH} " .. user_libs)

EOL
    )
  done
done

