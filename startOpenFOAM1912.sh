#----------------------------------*-sh-*--------------------------------------
# =========                 |
# \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
#  \\    /   O peration     |
#   \\  /    A nd           |
#    \\/     M anipulation  | Copyright (C) 2016-2019 OpenCFD Ltd.
#------------------------------------------------------------------------------
# License
#     This file is part of OpenFOAM.
#
#     OpenFOAM is free software: you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
#     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#     FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#     for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.
#
# File
#     startOpenFOAM
#
# Description
#      This script will
#          1) Start the OpenFOAM container with name 'of_v1912'
#             in the the shell terminal.
#          2) Post-processing: Users can launch paraview/paraFoam from the
#             terminal to post-process the results
#      Note
#          1) User should run xhost+ from other terminal
#          2) Docker daemon should be running before launching this script
#          3) User can launch the script in a different shell to have
#             create the OpenFOAM environment in a different terminal
#
#------------------------------------------------------------------------------

# xhost +local:of_v1912
# docker start -i of_v1912
# docker exec -it of_v1912 /bin/bash -rcfile /opt/OpenFOAM/setImage_v1912.sh

#Modified by Sourav
xhost +local:of_v1912
docker run -i -t --mount type=bind,source="$(pwd)",target="/home" \
openfoamplus/of_v1912_centos73 /bin/bash -rcfile /opt/OpenFOAM/setImage_v1912.sh

