
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

button_swapper := class(creative_device)
{
    @editable
    displayButtons:[]conditional_button_device = array{}

    @editable
    invisibleButton:conditional_button_device  = conditional_button_device{}

    @editable
    visibleButton:conditional_button_device  = conditional_button_device{}

    var invisibleTransform:transform = transform{}
    var visibleTransform:transform = transform{}

    var currentIndex:int = 0

    OnBegin<override>():void=
    {
        set invisibleTransform = invisibleButton.GetTransform()
        set visibleTransform = visibleButton.GetTransform()
    }

    IncrementButtons():void=
    {
        prevIndex := currentIndex
        set currentIndex = ClampIndex(1)
        Print("{prevIndex}")
        Print("{currentIndex}")
        SwapButtons(prevIndex, currentIndex)
    }

    DecrementButtons():void=
    {
        prevIndex := currentIndex
        set currentIndex = ClampIndex(-1)
        Print("{prevIndex}")
        Print("{currentIndex}")
        SwapButtons(prevIndex, currentIndex)
    }

    SwapButtons(hide:int, show:int):void=
    {
        spawn {HideButton(hide)}
        spawn {ShowButton(show)}
    }

    HideButton(index:int)<suspends>:void=
    {
        if (button := displayButtons[index]):
            button.MoveTo(invisibleTransform, 0.0)
    }

    ShowButton(index:int)<suspends>:void=
    {
        if (button := displayButtons[index]):
            button.MoveTo(visibleTransform, 0.0)
    }

    ClampIndex(change:int)<transacts>:int=
    {
        newIndex := currentIndex + change

        if (newIndex >= displayButtons.Length):
            return displayButtons.Length - 1
        else if (newIndex < 0):
            return 0
        else:
            return newIndex
    }
}