-- fping to openwrt lua collector prometheus compatible converstion
-- use at your own risk. this is hard coded for my home setup, ymmv.
-- conor power 2024

local function scrape()
	file, err = io.open("/tmp/fping-output", "r")
	if file then
		for target in file:lines() do
			-- very fping format dependant 
			-- 1.1.1.1        : xmt/rcv/%loss = 1/1/0%, min/avg/max = 2.89/2.89/2.89
			-- 8.8.8.8        : xmt/rcv/%loss = 1/1/0%, min/avg/max = 2.81/2.81/2.81
			-- turns this list into a format that the existing lua exporter can understand
			
			-- This probably needs a better match for ipv4/ipv6 and dns
			local pingtgt = string.match(target, "^(.+) :")
			local pingdst = string.gsub(pingtgt, "%s+", "")

			local xmt, rcv, loss = string.match(target, "xmt/rcv/%%loss = (%d+)/(%d+)/(%d+)%%") 
			local min, avg, max = string.match(target, ", min/avg/max = (%d+%.%d+)/(%d+%.%d+)/(%d+%.%d+)") 
			
			local label = {
				endpoint = pingdst
			}
	
			metric("fping_packet_loss_percent", "gauge", label, loss)
		
			-- fping when no response is received doesn't print any stats 
			-- eg 224.1.2.3 : xmt/rcv/%loss = 1/0/100%
			-- so don't publish metrics at all
			if min then		
				metric("fping_packet_latency_min", "gauge", label, min)
				metric("fping_packet_latency_avg", "gauge", label, avg)
				metric("fping_packet_latency_max", "gauge", label, max)
			end
		end
	else
		print("Error reading file" .. err)
	end
end

return { scrape = scrape }
