using { /Fortnite.com/AI }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Concurrency }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Verse.org/Random }

# This script was created by Murgn
# https://github.com/Murgn

FungiStates := enum{ Idle, Chase, Frozen }

fungi_perception := struct:
    PlayerDist : float
    PlayerLooking : logic
    TargetPos : vector3
    CautionDistance : float

# Seperate variables into structs to make it look nicer in editor 
fungi_npc_behaviour := class(npc_behavior):

    @editable var DetectionRadius : float = 900.0
    @editable var CautionDistance : float = 250.0
    @editable var LureCautionDistance : float = 0.0
    @editable var FleeDistance : float = 195.0
    @editable var LookThreshold : float = 0.35
    @editable var SleepRate : float = 0.1
    @editable var Poses : []mesh = array{}
    @editable var NpcMimic : creative_prop_asset = DefaultCreativePropAsset
    @editable var MimicOffset : vector3 = vector3{}
    @editable var MimicRotationOffset : rotation = rotation{}
    @editable var MimicSizeVariance : float = 0.25
    @editable var debug : logic = true
    var Prop : creative_prop = creative_prop{}
    
    var TargetOverride : ?creative_object_interface = false
    var Disablers : []vector3 = array{} # i have to use positions because you can't compare a creative_device and Self, i hate you verse
    var Lures : []creative_object_interface = array{}

    NpcAssistant : fungi_npc_assistant = fungi_npc_assistant{}

    var CurrentState : FungiStates = FungiStates.Idle
    var StateVersion : int = 0

    # do not touch this, only read from it
    var IsFrozen : logic = false
    var IsLured : logic = false

    var SpawnLocation : vector3 = vector3{}

    var BreakMimic : logic = false

    # Initialises values, begins the state loop
    OnBegin<override>()<suspends> : void =
        if:
            NpcAgent := GetAgent[]
            NpcFortChar := NpcAgent.GetFortCharacter[]
            NpcNav := NpcFortChar.GetNavigatable[]
            NpcFocus := NpcFortChar.GetFocusInterface[]
            Player := NpcAssistant.GetFirstPlayer[]
            AnimController := NpcFortChar.GetPlayAnimationController[]
        then:
            # Verse can't access NPC's static meshes, so I spawn a creative_prop that teleports to the npc every frame
            NpcFortChar.Hide()
            SpawnedProp := SpawnProp(NpcMimic, vector3{X:= 0.0, Y:= -1000.0, Z:= 0.0}, rotation{})
            PropInstance := SpawnedProp(0)
            Transform := NpcFortChar.GetTransform()
            
            set SpawnLocation = Transform.Translation

            if ( MaybeProp := PropInstance?):
                set Prop = MaybeProp

                # Randomises scale slightly to make them visually interesting, apparently we use TeleportTo to set the new transform? weird
                Variance := 1.0 + GetRandomFloat(-(MimicSizeVariance / 2.0), (MimicSizeVariance / 2.0))
                PropTransform := Prop.GetTransform()
                NewTransform := transform { Translation := PropTransform.Translation, Rotation:= PropTransform.Rotation, Scale := PropTransform.Scale * Variance }
                if(Prop.TeleportTo[NewTransform]):

                spawn { MimicNPCPosition(NpcFortChar) }
                RandomiseMimicMesh()                
                    
            loop:
                Sleep(SleepRate)

                if (not NpcFortChar.IsActive[]):
                    break

                Perception := Perceive(NpcFortChar, Player)
                NewState := EvaluateTransition(Perception)

                if (NewState <> CurrentState):
                    Transition(NewState, NpcNav)
                    case (NewState):
                        FungiStates.Idle   => spawn { IdleBehaviour(NpcNav, StateVersion) }
                        FungiStates.Chase  => spawn { ChaseBehaviour(NpcFortChar, NpcNav, Player, StateVersion) }
                        FungiStates.Frozen => spawn { FrozenBehaviour(NpcNav, AnimController, StateVersion) }
                
                # Log("State: {NpcAssistant.StateToString(CurrentState)}  Dist: {Perception.PlayerDist}  Looking: {NpcAssistant.LogicToString(Perception.PlayerLooking)}")


    # Calculates values that are needed for that frame
    Perceive(NpcFortChar : fort_character, Player : fort_character) : fungi_perception =
        NpcPos := NpcFortChar.GetTransform().Translation
        var CDist : float = CautionDistance

        var TargetPos : vector3 = vector3{}
        set TargetPos = NpcAssistant.GetTargetPos(Player, TargetOverride)
        
        var Looking : logic = false
        set Looking = NpcAssistant.IsLookingAtLocation(Player, NpcPos, LookThreshold)
        if(Disablers.Length > 0): ## Overrides looking if any disablers are on the NPC
            set Looking = true
            
        # Log("{Lures.Length}")    
        if(Lures.Length > 0):
            set IsLured = true
            set CDist = LureCautionDistance
            if(Lure := NpcAssistant.LocateNearestObject[Lures, NpcPos]):
                set TargetPos = RemoveBrokenLure(Lure.GetTransform().Translation, NpcPos)
        else:
            set IsLured = false
                
        Dist := Distance(NpcPos, TargetPos)

        set IsFrozen = Looking

        return fungi_perception{ PlayerDist := Dist, PlayerLooking := Looking , TargetPos := TargetPos, CautionDistance := CDist }

    # Evalues the transition ¯\(ツ)/¯
    EvaluateTransition(Perception : fungi_perception) : FungiStates =
        if (Perception.PlayerLooking?):
            return FungiStates.Frozen

        if (CurrentState = FungiStates.Frozen):
            return FungiStates.Chase

        if (Perception.PlayerDist <= DetectionRadius and Perception.PlayerDist > CautionDistance):
            return FungiStates.Chase

        return CurrentState

    ## You'll never guess what this does
    Transition(NewState : FungiStates, NpcNav : navigatable) : void =
        set CurrentState = NewState
        set StateVersion += 1

        if (NewState = FungiStates.Frozen):
            NpcNav.StopNavigation()

    ## If we've transitioned to a new state return back to the state loop
    IdleBehaviour(NpcNav : navigatable, Version : int)<suspends> : void =
        NpcNav.StopNavigation()
        loop:
            Sleep(SleepRate)
            if (Version <> StateVersion):
                break

    ## Navigates to the target
    ## TODO: Navigation is still kinda janky, last resort I could loop for a second setting the agents position to make sure its still?
    ChaseBehaviour(NpcFortChar : fort_character, NpcNav : navigatable, Player : fort_character, Version : int)<suspends> : void =
        var LastDest : vector3 = vector3{}
        loop:
            Sleep(SleepRate)
            if (Version <> StateVersion): 
                break

            NpcPos := NpcFortChar.GetTransform().Translation
            Perception := Perceive(NpcFortChar, Player)
            Dir := NpcPos - Perception.TargetPos

            # if (Direction := Dir.MakeUnitVector[]):
            #     Destination := TargetPos + (Direction * CautionDistance)
            #     spawn { Navigate(NpcNav, Destination, Version) }

            # testing without navigate, its being weird rn
            if (Direction := Dir.MakeUnitVector[]):
                var Destination : vector3 = Perception.TargetPos + (Direction * Perception.CautionDistance)
                if (Distance(Destination, SpawnLocation) > 100000.0):
                    Print("NPC too far away spawn:{SpawnLocation}dest:{Destination}")
                    set Destination = SpawnLocation

                if (Distance(Destination, LastDest) > 50.0):
                    set LastDest = Destination
                    NpcNav.StopNavigation()
                    NavTarget := MakeNavigationTarget(Destination)
                    
                    race:
                        NpcNav.NavigateTo(NavTarget)
                        loop:
                            Sleep(0.0)
                            if (Version <> StateVersion):
                                break

    # Same as idle, not sure if I want it to do anything different yet
    FrozenBehaviour(NpcNav : navigatable, AnimController : play_animation_controller, Version : int)<suspends> : void =
        NpcNav.StopNavigation()
        RandomiseMimicMesh()
        loop:
            set IsFrozen = true
            Sleep(SleepRate)
            if (Version <> StateVersion): 
                break

    ## Navigates once, if we're on a different state stops navigation
    Navigate(NpcNav : navigatable, Destination : vector3, Version : int)<suspends> : void =
        race:
            block:
                NavTarget := MakeNavigationTarget(Destination)
                NpcNav.NavigateTo(NavTarget)
            block:
                loop:
                    Sleep(0.0)
                    if (Version <> StateVersion):
                        NpcNav.StopNavigation()
                        break
    
    MimicNPCPosition(NpcFortChar : fort_character)<suspends>:void =
        loop:
            if (BreakMimic = true):
                set BreakMimic = false
                break

            Transform := NpcFortChar.GetTransform()
            if (Prop.TeleportTo[Transform.Translation + MimicOffset, Transform.Rotation.RotateBy(MimicRotationOffset)]):
                
            else:
            Sleep(0.0)

    RandomiseMimicMesh():void=
        if(Mesh := Poses[GetRandomInt(0, Poses.Length)]):
            Prop.SetMesh(Mesh)

            # Random Z Flipping
            PropTransform := Prop.GetTransform()
            var Scale : vector3 = PropTransform.Scale
            Flip := GetRandomInt(0, 1)
            
            if(Flip = 0):
                set Scale = vector3 { X := Scale.X, Y := Scale.Y, Z := Scale.Z}
            else:
                set Scale = vector3 { X := Scale.X * -1, Y := Scale.Y, Z := Scale.Z}
            
            NewTransform := transform {Translation := PropTransform.Translation, Rotation := PropTransform.Rotation, Scale := Scale}
            if(Prop.TeleportTo[NewTransform]):
                # Sets the transform
    
    RemoveBrokenLure(LurePos : vector3, NpcPos : vector3)<transacts>:vector3=
    {
        Origin : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
        if (LurePos = Origin):
            Print ("Lure in array is destroyed")
            var NewLures : []creative_object_interface = array{}
            for (Lure : Lures):
                if (Lure.GetTransform().Translation = LurePos):

                else:
                    set NewLures = NewLures + array{Lure}
            set Lures = NewLures

            if(Lure := NpcAssistant.LocateNearestObject[Lures, NpcPos]):
                return Lure.GetTransform().Translation
        return LurePos
    }

    Log(Message : string):void=
        if(debug?):
            Print(Message)


    