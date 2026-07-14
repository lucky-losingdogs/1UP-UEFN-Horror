using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }

fungi_target_interact_switch_device<public> := class(fungi_target_interact_test_device)
{
    #Ignore Prop var in the parent class and assign to this
    #Props must be placed near where the switches are and assigned in the array in the same order as the switches
    @editable
    Props:[]creative_prop = array{}

    @editable
    SwitchSequence:switch_sequence_any = switch_sequence_any{}

    #set true for fungus to toggle switches on/off
    @editable
    var ToggleSwitch : logic = false

    #set true for fungus to only turn switches off
    @editable
    var OffSwitch : logic = true

    var Switches:[]switch_device = array{}
    var ChosenPropIndex:int = 0

    OnBegin<override>()<suspends>:void=
    {
        (super:) OnBegin()
        CopySwitchArray()

        if (ToggleSwitch = false):
            set OffSwitch = true
        else:
           set OffSwitch = false 
    }

    OnNPCSpawned<override>(SpawnedAgent : agent):void=
        if:
            BehaviorInstance := SpawnedAgent.GetNPCBehavior[]
            CustomBehaviour := fungi_npc_behaviour[BehaviorInstance]
        then:
            set MaybeBehaviour = option{CustomBehaviour}

            # Sets NPCs target to our prop
            if(Behaviour := MaybeBehaviour?):
                MaybeProp := ChooseRandomProp() # Should add something to choose a different prop each time (or move to Timer)
                if(ChosenProp := MaybeProp?):
                    spawn {Timer(Behaviour, ChosenProp)}

    Interact<override>(Agent : agent,Behaviour:fungi_npc_behaviour)<suspends>:void=

        # Begin
        set IsInteracting = true
        Sleep(GetRandomFloat(1.0, 2.0)) # Feel free to param / serialize this
        # Freeze NPC
        
        set Behaviour.Disablers = Behaviour.Disablers + array{ GetTransform().Translation }

        # Interact
        Sleep(InteractionDuration)

        InteractSwitch(Agent)
        
        # End
        # Unfreeze NPC
        if:
            Index := Behaviour.Disablers.Find[GetTransform().Translation]
            NewDisablers := Behaviour.Disablers.RemoveElement[Index]
        then:
            set Behaviour.Disablers = NewDisablers
            set Behaviour.TargetOverride = false
            set IsInteracting = false

    InteractSwitch(Agent:agent):void=
    {
        if (ToggleSwitch = true):
            SwitchSequence.ForceToggleSwitch(ChosenPropIndex, Agent)
        else if (OffSwitch = true):
            SwitchSequence.ForceOffSwitch(ChosenPropIndex, Agent)      
    }

    Timer<override>(Behaviour:fungi_npc_behaviour, ChosenProp:creative_prop)<suspends>:void=
    {
        #Continue following the player before setting prop target
        loop:
            if (BreakTimer = true):
                return

            Sleep(GetRandomFloat(PlayerFollowDuration - 1.5, PlayerFollowDuration + 1.5))
            set Behaviour.TargetOverride = option{ChosenProp}
            
    }

    #Copy the array of switches in the switch sequence device
    CopySwitchArray():void=
    {
        set Switches = SwitchSequence.GetSwitchArray()
    }

    #Choose a random target Prop from the array of Props
    #Assign the Prop's index as the index to be used for the switch
    ChooseRandomProp()<transacts>:?creative_prop=
    {
        index:int = GetRandomInt(0, Props.Length)
        if (ChosenProp := Props[index]):
            set ChosenPropIndex = index
            return option{ChosenProp}
        else:
            return false
    }
}