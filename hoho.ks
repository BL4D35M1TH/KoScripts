parameter new_height is ship:orbit:body:radius + 100000.
parameter t0 is time:seconds + 100.
parameter burn_height is ship:orbit:semimajoraxis.
parameter dontCheck is true.

clearScreen.
print "Executing hohmann maneuver!".


set r1 to burn_height.
set r2 to new_height.

set celes_body to ship:orbit:body.
set u to celes_body:mu.
set v0 to velocityAt(ship, t0):orbit:mag.
set sma to (r1+r2)/2.

//test params
// set r2 to celes_body:radius + altitude.
// set v0 to velocity:orbit:mag.
// set sma to ship:orbit:semimajoraxis.

set vf to (u*((2/r1) - (1/(sma))))^0.5.
set deltaV to vf - v0.

print "r1: "+round(r1, 2) at (0, 4).
print "r2: "+round(r2, 2) at (0, 5).
print "sma: "+round(sma, 2) at (0, 6).
print "v0: "+round(v0, 2) at (0, 7).
print "vf: "+round(vf, 2) at (0, 8).
print "deltaV: "+round(deltaV, 2) at (0, 9).

add node(t0, 0, 0, deltaV).

print "Execute Node? (y/n)" at (20, 16).

if terminal:input:getchar = "y" or dontCheck{
    runOncePath("0:/xman.ks").
} else {
    print "Maneuver cancelled." at (20, 16).
}

