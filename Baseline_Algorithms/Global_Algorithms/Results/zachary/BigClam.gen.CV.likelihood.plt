#
# hold-out likelihood (Sun May 26 19:52:18 2019)
#

set title "hold-out likelihood"
set key bottom right
set autoscale
set grid
set xlabel "communities"
set ylabel "likelihood"
set tics scale 2
set terminal png font arial 10 size 1000,800
set output '../Results/zachary/BigClam.gen.CV.likelihood.png'
plot 	"../Results/zachary/BigClam.gen.CV.likelihood.tab" using 1:2 title "" with linespoints pt 6
