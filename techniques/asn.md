
# An ASN maps an organization to its IP ranges.

So instead of just:
	site.com → some IPs

You get:
	Company → ALL owned IP ranges

That means:
- Hidden assets
- Forgotten servers
- Non-CDN endpoints
- Internal/exposed services


# Example concept

If target uses something like:
- Cloudflare → hides origin
- BUT they still have IPs in their ASN → possible origin leak


# When ASN is VERY useful

Use ASN recon when:
- Target is big company
- Bug bounty scope says: “assets owned by organization”
- CDN hides origin (Cloudflare, Akamai)

# When NOT to waste time

Skip or limit ASN if:
- Target is small (1–2 domains)
- Clearly hosted fully on cloud (AWS/GCP shared infra)
- Scope is strict (only specific domains)


https://bgp.he.net
