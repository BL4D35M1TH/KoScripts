parameter celes_body is mun.

set r2 to celes_body:orbit:semimajoraxis.
set r1 to ship:orbit:semimajoraxis.

set c1 to (r1/r2 + 1)^3.
set c2 to 1/(8)^0.5.
set ang to 180*(1 - c2*c1^0.5).
set LoP1 to ship:orbit:longitudeofascendingnode  + ship:orbit:trueanomaly.
set LoP2 to celes_body:orbit:longitudeofascendingnode  + celes_body:orbit:trueanomaly.
set ang_diff to LoP1 - LoP2.
set vang1 to 360/ship:orbit:period.
set vang2 to 360/celes_body:orbit:period.
set c1 to ang - ang_diff.
set Tf to (max(360-c1, c1))/(vang1 - vang2).

clearScreen.
print "Angle difference: "+round(ang_diff, 2) at (0, 3).
print "LoP Ship: "+round(LoP1, 2) at (0, 4).
print "LoP Celestial Body: "+round(LoP2, 2) at (0, 5).
print "Angular Velocity Ship: "+round(vang1, 4) at (0, 6).
print "Angular Velocity Celestial body: "+round(vang2, 4) at (0, 7).
print "Transfer Burn eta: "+round(Tf, 2) at (0, 8).
print "Transfer angle: "+round(ang, 2) at (0, 9).

print "Execute Maneuver? (y/n)" at (20, 16).

if terminal:input:getchar = "y" {
    runPath("0:/hoho.ks", r2, time:seconds+Tf, r1).
} else {
    print "Maneuver Cancelled." at (20, 16).
}

