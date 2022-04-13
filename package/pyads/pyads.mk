################################################################################
#
## pyads
#
#################################################################################

PYADS_VERSION = 256e06a33f7ed76cc596b36f0ad00615a42c885d
PYADS_SITE = https://github.com/chwiede/pyads.git
PYADS_SITE_METHOD = git
PYADS_SETUP_TYPE = distutils
PYADS_LICENSE = MIT
PYADS_LICENSE_FILES = LICENSE
#PYTHON_PYADS_DEPENDENCIES = host-python-cython

$(eval $(python-package))
