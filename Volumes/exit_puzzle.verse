
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

exit_puzzle := class(volume_zone_parent)
{
    @editable PlayerSpawner : player_spawner_device = player_spawner_device{}
    @editable ResetVolumeOnSpawn : logic = false

    var VolumeDisabled : logic = false

    OnBegin<override>()<suspends>:void=
    {
        #Subscribes to the volume enter and exit events
        (super:) OnBegin()
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
    }

    #disables zones once the player has exited them so they can't be re-triggered
    OnExitZone<override>(Agent:agent):void=
    {
        for (zone:zones):
            DisableVolume(zone)
    }

    #enables volume by moving it back up into place
    EnableVolume(Volume:volume_device) : void=
    {
        var Pos : vector3 = Volume.GetTransform().Translation
        set Pos = vector3 {X := Pos.X, Y := Pos.Y + 10000.0, Z := Pos.Z}
        if(Volume.TeleportTo[Pos, Volume.GetTransform().Rotation]):
            Print("Enabled")   
            set VolumeDisabled = false     
    }

    #disables volume by moving it downwards
    DisableVolume(Volume:volume_device) : void=
    {
        var Pos : vector3 = Volume.GetTransform().Translation
        set Pos = vector3 {X := Pos.X, Y := Pos.Y - 10000.0, Z := Pos.Z}
        if(Volume.TeleportTo[Pos, Volume.GetTransform().Rotation]):
            Print("Disabled")
            set VolumeDisabled = true
    }

    OnPlayerSpawn(Agent:agent):void=
    {
        #if the zones should be reset if the player respawns and if zones has previously been disabled re-enable zones
        if (VolumeDisabled = true and ResetVolumeOnSpawn = true):
            for (zone:zones):
                EnableVolume(zone)
    }
}