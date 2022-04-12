( ConTimes.MUF. Part 3/3 of Tursi's Contimes clone )
( This code is the actual action )
( This function reads the stored data on a user and reports their )
( connections in a nice nifty little graph. It also manages the   )
( props that say whether or not this information is public.       )
( v1.0 - 9 June 01 )
( v1.1 - 11 June 01 - Added function to generate a whole day. Be  )
( aware that with this change about 64 variables are required.    )
( By default Fuzzball only allows 50, so the MAX_VARS define may  )
( need to be increased! [and fuzzball recompiled] I set it to 128 )
( v1.2 - 24 June 01 - Code started to slow down after a few weeks )
( so I've modified it to work out the first and last logins for   )
( and only scan those connections. This counts on the fact that   )
( props are stored alphabeticaly [and thus numerically]           )
( v1.3 - 24 June 01 - now includes the current session if the     )
( user is logged in. Fixes to start and end times [broken in 1.2] )
( Removed unused oneblock function.                               )
( v1.4 - 16 Dec 01 - Noted that logins that wrap around a week    )
( boundary [as opposed to just a day] don't show up - fixed       )
( v1.5 - 16 Mar 02 - Verify that the input range is from 1-9      )

lvar s1
lvar e1
lvar s2
lvar e2
lvar t
lvar timestr
lvar target
lvar start
lvar day
lvar daytotal
lvar total
lvar shown
lvar weekstart
lvar weekend

lvar array		(this lvariable *must* be last)

( print a separator line )
: printseparator ( -- )
"------------------------------------------------" .tell
;

( Create a string listing the start-end times stored in the )
( @Contimes propdir. This is faster to work with than       )
( scanning the properties every time. 'x' becomes current   )
( [skip any non-numeric properties]                         )
( By only including the relevant range, we speed the scan   )
( You MUST set 'weekstart' and 'weekend' first              )
: createtimestr					( -- n ) ( 0 for no info, 1 for success )
""								( str )
target @ "/@Contimes/" nextprop

dup "" strcmp not if
	0 exit
then

begin dup "" strcmp while		( str propname )
	dup "/" explode				( str propname s1 s2... n )
	begin dup 1 > while
		swap pop 1 -			( str propname s1 s2... n )
	repeat
	pop							( str propname timestr )
	dup atoi 0 = not if
		dup atoi weekstart @ >= if
			dup atoi weekend @ < if
				swap dup target @ swap getpropstr ( str timestr propname value )
				dup "x" stringcmp not if	( str timestr propname value )
					pop swap
					"-" strcat
					systime intostr strcat
					" " strcat				( str propname timestr )
					rot swap strcat
				else
					rot						( str propname value timestr )
					dup atoi				( str propname value timestr time )
					rot atoi + intostr		( str propname timestr endstr )
					swap					( str propname endstr timestr )
					"-" strcat				( str propname endstr timestr )
					swap strcat				( str propname timestr )
					rot swap				( propname str timestr )
					strcat " " strcat		( propname str )
				then
			else
				pop swap			( propname str )
			then
		else
			pop swap				( propname str )
		then
	else
		pop swap					( propname str )
	then
	swap							( str propname )
	target @ swap nextprop			( str nextprop )
repeat
pop									( str )
strip timestr !						( )
1 exit
;

( fills in the 48 entry array for 1 day's worth of time )
: oneday  ( i -- )
0 t !						( t = 0 )
dup 86400 + e1 !			( e1 = start + 86400 [1 day] )
s1 !						( s1 = start )
48							( counter )
begin dup while
	1 -						( counter )
	array over +			( counter var )
	0 swap !				( counter )
repeat						( clear array to 0s )
pop

timestr @ " " explode

begin dup while					( prop prop... n )
	swap						( prop prop... n timestr )
	"-" explode					( prop prop... n stimestr etimestr 2 ) (at least, it should be '2')
	pop atoi s2 !				( e2=etime )
	atoi e2 !					( s2=stime )
	( at this point, s1-e1 is the range we want, and  )
	( s2-e2 is the range we have. We need to work out )
	( which blocks this affects, and update them. )
	e2 @ s1 @ < not if
		s2 @ e1 @ >= not if
			( okay, it's valid in this week. trim to fit )
			s2 @ s1 @ < if		( if s2<s1 s2=s1 )
				s1 @ s2 !
			then
			e2 @ e1 @ > if		( if e2>e1 e2=e1 )
				e1 @ e2 !
			then
			( convert it to offsets )
			s2 @ s1 @ - s2 !
			e2 @ s1 @ - e2 !
			( now work out which blocks are affected )
			e2 @ s2 @ -			( length )
			dup t @ + t !		( t=t+length )
			s2 @ 1800 /			( length first )
			array				( length first var )
			swap +				( length var )
			swap				( var length )
			s2 @ 1800 % 0 = not if
				( account for the offset of the first entry )
				s2 @ 1800 %	1800 swap -	( var length diff )
				over over < if	( if length<diff )
					pop dup		( then diff=length )
				then
				dup 4 pick 		( var length diff var )
				@ + 			( var length diff value )
				4 pick !		( var length diff )
				-				( var length )
				swap 1 + swap	( var length )
			then

			begin dup 0 > while
				dup 1799 > if
					( 30 min block )
					1800 -		( var length )
					swap		( length var )
					dup 1800 swap !	( length var ) ( var = 1800 )
					swap		( var length )
				else
					( 15 min block )
					swap		( length var )
					dup @		( length var value )
					rot			( var value length )
					+			( var value )
					over !		( var )
					0			( var length )
				then
				swap dup @		( length var value )
				dup 1800 > if	( length var value )
					swap 1 +	( length value var )
					dup @		( length value var value2 )
					3 pick		( length value var value2 value )
					+			( length value var value2 )
					1800 -		( length value var value2 )
					over !		( length value var )
					1 -			( length value var )
					swap 1800 -	( length var value )
					over !		( length var )
				else
					pop
				then
				1 + swap		( var length )
			repeat
			pop pop
		then
	then
	1 -							( prop prop... n )
repeat
pop								( )

( update the day total )
daytotal @ t @ + daytotal !		( daytotal=daytotal+t )
;

( format time as hh:mm )
: formattime ( i -- s )
dup	3600 /							( i hrs )
dup 10 < if
	intostr "0" swap strcat
else
	intostr
then								( i hrsstr )
"h" strcat							( i hrsstr )
swap 3600 % 60 /					( hrsstr mins )
dup 10 < if
	intostr "0" swap strcat
else
	intostr
then								( hrsstr minstr )
strcat								( timestr )
;

( returns the time total line )
: gettotal ( -- s )
"Tot " 
total @ formattime strcat
;

: main (s -- )
dup "" strcmp not if
	pop "me"
then

dup "#help" stringcmp not if
	" " .tell
	"Contimes [<name> [ = <#weeks> ]]" .tell
	"Contimes #off      - disable public viewing of your logins" .tell
	"Contimes #on       - enable public viewing of your logins" .tell
	"Contimes #basic    - this is the full viewing mode" .tell
	"Contimes #advanced - removes the key from the output" .tell
	"Contimes #about    - for version and credits" .tell
	"Select 1-9 weeks back, or leave it out for the current week." .tell
	"If no name is entered, defaults to yourself." .tell
	exit
then

dup "#about" stringcmp not if
	" " .tell
	"Contimes v1.5 released 16 Mar 02 by Tursi" .tell
	"This program was inspired by the contimes program at TLK muck" .tell
	"which I never could get author information for. However, it" .tell
	"is entirely original code and not derived from that program." .tell
	exit
then

dup "#off" stringcmp not if
	me @ "/@Contimes/Public" "No" 0 addprop
	"+ Other players may NOT view your logins through Contimes." .tell
	exit
then

dup "#on" stringcmp not if
	me @ "/@Contimes/Public" "Yes" 0 addprop
	"+ Other players are permitted to view your logins through Contimes." .tell
	exit
then

dup "#basic" stringcmp not if
	me @ "/@Contimes/Advanced" "No" 0 addprop
	"+ You will now see the full output with help text." .tell
	exit
then

dup "#advanced" stringcmp not if
	me @ "/@Contimes/Advanced" "Yes" 0 addprop
	"+ You will now see the simplified output." .tell
	exit
then

"=" explode						( name time n )
dup 2 > if
	"* Too many arguments! Contimes #help for details." .tell
	exit
then
2 = not if
	0
else
	swap atoi
then							( name time )

swap .pmatch					( time #player )
dup #-1 dbcmp if
	"* Unable to locate that player." .tell
	exit
then

dup player? not if
	"* That is not a player." .tell
	exit
then

target !						( time ) (target=#player)

target @ "/@Contimes/Public" getpropstr
"No" stringcmp not if
	me @ target @ dbcmp not if
		"* That user has disabled viewing login times." .tell
		me @ "W" flag? if
			"* Would you like to use your wizard powers to override?" .confirm
			not if
				"* Aborted." .tell
				exit
			then
		else
			exit
		then
	then
then

dup 0 < over 9 > or if
  "* You may only enter a history from 0-9 weeks" .tell
  exit
then

604800 *						( time ) ( multiply for weeks )
systime							( time start )
swap -							( start )
start !							( ) ( start=start )
( now we need to roll it back to Sunday )
start @ timesplit				( seconds minutes hours monthday month year weekday yearday )
( year )
pop
( weekday )
1 - 86400 * start @ swap - start !
( year )
pop
( month )
pop
( monthday )
pop
( hours )
3600 * start @ swap - start !
( minutes )
60 * start @ swap - start !
( seconds )
start @ swap - start !			( )

start @ 86400 - weekstart !		( we subtract a day to start on Saturday, to catch wraparound sessions )
start @ 604800 + weekend !

printseparator
"Connections: _ on the week of %b %e, %y" start @ timefmt
target @ name "_" subst .tell
"----------A.M.--------------------P.M.----------" .tell
"1                   1 1 1                   1 1 " .tell
"2 1 2 3 4 5 6 7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0 1 " .tell
printseparator

createtimestr

0 = if
	"* No Information Available." .tell
	exit
then

timestr @ "" strcmp not if
	"0-0" timestr !
then

0 total !						( total=0 )
0 daytotal !					( daytotal=0 )

start @							( start )
7								( start day )
begin dup while
	"%a" 3 pick timefmt day !	( day = day of week)
	swap dup oneday swap
	"" array 48					( start day string var block )
	begin dup while
		swap dup @				( start day string block var value )
		dup 1800 >= if
			"*"
		else
			dup 900 >= if
				"+"
			else
				dup 0 > if
					"."
				else
					" "
				then
			then
		then					( start day string block var value char )
		swap pop				( start day string block var char )
		4 rotate swap strcat	( start day block var string )
		swap 1 +				( start day block string var )
		rot						( start day string var block )
		1 -
	repeat
	pop pop						( start day string )
	" " strcat day @ strcat
	" " strcat

	daytotal @ formattime strcat
	.tell						( start day )
	swap 86400 + swap			( start day )
	
	total @ daytotal @ + total ! 
	0 daytotal !
	1 -
repeat
printseparator
0 shown !

me @ "/@Contimes/Advanced" getpropstr
"yes" stringcmp if
	"  Key:  . = Less than 15 minutes" 
	shown @ not if
		"                 " strcat gettotal strcat
		1 shown !
	then
	.tell
	"        + = 15-29 minutes" .tell
	"        * = 30 minutes" .tell
	" " .tell
	"(version 1.5 by Tursi. contimes #help for info)" .tell
	printseparator
then

me @ target @ dbcmp if
	"Public viewing of your login times is "
	me @ "/@Contimes/Public" getpropstr
	"No" stringcmp if
		"On "
	else
		"Off"
	then
	strcat
	shown @ not if
		"        " strcat gettotal strcat
		1 shown !
	then 
	.tell
	printseparator
then

shown @ not if
	"                                                 "
	gettotal strcat .tell
then

pop pop
;
