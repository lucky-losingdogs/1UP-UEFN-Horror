
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

target_collision := class(AI.fungi_lure_device)
{
    var CollidedIndex : int = 0
    var hitTargets:int = 0

    @editable
    trigger : trigger_device = trigger_device{}

    Collides<override>(Prop : transform) : logic =
    {
        var Colliding : logic = false
        for (Index := 0..Bounds.Length - 1):
            if (Element := Bounds[Index]):
                DoesCollide := AABB(Prop, Element.GetTransform())
                if(DoesCollide?):
                    set Colliding = true
                    set CollidedIndex = Index
        return Colliding
    }

    HandleCollision<override>(Prop : creative_prop, Agent : agent):void=
    {
        Print("target hit!")
        if (Bound := Bounds[CollidedIndex]):
            Bound.Dispose()
            Prop.Dispose()
            set hitTargets += 1

        if (hitTargets >= Bounds.Length):
            HandleTargetsHit(Agent)
    }

    HandleTargetsHit<public>(Agent : agent):void=
    {
        Print("All targets hit!")
        trigger.Trigger(Agent)
    }
}