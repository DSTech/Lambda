local dTeamsLib = dTeams or {}

function dTeamsLib:getTeam(ent)
	return ent:GetNetworkedString("dTeam")
end
