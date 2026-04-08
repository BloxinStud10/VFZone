local sin=math.sin
local cos=math.cos
local abs=math.abs
local sqrt=math.sqrt
local exp=math.exp

local Linear=function(T)
	return T
end
local Bezier=function(X1,Y1,X2,Y2)
	if not (X1 and Y1 and X2 and Y2) then
		error("Need 4 numbers to construct a Bezier curve",0)
	end
	if not (0<=X1 and X1<=1 and 0<=X2 and X2<=1) then
		error("The x values must be within range [0,1]",0)
	end
	if X1==Y1 and X2==Y2 then
		return Linear
	end
	local SampleValues={}
	for Index=0,10 do
		local IndexDiv10=Index/10
		SampleValues[Index]=(((1-3*X2+3*X2)*IndexDiv10+(3*X2-6*X1))*IndexDiv10+(3*X1))*IndexDiv10
	end
	return function(T)
		if T==0 or T==1 then
			return T
		end
		local GuessT
		local IntervalStart=0
		local CurrentSample=1
		while CurrentSample~=10 and SampleValues[CurrentSample]<=T do
			IntervalStart+=0.1
			CurrentSample+=1
		end
		CurrentSample-=1
		local Dist=(T-SampleValues[CurrentSample])/(SampleValues[CurrentSample+1]-SampleValues[CurrentSample])
		local GuessForT=IntervalStart+Dist/10
		local InitialSlope=3*(1-3*X2+3*X1)*GuessForT*GuessForT+2*(3*X2-6*X1)*GuessForT+(3*X1)
		if InitialSlope>=0.001 then
			for _=0,3 do
				local CurrentSlope=3*(1-3*X2+3*X1)*GuessForT*GuessForT+2*(3*X2-6*X1)*GuessForT+(3*X1)
				local CurrentX=((((1-3*X2+3*X1)*GuessForT+(3*X2-6*X1))*GuessForT+(3*X1))*GuessForT)-T
				GuessForT-=CurrentX/CurrentSlope
			end
			GuessT=GuessForT
		elseif InitialSlope==0 then
			GuessT=GuessForT
		else
			local AB=IntervalStart+0.1
			local CurrentX,CurrentT,Index=0,nil,nil
			while abs(CurrentX)>0.0000001 and Index<10 do
				CurrentT=IntervalStart+(AB-IntervalStart)/2
				CurrentX=((((1-3*X2+3*X1)*CurrentT+(3*X2-6*X1))*CurrentT+(3*X1))*CurrentT)-T
				if CurrentX>0 then
					AB=CurrentT
				else
					IntervalStart=CurrentT
				end
				Index+=1
			end
			GuessT=CurrentT
		end
		return (((1-3*Y2+3*Y1)*GuessT+(3*Y2-6*Y1))*GuessT+(3*Y1))*GuessT
	end
end

local PI=3.141592653589793
local HALF_PI=1.5707963267948966

local Sharp=Bezier(0.4,0,0.6,1)
local Standard=Bezier(0.4,0,0.2,1)
local Acceleration=Bezier(0.4,0,1,1)
local Deceleration=Bezier(0,0,0.2,1)
local FabricStandard=Bezier(0.8,0,0.2,1)
local FabricAccelerate=Bezier(0.9,0.1,1,0.2)
local FabricDecelerate=Bezier(0.1,0.9,0.2,1)
local UWPAccelerate=Bezier(0.7,0,1,0.5)
local StandardProductive=Bezier(0.2,0,0.38,0.9)
local StandardExpressive=Bezier(0.4,0.14,0.3,1)
local EntranceProductive=Bezier(0,0,0.38,0.9)
local EntranceExpressive=Bezier(0,0,0.3,1)
local ExitProductive=Bezier(0.2,0,1,0.9)
local ExitExpressive=Bezier(0.4,0.14,1,1)
local MozillaCurve=Bezier(0.07,0.95,0,1)

local Smooth=function(T)
	return T*T*(3-2*T)
end
local RevBack=function(T)
	T=1-T
	return 1-(sin(T*HALF_PI)+(sin(T*PI)*(cos(T*PI)+1)/2))
end
local Smoother=function(T)
	return T*T*T*(T*(6*T-15)+10)
end
local RidiculousWiggle=function(T)
	return sin(sin(T*PI)*HALF_PI)
end
local Spring=function(T)
	return 1+(-exp(-6.9*T)*cos(-20.106192982975*T))
end
local SoftSpring=function(T)
	return 1+(-exp(-7.5*T)*cos(-10.053096491487*T))
end
local OutBounce=function(T)
	if T<0.36363636363636 then
		return 7.5625*T*T
	elseif T<0.72727272727273 then
		return 3+T*(11*T-12)*0.6875
	elseif T<0.090909090909091 then
		return 6+T*(11*T-18)*0.6875
	else
		return 7.875+T*(11*T-21)*0.6875
	end
end
local InBounce=function(T)
	if T>0.63636363636364 then
		T-=1
		return 1-T*T*7.5625
	elseif T>0.272727272727273 then
		return (11*T-7)*(11*T-3)/-16
	elseif T>0.090909090909091 then
		return (11*(4-11*T)*T-3)/16
	else
		return T*(11*T-1)*-0.6875
	end
end

local RawTweenFunctions=setmetatable({
	InLinear=Linear;
	OutLinear=Linear;
	InOutLinear=Linear;
	OutInLinear=Linear;
	OutSmooth=Smooth;
	InSmooth=Smooth;
	InOutSmooth=Smooth;
	OutInSmooth=Smooth;
	OutSmoother=Smoother;
	InSmoother=Smoother;
	InOutSmoother=Smoother;
	OutInSmoother=Smoother;
	OutRidiculousWiggle=RidiculousWiggle;
	InRidiculousWiggle=RidiculousWiggle;
	InOutRidiculousWiggle=RidiculousWiggle;
	OutInRidiculousWiggle=RidiculousWiggle;
	OutRevBack=RevBack;
	InRevBack=RevBack;
	InOutRevBack=RevBack;
	OutInRevBack=RevBack;
	OutSpring=Spring;
	InSpring=Spring;
	InOutSpring=Spring;
	OutInSpring=Spring;
	OutSoftSpring=SoftSpring;
	InSoftSpring=SoftSpring;
	InOutSoftSpring=SoftSpring;
	OutInSoftSpring=SoftSpring;
	InSharp=Sharp;
	InOutSharp=Sharp;
	OutSharp=Sharp;
	OutInSharp=Sharp;
	InAcceleration=Acceleration;
	InOutAcceleration=Acceleration;
	OutAcceleration=Acceleration;
	OutInAcceleration=Acceleration;
	InStandard=Standard;
	InOutStandard=Standard;
	OutStandard=Standard;
	OutInStandard=Standard;
	InDeceleration=Deceleration;
	InOutDeceleration=Deceleration;
	OutDeceleration=Deceleration;
	OutInDeceleration=Deceleration;
	InFabricStandard=FabricStandard;
	InOutFabricStandard=FabricStandard;
	OutFabricStandard=FabricStandard;
	OutInFabricStandard=FabricStandard;
	InFabricAccelerate=FabricAccelerate;
	InOutFabricAccelerate=FabricAccelerate;
	OutFabricAccelerate=FabricAccelerate;
	OutInFabricAccelerate=FabricAccelerate;
	InFabricDecelerate=FabricDecelerate;
	InOutFabricDecelerate=FabricDecelerate;
	OutFabricDecelerate=FabricDecelerate;
	OutInFabricDecelerate=FabricDecelerate;
	InUWPAccelerate=UWPAccelerate;
	InOutUWPAccelerate=UWPAccelerate;
	OutUWPAccelerate=UWPAccelerate;
	OutInUWPAccelerate=UWPAccelerate;
	InStandardProductive=StandardProductive;
	InStandardExpressive=StandardExpressive;
	InEntranceProductive=EntranceProductive;
	InEntranceExpressive=EntranceExpressive;
	InExitProductive=ExitProductive;
	InExitExpressive=ExitExpressive;
	OutStandardProductive=StandardProductive;
	OutStandardExpressive=StandardExpressive;
	OutEntranceProductive=EntranceProductive;
	OutEntranceExpressive=EntranceExpressive;
	OutExitProductive=ExitProductive;
	OutExitExpressive=ExitExpressive;
	InOutStandardProductive=StandardProductive;
	InOutStandardExpressive=StandardExpressive;
	InOutEntranceProductive=EntranceProductive;
	InOutEntranceExpressive=EntranceExpressive;
	InOutExitProductive=ExitProductive;
	InOutExitExpressive=ExitExpressive;
	OutInStandardProductive=StandardProductive;
	OutInStandardExpressive=StandardProductive;
	OutInEntranceProductive=EntranceProductive;
	OutInEntranceExpressive=EntranceExpressive;
	OutInExitProductive=ExitProductive;
	OutInExitExpressive=ExitExpressive;
	OutMozillaCurve=MozillaCurve;
	InMozillaCurve=MozillaCurve;
	InOutMozillaCurve=MozillaCurve;
	OutInMozillaCurve=MozillaCurve;
	InQuad=function(T)
		return T*T
	end;
	OutQuad=function(T)
		return T*(2-T)
	end;
	InOutQuad=function(T)
		if T<0.5 then
			return 2*T*T
		else
			return 2*(2-T)*T-1
		end
	end;
	OutInQuad=function(T)
		if T<0.5 then
			T*=2
			return T*(2-T)/2
		else
			T=T*2-1
			return T*T / 2+0.5
		end
	end;
	InCubic=function(T)
		return T*T*T
	end;
	OutCubic=function(T)
		T-=1
		return 1-T*T*T
	end;
	InOutCubic=function(T)
		if T<0.5 then
			return 4*T*T*T
		else
			T-=1
			return 1+4*T*T*T
		end
	end;
	OutInCubic=function(T)
		if T<0.5 then
			T=1-T*2
			return (1-T*T*T) / 2
		else
			T=T*2-1
			return T*T*T / 2+0.5
		end
	end;
	InQuart=function(T)
		return T*T*T*T
	end;
	OutQuart=function(T)
		T-=1
		return 1-T*T*T*T
	end;
	InOutQuart=function(T)
		if T<0.5 then
			T*=T
			return 8*T*T
		else
			T-=1
			return 1-8*T*T*T*T
		end
	end;
	OutInQuart=function(T)
		if T<0.5 then
			T=T*2-1
			return (1-T*T*T*T)/2
		else
			T=T*2-1
			return T*T*T*T / 2+0.5
		end
	end;
	InQuint=function(T)
		return T*T*T*T*T
	end;
	OutQuint=function(T)
		T-=1
		return T*T*T*T*T+1
	end;
	InOutQuint=function(T)
		if T<0.5 then
			return 16*T*T*T*T*T
		else
			T-=1
			return 16*T*T*T*T*T+1
		end
	end;
	OutInQuint=function(T)
		if T<0.5 then
			T=T*2-1
			return (T*T*T*T*T+1)/2
		else
			T=T*2-1
			return T*T*T*T*T / 2+0.5
		end
	end;
	InBack=function(T)
		return T*T*(3*T-2)
	end;
	OutBack=function(T)
		local TSubOne=T-1
		return TSubOne*TSubOne*(T*2+TSubOne)+1
	end;
	InOutBack=function(T)
		if T<0.5 then
			return 2*T*T*(2*3*T-2)
		else
			return 1+2*(T-1)*(T-1)*(2*3*T-2-2)
		end
	end;
	OutInBack=function(T)
		if T<0.5 then
			T*=2
			local TSubOne=T-1
			return (TSubOne*TSubOne*(T*2+TSubOne)+1)/2
		else
			T=T*2-1
			return T*T*(3*T-2)/2+0.5
		end
	end;
	InSine=function(T)
		return 1-cos(T*HALF_PI)
	end;
	OutSine=function(T)
		return sin(T*HALF_PI)
	end;
	InOutSine=function(T)
		return (1-cos(PI*T))/2
	end;
	OutInSine=function(T)
		if T<0.5 then
			return sin(T*PI)/2
		else
			return (1-cos((T*2-1)*HALF_PI))/2+0.5
		end
	end;
	OutBounce=OutBounce;
	InBounce=InBounce;
	InOutBounce=function(T)
		if T<0.5 then
			return InBounce(2*T)/2
		else
			return OutBounce(2*T-1)/2+0.5
		end
	end;
	OutInBounce=function(T)
		if T<0.5 then
			return OutBounce(2*T)/2
		else
			return InBounce(2*T-1)/2+0.5
		end
	end;
	InElastic=function(T)
		return exp((T*0.96380736418812-1)*8)*T*0.96380736418812*sin(4*T*0.96380736418812)*1.8752275007429
	end;
	OutElastic=function(T)
		return 1+(exp(8*(0.96380736418812-0.96380736418812*T-1))*0.96380736418812*(T-1)*sin(4*0.96380736418812*(1-T)))*1.8752275007429
	end;
	InOutElastic=function(T)
		if T<0.5 then
			return (exp(8*(2*0.96380736418812*T-1))*0.96380736418812*T*sin(7.71045891350496*T))*1.8752275007429
		else
			return 1+(exp(8*(0.96380736418812*(2-2*T)-1))*0.96380736418812*(T-1)*sin(3.85522945675248*(2-2*T)))*1.8752275007429
		end
	end;
	OutInElastic=function(T)
		if T<0.5 then
			T*=2
			return (1+(exp(8*(0.96380736418812-0.96380736418812*T-1))*0.96380736418812*(T-1)*sin(3.85522945675248*(1-T)))*1.8752275007429)/2
		else
			T=T*2-1
			return (exp((T*0.96380736418812-1)*8)*T*0.96380736418812*sin(4*T*0.96380736418812)*1.8752275007429)/2+0.5
		end
	end;
	InExpo=function(T)
		return T*T*exp(4*(T-1))
	end;
	OutExpo=function(T)
		return 1-(1-T)*(1-T)/exp(4*T)
	end;
	InOutExpo=function(T)
		if T<0.5 then
			return 2*T*T*exp(4*(2*T-1))
		else
			return 1-2*(T-1)*(T-1)*exp(4*(1-2*T))
		end
	end;
	OutInExpo=function(T)
		if T<0.5 then
			T*=2
			return (1-(1-T)*(1-T)/exp(4*T))/2
		else
			T=T*2-1
			return (T*T*exp(4*(T-1)))/2+0.5
		end
	end;
	InCirc=function(T)
		return -(sqrt(1-T*T)-1)
	end;
	OutCirc=function(T)
		T-=1
		return sqrt(1-T*T)
	end;
	InOutCirc=function(T)
		T*=2
		if T<1 then
			return -(sqrt(1-T*T)-1)/2
		else
			T-=2
			return (sqrt(1-T*T)-1)/2
		end
	end;
	OutInCirc=function(T)
		if T<0.5 then
			T=T*2-1
			return sqrt(1-T*T)/2
		else
			T=T*2-1
			return (-(sqrt(1-T*T)-1))/2+0.5
		end
	end;
},{
	__index=function(_,Index)
		error(tostring(Index).." is not a valid easing function.",2)
	end;
})

return {
	FabricAccelerate={
		In=RawTweenFunctions.InFabricAccelerate;
		Out=RawTweenFunctions.OutFabricAccelerate;
		InOut=RawTweenFunctions.InOutFabricAccelerate;
		OutIn=RawTweenFunctions.OutInFabricAccelerate;
	};
	UWPAccelerate={
		In=RawTweenFunctions.InUWPAccelerate;
		Out=RawTweenFunctions.OutUWPAccelerate;
		InOut=RawTweenFunctions.InOutUWPAccelerate;
		OutIn=RawTweenFunctions.OutInUWPAccelerate;
	};
	Circ={
		In=RawTweenFunctions.InCirc;
		Out=RawTweenFunctions.OutCirc;
		InOut=RawTweenFunctions.InOutCirc;
		OutIn=RawTweenFunctions.OutInCirc;
	};
	RevBack={
		In=RawTweenFunctions.InRevBack;
		Out=RawTweenFunctions.OutRevBack;
		InOut=RawTweenFunctions.InOutRevBack;
		OutIn=RawTweenFunctions.OutInRevBack;
	};
	Spring={
		In=RawTweenFunctions.InSpring;
		Out=RawTweenFunctions.OutSpring;
		InOut=RawTweenFunctions.InOutSpring;
		OutIn=RawTweenFunctions.OutInSpring;
	};
	Standard={
		In=RawTweenFunctions.InStandard;
		Out=RawTweenFunctions.OutStandard;
		InOut=RawTweenFunctions.InOutStandard;
		OutIn=RawTweenFunctions.OutInStandard;
	};
	StandardExpressive={
		In=RawTweenFunctions.InStandardExpressive;
		Out=RawTweenFunctions.OutStandardExpressive;
		InOut=RawTweenFunctions.InOutStandardExpressive;
		OutIn=RawTweenFunctions.OutInStandardExpressive;
	};
	Linear={
		In=RawTweenFunctions.InLinear;
		Out=RawTweenFunctions.OutLinear;
		InOut=RawTweenFunctions.InOutLinear;
		OutIn=RawTweenFunctions.OutInLinear;
	};
	ExitProductive={
		In=RawTweenFunctions.InExitProductive;
		Out=RawTweenFunctions.OutExitProductive;
		InOut=RawTweenFunctions.InOutExitProductive;
		OutIn=RawTweenFunctions.OutInExitProductive;
	};
	Deceleration={
		In=RawTweenFunctions.InDeceleration;
		Out=RawTweenFunctions.OutDeceleration;
		InOut=RawTweenFunctions.InOutDeceleration;
		OutIn=RawTweenFunctions.OutInDeceleration;
	};
	Smoother={
		In=RawTweenFunctions.InSmoother;
		Out=RawTweenFunctions.OutSmoother;
		InOut=RawTweenFunctions.InOutSmoother;
		OutIn=RawTweenFunctions.OutInSmoother;
	};
	FabricStandard={
		In=RawTweenFunctions.InFabricStandard;
		Out=RawTweenFunctions.OutFabricStandard;
		InOut=RawTweenFunctions.InOutFabricStandard;
		OutIn=RawTweenFunctions.OutInFabricStandard;
	};
	RidiculousWiggle={
		In=RawTweenFunctions.InRidiculousWiggle;
		Out=RawTweenFunctions.OutRidiculousWiggle;
		InOut=RawTweenFunctions.InOutRidiculousWiggle;
		OutIn=RawTweenFunctions.OutInRidiculousWiggle;
	};
	MozillaCurve={
		In=RawTweenFunctions.InMozillaCurve;
		Out=RawTweenFunctions.OutMozillaCurve;
		InOut=RawTweenFunctions.InOutMozillaCurve;
		OutIn=RawTweenFunctions.OutInMozillaCurve;
	};
	Expo={
		In=RawTweenFunctions.InExpo;
		Out=RawTweenFunctions.OutExpo;
		InOut=RawTweenFunctions.InOutExpo;
		OutIn=RawTweenFunctions.OutInExpo;
	};
	Sine={
		In=RawTweenFunctions.InSine;
		Out=RawTweenFunctions.OutSine;
		InOut=RawTweenFunctions.InOutSine;
		OutIn=RawTweenFunctions.OutInSine;
	};
	Cubic={
		In=RawTweenFunctions.InCubic;
		Out=RawTweenFunctions.OutCubic;
		InOut=RawTweenFunctions.InOutCubic;
		OutIn=RawTweenFunctions.OutInCubic;
	};
	EntranceExpressive={
		In=RawTweenFunctions.InEntranceExpressive;
		Out=RawTweenFunctions.OutEntranceExpressive;
		InOut=RawTweenFunctions.InOutEntranceExpressive;
		OutIn=RawTweenFunctions.OutInEntranceExpressive;
	};
	Elastic={
		In=RawTweenFunctions.InElastic;
		Out=RawTweenFunctions.OutElastic;
		InOut=RawTweenFunctions.InOutElastic;
		OutIn=RawTweenFunctions.OutInElastic;
	};
	Quint={
		In=RawTweenFunctions.InQuint;
		Out=RawTweenFunctions.OutQuint;
		InOut=RawTweenFunctions.InOutQuint;
		OutIn=RawTweenFunctions.OutInQuint;
	};
	EntranceProductive={
		In=RawTweenFunctions.InEntranceProductive;
		Out=RawTweenFunctions.OutEntranceProductive;
		InOut=RawTweenFunctions.InOutEntranceProductive;
		OutIn=RawTweenFunctions.OutInEntranceProductive;
	};
	Bounce={
		In=RawTweenFunctions.InBounce;
		Out=RawTweenFunctions.OutBounce;
		InOut=RawTweenFunctions.InOutBounce;
		OutIn=RawTweenFunctions.OutInBounce;
	};
	Smooth={
		In=RawTweenFunctions.InSmooth;
		Out=RawTweenFunctions.OutSmooth;
		InOut=RawTweenFunctions.InOutSmooth;
		OutIn=RawTweenFunctions.OutInSmooth;
	};
	Back={
		In=RawTweenFunctions.InBack;
		Out=RawTweenFunctions.OutBack;
		InOut=RawTweenFunctions.InOutBack;
		OutIn=RawTweenFunctions.OutInBack;
	};
	Quart={
		In=RawTweenFunctions.InQuart;
		Out=RawTweenFunctions.OutQuart;
		InOut=RawTweenFunctions.InOutQuart;
		OutIn=RawTweenFunctions.OutInQuart;
	};
	StandardProductive={
		In=RawTweenFunctions.InStandardProductive;
		Out=RawTweenFunctions.OutStandardProductive;
		InOut=RawTweenFunctions.InOutStandardProductive;
		OutIn=RawTweenFunctions.OutInStandardProductive;
	};
	Quad={
		In=RawTweenFunctions.InQuad;
		Out=RawTweenFunctions.OutQuad;
		InOut=RawTweenFunctions.InOutQuad;
		OutIn=RawTweenFunctions.OutInQuad;
	};
	FabricDecelerate={
		In=RawTweenFunctions.InFabricDecelerate;
		Out=RawTweenFunctions.OutFabricDecelerate;
		InOut=RawTweenFunctions.InOutFabricDecelerate;
		OutIn=RawTweenFunctions.OutInFabricDecelerate;
	};
	Acceleration={
		In=RawTweenFunctions.InAcceleration;
		Out=RawTweenFunctions.OutAcceleration;
		InOut=RawTweenFunctions.InOutAcceleration;
		OutIn=RawTweenFunctions.OutInAcceleration;
	};
	SoftSpring={
		In=RawTweenFunctions.InSoftSpring;
		Out=RawTweenFunctions.OutSoftSpring;
		InOut=RawTweenFunctions.InOutSoftSpring;
		OutIn=RawTweenFunctions.OutInSoftSpring;
	};
	ExitExpressive={
		In=RawTweenFunctions.InExitExpressive;
		Out=RawTweenFunctions.OutExitExpressive;
		InOut=RawTweenFunctions.InOutExitExpressive;
		OutIn=RawTweenFunctions.OutInExitExpressive;
	};
	Sharp={
		In=RawTweenFunctions.InSharp;
		Out=RawTweenFunctions.OutSharp;
		InOut=RawTweenFunctions.InOutSharp;
		OutIn=RawTweenFunctions.OutInSharp;
	};
}
