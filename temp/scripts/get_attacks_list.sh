for NID in $(curl -s http://127.0.0.1:9443/api/v1/fleet/nodes | jq -r '.[].node_id'); do
  echo "=========================================================="
  curl -s "http://127.0.0.1:9443/api/v1/fleet/nodes/${NID}" | jq '{
    node_id,
    site,
    hostname,
    attacks_count: (.attacks | length),
    attacks: [.attacks[]]
  }'
done