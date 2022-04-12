( Con-DisConnect.MUF. Part 2/3 of Tursi's Contimes clone )
( This code belongs on the _disconnect prop on room #0   )
( On disconnect, we need to find the prop with the 'x' value,  )
( and simply store the time difference in seconds between then )
( and now.)
( v1.0 - 9 June 01 )
( v1.1 - 15 Mar 01 - don't update on duplicate connections )
: main (s -- )
( Make sure this isn't a duplicate connection )
me @ descriptors
0 = not if
  begin depth while pop repeat
  exit
then
pop

( For simplicity in testing, we can be called in any way )
me @ "/@Contimes/" nextprop
begin dup "" strcmp while    ( propname )
 dup me @ swap getpropstr   ( propname value )
 "x" stringcmp not if    ( propname )
  dup "/" explode     ( propname s1 s2... n )
  begin dup 1 > while
   swap pop 1 -    ( propname s1 s2... n )
  repeat
  pop        ( propname timestr )
  atoi systime     ( propname time systime )
  swap -       ( propname diff )
  intostr me @ -3 rotate setprop ( )
  break
 then
 me @ swap nextprop     ( nextprop )
repeat
;
