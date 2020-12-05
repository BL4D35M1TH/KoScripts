rcs on.
set tgt_ship to target.
set tgt_dock to tgt_ship:DockingPorts[0].
set target to tgt_dock.
set ship_dock to ship:dockingports[0].
ship_dock:controlfrom.
set dock_dir to lookDirUp(-tgt_dock:portFacing:forevector, tgt_dock:portFacing:topvector).
lock steering to dock_dir.
lock rel_vel to tgt_ship:velocity:orbit - ship:velocity:orbit.
set tgt_box to tgt_ship:bounds.
set ship_box to ship:bounds.
set clearance to 4*(tgt_box:size:mag + ship_box:size:mag).

set pidFore to pidLoop(0.025, 0.0008, 0.45).
set pidFore:setpoint to 0.

set pidTop to pidLoop(0.025, 0.0008, 0.45).
set pidTop:setpoint to 0.

set pidStar to pidLoop(0.025, 0.0008, 0.45).
set pidStar:setpoint to 0.

set displacement to tgt_dock:portFacing:foreVector*4 -vxcl(tgt_dock:portFacing:foreVector, tgt_dock:nodePosition):normalized*clearance.
lock tgt_pos to tgt_dock:nodePosition + displacement.

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

lock offsetFore to vDot(tgt_pos, -facing:forevector).
lock offsetTop to vDot(tgt_pos, -facing:topvector).
lock offsetStar to vDot(tgt_pos, -facing:starvector).

set foreControl to 0.
set topControl to 0.
set starControl to 0.

set start_time to time:seconds.
function doLoop{
    parameter pos_acc is 4.
    parameter vel_acc is 0.3.
    // parameter doLog is false.
    until tgt_pos:mag < pos_acc and rel_vel:mag < vel_acc {
    set foreControl to  pidFore:update(time:seconds, offsetFore).
    set topControl to  pidTop:update(time:seconds, offsetTop).
    set starControl to  pidStar:update(time:seconds, offsetStar).

    set ship:control:fore to foreControl.
    set ship:control:top to topControl.
    set ship:control:starboard to starControl.

    if ship_dock:haspartner {
        break.
    }

    // if doLog{
    //     LOG time:seconds - start_time+","+pidFore:setpoint+","+offsetFore to "data.csv".
    //     }

    wait 0.001.
}
    set ship:control:fore to 0.
    set ship:control:top to 0.
    set ship:control:starboard to 0.
}

set start_time to time:seconds.
doLoop().

set displacement to tgt_dock:portFacing:foreVector*4.

doLoop(2, 0.2).

set displacement to tgt_dock:portFacing:foreVector*2 .

doLoop(1, 0.1).

set displacement to V(0,0,0).

doLoop(0.5, 0.1).