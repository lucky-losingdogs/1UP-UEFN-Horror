
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

moving_targets := class(volume_zone_parent)
{
    @editable
    propMovers:[]prop_mover_device = array{}

    var hitTargets:int = 0

    OnEnterZone<override>(Agent : agent):void=
    {
        for (mover : propMovers):
            mover.Advance()
    }

    OnExitZone<override>(Agent : agent):void=
    {
        spawn {WaitToReset()}
    }

    WaitToReset()<suspends>:void=
    {
        Sleep(5.0)
        for (mover : propMovers):
            mover.Reset()
    }
}