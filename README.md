# Introduction
This repository aims to extract and analyse all categories of bugs/errors in building the Archive of Formal Proofs, getting an overview of how these errors should be fixed

# Structure
Folder `afp-getter`: Some sessions do not have their own folder, this script helps to generate the name of the folders that include those sessions (building the folders will also build these sessions)

Folder `data_getter{version1}{version2}`: (These) folders are the process of trying to build the AFP entries of the immediately previous version, using Isabelle of the current version (for example, the folder `data_getter1920` is the process of trying to build the AFP entries of 2019 version, using Isabelle2020)
	In these folders: (take folder `data_getter1920` as an example)
		+ `diff_results`: the file containing the diff results when comparing version 2019 and 2020
		+ `different_files`: the file containing name of the FILEs that differ from version 2019 to 2020
		+ `different_sessions`: the file containing name of the SESSIONs that differ from version 2019 to 2020
		+ `errlogall.txt`: file containing the build log for all sessions in `different_sessions`
		+ `dependency`: file listing for each sessions, which sessions they depend on
	The workflow for this process:
		+ `refresh.sh`: clear all build logs and build results
		+ `script.sh`: generate the diff for corresponding files in different AFP version
		+ `get_sessions.py`: generate the name of all sessions that differ between the two AFP versions
		+ `trybuild{version1}{version2}.sh`: try building the sessions of the previous version, using the current Isabelle version
		+ `workflow.sh`: collated workflow for the folder

File `culprit_version{version1}{version2}.txt`: These files document the build logs of sessions in AFP version1 that were failed to be built by Isabelle version2.


# Prerequisite
To replicate the result, we need Isabelle version from 2019 to 2023 installed, also AFPs version from 2019 to 2023 cloned from Heptapod.

# Process
Run `script.sh` in `afp-getter` to generate the substitute name for sessions.
For each folders `data_getter1920` to `data_getter2223`, run the `workflow.sh` file

# Extra
In file `analysis.py`, contain the Python code to analyse the build error log for sessions that were failed to be built (only for version 2022-2023) so far, and categorize them, using mostly regular expressions.

`numbers`: Some subcategories obtained using regular expression for the error log.

