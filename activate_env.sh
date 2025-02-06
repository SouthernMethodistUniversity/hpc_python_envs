#!/bin/bash

ENV_PATH=$2
ENV_ACTIVATE=${ENV_PATH}/bin/activate
if [ -f $ENV_ACTIVATE ]; then
   mamba activate $1
   . ${ENV_ACTIVATE}
else
   mamba activate $1
   ${1}/bin/python -m venv --system-site-packages --symlinks ${ENV_PATH}
   . ${ENV_ACTIVATE}
fi
