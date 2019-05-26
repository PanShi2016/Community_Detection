These footballTSE files are derived from the file football.gml compiled by M.
Girvan and M. Newman (GN). The GN file contains the network of American
football games between Division IA colleges during regular season Fall 2000.
The GN file has an edge for every game played between two teams while the
node values indicate the conferences to which they belong. The original file
asks that if you make use of these data, that you please cite M. Girvan and
M. E. J. Newman, Community structure in social and biological networks, Proc.
Natl. Acad. Sci. USA 99, 7821-7826 (2002).

However, there are two issues with the original GN file.
These have been dealt with in the files footballTSE*
provided in this archive. If you use these corrected file then please cite
  T.S. Evans, "Clique Graphs and Overlapping Communities", J.Stat.Mech. (2010) P12037
  [arXiv:1009.0638]
in addition to the GN publication.


First three teams met twice in one season. In each case the
teams met in the regular season and then were again paired in
their conference final. The original football.gml therefore had
three repeated pairs:

lines 2387 and 2412, teams 3 (Kansas State) and 84 (Oklahoma)

lines 2992 and 3027, teams 99 (Marshall) and 14 (Western Michigan)

lines 942 and 952, teams 27 (Florida) and 17 (Auburn)

These multiple links have been eliminated so that the footballTSE* files
define a simple graph.


Secondly, the assignments to conferences, the node values, seem to be for the
2001 season and not the 2000 season. The games do appear to be for the 2000
season as stated. In particular the Big West conference existed for football
till 2000 while the Sun Belt conference was only started in 2001. This leads
to the following corrections:-

N.Texas (v11) is in conf 5 Big West (not Sun Belt, GN conference 10)

Arkansas State (v24) is in conf 5 Big West (not Sun Belt GN conference 10)

Boise State (v28) is in conf 5 Big West (not Western Athletic
GN conference 11)

Idaho (v50) is in conf 5 Big West (not Sun Belt, GN conference
10)

Louisiana Tech (v58) is in conf 16, an Independent (not Western Athletic GN
conference 11)

Louisiana Monroe (v59) is in conf 17, an Independent (not Sun Belt GN
conference 10)

Middle Tennessee State (v63) is in conf 15, an Independent (not Sun Belt GN
conference 10)

New Mexico State (v69) is in conf 5 Big West (not Sun Belt, GN conference 10)

Utah State (v90) is in conf 5 Big West (not Independents, GN conference 5)

Louisiana Lafayette (v97) is in conf 18, an Independent (not Sun Belt GN
conference 10)

Texas Christian (v110) is in Western Athletic conf 10 (not Conference USA GN
conference 4)


In addition to these changes, some of the conference assignments were changed
(see below). The games have been checked using the results given on the
"College Football Data Warehouse" (www.cfbdatawarehouse.com). Wikipedia
entries for the conferences, for instance Big West, were also useful.

The Conference Assignments in footballTSE* files are as follows (note 1 added
to each for the pajek partition in the .clu file)

  0 = Atlantic Coast
  1 = Big East
  2 = Big Ten
  3 = Big Twelve
  4 = Conference USA
  5 = Big West
  6 = Mid-American
  7 = Mountain West
  8 = Pacific Ten
  9 = Southeastern
 10 = Western Athletic
 11 = NotreDame
 12 = Navy
 13 = Connecticut	
 14 = CentralFlorida
 15 = Middle Tennessee State
 16 = LouisianaTech	
 17 = LouisianaMonroe	
 18 = LouisianaLafayette	

where 11-18 are Independents, i.e. each team is not in any
conference but neither is there any particular link between
these independents. Thus rather than assigning them a single
community label as in the original football.gml of GN, each
independent is assigned a unique community label.


**********************************************

For the record GN Conference Assignments were

  0 = Atlantic Coast
  1 = Big East
  2 = Big Ten
  3 = Big Twelve
  4 = Conference USA
  5 = Independents
  6 = Mid-American
  7 = Mountain West
  8 = Pacific Ten
  9 = Southeastern
 10 = Sun Belt
 11 = Western Athletic
