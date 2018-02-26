-- ------------------------------------------------------------------ --
-- 							MASTER FILE								  --
-- ------------------------------------------------------------------ --

-- ---------------------------------------------------------------------
-- import Rana lua libraries
-- ---------------------------------------------------------------------
Agent = require "ranalib_agent"
Shared = require "ranalib_shared"
Stat = require "ranalib_statistic"

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
version = "Final"
Shared.storeTable("version", version)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- ---------------------------------------------------------------------
-- repulsion/detection range
-- ---------------------------------------------------------------------
inquiline_repulsion_range = Stat.randomMean(0.5,5)
inquiline_wor_detection_range = Stat.randomMean(0.5,5)
inquiline_sol_detection_range = Stat.randomMean(0.8,8)
host_wor_detection_range = Stat.randomMean(0.3,3)
host_sol_detection_range = Stat.randomMean(0.6,6)
collision_callfrequency = .500 

-- ---------------------------------------------------------------------
-- agents lifetime
-- ---------------------------------------------------------------------
inq_wor_timeToLive = Stat.randomMean(2.2,22.08) -- (sd, mean)
inq_sol_timeToLive = Stat.randomMean(6.6,22.08)
host_sol_timeToLive = Stat.randomMean(4.8,16)
host_wor_timeToLive = Stat.randomMean(1.6,16)

-- ---------------------------------------------------------------------
-- nest density
-- ---------------------------------------------------------------------
--total_pop = inquiline_worker_amount + inquiline_soldier_amount + host_soldier_amount + host_worker_amount
area_one_termite = 8
t_density = 0.2
screen_area = ENV_HEIGHT*ENV_WIDTH
area_termites = screen_area*t_density
max_termites = screen_area*t_density/area_one_termite

host_prop = 0.88
inq_prop = 0.12
hw_fraction = 0.6
hs_fraction = 0.4
iw_fraction = 0.9
is_fraction = 0.1

host_number = math.floor(max_termites*host_prop)
inq_number = math.floor(max_termites*inq_prop)
iw = math.floor(inq_number*iw_fraction)
is = math.floor(inq_number*is_fraction)
hw = math.floor(host_number*hw_fraction)
hs = math.floor(host_number*hs_fraction)

-- ---------------------------------------------------------------------
-- agents amount
-- ---------------------------------------------------------------------
inquiline_worker_amount = iw --9 -- red agent
inquiline_soldier_amount = is --1 -- yellow agent
host_soldier_amount = hs --22 -- green agent
host_worker_amount = hw --52 --blue agent

-- ---------------------------------------------------------------------
-- agents speed
-- ---------------------------------------------------------------------
inq_wor_speed = Stat.randomMean(0.2,2)
inq_sol_speed = Stat.randomMean(0.2,2)
host_wor_speed = Stat.randomMean(0.6,6)
host_sol_speed = Stat.randomMean(0.6,6)

-- ---------------------------------------------------------------------
-- load up the oscillator agents
-- ---------------------------------------------------------------------
function InitializeAgent()

	say("The number of agents should be " ..max_termites.. ". Host number: " .. host_number .. " (HW = " ..hw .. ", HS = " ..hs.. "). Inquiline number: " .. inq_number .. " (IW = " ..iw .. ", IS = " ..is.. ")")
	
	-- add the data collector agent
  	PositionX = -10
	PositionY = -10

	host_ids = {} -- create tables
	inquiline_ids = {} -- create tables
						
	-- store and share data
	Shared.storeNumber("inquiline_repulsion_range", inquiline_repulsion_range)
	Shared.storeNumber("inquiline_wor_detection_range", inquiline_wor_detection_range)
	Shared.storeNumber("inquiline_sol_detection_range", inquiline_sol_detection_range)
	Shared.storeNumber("host_wor_detection_range", host_wor_detection_range)
	Shared.storeNumber("host_sol_detection_range", host_sol_detection_range)
	Shared.storeNumber("collision_callfrequency", collision_callfrequency)
	Shared.storeNumber("inquiline_worker_amount", inquiline_worker_amount)
	Shared.storeNumber("inquiline_soldier_amount", inquiline_soldier_amount)
	Shared.storeNumber("host_soldier_amount", host_soldier_amount)
	Shared.storeNumber("host_worker_amount", host_worker_amount)
	Shared.storeNumber("inq_wor_timeToLive", inq_wor_timeToLive)
	Shared.storeNumber("inq_sol_timeToLive", inq_sol_timeToLive)
	Shared.storeNumber("host_sol_timeToLive", host_sol_timeToLive)
	Shared.storeNumber("host_wor_timeToLive", host_wor_timeToLive)
	Shared.storeNumber("inq_wor_speed", inq_wor_speed)
	Shared.storeNumber("inq_sol_speed", inq_sol_speed)
	Shared.storeNumber("host_wor_speed", host_wor_speed)
	Shared.storeNumber("host_sol_speed", host_sol_speed)

	-- host
	--------------
		local ID = Agent.addAgent("16_host_workerMaster.lua") -- blue agent
		table.insert(host_ids, ID)
		
		local ID = Agent.addAgent("16_host_soldierMaster.lua") -- green agent
		table.insert(host_ids, ID)
	
	-- inquiline
	--------------
		local ID = Agent.addAgent("16_inquiline_workerMaster.lua") -- red agent
		table.insert(inquiline_ids, ID)

		local ID = Agent.addAgent("16_inquiline_soldierMaster.lua") -- yellow agent
		table.insert(inquiline_ids, ID)

	-- data
	--------------
	
	Shared.storeTable("inquiline_ids", inquiline_IDs)
	Shared.storeTable("host_ids", host_IDs)
	Shared.storeTable("matrix", interaction_table)	
end

	-- creating interaction table
	title={			"hw",		"hs",		"iw",		"is"}
	l1={	"hw",	["hw"]=0,	["hs"]=0,	["iw"]=0,	["is"]=0} -- the agent of the line encounters the agent of the column
	l2={	"hs",	["hw"]=0,	["hs"]=0,	["iw"]=0,	["is"]=0}
	l3={	"iw",	["hw"]=0,	["hs"]=0,	["iw"]=0,	["is"]=0}
	l4={	"is",	["hw"]=0,	["hs"]=0,	["iw"]=0,	["is"]=0}

	matrix={["hw"]=l1,["hs"]=l2,["iw"]=l3,["is"]=l4}

function HandleEvent(Event)
	
	if Event.description == "interaction" then
	matrix[Event.table.first][Event.table.second]=matrix[Event.table.first][Event.table.second]+1
	end

end

function CleanUp()
	
	-- saving interaction table
	file = io.open(version .. "_interaction_data.csv", "w")

	-- write out the line of headers
	file:write("\"Interaction\"")
	for col=1, 4 do
	file:write(",\"" .. title[col] .. "\"")
	end
	-- end the header row
	file:write("\n")
	-- write the matrix with a column of labels to the left
	for row=1,4 do
	-- write the row label
	file:write("\"" .. title[row] .. "\"")
	-- write the row of data
	for col=1, 4 do
	file:write(",\"" .. matrix[title[row]][title[col]] .. "\"")
	end
	-- end the row
	file:write("\n")
	end
	
	file:close()
	
	l_debug("Data collector  --interaction table-- is done\n")
	
end
