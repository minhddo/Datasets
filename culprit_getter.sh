# ISABELLE_DIR="/home/quiqui/Desktop/2024_sem1/AutomaticProofRepair/Versions"
# for ver in 19 20 21 "21-1" 22 23
# do
#     # alias isa${ver}=${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle
#     var_name="isa${ver//[^0-9]/}"
#     value="${ISABELLE_DIR}/Isabelle20${ver}/bin/isabelle"
#     eval "${var_name}=${value}"
# done


for ver in 20 21 "21-1" 22 23
do
    if [ "$ver" = "20" ]; then
        log_dir="/home/quiqui/.isabelle/Isabelle20${ver}/heaps/polyml-5.8.1_x86_64_32-linux/log/"
    elif [ "$ver" = "21" ]; then
        log_dir="/home/quiqui/.isabelle/Isabelle20${ver}/heaps/polyml-5.8.2_x86_64_32-linux/log/"
    else
        log_dir="/home/quiqui/.isabelle/Isabelle20${ver}/heaps/polyml-5.9_x86_64_32-linux/log/"
    fi
    culprit_file="culprit_version${ver}.txt"
    echo "Current Isabelle version: Isabelle20${ver}"
    for session in $(ls "${log_dir}" | grep -Ev '\.db$|\.gz$')
    do
        echo "$session"
        echo "==========" >> "$culprit_file"
        echo "$session" >> "$culprit_file"
        cat "${log_dir}/${session}" >> "$culprit_file"
        echo >> "$culprit_file"
    done
done
