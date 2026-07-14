using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Devices/CreativeAnimation }

# This section was created by Georgez05
# https://github.com/Georgez05
 
# This is just so the Triggers are in a separate dropdown.
functions_class := class<concrete>():
    @editable StartTrigger : trigger_device = trigger_device{}
    @editable StopTrigger : trigger_device = trigger_device{}
    @editable OneShotTrigger : trigger_device = trigger_device{}
    @editable Button:button_device = button_device{}

axis_class := class<concrete>():
    @editable X_Roll : logic = false
    @editable Y_Pitch : logic = false
    @editable Z_Yaw : logic = false
 
prop_setup_class := class<concrete>():
    # The prop you want to rotate.
    @editable Prop : []creative_prop = array{}
    # Which axis should the prop rotate on.
    @editable Axis : axis_class = axis_class{}
    # How much of an angle should the prop rotate in one go.
    @editable Amount_Degrees : float = 0.0
    # The speed of which it does the rotation amount.
    @editable Speed_Seconds : float = 0.0
    # How long should the prop wait to start rotating again.
    @editable Delay_Seconds : float = 0.0
    # Should the prop change direction after completing a rotation.
    @editable AlternateDirection : logic = false

    @editable
    LightChecker : ?toggle_lights_on_pipe_combination = option{toggle_lights_on_pipe_combination{}}

 
# Prop Rotator Device
# CREATED BY GURKIS

# this rotates an individual pipe using a prop_mover_device.
pipe_rotator_device<public> := class(creative_device):
 
    var thingbool : logic = false

    # Allows you to make the device auto start rotation or not.
    @editable AutoStart : logic = false
    @editable AutoStartDelay : float = 0.0

    @editable var Props_to_Rotate : []prop_setup_class = array{}
    var Functions : functions_class = functions_class{}
    @editable PropMover:prop_mover_device = prop_mover_device{}
    @editable ButtonTrigger:button_device = button_device{}
    # Logic variable to keep track of if rotation is started.
    var isStarted : logic = false
    var preventMultiTrigger:logic = true
    
    var TriggerNum:int = 0
    var IsDone:logic = false
    var PositiveTriggers:[]trigger_device = array{}
    var IsLocked : logic = false

    OnBegin<override>()<suspends>:void=
        Functions.StartTrigger.TriggeredEvent.Subscribe(TriggerStart)
        Functions.StopTrigger.TriggeredEvent.Subscribe(Stop)
        Functions.OneShotTrigger.TriggeredEvent.Subscribe(OneShot)
        ButtonTrigger.InteractedWithEvent.Subscribe(ButtonTriggered)
        PropMover.Begin()
        PropMover.End()
        
        if(AutoStart = true):
            Sleep(AutoStartDelay)
            InitRotate(false)
        
    LockPipe():void=
        set IsLocked = true
 
    # Makes all props start rotating infinitely.
    TriggerStart(MaybeAgent:?agent):void=
        if(isStarted = false):
            spawn{InitRotate(false)}
            set isStarted = false

    ButtonTriggered<public>(Agent:agent):void=
        ButtonTrigger.Disable()
        set TriggerNum = 0
        set IsDone = false
        if(isStarted = false):
            spawn{InitRotate(true)}

    ManualButtonTriggered<public>():void=
    {
        set TriggerNum = 0
        set IsDone = false
        if(isStarted = false):
            spawn{InitRotate(true)}
            set isStarted = false
    }

    # Stop any rotation loops currently active. Props already rotating will finish before stopping.
    Stop(MaybeAgent:?agent):void=
        set isStarted = false
 
    # Makes all props rotate one time.
    OneShot(MaybeAgent:?agent):void=
        if:
            thingbool = false
            isStarted = false
        then:
            set thingbool = true
            spawn{InitRotate(true)}
    
    # Initializes the rotation for each prop.
    InitRotate(isOneShot:logic)<suspends>:void=
        if (IsLocked?):
            Print("pipe is locked")
            return
        set isStarted = true
        for(x := 0..Props_to_Rotate.Length-1):
            if:
                Prop := Props_to_Rotate[x].Prop
                Amount := Props_to_Rotate[x].Amount_Degrees
                Speed := Props_to_Rotate[x].Speed_Seconds
                Delay := Props_to_Rotate[x].Delay_Seconds
                Axis := Props_to_Rotate[x].Axis
                AlternateDirection := Props_to_Rotate[x].AlternateDirection
            then:
                spawn{Rotate(Prop,Amount,Speed,Delay,Axis,isOneShot,AlternateDirection)}
 
    # Rotates the props, each with their own settings.
    Rotate(Prop:[]creative_prop,Amount:float,Speed:float,Delay:float,Axis:axis_class,isOneShot:logic,AlternateDirection:logic)<suspends>:void=
        PropMover.Begin()
        PropMover.End()
        set TriggerNum = 0
        var SwitchRotate : logic = false
        loop:
            # Check if rotation is still started.
            if(isStarted = true):
                # Set RotAmount to the default Amount value.
                var RotAmount : float = Amount
                # If Direction Alternating is on, flip flop the value.
                if(AlternateDirection = true):
                    if(SwitchRotate = false):
                        set SwitchRotate = true
                    else:
                        set SwitchRotate = false
 
                # If SwitchRotate is true, then invert the amount value.
                if(SwitchRotate = true):
                    set RotAmount = Amount * -1.0
 
                # Converting degrees to radians as the .ApplyRoll() etc functions use radians.
                FinalRot := DegreesToRadians(RotAmount)

                for(OneProp : Prop):
                    spawn{FinishRotate(OneProp,Axis,FinalRot,Speed)}
                Sleep(Speed)
                # If OneShot was on, stop the loop.
                if(isOneShot = true):
                    set isStarted = false
                    break
                Sleep(Delay)
            else:
                break
        
    FinishRotate(OneProp:creative_prop,Axis:axis_class,FinalRot:float,Speed:float)<suspends>:void=
        set TriggerNum = 0
        # Getting the required positional variables.
        Tran := OneProp.GetTransform().Translation
        Scale := OneProp.GetTransform().Scale
        var Rot : rotation = OneProp.GetTransform().Rotation
        # Check if user hasn't chosen any axis.
        if(Axis.X_Roll = false and Axis.Y_Pitch = false and Axis.Z_Yaw = false):
            Print("Prop Rotator Device: You need to choose at least one axis to rotate")
        else:
            if(Axis.X_Roll = true):
                set Rot = Rot.ApplyRoll(FinalRot)
            if(Axis.Y_Pitch = true):
                set Rot = Rot.ApplyPitch(FinalRot)
            if(Axis.Z_Yaw = true):
                set Rot = Rot.ApplyYaw(FinalRot)
        # Creating the transform variable.
        Transf := transform{Rotation := Rot, Translation := Tran, Scale := Scale}
        RotN := rotation{}
        # Moving the Prop.
        OneProp.MoveTo(Transf,Speed)
        PropMover.Begin()
        PropMover.End()

        set isStarted = false
        
        Sleep(0.1)
        ButtonTrigger.Enable()

        Sleep(0.4)
        # check if prop has a light checker
        if(LightChecker := Props_to_Rotate[0].LightChecker?):
            LightChecker.CheckForCombination()