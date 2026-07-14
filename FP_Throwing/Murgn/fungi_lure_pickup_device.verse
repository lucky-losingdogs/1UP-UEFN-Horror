
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# This script was created by Murgn
# https://github.com/Murgn

fungi_lure_pickup_device := class(creative_device):

    @editable ItemSpawners : []item_spawner_device = array{}
    @editable ItemGranters : []item_granter_device  = array{}
    @editable ItemRemover : item_remover_device = item_remover_device{}
    @editable LureDevice : fungi_lure_device = fungi_lure_device{}

    OnBegin<override>()<suspends>:void=
        for(Spawner : ItemSpawners):
            Spawner.ItemPickedUpEvent.Subscribe(OnPickUp)

        for(Spawner : ItemGranters):
            Spawner.ItemGrantedEvent.Subscribe(OnPickUp)

    OnPickUp(Agent:agent):void=
        ItemRemover.Remove(Agent)
        LureDevice.AddItem()
