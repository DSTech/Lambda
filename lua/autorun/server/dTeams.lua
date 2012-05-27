--[[

         dTeams
		 
	addTeam(name, color)
		Creates an empty Team named 'name' with the color 'color'
	addAlliance(name, color)
		Creates an empty alliance named 'name' with color 'color'
	setTeam(ent,Team)
		Sets 'ent's Team to 'Team'
	getTeam(ent)
		Returns 'ent's Team
	getTeamColor(ent)
		Returns the color of the Team
	getTeamByName(name)
		Returns the Team table for the Team with name 'name'
	isAlly(ent1, ent2)
		Returns true if ent1 and ent2 are on the same alliance.
	isEnemy(ent1, ent2)
		Returns true if ent1 and ent2 are on different alliances
	getDefaultTeam()
		Returns the table of the default/neutral Team.
	getDefaultAlliance()
		Returns the table of the default/neutral alliance.
	getAlliance(Team)
		Returns the alliance table of 'Team'
	getEntityAlliance(ent)
		Returns the alliance table of 'ent'
	teamsAllied(team1, team2)
		Returns true if team1 and team2 are on the same, non-default alliance
]]--

local dTeamsLib = dTeams or {
	_Teams = {
		["Independent"]={name="Independent", color=Color(0,255,255,255), entities = {}, alliance = "No Alliance" }
	},
	_Entities = {
		--[entity] = "teamname"
	},
	_Alliances = {
		["No Alliance"] = {
			name = "No Alliance",
			color = Color(200,200,200,255),
			teams = {
				["Neutral"] = true
			}
		}
		--["AllianceName"] = { name = "name", color = Color(), teams = {"Team1" = true, "Team2" = true} }
	}
}

function dTeamsLib:addTeam(sName, cColor)
	if (sName==nil) then return false end
	if (cColor==nil) then return false end
	if self._Teams[sName] then return false end
	self._Teams[sName] = {
		name = sName,
		color = cColor,
		entities = {},
		alliance = self:getDefaultAlliance().name
	}
	return true
end

function dTeamsLib:addAlliance(sName, cColor)
	if (sName==nil) then return false end
	if (cColor==nil) then return false end
	if self._Alliances[sName] then return false end
	self._Alliances[sName] = {
		name = sName,
		color = cColor,
		teams = {}
	}
	return true
end

function dTeamsLib:setTeam(ent,Team)
	if (Team==nil) then print("teamnil") return false end
	if (ent==nil) then print("entnil") return false end
	if self._Teams[Team]==nil then print(Team,"teamnoexisto") return false end
	
	--Remove this entity from another team, if it exists within it
	local tm = self:getTeam(ent)
	if(tm)then
		for k,v in pairs(self._Teams[Team].entities)do
			if(v == ent)then
				table.remove(self._Teams[Team].entities, k)
				break
			end
		end
	end
	
	self._Entities[ent] = Team
	table.insert(self._Teams[Team].entities, ent)
	return true
end

function dTeamsLib:getTeam(ent)
	if ent==nil then return nil end
	return self._Entities[ent]
end

function dTeamsLib:getTeamColor(ent)
	return (self._Teams[self:getTeam(ent)] or self:getDefaultTeam()).color
end

function dTeamsLib:getAlliance(Team)
	if Team==nil then return self:getDefaultAlliance() end
	if self._Teams[Team] == nil then return false end
	return self._Alliances[self._Teams[Team].alliance]
end

function dTeamsLib:getAllianceByName(alliance)
	if self._Alliances[alliance]==nil then return self:getDefaultAlliance() end
	return self._Alliance[alliance]
end

function dTeamsLib:getEntityAlliance(ent)
	if ent==nil then return getDefaultAlliance() end
	if self._Entities[ent]!=nil then
		return self._Alliances[self._Teams[self._Entities[ent]].alliance]
	end
	return getDefaultAlliance()
end

function dTeamsLib:setAlliance(Team, alliance)
	if self._Teams[Team] == nil then return false end
	if self._Alliances[alliance] == nil then return false end
	table.remove(self._Alliances[ self._Teams[Team].alliance ].teams, Team)
	self._Alliances[alliance].teams[Team] = true
	self._Teams[Team].alliance = alliance
	return true
end

function dTeamsLib:getDefaultAlliance()
	return self._Alliances["No Alliance"]
end

function dTeamsLib:getDefaultTeam()
	return self._Teams["Independent"]
end

function dTeamsLib:getTeamByName(name)
	return self._Teams[name]
end

function dTeamsLib:isEnemy(this, that)
	local thisteam, thatteam = self:getTeam(this), self:getTeam(that)
	if thisteam==nil or thatteam==nil then return true end
	return self:teamsAllied(thisteam, thatteam)
end

function dTeamsLib:isAlly(this, that)
	return not (self:isEnemy(this, that))
end

function dTeamsLib:teamsAllied(team1, team2)
	local thisalliance, thatalliance = self:getAlliance(this), self:getAlliance(that)
	if(self:getAlliance(team1)==neutAlliance or self:getAlliance(team2)==neutAlliance)then
		return false
	end
	return self:getAlliance(team1)==self:getAlliance(team2)
end

function dTeamsLib:getTeamEntities(Team)
	return self._Teams[Team].entities
end

function dTeamsLib:getTeamsInAlliance(alliance)
	aTeams = {}
	for k,v in pairs(self._Alliances[alliance].teams) do
		aTeams[k] = self:getTeamByName(k)
	end
	return aTeams
end

function dTeamsLib:mergeAlliances(majorally, minorally)
	for name,v in pairs(self._Alliances[minorally]/teams) do
		self._Alliances[majorally].teams[name] = true
		table.remove(self._Alliances[minorally].teams, name)
	end
	table.remove(self._Alliances[minorally])
end

_G.dTeams = dTeamsLib
