using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }

fungi_target_interact_pipe_device<public> := class(fungi_interact_only)
{
    @editable
    PipeRotaters:[]Pipes.pipe_rotator_device = array{}
    var PipeIndex:int = 0

    InteractionBehaviour<override>(Agent:agent):void=
    {
        SetRandomIndex()
        if (Rotater := PipeRotaters[PipeIndex]):
            Rotater.ButtonTriggered(Agent)
            #Reset(Agent)
    }

    SetRandomIndex():void=
    {
        set PipeIndex = GetRandomInt(0, PipeRotaters.Length)
    }
}