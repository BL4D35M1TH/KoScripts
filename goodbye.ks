clearscreen.
parameter orbit_height is 100000.
if ship:rootpart:tag:tonumber > 70000 {
    set orbit_height to ship:rootpart:tag:tonumber.
}
sas off.
print "Launching Secquence activated!".

lock throttle to 1.
lock mysteer to 90*(1 - altitude/70000)^3.
lock steering to heading(90, max(0, mysteer), 0).

//Launch
stage.

//Automated staging
set av_thrust to ship:availablethrustat(0).
set count to 0.
when ship:availablethrustat(0) < av_thrust and stage:ready then {
    print "Staging..."+count at (20, 2).
    stage.
    set count to count+1.
    set av_thrust to ship:availableThrustat(0).
    preserve.
}

wait until apoapsis > 0.95*orbit_height.
lock throttle to 1.1 - apoapsis/orbit_height.
print "Coasting!" at (20, 16).
wait until altitude > 70000 and apoapsis > orbit_height.

//Coasting
lock throttle to 0.
lock steering to facing.
wait until altitude > 70000.
unlock steering.
unlock throttle.
sas on.
panels on.
lights on.

//Circularization 
runPath("0:/circ.ks").
