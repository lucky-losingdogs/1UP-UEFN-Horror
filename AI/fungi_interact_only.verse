using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }

fungi_interact_only<public> := class(creative_device)
{
    @editable Prop : creative_prop = creative_prop{}

    @editable
    var InteractionDuration : float = 2.0

    @editable NPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable PlayerSpawner : player_spawner_device = player_spawner_device{}
    
    var IsInteracting : logic = false
    var BreakTimer : logic = false

    var NPC : ?agent = false
    var NPCBehaviour : fungi_npc_behaviour = fungi_npc_behaviour{}

    OnBegin<override>()<suspends>:void=
    {
        NPCSpawner.SpawnedEvent.Subscribe(OnNPCSpawned)
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
    }

    OnNPCSpawned(SpawnedAgent : agent):void=
    {
        if:
            BehaviorInstance := SpawnedAgent.GetNPCBehavior[]
            Behaviour := fungi_npc_behaviour[BehaviorInstance]
        then:
            set Behaviour.TargetOverride = option{Prop}
            
            set NPC = option{SpawnedAgent}
            set NPCBehaviour = Behaviour

            spawn {Timer(SpawnedAgent, Behaviour)}
    }

    Interact(Agent : agent,Behaviour:fungi_npc_behaviour)<suspends>:void=

        # Begin
        set IsInteracting = true

        # Interact
        Sleep(InteractionDuration)

        if (Behaviour.IsLured?):
            Print("lured")
        if (Behaviour.IsFrozen = false and Behaviour.IsLured = false):
            InteractionBehaviour(Agent)

        set IsInteracting = false

    InteractionBehaviour(Agent:agent):void=
    {   
    }

    Timer(Agent:agent,Behaviour:fungi_npc_behaviour)<suspends>:void=
    {
        loop:
            if (BreakTimer = true):
                return

            Sleep(0.0)

            if (IsInteracting = false and Behaviour.IsFrozen = false and Behaviour.IsLured = false):
                spawn { Interact(Agent,Behaviour) }
    }

    OnPlayerSpawn(Agent:agent):void=
    {
        if(SpawnedAgent := NPC?):
            Print("spawned agent is saved npc")
            SetBreakTimer(false)
            spawn {Timer(SpawnedAgent, NPCBehaviour)}
    }

    SetBreakTimer<public>(value:logic):void=
    {
        set BreakTimer = value
    }
}