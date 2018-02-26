-- ------------------------------------------------------------------ --
-- 							HOST SOLDIER FILE						  --
-- ------------------------------------------------------------------ --

-- ---------------------------------------------------------------------
-- import Rana lua libraries
-- ---------------------------------------------------------------------
Stat = require "ranalib_statistic"
Move = require "ranalib_movement"
Collision = require "ranalib_collision"
Utility = require "ranalib_utility"
Agent = require "ranalib_agent"
Event = require "ranalib_event"
Physics = require "ranalib_physics"
Shared = require "ranalib_shared"
Map = require "ranalib_map"
RanaMath = require "ranalib_math"
Core = require "ranalib_core"

-- ---------------------------------------------------------------------
-- initialization parameters
-- ---------------------------------------------------------------------
firstStep = true
repulsed = false

-- calc distance
sample_time = 100*STEP_RESOLUTION
hsbX = Shared.getNumber("hsBornPositionX")
hsbY = Shared.getNumber("hsBornPositionY")
last_position = {["x"]=hsbX,["y"]=hsbY}
sample_counter = sample_time
distance = 0

call_counter = 1
collision_callfrequency = 0
timeToLiveMax = Shared.getNumber("host_sol_timeToLive")
dist = {}
version = Shared.getTable("version")

-- ---------------------------------------------------------------------
-- initialize agent
-- ---------------------------------------------------------------------
function InitializeAgent()
		
	say("Agent host soldier #: " .. ID .. " has been initialized")

	Agent.changeColor{r=106, g=212, b=131}

	Speed = Shared.getNumber("host_sol_speed")

	detectionRange = Shared.getNumber("host_sol_detection_range")
	collision_callfrequency = Shared.getNumber("collision_callfrequency")

	timeToLive = timeToLiveMax
    say("I start with an expected lifetime of ".. timeToLive .. " seconds")

	ids = {}
	
end

function HandleEvent(event)

	if event.description == "inquiline_soldier" 
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then	
		
				Event.emit{description="interaction",table={first="hs", second="is"}}
				
				timeToLive = timeToLive - Stat.randomMean(2.8,9.45)*collision_callfrequency;
								
				say("Termite host soldier #: " .. ID .. " was poisoned by the inquiline soldier!")
					
	if event.description == "inquiline_worker" 
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
				
				Event.emit{description="interaction",table={first="hs", second="iw"}}
				
				timeToLive = timeToLive - Stat.randomMean(0.95,9.45)*collision_callfrequency;
				
				say("Termite host soldier #: " .. ID .. " was poisoned by the inquiline worker!")
				
	elseif event.description == "host_worker"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
		
				Event.emit{description="interaction",table={first="hs", second="hw"}}
		
				timeToLive = timeToLive + Stat.randomMean(0.47,4.72)*collision_callfrequency;

				say("Termite host soldier #: " .. ID .. " was cured by the host worker!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
		
	elseif event.description == "host_soldier"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
				
				Event.emit{description="interaction",table={first="hs", second="hs"}}
				
				timeToLive = timeToLive + Stat.randomMean(1.4,4.72)*collision_callfrequency;

				say("Termite host soldier #: " .. ID .. " was cured by the host soldier!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
	
	end	
	
	end

end

function TakeStep()

	if firstStep then initStep() end

        call_counter = call_counter +1
        timeToLive = timeToLive -1*STEP_RESOLUTION

	if call_counter >= collision_callfrequency*1/STEP_RESOLUTION then
		Event.emit{description="host_soldier"}
		call_counter = 0
	end

	if not Moving then 
		Move.toRandom() 
		repulsed = false
	end

	-- host soldier lifetime
	--------------
	if timeToLive <= 0 then
	 	say("Host soldier agent #" .. ID .." died at the old age of  ".. Core.time())
 	    Event.emit{description="host_soldier_died"}
        Event.emit{description="hsdistance",table={id=ID,dist=distance}}
        Agent.removeAgent(ID)
    end
     
    -- host soldier distances
	--------------
    sample_counter = sample_counter - STEP_RESOLUTION
   
    if sample_counter<=0 then
	 	sample_counter = sample_time
		dist = math.sqrt((PositionX - last_position["x"])^2 + (PositionX - last_position["y"])^2)
		last_position = {["x"]=PositionX,["y"]=PositionY}
		distance = distance + dist
    end
    
end

function initStep()

	firstStep = false

end

function CleanUp()

	say("Inquiline worker agent " ..ID.. " distance= " ..distance)
	
end
