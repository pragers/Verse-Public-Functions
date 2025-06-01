
using { /Fortnite.com/Devices }

using { /Fortnite.com/Characters }

using { /Verse.org/Simulation }

using { /UnrealEngine.com/Temporary/Diagnostics }

using { /UnrealEngine.com/Temporary/SpatialMath }

using { /UnrealEngine.com/Temporary/UI }

using { /Verse.org/Concurrency }



custom_cancelable<public> := class:

    var Canceled : logic = false

    CancelEvent : event() = event(){}
    Cancel():void=
        set Canceled = true
        CancelEvent.Signal()

custom_subscribable<public>(t:type)<computes> := class<public>(awaitable(t)):

    InnerEvent : event(t) = event(t){}

    Subscribe<public>(Callback:type {__(:t):void}):custom_cancelable=

        Cancelable := custom_cancelable{}
        
        spawn{_WaitForEvent(Callback, Cancelable)}
        Cancelable


    _WaitForEvent<internal>(Callback:type {__(:t):void}, Cancelable: custom_cancelable)<suspends>:void=
        race:
            loop:
                Payload := InnerEvent.Await()
                if(not Cancelable.Canceled?):
                    Callback(Payload)
                else:
                    break
            Cancelable.CancelEvent.Await()
            
    Signal<public>(Payload:t):void =
        InnerEvent.Signal(Payload)
    Await<override>()<suspends>:t=
        InnerEvent.Await()

custom_subscribable<public>():= custom_subscribable(tuple())

custom_timer<public> := class(creative_device):
    @editable Mode<public> : custom_timer_mode = custom_timer_mode.Seconds

    CompletedEvent<public> : custom_subscribable(?agent) = custom_subscribable(?agent){}

    UpdatedEvent<public> : custom_subscribable(float) = custom_subscribable(float){}

    StoppedEvent<private> : event() = event(){}

    PausedEvent<private> : event() = event(){}

    ResumedEvent<private> : event() = event(){}

    @editable Text : billboard_device = billboard_device{}

    var StartingTime : float = 0.0

    var CurrentTime<private> : float = 0.0

    var State<private> : custom_timer_state = custom_timer_state.Stopped
    var CurrentAgent : ?agent = false
    
    SetTime<public>(Time : float) : void =

        set StartingTime = Time

        set CurrentTime = StartingTime
        Text.SetText(SecondsToTime(CurrentTime))
        Text.UpdateDisplay()
    ShowText():void=
        Text.ShowText()
    HideText():void=
        Text.HideText()
    Start<public>(Agent:agent,EnableVisibilty:logic) : void =

        case ( State):

            custom_timer_state.Running =>

            custom_timer_state.Paused =>

                Resume()

            custom_timer_state.Stopped =>

                Reset()

                set State = custom_timer_state.Running

                spawn{ Update() } 
        if:
            EnableVisibilty = true
        then:
            Text.ShowText()

    Update<private>()<suspends> : void =

        TickTime := Mode = custom_timer_mode.Seconds and 1.0 or Mode = custom_timer_mode.HalfSeconds and 0.5 or 0.1

        loop:

            race:

                StoppedEvent.Await()

                PausedEvent.Await()

                loop:

                    Sleep(TickTime)

                    set CurrentTime = CurrentTime - TickTime

                    UpdatedEvent.Signal(CurrentTime)
                    
                    if ( CurrentTime <= 0.0):

                        set State = custom_timer_state.Stopped
                        Text.HideText()
                        CompletedEvent.Signal(CurrentAgent)
                    Text.SetText(SecondsToTime(CurrentTime))
                    Text.UpdateDisplay()

            if ( State = custom_timer_state.Stopped) then break
            else ResumedEvent.Await()


    Reset<public>() : void =

        Stop()

        set CurrentTime = StartingTime

        UpdatedEvent.Signal(CurrentTime)



    Pause<public>() : void = { set State = custom_timer_state.Paused; PausedEvent.Signal(); }

    Resume<public>() : void = { set State = custom_timer_state.Running; ResumedEvent.Signal(); }

    Stop<public>() : void =  { set State = custom_timer_state.Stopped; StoppedEvent.Signal(); }


    GetCurrentState<public>()<transacts> : custom_timer_state = State

    GetCurrentTime<public>()<transacts> : float = CurrentTime



custom_timer_state<public> := enum:

    Running

    Paused

    Stopped


custom_timer_mode<public> := enum:

    Seconds

    HalfSeconds

    Deciseconds
StringToMessage<localizes>(str:string):message = "{str}"

SecondsToTime(seconds:float):message =
    var RoundedSeconds :int = 86400
    if:
        RoundSeconds := Round[seconds]
        set RoundedSeconds = RoundSeconds
    var Hours : int  = 0
    var Minutes : int = 0
    if:
        HourC := Quotient[RoundedSeconds, 3600]
        Second := Mod[RoundedSeconds, 3600]
        set Hours = HourC
        set RoundedSeconds = Second
    if: 
        MinuteC := Quotient[RoundedSeconds, 60]
        Second := Mod[RoundedSeconds, 60]
        set Minutes = MinuteC
        set RoundedSeconds = Second
    if:
        Hours>0
    then:
        return StringToMessage("{padZero(Hours)}:{padZero(Minutes)}:{padZero(RoundedSeconds)}")
    else if:
        Minutes>0
    then:
        return StringToMessage("{padZero(Minutes)}:{padZero(RoundedSeconds)}")
    else:
        return StringToMessage("{RoundedSeconds}")
padZero(num:int):string =
    NumStr:string = "{num}"
    if (NumStr.Length < 2) then return "0" + NumStr
    else return NumStr