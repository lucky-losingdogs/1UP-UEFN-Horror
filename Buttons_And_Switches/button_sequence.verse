
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

button_sequence := class(creative_device)
{
    #set buttons in editor
    @editable
    buttons:[]button_device = array{}

    #set true to enable randomising the order of the buttons
    @editable
    var randomise:logic = true

    @editable
    Trigger:trigger_device = trigger_device{}

    var buttonOrder:[]int = array{}
    var orderIndex:int = 0
    var buttonsPerformed:logic = false
    
    OnBegin<override>()<suspends>:void=
    {   
        #index through array of buttons and subscribe each one to the HandlerFunction in the ParameterHandler class
        for(index->value : buttons):
            value.InteractedWithEvent.Subscribe(button_handler{device:=Self, index:=index}.HandlerFunction)

        SetSequence()
    }
 
    OnButtonInteraction(index : int, Agent:agent):void=
    {
        CheckOrder(index, Agent)
    }

    CheckOrder(index:int, Agent:agent):void=
    {
        if (index = buttonOrder[orderIndex]):
            Print("Correct button")
            set orderIndex += 1
        else:
           Print("Wrong button order")
           set orderIndex = 0
           
        if (orderIndex = buttonOrder.Length):
            Print("All buttons pressed in correct order!")
            Unlock(Agent)<#Add stuff to do after corredct sequence here#>
            set orderIndex = 0 <#Reset index for debug purposes#>
    }
    
    SetSequence():void=
    {
        for (index->value : buttons):
            if (newArray := buttonOrder.Insert[0, array{index}]):
                set buttonOrder = newArray
        
        if (randomise = true):
            set buttonOrder = Shuffle(buttonOrder)
    }

    Unlock(Agent:agent):void=
    {
        Trigger.Trigger(Agent)
    }
}

button_handler := class()
{
    device : button_sequence
    index : int  <#The additional parameter that will be passed to the subscribed function#>

    #subscribed to each button
    #calls the actual button interaction function and passes parameter
    HandlerFunction(Agent : agent) : void =
    {
        device.OnButtonInteraction(index, Agent)
    }
}