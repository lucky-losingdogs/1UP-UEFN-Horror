using { /Verse.org/SpatialMath }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

hide_gas := class(creative_device)
{
    @editable
    Trigger : trigger_device = trigger_device{}

    @editable
    ItemPlacer : item_placer_device = item_placer_device{}

    OnBegin<override>():void=
    {
        Trigger.TriggeredEvent.Subscribe(OnItemGranted)
    }

    OnItemGranted(Agent:?agent):void=
    {
        Transform:=ItemPlacer.GetGlobalTransform()
        ForwardVec := Transform.Rotation.GetForwardAxis()
        LeftVec := Transform.Rotation.GetLeftAxis()
        UpVec := Transform.Rotation.GetUpAxis()

        NewTranslation := Transform.Translation + (ForwardVec * 0.0) + (LeftVec * 0.0) + (UpVec * -1000.0)
        Print("{NewTranslation}")
        NewTransform := transform
        {
            Translation := NewTranslation
            Rotation := Transform.Rotation
        }

        if (ItemPlacer.TeleportTo[NewTransform]){}
    }
}