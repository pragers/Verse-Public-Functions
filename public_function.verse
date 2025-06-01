PublicFunctions<public>:= module:
    # Returns Number converted to a string, truncated to Decimals places.
    ToTruncatedString<public>(Number:float, Decimals:int):[]char=
        var Str:[]char = ToString(Number)
        if:
            DotIndex := Str.Find['.']
            StopIndex := if (Decimals > 0) then Min(DotIndex+Decimals+1,Str.Length) else DotIndex
            StrSlice:= Str.Slice[0, StopIndex] 
            set Str = StrSlice
        return Str

    EasingOut<public>(Start:float,End:float,Steps:int,CurrentStep:int):float = 
        if:
            Steps<= 1
        then:
            return Start
        StepSize:= 1.0/(1.0*Steps)
        T:= (CurrentStep*1.0)/(1.0*Steps)
        if:
            SnappedT:= Floor[T/StepSize]*StepSize
            EasedT:= 1.0-Pow(1.0-SnappedT, 3.0)
        then:
            return Start + (End - Start) * EasedT
        return Start
    UiAmountFormatting<public>(Number:float):[]char=
        var NewNumber:float= Number
        var NumText:[]char=ToTruncatedString(Number,1)
        if:
            NewNumber>= Pow(10.0,9.0)
            set NewNumber =  Number/Pow(10.0,9.0)
        then:
            set NumText= "{ToTruncatedString(NewNumber, 1)}B"
        else if:
            NewNumber >= Pow(10.0,6.0)
            set NewNumber =  Number/Pow(10.0,6.0)
        then:
            set NumText= "{ToTruncatedString(NewNumber, 1)}M"
        else if:
            NewNumber >= Pow(10.0,3.0)
            set NewNumber =  Number/1000.0
        then:
            set NumText= "{ToTruncatedString(NewNumber, 1)}K"
        else if:
            Number = 1.0*Round[Number]
        then:
            set NumText= "{ToTruncatedString(Number, 0)}"
        return NumText
    TimeFormatting<public>(Number:float):string = 
        if:
            NewNumber:= Round[Number]
        then:
            return TimeFormatting(NewNumber)
        else:
            return ""
    TimeFormatting<public>(Number:int):string =
        var Num :int= Number
        var HoursAmount:int= 0
        var Hours:string= "00"
        var MinutesAmount : int = 0
        var Minutes:string= "00"
        var Seconds:string= "00"

        if: 
            Num1:=Mod[Num,3600]
            Num2 := Quotient[Num, 3600]
            set HoursAmount = Num2
            String1 := "{Num2}"
            set Num = Num1
        then:
            if:
                String1.Length <2
            then:
                set Hours = "0"+String1
            else:
                set Hours = String1
        if:
            Num1:=Mod[Num,60]
            Num2 := Quotient[Num, 60]
            set MinutesAmount = Num2
            String1 := "{Num2}"
            set Num = Num1
        then:
            if:
                String1.Length <2
            then:
                set Minutes = "0"+String1
            else:
                set Minutes = String1
        String3:= "{Num}"
        if:
            String3.Length < 2
        then:
            set Seconds = "0"+String3
        else:
            set Seconds = String3  
        if:
            HoursAmount > 0
        then:
            return "{Hours}:{Minutes}:{Seconds}"

        return "{Minutes}:{Seconds}"

using { /Verse.org/Random }

Array<public> := module:

    # Makes an `array` with only unique elements
    (Input:[]t where t:subtype(comparable)).Unique<public>()<transacts>:[]t =
        var UniqueArray : []t = array{} 
        for (Value : Input):
            if (UniqueArray.Find[Value] > -1) {}
            else:
                set UniqueArray = UniqueArray.Append(Value)
        return UniqueArray

    # Makes an `array` by returning items in a random order 
    (Input:[]t where t:type).Shuffle<public>()<transacts>:[]t =
        Shuffle(Input)

    # Makes an `array` by returning items in a random order 
    # Fails if `Input` is empty
    (Input:[]t where t:type).RandomElement<public>()<decides><transacts>:t =
        Index : int := GetRandomInt(0, Input.Length - 1)
        Input[Index]

    # Makes an `array` by running a `Mapper` function on every item
    (Input:[]t where t:type).Map<public>(Mapper: type{_(:t)<transacts> : t})<transacts>:[]t =
        for (Value : Input, NewValue := Mapper(Value)). NewValue

    # Makes an `array` duplicate of the input
    (Input:[]t where t:type).Copy<public>()<transacts>:[]t =
        for (Value : Input). Value

    # Makes an `array` by filtering out items that `FilterBy` function succeeds
    (Input:[]t where t:type).Filter<public>(FilterBy: type{_(:t)<decides><transacts> : void})<transacts>:[]t =
        for (Value : Input, FilterBy[Value]). Value

    # Succeeds if all items in an `array` make the `FilterBy` function succeed
    (Input:[]t where t:type).IsEveryElement<public>(FilterBy: type{_(:t)<decides><transacts> : void})<decides><transacts> : void =
        FilteredArray := Input.Filter(FilterBy)
        FilteredArray.Length = Input.Length

    # Succeeds if any items in an `array` make the `FilterBy` function succeed
    (Input:[]t where t:type).IsAnyElement<public>(FilterBy: type{_(:t)<decides><transacts> : void})<decides><transacts> : void =
        FilteredArray := Input.Filter(FilterBy)
        FilteredArray.Length > 0

        # Reduces an `array` by running a function on an accumulator
    (Input:[]t where t:type).Reduce<public>(ReductionFunction: type{_(:k, :t)<transacts> : k}, Accumulator: k where k:type)<transacts>:k =
        if (Input.Length > 0, Return := Input.Slice[1].Reduce(ReductionFunction, ReductionFunction(Accumulator, Input[0]))):
            return Return
        else: 
            return Accumulator

    # Sums an `array` of ints
    (Input:[]int).SumInts<public>()<transacts> : int = 
        return Input.Reduce(Reduce.SumInts, 0)
    
    # Sums an `array` of floats
    (Input:[]float).SumFloats<public>()<transacts> : float = 
        return Input.Reduce(Reduce.SumFloats, 0.0)

    # Makes an `array` with the `Element` added to the end
    (Input:[]t where t:type).Append<public>(Element:t)<computes>:[]t = 
        return Input + array{Element}

    # Makes an `array` with the `Element` added to the beginning
    (Input:[]t where t:type).Prepend<public>(Element:t)<computes>:[]t = 
        return array{Element} + Input

    # Makes an `array` with the items in reverse order
    (Input:[]t where t:type).Reverse<public>()<computes>:[]t=
        for (Index -> _Unused : Input, Element := Input[Input.Length - Index - 1]). Element

    # Makes an `array` of ints sorted in order of the `SortOrder` enum
    (Input:[]int).SortInts<public>(SortOrder : Sort.orderBy)<transacts> : []int = 
        return Input.Sort(SortOrder, Array.Sort.CompareInts)

    # Makes an `array` of ints sorted in order of the `SortOrder` enum
    (Input:[]float).SortFloats<public>(SortOrder : Sort.orderBy)<transacts> : []float = 
        return Input.Sort(SortOrder, Array.Sort.CompareFloats)

    # Makes an `array` of items sorted in order of the `SortOrder` enum with a `Comparer` function
    # Usage: SortedItems := Sort(Items, Array.Sort.orderBy.Asc, Array.Sort.CompareFloats)
    (Input:[]t where t:type).Sort<public>(SortOrder : Sort.orderBy, Comparer: type{_(:t, :t)<transacts> : int})<transacts> : []t = 
        if (Input.Length > 1, Pivot := Input[Floor(Input.Length/2)]):
            Left := for(Item : Input, Comparer(Item, Pivot) < 0) do Item 
            Middle := for(Item : Input, Comparer(Item, Pivot) = 0) do Item
            Right := for(Item : Input, Comparer(Item, Pivot) > 0) do Item
            if(SortOrder = Sort.orderBy.Asc):
                Left.Sort(SortOrder, Comparer) + Middle + Right.Sort(SortOrder, Comparer)
            else: 
                Right.Sort(SortOrder, Comparer) + Middle + Left.Sort(SortOrder, Comparer)
        else:    
            Input 

    # Returns the item that is the largest by the `Comparer` function
    # Fails if `arary` is empty
    (Input:[]t where t:type).MaxBy<public>(Comparer: type{_(:t, :t)<transacts> : int})<transacts><decides> : t = 
        Input.Sort(Sort.orderBy.Desc, Comparer)[0]
    
    # Returns the item that is the smallest by the `Comparer` function
    # Fails if `arary` is empty
    (Input:[]t where t:type).MinBy<public>(Comparer: type{_(:t, :t)<transacts> : int})<transacts><decides> : t = 
        Input.Sort(Sort.orderBy.Asc, Comparer)[0]

    # Submodule for Reduce functions   
    Reduce<public> := module:
        SumInts<public>(Accumulator: int, Input: int)<computes>: int =
            return Accumulator + Input
        SumFloats<public>(Accumulator: float, Input: float)<computes>: float =
            return Accumulator + Input

    # Submodule for Sort functions   
    Sort<public> := module:
        orderBy<public> := enum{Asc, Desc}

        CompareInts<public>(A : int, B : int)<transacts>: int = 
            if(A < B) then -1
            else if(A > B) then 1
            else 0

        CompareFloats<public>(A : float, B : float)<transacts>: int = 
            if(A < B) then -1
            else if(A > B) then 1
            else 0
    
            
