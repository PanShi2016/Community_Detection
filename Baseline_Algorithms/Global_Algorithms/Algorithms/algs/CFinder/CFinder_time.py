#!/usr/bin/env python
# encoding: utf-8

# link_clustering.py
# Jim Bagrow, Yong-Yeol Ahn
# Last Modified: 2010-02-16


# Copyright 2008,2009,2010 James Bagrow, Yong-Yeol Ahn
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


import sys, os, time, subprocess
from copy import copy
from optparse import OptionParser
#import oscommand ="ver"os.system("C:\Users\vklonghml\Desktop\beauti\example\CFinder\CFinderWinLinux\CFinder_commandline -i graph_single.pairs -o .\my")

if __name__ == '__main__':
    filename = sys.argv[1]
    print filename
    starttime = time.clock()
    #os.system("C:\\Users\\vklonghml\\Desktop\\beauti\\example\\CFinder\\CFinderWinLinux\\CFinder_commandline -i C:\\Users\\vklonghml\\Desktop\\beauti\\example\\CFinder\\CFinderWinLinux\\data\\grad\\graph_single.pairs -o .\\result\\grad -k 4")
	#time saving
    endtime = time.clock()
    h = open( "CFinder_time.txt",'w')
    h.write( str(endtime-starttime) )
    h.write("\n")
    h.close()
