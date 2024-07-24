#!/bin/bash
afp_folders="(path to folder containing all AFP versions)"
tmp="tmpfile.txt"

for version in 19 20 21 "21-1" 22 23
do
	echo "afp-20${version}"
	echo "       "
	thys_folder="${afp_folders}/afp-20${version}/thys"
	dfile=substitute_ver20${version}
	touch "${dfile}"
	for session in $(ls "${thys_folder}")
	do
		if [ "$session" = "etc" ]; then
			continue
		fi
		pathz="${thys_folder}/${session}"
		if [ -d "$pathz" ]; then
			values=($(sed -n 's/^session \([^ ]\+\) \((\([^ =]\+\)) \)\?\(in [^ =]\+ \)\?= [^ +]\+ +/\1/p' "$pathz/ROOT"))
			
			# remove whitespace
			for value in "${values[@]}"; do
				# Remove unwanted whitespaces and double quotes
				value=$(echo "$value" | sed 's/[[:space:]]//g')
				value=$(echo "$value" | sed 's/^"\([^"]\+\)"$/\1/;t;')
				if [ "$value" != "$session" ]; then

					echo "$value $session;" >> "$dfile"
				fi
			done
		fi
	done
done

find_substitute() {
	local input_string="$1"
	local rule_files="$2"

	if [[ ! -f "$rule_files" ]]; then
		echo "No rule files"
		return 1
	fi

	local substitute=$(grep -E "^$input_string " "$rule_files" | sed -e 's/^[^ ]\+ \([^;]\+\);$/\1/')
	if [[ -n "$substitute" ]]; then
		echo "$substitute"
		return 0
	else
		echo "$input_string"
		return 0
	fi
}
