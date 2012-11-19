util.AddNetworkString("Lambda Order")
net.Receive("Lambda Order", function(len, plr)
	local order = von.deserialize(net.ReadString())
	local entc = net.ReadUInt(16)
	local entities = {}
	for i = 1, entc do
		table.insert(entities, net.ReadEntity())
	end
	local err, msg = pcall(multiAssignOrder, plr, order, entities)
	if(err == false)then
		ErrorNoHalt(msg)
	end
end)

function multiAssignOrder(commander, order, entities)
	print("Order:")
	PrintTable(order)
	commander:ChatPrint("Order received with "..(#entities).." units as recipients!")
	for k,v in pairs(entities)do
		assignOrder(commander, order, v)
	end
end

function assignOrder(commander, order, entity)
	if((not IsValid(commander))
			or (not IsValid(entity))
			or (not order)
			or dTeams:getTeam(commander) ~= dTeams:getTeam(entity)
			or type(entity.Order)~="function")then
		return false
	end
	entity:Order(order)
end
