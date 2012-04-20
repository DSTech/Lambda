--[[

         dTeams
		 
	addTeam(name, color)
		Creates an empty team named 'name' with the color 'color'
	addAlliance(name, color)
		Creates an empty alliance named 'name' with color 'color'
	setTeam(ent,team)
		Sets 'ent's team to 'team'
	getTeam(ent)
		Returns 'ent's team
	getTeamColor(ent)
		Returns the color of the team
	getTeamByName(name)
		Returns the team table for the team with name 'name'
	isAlly(ent1, ent2)
		Returns true if ent1 and ent2 are on the same alliance.
	isEnemy(ent1, ent2)
		Returns true if ent1 and ent2 are on different alliances
	getDefaultTeam()
		Returns the table of the default/neutral team.
	getDefaultAlliance()
		Returns the table of the default/neutral alliance.
	getAlliance(team)
		Returns the alliance table of 'team'
	getEntityAlliance(ent)
		Returns the alliance table of 'ent'
	teamsAllied(team1, team2)
		Returns true if team1 and team2 are on the same, non-default alliance
]]--

local dTeamsLib = {
	_Teams = dTeams._Teams or {
		["Independents"]={name="Independents", color=Color(0,255,255,255), players = {}, entities = {}, alliance = "No Alliance" }
	},
	_Entities = dTeams._Entities or {
		--[entity] = "teamname"
	},
	_Players = dTeams._Players or {
		--[player] = "teamname"
	},
	_Alliances = dTeams._Alliances or {
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
		players = {},
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

function dTeamsLib:setTeam(ent,team)
	if (team==nil) then print("teamnil") return false end
	if (ent==nil) then print("entnil") return false end
	if self._Teams[team]==nil then print("teamnoexisto") return false end
	if (ent:IsPlayer()) then
		self._Players[ent] = team
		table.insert(self._Teams[team].players, ent)
	else
		self._Entities[ent] = team
		table.insert(self._Teams[team].entities, ent)
	end
	return true
end

function dTeamsLib:getTeam(this)
	if this==nil then return nil end
	if (this:IsPlayer()) then
		return self._Players[this]
	else
		return self._Entities[this]
	end
end

function dTeamsLib:getTeamColor(ent)
	return (self._Teams[self:getTeam(ent)] or self:getDefaultTeam()).color
end

function dTeamsLib:getAlliance(team)
	if team==nil then return self:getDefaultAlliance() end
	if self._Teams[team] == nil then return false end
	return self._Alliances[self._Teams[team].alliance]
end

function dTeamsLib:getAllianceByName(alliance)
	if self._Alliances[alliance]==nil then return self:getDefaultAlliance() end
	return self._Alliance[alliance]
end

function dTeamsLib:getEntityAlliance(ent)
	if ent==nil then return getDefaultAlliance() end
	if self._Entities[ent]!=nil then
		return self._Alliances[self._Teams[self._Entities[ent]].alliance]
	elseif self._Players[ent]!=nil then 
		return self._Alliances[self._Teams[self._Players[ent]].alliance]
	end
	return getDefaultAlliance()
end

function dTeamsLib:setAlliance(team, alliance)
	if self._Teams[team] == nil then return false end
	if self._Alliances[alliance] == nil then return false end
	table.remove(self._Alliances[ self._Teams[team].alliance ].teams, team)
	self._Alliances[alliance].teams[team] = true
	self._Teams[team].alliance = alliance
	return true
end

function dTeamsLib:getDefaultAlliance()
	return self._Alliances["No Alliance"]
end

function dTeamsLib:getDefaultTeam()
	return self._Teams["Independents"]
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

function dTeamsLib:getTeamEntities(team)
	return self._Teams[team].entities
end

function dTeamsLib:getTeamPlayers(team)
	return self._Teams[team].players
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
