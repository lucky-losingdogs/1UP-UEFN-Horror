using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/AI }
using { /Verse.org/Random }

fungi_target_interact_switch_device_2<public> := class(fungi_interact_only)
{
    @editable
    SwitchSequence:switch_sequence_any = switch_sequence_any{}

    @editable
    MushroomAudioPlayer:audio_player_device = audio_player_device{}

    #set true for fungus to toggle switches on/off
    @editable
    var ToggleSwitch : logic = false

    #set true for fungus to only turn switches off
    @editable
    var OffSwitch : logic = true

    OnBegin<override>()<suspends>:void=
    {
        if (ToggleSwitch = false):
            set OffSwitch = true
        else:
           set OffSwitch = false 

        (super:) OnBegin()
    }

    InteractionBehaviour<override>(Agent:agent):void=
    {
        if (ToggleSwitch = true):
            SwitchSequence.ForceToggleSwitch(0, Agent)
            MushroomAudioPlayer.Play()
        else if (OffSwitch = true):
            SwitchSequence.ForceOffSwitch(0, Agent)
            MushroomAudioPlayer.Play() 
    }
}