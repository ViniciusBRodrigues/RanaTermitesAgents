-- ------------------------------------------------------------------ --
-- 							HOST WORKER FILE						  --
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
hwbX = Shared.getNumber("hwBornPositionX")
hwbY = Shared.getNumber("hwBornPositionY")
last_position = {["x"]=hwbX,["y"]=hwbY}
sample_counter = sample_time
distance = 0

call_counter = 1
collision_callfrequency = 0
timeToLiveMax = Shared.getNumber("host_wor_timeToLive")
version = Shared.getTable("version")

-- ---------------------------------------------------------------------
-- initialize agent
-- ---------------------------------------------------------------------
function InitializeAgent()
	
	say("Agent host worker #: " .. ID .. " has been initialized")
	
	Agent.changeColor{r=116, g=172, b=255}

	Speed = Shared.getNumber("host_wor_speed")
	
	detectionRange = Shared.getNumber("host_wor_detection_range")
	collision_callfrequency = Shared.getNumber("collision_callfrequency")

	timeToLive = timeToLiveMax
    say("I start with an expected lifetime of ".. timeToLive .. " seconds")

	ids = {}
	
end

function HandleEvent(event)

	if event.description == "inquiline_soldier" 
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
				
				Event.emit{description="interaction",table={first="hw", second="is"}}
				
				timeToLive = timeToLive - Stat.randomMean(2.8,9.45)*collision_callfrequency;
								
				say("Termite host soldier #: " .. ID .. " was poisoned by the host worker!") 
								
	if event.description == "inquiline_worker" 
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
		
				Event.emit{description="interaction",table={first="hw", second="iw"}}
				
				timeToLive = timeToLive - Stat.randomMean(0.95,9.45)*collision_callfrequency;
								
				say("Termite host soldier #: " .. ID .. " was poisoned by the host worker!")
				
	elseif event.description == "host_worker"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
		
				Event.emit{description="interaction",table={first="hw", second="hw"}}
				
				timeToLive = timeToLive + Stat.randomMean(0.47,4.72)*collision_callfrequency;

				say("Termite inquiline soldier #: " .. ID .. " was cured by the iquiline!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
		
	elseif event.description == "host_soldier"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
		
				Event.emit{description="interaction",table={first="hw", second="hs"}}
		
				timeToLive = timeToLive + Stat.randomMean(1.4,4.72)*collision_callfrequency;

				say("Termite inquiline soldier #: " .. ID .. " was cured by the iquiline!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
	
	end	
		
	end

end

function TakeStep()

	if firstStep then initStep() end

        call_counter = call_counter +1
        timeToLive = timeToLive -1*STEP_RESOLUTION

	if call_counter >= collision_callfrequency*1/STEP_RESOLUTION then
		Event.emit{description="host_worker"}
		call_counter = 0
	end

	if not Moving then 
		Move.toRandom() 
		repulsed = false
	end

	-- host worker lifetime
	--------------
	if timeToLive <= 0 then
	 	say("Host worker agent #" .. ID .." died at the old age of  ".. Core.time())
	 	Event.emit{description="host_worker_died"}
        Event.emit{description="hwdistance",table={id=ID,dist=distance}}
        Agent.removeAgent(ID)
    end
     
    -- host worker distances
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
