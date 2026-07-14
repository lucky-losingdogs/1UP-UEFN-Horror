
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

button_sequence_any := class(button_sequence)
{
    OnBegin<override>()<suspends>:void=
    {   
        set randomise = false
        (super:) OnBegin()
    }

    OnButtonInteraction<override>(index : int, Agent:agent):void=
    {
        if(button:=buttons[index]):
            button.Disable()

        CheckPressed(index, Agent)
    }

    CheckPressed(index:int, Agent:agent):void=
    {
        set orderIndex += 1
        if (orderIndex = buttons.Length):
            Trigger.Trigger(Agent)
    }
}