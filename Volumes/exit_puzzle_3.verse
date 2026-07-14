
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

exit_puzzle_3 := class(exit_puzzle_2)
{
    @editable
    LureDevice : AI.fungi_lure_device = AI.fungi_lure_device{}

    #when player enters zone
    OnEnterZone<override>(Agent : agent):void=
    {
        Print("Agent entered zone")
        FungiDevice.SetBreakTimer(true)
        ClearInventory()
    }

    ClearInventory():void=
    {
        LureDevice.ClearInventory()
    }
}