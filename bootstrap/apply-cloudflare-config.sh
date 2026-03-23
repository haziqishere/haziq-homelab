curl "https://api.cloudflare.com/client/v4/accounts/<ACCOUNT_ID>/cfd_tunnel/6c3da374-4317-4210-b505-ab56c6049416"/token \
  -H "Authorization: Bearer <TOKEN>

curl -X PUT \
  "https://api.cloudflare.com/client/v4/accounts/a5d481afecb71a5a505ad12302456e39/cfd_tunnel/6c3da374-4317-4210-b505-ab56c6049416/configurations" \
  -H "Authorization: Bearer <YOUR_API_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "warp_routing": {
        "enabled": true
      },
      "ingress": [
        {
          "hostname": "minecraft.haziqhakimi.online",
          "service": "tcp://minecraft-service.minecraft.svc.cluster.local:25565"
        },
        {
          "service": "http_status:404"
        }
      ]
    }
  }'