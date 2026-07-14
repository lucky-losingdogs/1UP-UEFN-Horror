using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/SceneGraph }

throw_controller<public> := class<final_super>(component)
{
    @editable
    inputTrigger : input_trigger_device = input_trigger_device{}

    @editable
    projectile : creative_prop_asset = DefaultCreativePropAsset

    @editable
    var throwForce : float = 100.0

    @editable
    var maxDistance : float = 3000.0

    var isCarryingThrowable:logic = false

    OnBeginSimulation<override>():void=
    {
        (super:)OnBeginSimulation()
    }

    OnSimulate<override>()<suspends>:void =
    {
        inputTrigger.PressedEvent.Subscribe(OnThrowAction)
    }

    OnThrowAction(Agent : agent) : void=
    {
        if (isCarryingThrowable = false):
            Print("not carrying")
            return

        if(FC := Agent.GetFortCharacter[]):
            #get view rotation and view location (of char)
            viewRot := FC.GetViewRotation()
            viewLoc := FC.GetViewLocation()
            forwardVector := viewRot.GetLocalForward()
            spawnLoc := viewLoc + (forwardVector * 300.0)
            
            spawnResults := SpawnProp(projectile, spawnLoc, viewRot)
            if (spawnedProp := spawnResults(0)?):
                spawn {MoveProjectile(spawnedProp, forwardVector)}
                DisableThrowing()
    }

    MoveProjectile(prop : creative_prop, Direction : vector3)<suspends> : void=
    {
        var velocity : vector3 = Direction * throwForce
        var distance : float = 0.0
        gravity : float = 980.0

        loop:
            #if projectile reaches certain distance, destroy it
            if (distance >= maxDistance):
                prop.Dispose()
                break

            propTransform := prop.GetTransform()

            set velocity.Z -= gravity * 0.03
            newPos := propTransform.Translation + velocity * 0.03

            #move prop to new pos & update distance
            if (prop.TeleportTo[newPos, propTransform.Rotation]):
                CreateCast(propTransform)
                set distance += throwForce
                Sleep(0.03)
    }

    EnableThrowing():void=
    {
        set isCarryingThrowable = true
        Print("picked up")
    }

    DisableThrowing():void=
    {
        set isCarryingThrowable = false
    }

    CreateCast(propTransform:transform):void=
    {
        foundComponents := Entity.FindDescendantComponents(casting)
        for (Component : foundComponents):
            if (castingComponent := casting[Component]):
                castingComponent.CheckCollision(propTransform)
    }
}