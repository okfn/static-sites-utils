import os
import sys

try:
    import tldextract
    import CloudFlare
except ImportError:
    print(
        """This script requires the following packages:

    pip install -r requirements.txt
    """
    )
    sys.exit(1)

RECORD_CONTENT = "c.storage.googleapis.com"

def update_cname_records(domains, new_record_content, proxied):

    for domain in domains:
        print(f'Updating {domain} to {new_record_content}')
        update_cname_record(domain, new_record_content, proxied)


def update_cname_record(domain, new_record_content, proxied):

    parts = tldextract.extract(domain)

    root = parts.registered_domain
    subdomain = parts.subdomain

    cf = CloudFlare.CloudFlare()
    zones = cf.zones.get(params={"name": root})

    if not zones:
        print(f"Error - Zone not found: {root}")
        sys.exit(1)

    zone_id = zones[0]["id"]

    # Check if DNS record exists

    records = cf.zones.dns_records.get(
        zone_id, params={"name": domain, "type": "CNAME"}
    )

    params = {
        "name": domain,
        "type": "CNAME",
        "content": new_record_content,
        "ttl": 1,
        "proxied": proxied,
    }

    if not records:

        # Create a new record
        cf.zones.dns_records.post(zone_id, data=params)
        print(f"Created new CNAME record for {domain}")
    else:

        if records[0]["content"] == new_record_content:
            print("Existing CNAME record already has the correct value")
            return

        record_id = records[0]["id"]

        # Update existing record
        cf.zones.dns_records.put(zone_id, record_id, data=params)

        print(f"Updated existing CNAME record for {domain}")


if __name__ == "__main__":

    domains_input = sys.argv[1]
    if len(sys.argv) > 1:
        # usually k8s-production.openknowledge.io (not proxied)
        new_record_content=sys.argv[2]
        # false for k8s-production.openknowledge.io, True for c.storage.googleapis.com (default)
        proxied=bool(int(sys.argv[3]))
    else:
        # Default is moving to oki-archive
        new_record_content=RECORD_CONTENT
        proxied = True

    if os.path.exists(domains_input):
        with open(domains_input, "r") as f:
            domains = [l.strip() for l in f.readlines()]
    else:
        domains = domains_input.split(",")

    update_cname_records(domains, new_record_content, proxied)

    print(f"Done, processed {len(domains)} domains")
