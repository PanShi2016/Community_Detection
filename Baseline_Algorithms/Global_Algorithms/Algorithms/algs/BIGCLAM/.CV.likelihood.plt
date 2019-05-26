#
# hold-out likelihood (Mon Nov 14 21:53:40 2016)
#

set title "hold-out likelihood"
set key bottom right
set autoscale
set grid
set xlabel "communities"
set ylabel "likelihood"
set tics scale 2
set terminal png font arial 10 size 1000,800
set output '.CV.likelihood.png'
plot 	".CV.likelihood.tab" using 1:2 title "" with linespoints pt 6
