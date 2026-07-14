using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

place_lure := class(creative_device)
{
    @editable
    ConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    LureProp : creative_prop_asset = DefaultCreativePropAsset

    @editable
    var MaxDistance:float = 50.0

    OnBegin<override>()<suspends>:void=
    {
        ConditionalButton.ActivatedEvent.Subscribe(OnActivated)
    }

    OnActivated(Agent : agent):void=
    {
        spawnRot := ConditionalButton.GetTransform().Rotation
        up := spawnRot.GetLocalUp()
        spawnLoc := ConditionalButton.GetTransform().Translation + (up * 50.0)

        spawnResults := SpawnProp(LureProp, spawnLoc, spawnRot)

       if (spawnedProp := spawnResults(0)?):
            spawn {MoveProp(spawnedProp, -up)}
    }

    MoveProp(Prop : creative_prop, DownDir : vector3)<suspends> : void=
    {
        var velocity : vector3 = DownDir * 9.8
        var distance : float = 0.0
        
        loop:
            if (distance >= MaxDistance):
                break

            propTransform := Prop.GetTransform()
            set velocity.Z -= 9.8 * 0.03
            newPos := propTransform.Translation + velocity * 0.03

            #move prop to new pos & update distance
            if (Prop.TeleportTo[newPos, propTransform.Rotation]):
                set distance += 9.8
                Sleep(0.03)
    }
}