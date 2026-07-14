
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

switch_sequence_any := class(creative_device)
{
    #set buttons in editor
    @editable
    Switches:[]switch_device = array{}

    @editable
    Trigger : trigger_device = trigger_device{}
    
    OnBegin<override>()<suspends>:void=
    {   
        #index through array of buttons and subscribe each one to the HandlerFunction in the ParameterHandler class
        for(Index->Switch : Switches):
            Switch.TurnedOnEvent.Subscribe(OnSwitchInteraction)
            Switch.TurnedOffEvent.Subscribe(OnSwitchInteraction)
    }

    OnSwitchInteraction(Agent:agent):void=
    {
        TriggerAction(Agent)
    }

    CheckAllPressed(Agent:agent)<transacts>:logic=
    {  
        for (index->Switch : Switches):
            if (Switch.GetCurrentState[Agent] = false):
                return false
        return true
    }

    TriggerAction(Agent:agent):void=
    {
        Trigger.Trigger(Agent)
    }

    ForceToggleSwitch<public>(index:int, Agent:agent):void=
    {
        if (Switch:=Switches[index]):
            Switch.ToggleState(Agent)
    }

    ForceOffSwitch<public>(index:int, Agent:agent):void=
    {
        if (Switch:=Switches[index]):
            Switch.TurnOff(Agent)
    }

    GetSwitchArray<public>()<transacts>:[]switch_device=
    {
        return Switches
    }
}