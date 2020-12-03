function burn_fuel{
    parameter deltav.

    set fuel_flow to 0.
    list engines in myeng.
    for eng in myeng{
        if eng:ignition and not eng:flameout{
            set eng_flow to eng:availableThrust/(eng:isp*constant:g0).
            set fuel_flow to fuel_flow + eng_flow.
        }
    }
    set ISP to ship:availablethrust/(fuel_flow*constant:g0).

    set m0 to ship:mass.
    set exp to -deltav/(ISP*constant:g0).
    set m1 to m0*constant:e^exp.
    set fuel_mass to m0 - m1.
    set burn_time to fuel_mass/fuel_flow.

    return list(m1, burn_time).
}

function smartwarp{
    parameter tt.
    print "Warping!".
    kuniverse:timewarp:warpto(time:seconds + tt).
}

if maxThrust = 0 { stage. }

set node to nextNode.
set delv to node:burnvector:mag.
set burn_data to burn_fuel(delv).
set dry_mass to burn_data[0].
set burn_length to burn_data[1].

clearScreen.
print "Post-burn mass: "+round(dry_mass,1) at (0,0).
print "Burn length: "+round(burn_length, 1) at (0,1).

smartwarp(node:eta -burn_length/2 - 240).
clearScreen.
print "Burn ETA: "+round(node:eta - burn_length/2, 1) at (0,0).
print "Orienting to burn vector." at (0, 1).

wait 1.
sas off.
lock steering to node:burnvector.
wait until vang(ship:facing:vector, node:burnvector) < 1.

smartwarp(node:eta -burn_length/2 -10).
wait 1.
lock steering to node:burnvector.
clearScreen.
print "Burn ETA: "+round(node:eta - burn_length/2, 1) at (0,0).

wait until node:eta <= burn_length/2.
set face to facing.
lock steering to facing.
lock throttle to 1.
print "Burning!" at (0,1).

wait until ship:mass <= dry_mass.
lock throttle to 0.

clearScreen.
print "Main burn complete. Executing course correction burn." at (0,0).

set delv to node:burnvector:mag.
set burn_data to burn_fuel(delv).
set dry_mass to burn_data[0].
set burn_length to burn_data[1].
set thrott to burn_length/5. //Number of seconds you want the burn to last. Increase divisor for more precision.

print "Course correction burn calculated. Executing burn." at (0,1).
wait 1.
lock steering to node:burnvector.
wait until vang(node:burnvector, ship:facing:vector) < 1 and angularVel:mag < 0.1.

set face to facing.
lock steering to facing.
clearScreen.
lock throttle to thrott.
print "Burning!" at (0,0).

wait until vAng(face:vector, node:burnvector) > 50.
lock throttle to 0.
wait 1.
clearScreen.
print "Node executed with unknown success.".
