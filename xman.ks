
function executeNode {

    clearScreen.
    print "Executing maneuver node." at (0,0).

    //Staging when stage spent
    set av_thrust to ship:availablethrustat(0).
    set count to 0.
    when ship:availablethrustat(0) < av_thrust and stage:ready then {
        print "Staging..."+count at (20, 2).
        stage.
        set count to count+1.
        set av_thrust to availableThrust.
    }

    //Gathering info
    set ISP to 0.
    list engines in myengines.
    for eng in myengines {
        if eng:ignition and not eng:flameout {
            set engISP to eng:isp*eng:availableThrust/ship:availablethrust.
            set ISP to ISP+engISP.
        }
        
    }
    set fuelflow to availableThrust*1000/max(1, ISP).
    set deltaV to myNode:deltav:mag.
    set m0 to ship:mass*1000.
    lock acc to max(0.1, availableThrust/mass).

    set m1 to m0/(constant:e^(0.6*deltaV/ISP)).
    set burnTime to (m0-m1)/fuelflow.
    set t0 to time:seconds + myNode:eta - burnTime.

    //Display all the stuff
    print "ISP: "+round(ISP, 2) at (0,5).
    print "fuelflow: "+round(fuelflow, 2) at (0,6).
    print "deltaV: "+round(deltaV, 2) at (0,7).
    print "acc: "+round(acc, 2) at (0,8).
    print "m0: "+round(m0, 2) at (0,9).
    print "m1: "+round(m1, 2) at (0,10).
    print "burntime: "+round(burnTime, 2) at (0,11).


    //Warping to a bit before burn, to orient ship.
    unlock steering.
    sas on.
    lock throttle to 0.
    kuniverse:timeWarp:warpTo(t0 - 300).
    sas off.
    lock steering to myNode:burnvector.
    wait until vAng(myNode:burnvector, ship:facing:vector) < 1.

    //Warping 10 seconds before burn.
    unlock steering.
    sas on.
    kuniverse:timeWarp:warpTo(t0 - 15).
    sas off.
    lock steering to myNode:burnvector.

    //Burning
    wait until time:seconds >= t0.
    lock throttle to min(1, burnTime/5).
    wait until myNode:deltav:mag < 0.05*deltaV.
    lock throttle to max(0.01, myNode:deltav:mag/acc).
    set mysteer to myNode:burnvector.
    lock steering to mysteer.
    wait until vAng(ship:facing:vector, myNode:burnvector) > 10.
    lock throttle to 0.

    //Leaving you to float
    clearScreen.
    print "Node executed.".
    wait 1.
    remove myNode.
    unlock throttle.
    unlock steering.
    sas on.
    panels on.
    lights on.
}

if hasNode {
    set myNode to nextNode.
    executeNode().
} else {
    clearScreen.
    print "Node not found!".
}
