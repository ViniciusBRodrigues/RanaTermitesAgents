-- ------------------------------------------------------------------ --
-- 							INQUILINE WORKER FILE					  --
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
iwbX = Shared.getNumber("iwBornPositionX")
iwbY = Shared.getNumber("iwBornPositionY")
last_position = {["x"]=iwbX,["y"]=iwbY}
sample_counter = sample_time
distance = 0

call_counter = 1
collision_callfrequency = 0
timeToLiveMax = Shared.getNumber("inq_wor_timeToLive")
dist = {}
version = Shared.getTable("version")

-- ---------------------------------------------------------------------
-- initialize agent
-- ---------------------------------------------------------------------
function InitializeAgent()

	say("Agent inquiline worker #: " .. ID .. " has been initialized")
	
	Agent.changeColor{r=193, g=118, b=118}

	Speed = Shared.getNumber("inq_wor_speed")
	
	repulsionRange = Shared.getNumber("inquiline_repulsion_range")
	detectionRange = Shared.getNumber("inquiline_wor_detection_range")
	collision_callfrequency = Shared.getNumber("collision_callfrequency")

	timeToLive = timeToLiveMax
    say("I start with an expected lifetime of ".. timeToLive .. " seconds")

	ids = {}

end

function HandleEvent(event)

	-- avoiding the hosts
	--------------
	if event.description == "host_worker"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
		
			Event.emit{description="interaction",table={first="iw", second="hw"}}
			
			local new_X
			local new_Y

			-- move in opposite direction
			--------------
				if event.X > PositionX then
					new_X = PositionX - Stat.randomInteger(repulsionRange/2,repulsionRange)
				else
					new_X = PositionX + Stat.randomInteger(repulsionRange/2,repulsionRange)
				end

				if event.Y > PositionY then
					new_Y = PositionY - Stat.randomInteger(repulsionRange/2,repulsionRange)

				else
					new_Y = PositionY + Stat.randomInteger(repulsionRange/2,repulsionRange)
				end

				repulsed = true
				
				Speed = Stat.randomMean(0.9,9.54) -- changing speed
				
				timeToLive = timeToLive - Stat.randomMean(1,2)*collision_callfrequency;  -- losing life
				Move.to{x= new_X, y=new_Y}
					
				say("Termite inquiline worker #: " .. ID .. " was poisoned by the host worker!")
				
	if event.description == "host_soldier" 
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
						
			Event.emit{description="interaction",table={first="iw", second="hs"}}

			local new_X
			local new_Y

			-- move in opposite direction
			--------------
				if event.X > PositionX then
					new_X = PositionX - Stat.randomInteger(repulsionRange/2,repulsionRange)
				else
					new_X = PositionX + Stat.randomInteger(repulsionRange/2,repulsionRange)
				end

				if event.Y > PositionY then
					new_Y = PositionY - Stat.randomInteger(repulsionRange/2,repulsionRange)

				else
					new_Y = PositionY + Stat.randomInteger(repulsionRange/2,repulsionRange)
				end

				repulsed = true
				
				Speed = Stat.randomMean(0.3,3) -- changing speed
				
				timeToLive = timeToLive - Stat.randomMean(2.8,9.54)*collision_callfrequency;  -- losing life
				Move.to{x= new_X, y=new_Y}
					
				say("Termite inquiline worker #: " .. ID .. " was poisoned by the host soldier!")
	
	elseif event.description == "inquiline_worker"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
				
				Event.emit{description="interaction",table={first="iw", second="iw"}}
				
				Speed = Stat.randomMean(0.2,2)
		
				timeToLive = timeToLive + Stat.randomMean(0.47,4.77)*collision_callfrequency;

				say("Termite inquiline worker #: " .. ID .. " was cured by the iquiline worker!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
		
	elseif event.description == "inquiline_soldier"
		and Physics.calcDistance{x1=event.X, x2=PositionX, y1=event.Y, y2=PositionY} < detectionRange 
		then
				
				Event.emit{description="interaction",table={first="iw", second="is"}}
				
				Speed = Stat.randomMean(0.2,2)
		
				timeToLive = timeToLive + Stat.randomMean(1.4,4.77)*collision_callfrequency;

				say("Termite inquiline worker #: " .. ID .. " was cured by the iquiline soldier!")
				
		if timeToLive >= timeToLiveMax then timeToLive = timeToLiveMax end
		
	end	
		
	end

end

function TakeStep()

	if firstStep then initStep() end

        call_counter = call_counter +1
        timeToLive = timeToLive -1*STEP_RESOLUTION

	if call_counter >= collision_callfrequency*1/STEP_RESOLUTION then
		Event.emit{description="inquiline_worker"}
		call_counter = 0
	end

	if not Moving then 
		Move.toRandom() 
		repulsed = false
	end
	
	-- inquiline worker lifetime
	--------------
	if timeToLive <= 0 then
		say("Inquiline worker agent #" .. ID .." died at the old age of  ".. Core.time())
        Event.emit{description="inquiline_worker_died"}
        Event.emit{description="iwdistance",table={id=ID,dist=distance}}
        Agent.removeAgent(ID)
    end
   
    -- inquiline worker distances
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
