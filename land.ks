clearScreen.
print "Landing sequence activated!".

runOncePath("0:/hoho.ks", 0, time:seconds + eta:periapsis, ship:body:radius + periapsis).

sas off.
legs on.
panels off.
lock steering to srfRetrograde.

wait until vAng(facing:vector, srfRetrograde:vector) < 1.


set shipbox to ship:bounds.
lock radar to shipbox:bottomaltradar.
set celes_bd to ship:orbit:body.
set g to celes_bd:mu/(celes_bd:radius)^2.
lock a to availableThrust/mass.

//Crash warp
set crash_time to (2*radar/g)^0.5.
kuniverse:timewarp:warpto(time:seconds + crash_time - 10).


until false {
    set s to (verticalSpeed^2)/(2*(a-g)).
    if radar < s + 200 {
        break.
    }
    wait 0.01.
}

lock throttle to 1.

wait until verticalSpeed >= -10.
lock steering to up.

set PID to pidLoop(0.01,0.005,0.005).
set PID:setpoint to -10.
set thrott to 1.
lock throttle to thrott.

when radar < 10 then {
    set PID:setpoint to -1.
}

until radar < 2 {
    set thrott to thrott + PID:update(time:seconds, verticalSpeed).

    print "V speed: "+round(verticalSpeed,2) at (0, 5).
    print "Altitude: "+round(radar, 2) at (20, 5).
    print "P: "+round(PID:pterm, 2) at (0, 10).
    print "I: "+round(PID:iterm, 2) at (8, 10).
    print "D: "+round(PID:dterm, 2) at (16, 10).

    wait 0.001.
}

lock throttle to 0.
unlock steering.
sas on.

