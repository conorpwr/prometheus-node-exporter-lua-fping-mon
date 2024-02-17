This assumes you have an existing set up that polls the router correctly

1. Ensure you have fping and prometheus-node-exporter-lua installed
2. Copy fpingmon.lua into /usr/lib/lua/prometheus-collectors/
3. Run a script that writes the output of fping into /tmp/fping-output

You should start seeing metrics under fping_packet_latency_(avg|min|max) and fping_packet_loss_percent

Example of the script used to write fping stats

```
while true;
	do fping -f /tmp/fping-list -c 5 -q &> /tmp/fping-output.tmp;
	cp /tmp/fping-output.tmp /tmp/fping-output
	sleep 15;
done
```
