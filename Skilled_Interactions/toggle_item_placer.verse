
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/SpatialMath }
using { /Verse.org/Assets }

toggle_item_placer := class(creative_device)
{
    @editable
    SkilledInteraction:skilled_interaction_device = skilled_interaction_device{}

    @editable
    ItemPlacer:item_placer_device = item_placer_device{}

    @editable
    var MoveX:float = 0.0

    OnBegin<override>()<suspends>:void=
    {
        SkilledInteraction.InteractionSucceededEvent.Subscribe(OnSuccess)
    }

    OnSuccess(Agent:agent):void=
    {
        Transform:=ItemPlacer.GetGlobalTransform()
        ForwardVec := Transform.Rotation.GetForwardAxis()
        LeftVec := Transform.Rotation.GetLeftAxis()
        UpVec := Transform.Rotation.GetUpAxis()

        NewTranslation := Transform.Translation + (ForwardVec * MoveX) + (LeftVec * 0.0) + (UpVec * 0.0)
        NewTransform := transform
        {
            Translation := NewTranslation
            Rotation := Transform.Rotation
        }

        if (ItemPlacer.TeleportTo[NewTransform]){}
    }
}