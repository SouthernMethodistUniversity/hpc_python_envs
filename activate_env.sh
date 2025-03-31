#!/bin/bash

CONDA_INIT=$3
ENV_PATH=$2
ENV_ACTIVATE=${ENV_PATH}/bin/activate

# load conda env
source ${CONDA_INIT}
conda activate ${1}

if [ -f $ENV_ACTIVATE ]; then
   . ${ENV_ACTIVATE}
else
   ${1}/bin/python -m venv --system-site-packages --symlinks ${ENV_PATH}
   . ${ENV_ACTIVATE}
fi
