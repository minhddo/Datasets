ISABELLE_DIR="/home/quiqui/Desktop/2024_sem1/AutomaticProofRepair/Versions"
for ver in 19 20 21 "21-1" 22 23
do
    # alias isa${ver}=${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle
    var_name="isa${ver//[^0-9]/}"
    value="${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle"
    eval "${var_name}=${value}"
done


build_failed="failed.txt"
dependency="dependency.txt"
errorlogfile="errlogall.txt"


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

# This piece of code is to try to build every single session in the afp-2020 repository, 
# and echo out the stdout of the build to a file, the list of dependencies for that session to another file,
# and echo out all the sessions that failed to build to another file

# ================================
for session_name in $(cat different_sessions)
do
	if [ "${session_name}" = "Algebraic_Numbers" ] || [ "${session_name}" = "Berlekamp_Zassenhaus" ] || [ "${session_name}" = "ROOTS" ]; then
		continue
	fi
	if grep -Pzqo "===========\n${session_name}" "${dependency}"; then
		continue
	fi
	echo
	echo
	echo "============="
	echo "Building ${session_name}"
	included_build="-D ../../AFPs/afp-2020/thys/${session_name}"
	import_sessions=""
	outfile="out.txt"
	errfile="err.txt"
	eval "${isa21} build ${import_sessions} ${included_build} > ${outfile} 2> ${errfile}"
	echo "${session_name}" >> "${dependency}"
	echo "----" >> "${dependency}"
	all_imports=""
	logerr=""
	# The loop tries to build a session, continuously build it and add new prerequisite to the build command,
	# until all the prerequisite are met
	while [ -s "$errfile" ]; do
		if grep -q "missing" "$errfile"; then
			break
		fi
		if grep -q "Cannot load theory" "$errfile"; then
			break
		fi
		errlog=$(cat ${errfile})
		logerr+="$errlog\n"
		if ! grep -q "Bad parent session" "${errfile}" && ! grep -q "Bad imports session" "${errfile}"; then
			echo "===============" >> "${errorlogfile}"
			echo "${session_name}" >> "${errorlogfile}"
			echo >> "${errorlogfile}"
			echo "*** Unknown errors occured"
			echo "$(cat "$errfile")" >> "${errorlogfile}"
			echo >> "${errorlogfile}"
			echo >> "${dependency}"
			echo "===========" >> "${dependency}"
			echo "$session_name" >> "${build_failed}"
			continue 2
		fi
		extra_import=${errlog#*** Bad parent session \"}
		extra_import=${extra_import#*** Bad imports session \"}
		extra_import=${extra_import%\" for*}
		extra_import=$(find_substitute "$extra_import" "../afp-getter/substitute_ver2020")
		if [ "$extra_import" = "HOL-Word" ]; then
			echo "===============" >> "${errorlogfile}"
			echo "${session_name}" >> "${errorlogfile}"
			echo "*** HOL-Word import" >> "${errorlogfile}" 
			echo >> "${errorlogfile}"
			echo >> "${dependency}"
			echo "===========" >> "${dependency}"
			echo "$session_name" >> "${build_failed}"
			continue 2
		fi
		import_sessions+="-d ../../AFPs/afp-2020/thys/${extra_import} "

		all_imports+="${extra_import}\n"
		echo "${extra_import}" >> "${dependency}"
		eval "${isa21} build ${import_sessions} ${included_build} > ${outfile} 2> ${errfile}"
	done
	echo "===============" >> "${errorlogfile}"
	echo "${session_name}" >> "${errorlogfile}"
	echo "$(cat ${outfile})" >> "${errorlogfile}"
	echo >> "${errorlogfile}"
	echo >> "${dependency}"
	echo "===========" >> "${dependency}"
	echo "======Exit status======"
	echo $?
	if grep -q "Unfinished" "${outfile}"; then
		echo "Build failed"
		echo "${session_name}" >> "${build_failed}"
	elif [ -s "$errfile" ]; then
		echo "Build failed"
		cat "$errfile" >> "${errorlogfile}"
		echo "${session_name}" >> "${build_failed}"
	else
		echo "Build successful"
	fi
done
# ==========================