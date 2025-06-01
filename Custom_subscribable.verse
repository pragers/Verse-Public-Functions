using { /Fortnite.com/Devices }

using { /Fortnite.com/Characters }

using { /Verse.org/Simulation }

using { /UnrealEngine.com/Temporary/Diagnostics }

using { /UnrealEngine.com/Temporary/SpatialMath }

using { /UnrealEngine.com/Temporary/UI }

using { /Verse.org/Concurrency }


#adds custom cancelable
custom_cancelable<public> := class:

    var Canceled : logic = false

    CancelEvent : event() = event(){}
    Cancel():void=
        set Canceled = true
        CancelEvent.Signal()

# adds custom subscribable to allow subscribing to allow to subscribe to your own functions
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

#Allow custom subscribable to be used without parameters
custom_subscribable<public>():= custom_subscribable(tuple())