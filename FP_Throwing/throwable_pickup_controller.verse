using { /Verse.org/SceneGraph }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

throwable_pickup_controller<public> := class<final_super>(component)
{
    @editable
    itemSpawner : item_spawner_device = item_spawner_device{}

    @editable
    itemRemover : item_remover_device = item_remover_device{}

    OnBeginSimulation<override>():void=
    {
        (super:)OnBeginSimulation()
    }

    OnSimulate<override>()<suspends>:void =
    {
        itemSpawner.ItemPickedUpEvent.Subscribe(OnPickUp)
    }

    #remove item from inventory and enable throwing
    OnPickUp(Agent:agent):void=
    {
        itemRemover.Remove(Agent)
        EnableThrowing()
    }

    EnableThrowing():void=
    {
        foundComponents := Entity.FindDescendantComponents(throw_controller)
        for (Component : foundComponents):
            if (throwComponent := throw_controller[Component]):
                throwComponent.EnableThrowing()
    }
}

    