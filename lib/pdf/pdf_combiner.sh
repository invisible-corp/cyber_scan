#! /bin/bash

source ./cyber_scan/lib/scan/helpers/inputs.sh
source ./cyber_scan/validators/domain_validator.sh
source ./cyber_scan/validators/paths_validator.sh
source ./cyber_scan/assets/set_color.sh

function pdf_combiner()
{
	file_input

	paths_input
	if [ $? -ne 0 ]; then
		return 1
	fi

	> "$file_name.nmap"

    	for path in "${path_array[@]}"; do
        	cat "$path" >> "$file_name.nmap"
    	done

}
