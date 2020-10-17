clearScreen.

print "Executing circularization maneuver!".

if periapsis > apoapsis {
    set circ_height to ship:orbit:body:radius + periapsis.
    set circ_time to eta:periapsis.
} else {
    set circ_height to ship:orbit:body:radius + apoapsis.
    set circ_time to eta:apoapsis.
}

runOncePath("0:/hoho.ks", circ_height, time:seconds + circ_time, circ_height, false).
