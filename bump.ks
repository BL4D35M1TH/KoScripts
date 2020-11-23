//This is the part where the rocket launches itself to an apoapsis of 2km to test the landing sequence
clearScreen.
sas off.
lock steering to heading(90, 110). //pitch's 110 because setting it to <90 sent the rocket diving into the ocean. Oops.
if maxThrust = 0{ //Since this runs from boot, this makes it so it launches as soon as you switch to the launch pad from the VAB
    stage.
}
lock throttle to 1. //Aaaaand liftoff
gear off. 
wait until apoapsis > 2000. //It won't reach 2km, due to drag. Expect more like 1.8km. 
lock throttle to 0. //Now we coast to the apoapsis 

//Preparing for the drop
gear on. //Need to deploy them soon, to get the accurate bounding box(see below). It makes more drag, I know.
wait until verticalSpeed < 0. //Not really useful for non-vertical trajectories. 
lock steering to srfRetrograde. //Hope the rocket has enough torque!
set shipbox to ship:bounds. //Takes the additional extended gear length into account, if they managed to deploy fully by this point.
lock radar to shipbox:bottomaltradar. //Distance to ground from the bottom of the landing legs.

//This checks whether the rocket can stop itself before it crashes into the ground.
set acc to availableThrust/mass. //This is the minimum amount of acceleration the rocket will have, to give it more margin of error
set safe_speed to 20. //This is the speed below which the pidloop will kick into action. Until then, throttle's gonna be at max.
set grav to ship:body:mu/ship:body:radius^2. //The maximum gravity the rocket's gonna experience, to give it more margin of error
until false {
    set safe_dist to radar - 20. //Again, a safety measure. It makes it so the rocket treats the ground to be closer than it really is.
    print "Safe distance: "+round(safe_dist, 1) at (0, 2).
    
    //V^2 = U^2 + 2as
    //This assumes constant acceleration 
    //Using velocity:surface:mag even though the above equation is 1D because it is simpler. Will just waste a bit more fuel instead of my sanity.
    set s to (velocity:surface:mag^2 - safe_speed^2)/(2*(acc - grav)). //Just maths stuff. Ignore it.
    print "Stopping distance: "+round(s, 1) at (0, 3).

    //Checks if the calculated distance required to bring the rocket to a safe speed is less than the current height
    if s > safe_dist { 
        print "De-accelerating.".
        break.
    }

    wait 0.001.

}

//Breaking burn
lock throttle to 1.
wait until -velocity:surface:mag > -safe_speed. //Yes, I know the minus signs are pointless. 
set thrott to grav/acc. //So the pidloop has something to work with. It does not responds well to sudden changes.
lock throttle to thrott.

set pid to pidLoop(0.01,0.005,0.005). //Just some values which looked good. Works fine. Most of the time.
set pid:setpoint to -safe_speed. //This is gonna change soon, see below
// (y-y1) = (y2-y1)/(x2-x1)*(x-x1) *************************
// (x1,y1) = (radar, safe_speed)      WARNING! WARNING!
// (x2,y2) = (5, 1)                 MATHS STUFF HAPPENING
// y = (y2-y1)/(x2-x1)*(x-x1) + y1 *************************
set x1 to radar.
set m to (1-safe_speed)/(5-x1).
lock y to m*(radar - x1) + safe_speed. //Y is the decreasing vertical speed setpoint for the pidloop so it does not crashes into the ground at 20m/s

//And now enters the pidloop!
until false {
    set thrott to thrott + pid:update(time:seconds, -velocity:surface:mag). //I know that you are probably annoyed by the minus signs. The previous version used verticalSpeed and I just replaced all instances, that's why.
    set pid:setpoint to -max(1, y). //Change that 1 for for a smoother or scarier landing.
    print "Target velocity: "+round(pid:setpoint, 1) at (0, 4).
    print "Current velocity: "+round(-velocity:surface:mag, 1) at (0, 5).

    //The first if{} is to ensure that the rocket does not goes mad chasing the surface retrograde
    if velocity:surface:mag < 1.5 {
        lock steering to up.
        //I could think of no better way to ensure that the rocket has, in fact, landed
        if radar < 0 {
            print "Landed.". //Hopefully in one piece...
            break.
        }

    }

    wait 0.001.
}

//Easing out
lock throttle to 0.
wait 1.
unlock steering.
sas on. //This is good. 
clearScreen.
print "Stable.". //Questionable
