# Geolocate IP's using geoip databases
# Made by vifino
require 'geoip'
geoipdb = "modules/geoip/GeoIP.dat"
geocitydb = "modules/geoip/GeoLiteCity.dat"
if not (File.exists?(geoipdb) and File.exists?(geoipdb))
	puts "GeoIP Databases not found! The GeoIP Commands will not work!"
else
	@geoipdb = GeoIP.new(geoipdb)
	@geocitydb = GeoIP.new(geocitydb)
	$commands["geoip_country"] = :geoip_country
	$commands["geoip_city"] = :geoip_city
	$commands["geoip"] = :geoip_country
end
def geoip_country(args,nick,channel)
	if args then
		addr = (args+" ").split(" ")[0]
		#addr=args
		begin
			res = @geoipdb.country(addr)
			return "Country: "+res.country_name+", '"+res.country_code3+"'"
		rescue => exception
			return "Invalid URL or URL not found!"
		end
	end
end
def geoip_city(args,nick,channel)
	if args then
		addr = (args+" ").split(" ")[0]
		puts addr
		#addr=args
		begin
			res = @geocitydb.city(addr)
			p res
			return ""+res.city_name+", "+res.country_name
		rescue => exception
			return "Invalid URL or URL not found!"
		end
	end
end
