{
rcs on.
sas off.
set tgt_ship to target.
set tgt_dock to tgt_ship:DockingPorts[0].
set target to tgt_dock.
set ship_dock to ship:dockingports[0].
ship_dock:controlfrom.
lock dock_dir to lookDirUp(-tgt_dock:portFacing:forevector, tgt_dock:portFacing:topvector).
lock steering to dock_dir.
wait until vAng(facing:vector, dock_dir:vector) < 1 and angularVel:mag < 1.
lock rel_vel to ship:velocity:orbit - tgt_ship:velocity:orbit.
set tgt_box to tgt_ship:bounds.
set ship_box to ship:bounds.
set clearance to 3*(tgt_box:size:mag + ship_box:size:mag).
}

{
set kP to 1.
set kI to 0.05.
set kD to 0.1.
set Imin to -1.
set Imax to 1.

set pidFore to pidLoop(kP, kI, kD, Imin, Imax).
set pidFore:setpoint to 0.

set pidTop to pidLoop(kP, kI, kD, Imin, Imax).
set pidTop:setpoint to 0.

set pidStar to pidLoop(kP, kI, kD, Imin, Imax).
set pidStar:setpoint to 0.

set controlFore to 0.
set controlTop to 0.
set controlStar to 0.
}

set tgt_pos to tgt_dock:nodePosition.
set toPlace to 0.
set desiredVel to V(0,0,0).
set tgt_vel to V(0,0,0).

vecDraw(
    V(0,0,0),
    {return tgt_pos.},
    RGB(255,0,0),
    "",
    1,
    TRUE,
    1,
    TRUE
).

vecDraw(
    V(0,0,0),
    {return tgt_vel.},
    RGB(255,0,255),
    "",
    1,
    TRUE,
    1,
    TRUE
).

set pos_accu to 4.
set vel_accu to 0.3.
set maxVel to 2.
set accel to 1/ship:mass.
set rcsDeadZone to 0.05.

function printStuff {
    print "Running to "+toPlace at (0,1).
    print round(controlFore, 3) at (0,2).
    print round(controlTop, 3) at (0,3).
    print round(controlStar, 3) at (0,4).
}

set boardPos to -vDot(tgt_dock:nodePosition:normalized, tgt_dock:portFacing:starvector).
function displacement{
    if toPlace = 0 {
        return tgt_dock:portFacing:foreVector*4 + boardPos*tgt_dock:portFacing:starVector*clearance.
    }
    else if toPlace = 1 {
        return tgt_dock:portFacing:foreVector*4.
    }
    else if toPlace = 2 {
        return tgt_dock:portFacing:foreVector*2.
    }
    else if toPlace = 3 {
        return V(0,0,0).
    }
}

FUNCTION dist_to_vel {
    PARAMETER distVec.
    LOCAL targetVel IS MIN(SQRT(2 * distVec:MAG / accel) * accel,maxVel).
    RETURN distVec:NORMALIZED * targetVel.
}

function doLoop{

    set startTime to time:seconds.
    set prevPos to tgt_pos.
    set tgt_vel to V(0,0,0).

    until tgt_pos:mag < pos_accu and rel_vel:mag < vel_accu {
    
    set tgt_pos to tgt_dock:nodePosition + displacement().
    set desiredVel to dist_to_vel(tgt_pos).

    set pidFore:setpoint to vDot(desiredVel, facing:forevector).
    set pidTop:setpoint  to vDot(desiredVel, facing:topvector).
    set pidStar:setpoint to vDot(desiredVel, facing:starvector).

    set controlFore to controlFore + pidFore:update(time:seconds, vDot(tgt_vel, facing:forevector)).
    set controlTop to  controlTop  +  pidTop:update(time:seconds, vDot(tgt_vel, facing:topvector)).
    set controlStar to controlStar + pidStar:update(time:seconds, vDot(tgt_vel, facing:starvector)).

    set ship:control:fore to controlFore.
    set ship:control:top to controlTop.
    set ship:control:starboard to controlStar.

    wait 0.

    if abs(controlFore) > rcsDeadZone { set controlFore to 0. }
    if abs(controlTop) > rcsDeadZone { set controlTop to 0. }
    if abs(controlStar) > rcsDeadZone { set controlStar to 0. }

    if ship_dock:haspartner { break. }

    printStuff().
    wait 0.001.

    set deltaTime to time:seconds - startTime.
    set startTime to time:seconds.
    set deltaPos to tgt_pos - prevPos.
    set prevPos to tgt_pos.
    set tgt_vel to -deltaPos/deltaTime.

    if tgt_vel:mag > 1000 {
        set tgt_vel to V(0,0,0).
    }
}
    set ship:control:fore to 0.
    set ship:control:top to 0.
    set ship:control:starboard to 0.
}

clearScreen.

doLoop().


set toPlace to 1.
doLoop().

set toPlace to 2.
set pos_accu to 0.2.
set vel_accu to 0.1.
doLoop().

set toPlace to 3.
set pos_accu to 0.02.
set vel_accu to 0.1.
doLoop().
clearVecDraws().