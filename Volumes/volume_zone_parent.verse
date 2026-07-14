
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

volume_zone_parent := class(creative_device)
{
    @editable
    zones:[]volume_device = array{}

    OnBegin<override>()<suspends>:void=
    {
        for(zone:zones):
            zone.AgentEntersEvent.Subscribe(OnEnterZone)
            zone.AgentExitsEvent.Subscribe(OnExitZone)
    }

    #when player enters zone
    OnEnterZone(Agent : agent):void=
    {
        Print("agent entered zone")
    }
        
    #when player exits zone
    OnExitZone(Agent : agent):void=
    {
        Print("agent exited  zone")
    }
}