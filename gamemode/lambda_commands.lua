util.AddNetworkString("Lambda Order")
net.Receive("Lambda Order", function(len, plr)
	local order = von.deserialize(net.ReadString())
	local entc = net.ReadUInt(16)
	local entlst = {}
	for i = 1, entc do
		table.insert(entlst, net.ReadEntity())
	end
	PrintTable(order)
	plr:ChatPrint("Order received with "..(#entlst).." units as recipients!")
end)
