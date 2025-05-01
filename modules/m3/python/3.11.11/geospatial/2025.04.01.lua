
help([[
Name: Python Environment geospatial
Version: 3.11.11/2025.04.01
Website: NA

This environment provides tools for geospatial applications

]])
whatis("Name: Python Environment -- geospatial")
whatis("Version: 3.11.11")
whatis("Category: Python")
whatis("Description: This environment provides tools for geospatial applications")
family("Python")

depends_on('miniforge/24.11.2-1')
local home = os.getenv("HOME")
local user_libs = pathJoin(home, '.venv/auto_python_3.11.11_geospatial_2025.04.01')
local conda_init = '/hpc/m3/apps/miniforge/24.11.2-1/etc/profile.d/conda.sh'

source_sh("bash", "/hpc/m3/hpc_python_envs/activate_env.sh /hpc/m3/python/3.11.11/geospatial-2025.04.01 " .. user_libs .. ' ' .. conda_init)

