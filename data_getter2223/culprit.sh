ISABELLE_DIR="(path to folder containing all Isabelle versions)"
for ver in 19 20 21 "21-1" 22 23
do
    # alias isa${ver}=${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle
    var_name="isa${ver//[^0-9]/}"
    value="${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle"
    eval "${var_name}=${value}"
done

errorlogfile="errlogall.txt"
culprit="culprit.txt"
touch "${culprit}"
for session_name in $(ls ../../AFPs/afp-2022/thys/)
do
	if grep -q "${session_name} FAILED" "${errorlogfile}"; then
		echo "==========" >> "${culprit}"
		echo "${session_name}" >> "${culprit}"
		eval "${isa23} build_log -H Error ${session_name}" >> ${culprit}
		echo >> "${culprit}"
	fi
done