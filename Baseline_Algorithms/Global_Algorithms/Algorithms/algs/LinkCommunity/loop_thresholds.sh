#!/usr/bin/env bash

# loop_thresholds.sh
# Jim Bagrow
# Last Modified: 2009-03-10


# Copyright 2009,2010 James Bagrow
# 
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



# these need to be updated by you:
EXEC=./algs/LinkCommunity/clusterJaccsFile
NET=Graph.pairs
JACC=Graph.jaccs
OUTDIR=clusters
outputpath="./result/grad"

if [ ! -d "$outputpath" ]; then
mkdir "$outputpath"
fi

# $EXEC Graph.pairs Graph.jaccs Graph.clusters Graph.cluster_stats threshold

$EXEC Graph.pairs Graph.jaccs Graph_1.clusters Graph_1.cluster_stats 0.1 LCtime_1.txt
$EXEC Graph.pairs Graph.jaccs Graph_2.clusters Graph_2.cluster_stats 0.2 LCtime_2.txt
$EXEC Graph.pairs Graph.jaccs Graph_3.clusters Graph_3.cluster_stats 0.3 LCtime_3.txt
$EXEC Graph.pairs Graph.jaccs Graph_4.clusters Graph_4.cluster_stats 0.4 LCtime_4.txt
$EXEC Graph.pairs Graph.jaccs Graph_5.clusters Graph_5.cluster_stats 0.5 LCtime_5.txt
$EXEC Graph.pairs Graph.jaccs Graph_6.clusters Graph_6.cluster_stats 0.6 LCtime_6.txt
$EXEC Graph.pairs Graph.jaccs Graph_7.clusters Graph_7.cluster_stats 0.7 LCtime_7.txt
$EXEC Graph.pairs Graph.jaccs Graph_8.clusters Graph_8.cluster_stats 0.8 LCtime_8.txt
$EXEC Graph.pairs Graph.jaccs Graph_9.clusters Graph_9.cluster_stats 0.9 LCtime_9.txt
#$EXEC $NET $JACC $OUTDIR/Graph_1.cluster $OUTDIR/Graph_1.cluster_stats 0.1
 
 mv ./Graph*.* $outputpath

 mv ./LCtime*.txt $outputpath



