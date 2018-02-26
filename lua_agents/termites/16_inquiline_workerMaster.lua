-- ------------------------------------------------------------------ --
-- 							INQUILINE WORKER MASTER FILE			  --
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
Core = require "ranalib_core"
RanaMath = require "ranalib_math"

-- ---------------------------------------------------------------------
-- initialization parameters
-- ---------------------------------------------------------------------
repulse = true
inquiline_worker_amount = Shared.getNumber("inquiline_worker_amount")
timeToLiveMax = Shared.getNumber("inq_wor_timeToLive")
inq_worker_count = 0
version = Shared.getTable("version")
distances = {}

-- ---------------------------------------------------------------------
-- initialize agent
-- ---------------------------------------------------------------------
function InitializeAgent() -- "worker master" position
	
	ids = {}
	tempo = {}
  	tempoDeath = {} 	
  	
  	PositionX = -10
	PositionY = -10

end

-- ---------------------------------------------------------------------
-- creating and counting inquilines soldiers
-- ---------------------------------------------------------------------
function HandleEvent(Event) -- counting of deaths

	-- say("got event "..Event.description) --debug
	if Event.description == "inquiline_worker_died" then
	inq_worker_count = inq_worker_count - 1
	table.insert(tempoDeath, Core.time())
	end
	
	if Event.description == "iwdistance" then
	distances[Event.table["id"]]=Event.table["dist"]
	-- say("got distance event " ..Event.table["id"] .." ".. Event.table["dist"]) --debug
	end
	
end

function TakeStep()
	
	local P = inquiline_worker_amount/(timeToLiveMax/STEP_RESOLUTION)
		if Stat.randomFloat(0,1)<P then
			local posX = Stat.randomMean(10,10)
			local posY = Stat.randomMean(10,10)
			Agent.addAgent("16_inquiline_worker.lua", posX, posY)
			Event.emit{description="New inquiline worker"}
			table.insert(ids, ID)
			table.insert(tempo, Core.time())
			inq_worker_count = inq_worker_count + 1
			iwBornPosition = posX.. posY
			iwBornPositionX = posX
			iwBornPositionY = posY
			--say("IW position is " ..iwBornPosition)
		end
		
		Shared.storeNumber("iwBornPositionX", iwBornPositionX)
		Shared.storeNumber("iwBornPositionY", iwBornPositionY)

end

function CleanUp()
	
	file = io.open(version .. "_inq_worker_data.csv", "w")
	
	file:write("\"Agent\",\"Time\",\"Death\"\n")
	for k,v in pairs(tempo) do
	file:write("\"is"..k.."\",\"".. v)
	file:write("\",\"" .. (tempoDeath[k] or "NaN") .. "\"\n")
	end
	file:write("\n\n\"Agent\",\"Distance\"\n")
	for k,v in pairs(distances) do 
	file:write("\"iw"..k.."\",\"".. v .."\"\n")
	end
	
	file:close()
	
	l_debug("Data collector --inq worker-- is done\n")
	
end
