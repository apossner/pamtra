# PAMTRA package - Passive and Active Microwave TRANsfer 

[![Documentation Status](https://readthedocs.org/projects/pamtra/badge/?version=latest)](https://pamtra.readthedocs.io/en/latest/?badge=latest)


Python 2.7/Fortran 90 package to solve the passive and active microwave radiative transfer in a plan parallel horizontally homogeneous atmosphere with hydrometeors

## Manual and Installation

See https://pamtra.readthedocs.io/ for documentation.

## Mailing list

If you want to join the mailing list you can find it here https://lists.uni-koeln.de/mailman/listinfo/meteo-pamtra. There you can ask any question related to the usage of PAMTRA.

# Comment Anna Possner:
for compilation on mistral load following modules
>module unload netcdf
>module load python/2.7.12
>module load intel/17.0.6

if there is an error with pamtra/tools/py_usStandard => check for folder inside folder (e.g. pamtra/tools/py_usStandard/py_usStandard)

Note that Python version is important. Newer version does not seem to have all packages needed by Pamtra


