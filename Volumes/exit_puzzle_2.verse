
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

exit_puzzle_2 := class(exit_puzzle)
{
    #the puzzle NPC's interaction script
    @editable
    FungiDevice:AI.fungi_interact_only = AI.fungi_interact_only{}

    @editable
    Trigger : ?trigger_device = option{trigger_device{}}

    OnEnterZone<override>(Agent : agent):void=
    {
        Print("Agent entered zone")

        #breaks the NPC's interaction loop
        FungiDevice.SetBreakTimer(true)

        #triggers usually a lock toggle
        if (IsTrigger := Trigger?):
            IsTrigger.Trigger(Agent)
    }
}