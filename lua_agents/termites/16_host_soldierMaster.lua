-- ------------------------------------------------------------------ --
-- 							HOST SOLDIER MASTER FILE				  --
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
host_soldier_amount = Shared.getNumber("host_soldier_amount")
host_soldier_count = 0
timeToLiveMax = Shared.getNumber("host_sol_timeToLive")
version = Shared.getTable("version")
distances = {}

-- ---------------------------------------------------------------------
-- initialize agent
-- ---------------------------------------------------------------------
function InitializeAgent() -- "soldier master" position

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

	if Event.description == "host_soldier_died" then
	host_soldier_count = host_soldier_count - 1
	table.insert(tempoDeath, Core.time())
	end
	
	if Event.description == "hsdistance" then
	distances[Event.table["id"]]=Event.table["dist"]
	end
	
end

function TakeStep()

	local P = host_soldier_amount/(timeToLiveMax/STEP_RESOLUTION)
		if Stat.randomFloat(0,1)<P then
			local posX = Stat.randomMean(30,ENV_HEIGHT/2)
			local posY = Stat.randomMean(30,ENV_HEIGHT/2)
			Agent.addAgent("16_host_soldier.lua", posX, posY)
			Event.emit{description="New host soldier"}
			table.insert(ids, ID)
			table.insert(tempo, Core.time())
			host_soldier_count = host_soldier_count + 1 -- counting births
			hsBornPosition = posX.. posY
			hsBornPositionX = posX
			hsBornPositionY = posY
		end
	
		Shared.storeNumber("hsBornPositionX", hsBornPositionX)
		Shared.storeNumber("hsBornPositionY", hsBornPositionY)
end

function CleanUp()
	
	file = io.open(version .. "_host_soldier_data.csv", "w")
	
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
	
	l_debug("Data collector  --inq soldier-- is done\n")
	
end
