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

