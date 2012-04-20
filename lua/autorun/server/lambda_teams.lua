pcall(concommand.Remove, "JoinTeam")
concommand.Add("JoinTeam", function(plr,cmd,args)
	if(plrSetTeam(plr, args[1]))then
		plr:ChatPrint("You've joined the team \""..args[1].."\"!")
	else
		plr:ChatPrint("The team \""..args[1].."\" does not exist or is unjoinable.")
	end
end)

pcall(concommand.Remove, "CreateTeam")
concommand.Add("CreateTeam", function(plr,cmd,args)
	if(dTeams._Teams[args[1]])then
		dTeams:setTeam(plr, args[1])
		plr:ChatPrint("You've created the team \""..args[1].."\"!")
	else
		plr:ChatPrint("The team \""..args[1].."\" already exists.")
		if(plrSetTeam(plr, args[1]))then
			plr:ChatPrint("Instead, you've been placed on the pre-existing team.")
		else
			plr:ChatPrint("You also cannot be placed on that team, for arbitrary reasons.")
		end
	end
end)

function plrSetTeam(plr,Team)
	for k,v in pairs(plr:GetWeapons())do
		if(v:GetClass()=="lambda_commander")then
			v:ClearSelection()
		end
	end
	return dTeams._Teams[Team] and dTeams:setTeam(plr, Team)
end
