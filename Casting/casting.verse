using { /Fortnite.com }
using { /Fortnite.com/Devices }
using { /Verse.org }
using { /Verse.org/SceneGraph }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/SpatialMath }
XYZ<public> := import(/UnrealEngine.com/Temporary/SpatialMath)

debugDraw := class(debug_draw_channel) {}

casting<public> := class<final_super>(component)
{
    DebugDraw:debug_draw = debug_draw{Channel := debugDraw}

    CheckCollision<public>(propTransform:XYZ.transform):void=
    {
        ViewRot := XYZ.FromRotation(propTransform.Rotation)
        ViewXFrom := transform:
            Translation := XYZ.FromVector3(propTransform.Translation)
            Rotation := ViewRot

        HitsGen := Entity.FindSweepHits(ViewXFrom.Rotation.GetForwardAxis() * 1.0, ViewXFrom, collision_sphere{Radius:=500.0})
        #for every hit generationed, do hit
        #store sweep hits in array form
        HitsArray := for(Hit:HitsGen) do Hit
        
        #draw line for first hit
        if(FirstHit := HitsArray[0]):
            DebugDraw.DrawSphere(Center:= FirstHit.ContactPosition)
            Print("first hit: {FirstHit.ContactPosition}")
            if(Box:=Meshes.Capsule_163D472E[FirstHit.TargetComponent]):
                Print("Hit capsule mesh!")

    }
}