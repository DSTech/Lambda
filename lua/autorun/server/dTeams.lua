--[[

         dTeams
		 
	addTeam(name, color)
		Creates an empty team named 'name' with the color 'color'
	addAlliance(name, color)
		Creates an empty alliance named 'name' with color 'color'
	setTeam(team, ent)
		Sets 'ent's team to 'team'
	getTeam(ent)
		Returns 'ent's team
	getTeamByName(name)
		Returns the team table for the team with name 'name'
	isAlly(ent1, ent2)
		Returns true if ent1 and ent2 are on the same alliance.
	isEnemy(ent1, ent2)
		Returns true if ent1 and ent2 are on different alliances
	getNeutralTeam()
		Returns the table of the default/neutral team.
	getNeutralAlliance()
		Returns the table of the default/neutral alliance.
	getAlliance(team)
		Returns the alliance table of 'team'
	getEntityAlliance(ent)
		Returns the alliance table of 'ent'
	teamsAllied(team1, team2)
		Returns true if team1 and team2 are on the same, non-default alliance
]]--


dTeams = {
	_Teams = {
		["Independents"]={name="Independents", color=Color(0,255,255,255), players = {}, entities = {}, alliance = "No Alliance" }
	},
	_Entities = {
		--[entity] = "teamname"
	},
	_Players = {
		--[player] = "teamname"
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

function dTeams.addTeam(sName, cColor)
	if (sName==nil) then return false end
	if (cColor==nil) then return false end
	dTeams._Teams[sName] = {
		name = sName,
		color = cColor,
		players = {},
		entities = {},
		alliance = dTeams.getNeutralAlliance().name
		}
	if dTeams._Teams[sName]==nil return false end
	return true
end

function dTeams.addAlliance(sName, cColor)
	if (sName==nil) then return false end
	if (cColor==nil) then return false end
	dTeams._Alliances[sName] = {
		name = sName,
		color = cColor,
		teams = {}
		}
	if dTeams._Alliances[sName]==nil then return false end
	return true
end

function dTeams.setTeam(team, ent)
	if (team==nil) then return false end
	if (ent==nil) then return false end
	if dTeams._Teams[team]==nil then return false end
	if (ent:IsPlayer()) then
		dTeams._Player[ent] = team
		table.insert(dTeams._Teams[team].players, ent)
	else
		dTeams._Entities[ent] = team
		table.insert(dTeams._Teams[team].entities, ent)
	end
	return true
end

function dTeams.getTeam(this)
	if this==nil then return dTeams.getNeutralTeam()
	if (this:IsPlayer()) then
		return dTeams._Players[this]
	else
		return dTeams._Entities[this]
	end
	return dTeams.getNeutralTeam()
end

function dTeams.getAlliance(team)
	if team==nil then return dTeams.getNeutralAlliance() end
	if dTeams._Teams[team] == nil then return false end
	return dTeams._Alliances[dTeams._Teams[team].alliance]
end

function dTeams.getAllianceByName(alliance)
	if dTeams._Alliances[alliance]==nil then return dTeams.getNeutralAlliance() end
	return dTeams._Alliance[alliance]
end

function dTeams.getEntityAlliance(ent)
	if ent==nil then return getNeutralAlliance() end
	if dTeams._Entities[ent]!=nil then
		return dTeams._Alliances[dTeams._Teams[dTeams._Entities[ent]].alliance]
	else if dTeams._Players[ent]!=nil then 
		return dTeams._Alliances[dTeams._Teams[dTeams._Players[ent]].alliance]
	end
	return getNeutralAlliance()
end

function dTeams.setAlliance(team, alliance)
	if dTeams._Teams[team] == nil then return false end
	if dTeams._Alliances[alliance] == nil then return false end
	table.remove(dTeams._Alliances[ dTeams._Teams[team].alliance ].teams, team)
	dTeams._Alliances[alliance].teams[team] = true
	dTeams._Teams[team].alliance = alliance
	return true
end

function dTeams.getNeutralAlliance()
	return dTeams._Alliances["No Alliance"]
end

function dTeams.getNeutralTeam()
	return dTeams._Teams["Independents"]
end

function dTeams.getTeamByName(name)
	return dTeams._Teams[name]
end

function dTeams.isEnemy(this, that)
	if this==nil or that==nil then return true end
	return dTeams.teamsAllied(dTeams.getTeam(this), dTeams.getTeam(that))
end

function dTeams.isAlly(this, that)
	return !dTeams.isEnemy(this, that)
end

function dTeams.teamsAllied(team1, team2)
	if (getAlliance(team1)==getNeutralAlliance() or getAlliance(team2)==getNeutralAlliance()) then return false end
	return getAlliance(team1)==getAlliance(team2)
end

function dTeams.getTeamEntities(team)
	return dTeams._Teams[team].entities
end

function dTeams.getTeamPlayers(team)
	return dTeams._Teams[team].players
end

function dTeams.getTeamsInAlliance(alliance)
	aTeams = {}
	for k,v in pairs(dTeams._Alliances[alliance].teams) do
		aTeams[k] = getTeamByName(k)
	end
	return aTeams
end

function dTeams.mergeAlliances(majorally, minorally)
	for name,v in pairs(dTeams._Alliances[minorally]/teams) do
		dTeams._Alliances[majorally].teams[name] = true
		table.remove(dTeams._Alliances[minorally].teams, name)
	end
	table.remove(dTeams._Alliances[minorally])
end
