using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/AI }
using { /Verse.org/SceneGraph }

# This script was created by Murgn
# https://github.com/Murgn

fungi_lure_device<public> := class(creative_device):

    @editable Input : input_trigger_device = input_trigger_device{}
    @editable Projectile : creative_prop_asset = DefaultCreativePropAsset

    @editable NpcSpawner : npc_spawner_device = npc_spawner_device{}
    var Npcs : []fungi_npc_behaviour = array{}

    @editable Bounds <protected>  : []creative_prop = array{}
    @editable var PropScale : float = 0.5
    @editable var PropColliderScale : float = 0.5

    @editable var Gravity : float = 9.8
    @editable var ThrowForce : float = 100.0
    @editable var MaxDistance : float = 3000.0

    var Clicked : logic = false
    var ItemCount : int = 0
    var isCarryingThrowable:logic = false

    OnBegin<override>()<suspends> : void=
        NpcSpawner.SpawnedEvent.Subscribe(OnNPCSpawned)
        Input.PressedEvent.Subscribe(OnPressed)
        Input.ReleasedEvent.Subscribe(OnReleased)

    OnNPCSpawned(SpawnedAgent : agent):void=
        if:
            BehaviorInstance := SpawnedAgent.GetNPCBehavior[]
            CustomBehaviour := fungi_npc_behaviour[BehaviorInstance]
        then:
            set Npcs = Npcs + array{CustomBehaviour}
            set CustomBehaviour.debug = true

    OnPressed(Agent : agent) : void=
        if(Clicked = false, isCarryingThrowable = true):
            OnThrowAction(Agent)

        set Clicked = true
    
    OnReleased(Agent : tuple(agent, float)) : void=
        set Clicked = false

    OnThrowAction(Agent : agent) : void=
        if(FC := Agent.GetFortCharacter[]):
            FC.GetTransform()
            Rot := FC.GetViewRotation()
            Loc := FC.GetViewLocation()
            Forward := Rot.GetLocalForward()
            SpawnLoc := Loc + (Forward * 150.0)   
            
            PropTransform := transform{
                Translation := SpawnLoc,
                Rotation := Rot,
                Scale := vector3{X := PropScale, Y := PropScale, Z := PropScale}
            }

            SpawnResults := SpawnProp(Projectile, PropTransform)

            if (SpawnedProp := SpawnResults(0)?):
                spawn { DestroyAfter(SpawnedProp, 10.0) }
                spawn { MoveProjectile(SpawnedProp, Forward, Agent) }
                for(Npc : Npcs):
                    set Npc.Lures = Npc.Lures + array{SpawnedProp}
                
                RemoveItem()


    MoveProjectile(Prop : creative_prop, Direction : vector3, Agent : agent)<suspends> : void=
        var Velocity : vector3 = Direction * ThrowForce
        var PropDistance : float = 0.0

        if(FC := Agent.GetFortCharacter[], FortTransform := FC.GetTransform()):
            var LastPosition : vector3 = vector3{}
            loop:
                if (PropDistance >= MaxDistance):
                    Prop.Dispose()
                    break
                    
                PropTransform := Prop.GetTransform()
                DoesCollide := Collides(PropTransform)
                
                if(DoesCollide?):
                    HandleCollision(Prop, Agent)
                    if(Prop.TeleportTo[LastPosition, FortTransform.Rotation]): # Teleport back to previous pos if collides

                    break
                    
                set LastPosition = PropTransform.Translation
                set Velocity.Z -= Gravity
                NewPos := PropTransform.Translation + Velocity
                    
                # trying to make throwables move smoother
                if(Prop.TeleportTo[NewPos, FortTransform.Rotation]):
                    set PropDistance += Distance(FC.GetTransform().Translation, Prop.GetTransform().Translation)

                Sleep(0.01) 

    DestroyAfter(Prop : creative_prop, Seconds : float)<suspends> : void=
        Sleep(Seconds)
        PropPosition := Prop.GetTransform().Translation
        for(Npc : Npcs):
            set Npc.Lures = RemovePropFromArrayByPos(Npc.Lures, PropPosition)
        Prop.Dispose()

    AddItem():void=
        set ItemCount = Clamp(ItemCount + 1, 0, 255)
        set isCarryingThrowable = logic{ItemCount > 0}

    RemoveItem():void=
        set ItemCount = Clamp(ItemCount - 1, 0, 255)
        set isCarryingThrowable = logic{ItemCount > 0}

    ClearInventory<public>():void=
    {
        for (i := 1..ItemCount ):
            RemoveItem()
    }
        
    Collides<protected>(Prop : transform) : logic =
        var Colliding : logic = false
        for (Index := 0..Bounds.Length - 1):
            if (Element := Bounds[Index]):

                # Adjusting prop's scale by propscale
                PropTransform := transform{
                    Translation := Prop.Translation,
                    Rotation := Prop.Rotation,
                    Scale := Prop.Scale * PropColliderScale
                }

                DoesCollide := AABB(PropTransform, Element.GetTransform())
                if(DoesCollide?):
                    set Colliding = true
        return Colliding

    AABB<protected>(A : transform, B : transform) : logic =
        PosA : vector3 = A.Translation
        HalfA : vector3 = A.Scale / 2.0 * 100.0 # multiplying by 100 because uefn units are dumb and scaled by 100 
        
        PosB : vector3 = B.Translation
        HalfB : vector3 = B.Scale / 2.0 * 100.0

        # Print("PosA {PosA}, HalfA{HalfA}, PosB{PosB}, HalfB{HalfB}")
        
        DX := Abs(PosA.X - PosB.X)
        DY := Abs(PosA.Y - PosB.Y)
        DZ := Abs(PosA.Z - PosB.Z)

        # Print("DX {DX}, DY{DY}, DZ{DZ}")
        
        var DoesCollide : logic = false
        if(DX <= HalfA.X + HalfB.X, DY <= HalfA.Y + HalfB.Y, DZ <= HalfA.Z + HalfB.Z):
            set DoesCollide = true

        return DoesCollide

    HandleCollision<protected>(Prop : creative_prop, Agent : agent):void=
    {
        Print("collided!")
    }

    # please can verse just be a normal language this sucks
    RemovePropFromArrayByPos(Array : []creative_object_interface, Position : vector3) : []creative_object_interface =
        for (Elem : Array, Distance(Elem.GetTransform().Translation, Position) > 0.1): # using a tolerance because i dont trust uefn to be normal
            Elem

    # only use this for indexes, i cba to put this code anywhere else
    RemoveIntFromArrayAt(Array : []int, Index : int) : []int =
        for (I -> Elem : Array, I <> Index):
            if (I > Index):
                Elem - 1
            else:
                Elem
