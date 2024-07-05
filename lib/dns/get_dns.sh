#! /bin/bash

source ./cyber_scan/lib/settings/services.sh
source ./cyber_scan/lib/settings/tor.sh
source ./cyber_scan/validators/domain_validator.sh
source ./cyber_scan/lib/scan/helpers/inputs.sh
source ./cyber_scan/lib/dns/extract_ips.sh
source ./cyber_scan/lib/util/success_output.sh
source ./cyber_scan/assets/set_color.sh

function get_dns()
{
	service "Extracting dns addresses"

	proxychains_input
	if [[ $proxychains == [Yy] ]]; then
		tor_service
		is_tor="proxychains"
	else
		is_tor=""
	fi

	domain_input
	base_name=$(domain_validator "$domain")
	if [ $? -ne 0 ]; then
        	return 1
    	fi

	dir_input

	website_name=$(echo "$base_name" | sed 's/\..*//')
	servers_names_file="scan/$dir_name/servers.txt"
	info_file="scan/$dir_name/info.txt"

	mkdir -p "scan/$dir_name"
	touch -c "$info_file"


	echo "Victim: $base_name" > "$info_file"

	$is_tor nslookup "$base_name" | grep "Address: " >> "$info_file" \
	 || { echo "$(set_color "red")Error:$(set_color "*") Failed to execute nslookup. Aborting."; return 1; }

	$is_tor host -t ns "$base_name" >> "$servers_names_file" \
	 || { echo "$(set_color "red")Error:$(set_color "*") Failed to execute host. Aborting."; return 1; }

	if [[ ! -s "$servers_names_file" ]]; then
		echo "$(set_color "red")Error:$(set_color "*") No IP addresses found for the website. Aborting."
            	return 1
        fi

	extract_ips $is_tor "$servers_names_file" \
	 || { echo "$(set_color "red")Error:$(set_color "*") Failed to extract IP addresses. Aborting."; return 1; }

	printf "\n\n\n\n" >> "$info_file"

	rm "$servers_names_file" \
	 || { echo "$(set_color "yellow")Warning:$(set_color "*") Failed to remove temporary file '$servers_names_file'."; }

	success_output "$dir_name" "$info_file"
}
