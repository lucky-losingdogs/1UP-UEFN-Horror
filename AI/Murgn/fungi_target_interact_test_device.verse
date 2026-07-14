using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }

# This script was created by Murgn
# https://github.com/Murgn

fungi_target_interact_test_device <public>:= class(creative_device):

    # Put Volume around Prop
    @editable Prop : creative_prop = creative_prop{}
    @editable Volume : volume_device = volume_device{}

    @editable NpcSpawner : npc_spawner_device = npc_spawner_device{}

    @editable PropCautionDistance : float = 10.0
    @editable var InteractionDuration : float = 2.0
    @editable var PlayerFollowDuration : float  = 10.0
    
    var MaybeBehaviour : ?fungi_npc_behaviour = false
    var PlayerCautionDistance : float = -1.0

    var BreakTimer:logic = false
    var IsInteracting:logic = false

    OnBegin<override>()<suspends>:void=
        NpcSpawner.SpawnedEvent.Subscribe(OnNPCSpawned)
        Volume.AgentEntersEvent.Subscribe(OnVolumeEntered)
        Volume.AgentExitsEvent.Subscribe(OnVolumeExited)
         
## NPC
    OnNPCSpawned(SpawnedAgent : agent):void=
        if:
            BehaviorInstance := SpawnedAgent.GetNPCBehavior[]
            CustomBehaviour := fungi_npc_behaviour[BehaviorInstance]
        then:
            set MaybeBehaviour = option{CustomBehaviour}

            # Sets NPCs target to our prop
            if(Behaviour := MaybeBehaviour?):
                spawn {Timer(Behaviour, Prop)}

## VOLUMES
    OnVolumeEntered(Agent : agent):void=
        if(Behaviour := MaybeBehaviour?):
            if(PlayerCautionDistance <> -1.0):
                set PlayerCautionDistance = Behaviour.CautionDistance
            
            set Behaviour.CautionDistance = PropCautionDistance
            if (IsInteracting = false and Behaviour.IsFrozen = false):
                spawn { Interact(Agent,Behaviour) }

    OnVolumeExited(Agent : agent):void=
        if(Behaviour := MaybeBehaviour?):
            set Behaviour.CautionDistance = PlayerCautionDistance
            set Behaviour.TargetOverride = false
            set IsInteracting = false

## INTERACTION    
    Interact(Agent : agent, Behaviour:fungi_npc_behaviour)<suspends>:void=

        # Begin
        set IsInteracting = true
        Sleep(GetRandomFloat(1.0, 2.0)) # Feel free to param / serialize this
        # Freeze NPC
        set Behaviour.Disablers = Behaviour.Disablers + array{ GetTransform().Translation }

        # Interact
        Sleep(InteractionDuration)

        ###
        # Stick ur interaction code here
        ###
        
        # End
        # Unfreeze NPC
        if:
            Index := Behaviour.Disablers.Find[GetTransform().Translation]
            NewDisablers := Behaviour.Disablers.RemoveElement[Index]
        then:
            set Behaviour.Disablers = NewDisablers
            set Behaviour.TargetOverride = false
            set IsInteracting = false

    #Continue following the player before setting prop target
    Timer(Behaviour:fungi_npc_behaviour, ChosenProp:creative_prop)<suspends>:void=
    {
        loop:
            if (BreakTimer = true):
                return

            Sleep(GetRandomFloat(PlayerFollowDuration - 1.5, PlayerFollowDuration + 1.5))
            set Behaviour.TargetOverride = option{Prop}
    }

    #Use an external trigger to break the Timer to prevent continual behaviour
    SetBreakTimer<public>(value:logic):void=
    {
        set BreakTimer = value
    }

    GetNPCSpawner<public>()<transacts>:npc_spawner_device=
    {
        return NpcSpawner
    }