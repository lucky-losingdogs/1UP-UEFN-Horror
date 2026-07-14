
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

<#
    NOTE: there's a small bug that if the player's isnt actively holding the gas can
    then they need to leave and re-enter the volume zone while holding the gas can,
    they can't just start holding while already in the volume
#>

gas_device := class(volume_zone_parent)
{
    @editable
    lock:lock_device = lock_device{}

    @editable
    conditionalButtonChecker:conditional_button_device = conditional_button_device{}

    @editable
    conditionalButtonRemover:conditional_button_device = conditional_button_device{}

    @editable
    trigger : trigger_device = trigger_device{}
    var triggerSubscription:?cancelable = false

    @editable
    inputTrigger : input_trigger_device = input_trigger_device{}
    var inputPressSubscription:?cancelable = false
    var inputReleaseSubscription:?cancelable = false

    var isHoldingInput:logic = false
    var hasLeftZone:logic = false
    var isUnlocked:logic = false
    var isCanEmpty:logic = false
    
    @editable
    var maxGeneratorVolume:float = 100.0
    @editable
    var maxCanVolume:float = 25.0
    @editable
    var fillIncrement:float = 1.0
    
    var currentCanFill:float = 0.0
    var generatorFill:float = 0.0

    @editable
    buttonSwapper:button_swapper = button_swapper{}
    
    OnBegin<override>()<suspends>:void=
    {
        (super:)OnBegin()

        conditionalButtonChecker.ActivatedEvent.Subscribe(OnConditionMet)
    }
    
    OnEnterZone<override>(Agent : agent):void=
    {
        Print("agent entered zone")
        CheckForCondition(Agent)
    }
    
    #use the conditional button to check if the player is carrying the key item(s)
    #if yes, force activate the button's activation event (subscribed to OnConditionMet)
    CheckForCondition(Agent : agent):void=
    {
        if (conditionalButtonChecker.HasAllItems[Agent]):
            conditionalButtonChecker.Activate(Agent)
    }
    
    OnConditionMet(Agent : agent):void=
    {
        trigger.Enable()
        #sub the trigger to input handler and force trigger it
        set triggerSubscription = option{ trigger.TriggeredEvent.Subscribe(InputHandler) }
        trigger.Trigger(Agent)

        set hasLeftZone = false
    }
        
    #when player exits mutator zone
    OnExitZone<override>(Agent : agent):void=
    {
        UnsubEvents()
        trigger.Disable()
        set hasLeftZone = true
        set isCanEmpty = false
    }
    
    InputHandler(mAgent: ?agent):void=
    {
        if (Agent := mAgent?):    
            inputTrigger.Register(Agent)
            spawn {Filling(Agent)}
            
            set inputPressSubscription = option{ inputTrigger.PressedEvent.Subscribe(WaitForInput) }
            set inputReleaseSubscription = option{ inputTrigger.ReleasedEvent.Subscribe(WaitForRelease) }
    }

    WaitForInput(mAgent: agent):void=
    {
        set isHoldingInput = true   
    }
    
    WaitForRelease(mAgent: agent, num:float):void=
    {
        set isHoldingInput = false
    }

    Filling(Agent : agent)<suspends>:void=
    {
        loop:
            #if generator is already filled, prevent continued filling
            if (isUnlocked = true or isCanEmpty = true):
                return
            
            #sleep(0.0) allows for looping every frame
            Sleep(0.0)
            
            #holdingInput is true if input is held down and false when input released
            if (isHoldingInput = true):

                #if gas can has reached it's maximum volume, remove key item and break from loop
                set currentCanFill += fillIncrement

                Print("Can Volume: {currentCanFill}")
                if (CheckGasVolume() = true):
                    RemoveKeyItem(Agent)

                    buttonSwapper.IncrementButtons()

                    set generatorFill += maxCanVolume
                    set currentCanFill = 0.0
                    
                    Print("Generator volume: {generatorFill}")
                    if (generatorFill >= maxGeneratorVolume):
                        Print("Max fill reached")
                        UnlockGate(Agent)
                    return
            #if the player has left the zone, return to prevent continuous looping
            if (hasLeftZone = true):
                return
    }

    #increments the amount that the current can has been used
    #once it reaches its max it resets the current can amount and returns true
    CheckGasVolume()<transacts>:logic=
    {
        if (currentCanFill >= maxCanVolume):
            set isCanEmpty = true
            return true
        else:
            return false
    }

    #activates the conditional button which removes the key item
    RemoveKeyItem(Agent: agent):void=
    {
        conditionalButtonRemover.Activate(Agent)
    }

    #unlock and open gate
    UnlockGate(Agent : agent):void=
    {
        set isUnlocked = true
        lock.Unlock(Agent)
        lock.Open(Agent)
        inputTrigger.Disable()
    }

    #cancel any subscriptions to prevent functionality 
    #happening after the player leaves the zone
    UnsubEvents():void=
    {
        if (subscription := triggerSubscription?):
            subscription.Cancel()
        if (subscription := inputPressSubscription?):
            subscription.Cancel()
        if (subscription := inputReleaseSubscription?):
            subscription.Cancel()
    }
}