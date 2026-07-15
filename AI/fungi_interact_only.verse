using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

fungi_interact_only<public> := class(creative_device)
{
    @editable Prop : creative_prop = creative_prop{}

    @editable
    var InteractionDuration : float = 2.0

    @editable NPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable PlayerSpawner : player_spawner_device = player_spawner_device{}

    @editable SpawnLocation : ?creative_prop = option{creative_prop{}}

    @editable ResetButton : ?button_device = option{button_device{}}
    
    var IsInteracting : logic = false
    var BreakTimer : logic = false

    var NPC : ?agent = false
    var NPCBehaviour : fungi_npc_behaviour = fungi_npc_behaviour{}

    OnBegin<override>()<suspends>:void=
    {
        NPCSpawner.SpawnedEvent.Subscribe(OnNPCSpawned)
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        if (ResetButt := ResetButton?):
            ResetButt.InteractedWithEvent.Subscribe(Reset)
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

            if (NewLocation := SpawnLocation?):
                MoveToSpawn(SpawnedAgent, NewLocation)

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

    MoveToSpawn(NPCAgent : agent, Location : creative_prop):void=
    {
        if (FC := NPCAgent.GetFortCharacter[], PropTransform := Location.GetTransform()):
            Print("OnNpcSpawned, attempting to spawn at {PropTransform.Translation.X}, {PropTransform.Translation.Y}")
            if (FC.TeleportTo[PropTransform.Translation, PropTransform.Rotation]):
                Print("Spawned!")
    }

    Reset(Agent:agent):void=
    {
        NPCBehaviour.DestroyMimic()
        if:
            Npc := NPC?
            FC := Npc.GetFortCharacter[]
        then:
            var Pos : vector3 = FC.GetTransform().Translation
            set Pos = vector3 {X := Pos.X, Y := Pos.Y - 10000.0, Z := Pos.Z}

            if (FC.TeleportTo[Pos, FC.GetTransform().Rotation]):
                spawn {WaitToDespawn()}
    }

    WaitToDespawn()<suspends>:void=
    {
        Sleep(0.2)
        NPCSpawner.DespawnAll(false)
        NPCSpawner.Spawn()
    }
}