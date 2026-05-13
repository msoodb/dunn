
NS Record
	example.com NS ns1.provider.com
	Which DNS servers are authoritative for the domain.
	These are the official government offices that know everything about this domain.
	dig NS cibil.com

SOA Record
	Start Of Authority.
	Master record for the whole zone.
	The domain's official registry document.
	
A Record;
	example.com -> 1.2.3.4
	Maps a domain name to an IPv4 address.
	example.com lives at 1.2.3.4
	dig A cibil.com
	dig A sub.example.com @dns1.dnsserver.net

AAAA Record
	Same as A record, but for IPv6.

CNAME Record
	shop.example.com -> stores.example.net
	Alias to another domain.
	This business is known by another name.

MX
	example.com MX mail.example.com
	Deliver my letters HERE.
	dig MX cibil.com
	
TXT Record
	Generic text storage.
	Public notes attached to the domain.
	dig TXT cibil.com
	dig TXT cibil.com @dns1.dnsserver.net

SPF
	v=spf1 ip4:1.2.3.4 -all
	Like a trusted sender list.
	Only THESE people may send letters in my name.
	Which servers are allowed to send mail for the domain.

DKIM
	Cryptographic email signature.
	Proves email was genuinely sent by authorized server and not modified.
	Official wax seal/signature on the letter.
	
DMARC
	Policy for failed SPF/DKIM checks.
	Tells receivers what to do with suspicious mail.
	If the letter signature is fake, throw it away or mark suspicious.

PTR Record
	Reverse DNS.
	Given a street address, tell me who lives there.
	IP -> name

DNS zone transfer.The idea is:
	“Can I ask the authoritative DNS server to give me the entire DNS database (zone) for cibil.com?”
	That is done with AXFR.
	dig axfr cibil.com @dns1.cscdns.net
	host -l cibil.com dns1.cscdns.net
	Without AXFR success, You CANNOT directly dump all records.DNS does not provide: Give me everything.
	Normally you must enumerate manually.
