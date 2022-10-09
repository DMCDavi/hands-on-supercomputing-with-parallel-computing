#****************************************************************************80
#  Code:
#   plot.gp
#
#  Purpose:
#    Script GNUPLOT  - Multiple Charts 
#
#  Modified:
#   Sept 12 2012 10:47
#
#  Author:
#    Murilo Do Carmo Boratto [muriloboratto@uneb.br]
#
#  Execute:
#     gnuplot "<name of script>"
#
#  Example:
#     gnuplot "plot.gp"
# 
#****************************************************************************80*/
 

set title "Experimental Time Tetraprocessor Cluster Quadcluster (Threads=8 and Size Block=1024)" 

set ylabel "Time(seconds)"
set xlabel "Size"

set style line 1 lt 2 lc rgb "cyan"   lw 2 
set style line 2 lt 2 lc rgb "red"    lw 2
set style line 3 lt 2 lc rgb "yellow" lw 2
set style line 4 lt 2 lc rgb "green"  lw 2
set style line 5 lt 2 lc rgb "blue"   lw 2
set style line 6 lt 2 lc rgb "black"  lw 2
set terminal postscript eps enhanced color

set xtics nomirror
set ytics nomirror
set key top left
set key box

set output 'grafico.eps'
set style data lines

plot "dados.data" using 1:2 title "LAPACK"     ls 6 with linespoints,\
     "dados.data" using 1:3 title "Threads=2"  ls 2 with linespoints,\
     "dados.data" using 1:4 title "Threads=4"  ls 4 with linespoints,\
     "dados.data" using 1:6 title "Threads=8"  ls 5 with linespoints,\
     "dados.data" using 1:7 title "Threads=16" ls 1 with linespoints

