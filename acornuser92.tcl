#!/usr/bin/tclsh

# 2D water surface demo/toy
# based on an algorithm posted in the August '92 issue of Acorn User magazine
# for more information, please refer to these links:
# https://stardot.org.uk/forums/viewtopic.php?f=29&t=25379
# https://archive.org/details/AcornUser1992Magazine/AcornUser9208/page/n67/mode/2up
# https://github.com/dusthillresident/JohnsonScript/blob/master/example_programs/acornuser_michelgrimminck_ripple.jo

package require Tk

tk appname "AcornUser August 92 water surface, original by Michel Grimminck"

set wh 63 ;# width and height of the water surface
set sc 8  ;# scale size used for drawing
set xs 1
set ys 1

# initialise arrays
for {set x 0} {$x<$wh} {incr x} {
 for {set y 0} {$y<$wh} {incr y} {
  set height("$x,$y") 0
  set velocity("$x,$y") 0
 }
}
array set cols { -4 \#406000 -3 \#406a20 -2 \#407040 -1 \#407a60 0 \#407a80 1 \#4080A0 2 \#408aC0 3 \#4090E0 4 \#409aFF
               }
set height("-1,-1") -1
set velocity("-1,-1") -1


proc process_frame {} {
 set friction 0.02
 set tension 0.5
 global wh height velocity
 for {set x 1} {$x<$wh-1} {incr x} {
  for {set y 1} {$y<$wh-1} {incr y} {
   set velocity("$x,$y") [expr {(1-$friction)*($velocity("$x,$y")-$tension*(4*$height("$x,$y")-$height("[expr {$x-1}],$y")-$height("[expr {$x+1}],$y")-$height("$x,[expr {$y-1}]")-$height("$x,[expr {$y+1}]")))}]
  }
 }
 for {set x 1} {$x<$wh-1} {incr x} {
  for {set y 1} {$y<$wh-1} {incr y} {
   set height("$x,$y") [expr {$height("$x,$y")+$velocity("$x,$y")}]
  }
 }
}

set height("32,32") -10

#pack [canvas .squares -width [expr {$wh*$sc}] -height [expr {$wh*$sc}] -background black] -fill both -expand 1
image create photo img
image create photo displ
pack [label .squares -image displ] -fill both -expand 1
img put black -to 0 0 $wh $wh

proc display_frame {} {
 global wh height cols
 for {set x 1} {$x<$wh-1} {incr x} {
  for {set y 1} {$y<$wh-1} {incr y} { 
   set colour [expr { int($height("$x,$y")*4) }]
   if {$colour<-4} {set colour -4}
   if {$colour>4}  {set colour 4}
   set colour $cols($colour)
   img put $colour -to $x $y
  }
 }
 displ copy img -zoom $::xs $::ys
}

set mouse_pressed 0

proc clickaction {x y} {
 global height xs ys
 set xx [expr {int($x/$xs)}]
 set xx [expr { !($xx<1||$xx>=$::wh-1) ? $xx : -1 }]
 set yy [expr {int($y/$ys)}]
 set yy [expr { !($yy<1||$yy>=$::wh-1) ? $yy : -1 }]
 set height("$xx,$yy") 10
}

bind .squares <ButtonPress> {
 set ::mouse_pressed 1
 clickaction %x %y
}

bind .squares <ButtonRelease> {
 set ::mouse_pressed 0
}

bind .squares <Motion> {
 if $::mouse_pressed {
  clickaction %x %y
 }
}

bind . <Configure> {
 displ blank
 set ::xs [expr {[winfo width .squares]/$::wh}]
 set ::ys [expr {[winfo height .squares]/$::wh}]
 set ::xs [expr {$::xs<1 ? 1 : $::xs}]
 set ::ys [expr {$::ys<1 ? 1 : $::ys}]
}

proc updater {} {
 process_frame
 display_frame
 after 6 updater
}
updater

after 32 {wm geometry . 256x256}