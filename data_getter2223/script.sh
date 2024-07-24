touch diff_results
echo -n > diff_results

touch different_files
echo -n > different_files
for session in $(ls ../../AFPs/afp-2022/thys)
do

	DIFF_DETAIL=`diff -r -x ROOT -x root.tex -x root.bib ../../AFPs/afp-2022/thys/${session} ../../AFPs/afp-2023/thys/${session}`

	if [ ! -z "${DIFF_DETAIL}" ]
	then
		echo "==========" >> diff_results
		echo $session >> diff_results
		echo -n >> diff_results
		diff -r -x ROOT -x root.tex -x root.bib ../../AFPs/afp-2022/thys/${session} ../../AFPs/afp-2023/thys/${session} >> diff_results

		echo "==========" >> different_files
		echo $session >> different_files
		echo -n >> different_files
		diff -rq -x ROOT -x root.tex -x root.bib ../../AFPs/afp-2022/thys/${session} ../../AFPs/afp-2023/thys/${session} >> different_files
		echo -n >> different_files
		echo -n >> different_files
	fi
done
echo "==========" >> different_files

