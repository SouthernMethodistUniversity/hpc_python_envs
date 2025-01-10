#!/bin/bash

ENV_PATH=$2
ENV_ACTIVATE=${ENV_PATH}/bin/activate
if [ -f $ENV_ACTIVATE ]; then
   . ${ENV_ACTIVATE}
else
   mambe activate $1
   python -m venv --system-site-packages --symlinks ${ENV_PATH}
   mamba deactivate
   . ${ENV_ACTIVATE}
fi
