import CloudFlare


cf = CloudFlare.CloudFlare()
zones = cf.zones.get(params={'per_page':150})

for zone in zones:
    records = cf.zones.dns_records.get(
        zone['id'], params={"name": zone['name'], "type": "CNAME"}
    )
    for record in records:
        print(zone['name'], record['type'], record['content'])