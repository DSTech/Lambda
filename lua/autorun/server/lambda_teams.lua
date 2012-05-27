pcall(concommand.Remove, "ListTeams")
concommand.Add("ListTeams", function(plr,cmd,args)
	plr:ChatPrint("List of teams:")
	for k,v in pairs(dTeams:getTeams())do
		plr:ChatPrint(v.name)
	end
end)

pcall(concommand.Remove, "ShowTeam")
concommand.Add("ShowTeam", function(plr,cmd,args)
	plr:ChatPrint("You are on team \""..tostring(dTeams:getTeam(plr)).."\"")
end)

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
	if not(dTeams._Teams[args[1]])then
		dTeams:addTeam(args[1], Color(math.random(255),math.random(255),math.random(255),255))
		plrSetTeam(plr, args[1])
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

function plrSetTeam(plr,TeamName)
	for k,v in pairs(plr:GetWeapons())do
		if(v:GetClass()=="lambda_commander")then
			v:ClearSelection()
		end
	end
	return (dTeams._Teams[TeamName] and dTeams:setTeam(plr, TeamName))
end
