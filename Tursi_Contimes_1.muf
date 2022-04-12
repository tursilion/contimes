( Con-Connect.MUF. Part 1/3 of Tursi's Contimes clone )
( This code belongs on the _connect prop on room #0   )
( On connect, we want to log the current time as a prop, and 'x' )
( as the value. On disconnect, we will fill in the 'x' with minutes )
( connected. Here we will also clean out ancient and incomplete )
( props [perhaps due to crashes] )
( v1.1 - 10 June 01  - updated to not delete preferences )
( v1.2 - 15 Mar 02 - Only update when we're the only connection )
 
: main (s -- )
( Make sure this isn't a duplicate connection )
me @ descriptors
1 = not if
  begin depth while pop repeat
  exit
then

pop
 
( For simplicity in testing, we can be called in any way )
( First scan all the props that already exist. Delete all props )
( which are either more than 9 weeks old, or which contain 'x'  )
( as their data, which means they were never filled in for some )
( reason. )

me @ "/@Contimes/" nextprop			(propname)
begin dup "" strcmp while			( propname )
	dup me @ swap getpropstr		( propname value )
	"x" stringcmp not if			( propname )
		dup me @ swap nextprop		( propname nextprop )
		swap me @ swap remove_prop  ( nextprop )
		continue
	else
		dup "/" explode				( propname s1 s2... n )
		begin dup 1 > while
			swap pop 1 -			( propname s1 s2... n )
		repeat
		pop							( propname timestr )
		atoi						( propname time )
		dup 0 = not if
			systime						( propname time systime )
			swap -						( propname diff )
			6048000 > if				( propname ) ( 6048000 = 10 weeks in seconds )
				dup me @ swap nextprop  ( propname nextprop )
				swap me @ swap remove_prop ( nextprop )
				continue
			then
		else
			pop
		then
	then
	me @ swap nextprop				( nextprop )
repeat

( Now we add the current information )

pop									( )
me @								( #player )
systime intostr "/@Contimes/" swap strcat
"x" 0								( #player prop 'x' 0 )
addprop								( )
;
