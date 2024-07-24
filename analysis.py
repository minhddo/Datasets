import re 

text_file="culprit_version23.txt"


# "Ambiguous specification of literal fact"

error_types = [
	"bibtex_error",
	"failed_to_load_theory",


	"failed_refine_pending_goal",
	"failed_apply_initial_method",
	"failed_apply_terminal_method",
	"failed_finish_proof",

	"ML_error", # --

	"undefined_terms",

	"ambiguous_input",

	"inner_syntax_error", # --

	"exception",

	"proof_failed",

	"lifting_failed",

	"not_a_constant",

	"type_unification_failed"

]

session_errors = {}
count = 0

count = {
	r'Failed to apply initial proof method( \(line (\d+) of \"([^\"]+)\"\))?:': 0,
	r'Failed to apply proof method( \(line (\d+) of \"([^\"]+)\"\))?:': 0,
	r'Failed to finish proof( \(line (\d+) of \"([^\"]+)\"\))?:': 0,
	r'Failed to apply terminal proof method( \(line (\d+) of \"([^\"]+)\"\))?:': 0
}


count_type = {
	"bibtex_error": 0,
	"failed_to_load_theory": 0,
	"undefined_terms": 0,
	"ambiguous_input": 0,
	"exception": 0,
	"not_a_constant": 0,
	"lifting_failed": 0,
	"type_unification_failed": 0,
	"proof_failed": 0,
	"ML_error": 0,
	"inner_syntax_error": 0
}
with open(text_file, 'r') as f:
	session_name = ""

	current_session = []
	current_err = {}

	current_ML_bundle = []
	current_ML_block = {}
	while line := f.readline():
		if line.strip() == "==========":
			if session_name != "":
				session_errors[session_name] = current_session
			session_name = ""
			current_session = []
			continue

		if session_name == "":
			session_name = line.strip()
		else:
			line = line.strip("* ")

			if line.startswith("At command "):
				if "error_type" in current_err:
					if current_err != "ML_error":
						if "command_name" not in current_err or "line" not in current_err or "file_path" not in current_err or not current_err["line"] or not current_err["file_path"]:
							match = re.search(r'At command \"([^\"]+)\" \(line (\d+) of \"([^\"]+)\"\)', line)
							if match:
								current_err["line"] = match.group(1)
								current_err["file_path"] = match.group(2)
					else:
						current_ML_bundle.append(current_ML_block)
						current_ML_block = {}
						for ml_error in current_ML_bundle:
							ml_error["error_type"] = "ML_error"
							if "file_path" in ml_error and "line" not in ml_error:
								match = re.search(r'At command \"([^\"]+)\" \(line (\d+) of \"([^\"]+)\"\)', line)
								if match:
									ml_error["line"] = match.group(1)
									ml_error["file_path"] = match.group(2)
							current_session.append(ml_error)
						current_ML_bundle = []
						current_err = {}
						continue
				current_session.append(current_err)
				current_err = {}
				continue


			bibtex_pattern = r'Bad bibtex_entry \"([^\"]+)\" \(line (\d+) of \"([^\"]+)\"\)'
			if (match := re.search(bibtex_pattern, line)):
				current_err["error_type"] = "bibtex_error"
				current_err["line"] = match.group(1)
				current_err["file_path"] = match.group(2)
				count_type["bibtex_error"] += 1
				current_session.append(current_err)
				current_err = {}
				continue


			file_error_pattern = r'Failed to load theory \"([^\"]+)\" \(unresolved (?:\"(?:[^\"]+)\", )*(?:\"([^\"]+)\")\)'
			if (match := re.search(file_error_pattern, line)):
				current_err["error_type"] = "failed_to_load_theory"
				current_err["file_failed"] = match.group(1)
				count_type["failed_to_load_theory"] += 1
				current_session.append(current_err)
				current_err = {}
				continue


			proof_error_patterns = [
				r'Failed to apply initial proof method( \(line (\d+) of \"([^\"]+)\"\))?:',
				r'Failed to apply proof method( \(line (\d+) of \"([^\"]+)\"\))?:',
				r'Failed to finish proof( \(line (\d+) of \"([^\"]+)\"\))?:',
				r'Failed to apply terminal proof method( \(line (\d+) of \"([^\"]+)\"\))?:'
			]
			is_proof_error = False
			for pattern in proof_error_patterns:
				if (match := re.search(pattern, line)):
					current_err["line"] = match.group(2)
					current_err["file_path"] = match.group(3)
					is_proof_error = True
					break
			if is_proof_error:
				continue


			undefined_terms_pattern = r'Undefined (?:fact|constant): \"([^\"]+)\" \(line (\d+) of \"([^\"]+)\"\)'
			if (match := re.search(undefined_terms_pattern, line)):
				current_err["error_type"] = "undefined_terms"
				current_err["term"] = match.group(1)
				current_err["line"] = match.group(2)
				current_err["file_path"] = match.group(3)
				count_type["undefined_terms"] += 1
				continue


			ambiguous_input_pattern = r'Ambiguous input \(line (\d+) of \"([^\"]+)\"\) produces (\d+) parse trees:'
			if (match := re.search(ambiguous_input_pattern, line)):
				current_err["error_type"] = "ambiguous_input"
				current_err["line"] = match.group(1)
				current_err["file_path"] = match.group(2)
				current_err["number_parse_trees"] = match.group(3)
				count_type["ambiguous_input"] += 1
				continue

			# inner_syntax_error_pattern = r''
			inner_syntax_error_pattern = r'Inner syntax error(?:.*?) \(line (\d+) of \"([^\"]+)\"\)'
			if (match := re.search(inner_syntax_error_pattern, line)):
				current_err["error_type"] = "inner_syntax_error"
				current_err["line"] = match.group(1)
				current_err["file_path"] = match.group(2)
				count_type["inner_syntax_error"] += 1
				continue

			exception_pattern = r'exception (.+?) raised \(line (\d+) of \"([^\"]+)\"\):(?:.+)*'
			if (match := re.search(exception_pattern, line)):
				current_err["error_type"] = "exception"
				current_err["exception_name"] = match.group(1)
				current_err["line"] = match.group(2)
				current_err["file_path"] = match.group(3)
				count_type["exception"] += 1
				continue

			# Proof failed
			if (match := re.search(r'Proof failed', line)):
				current_err["error_type"] = "proof_failed"
				count_type["proof_failed"] += 1
				continue

			# Lifting failed
			if (match := re.search(r'Lifting failed for the following types:', line)):
				current_err["error_type"] = "lifting_failed"
				count_type["lifting_failed"] += 1
				continue

			# Not a constant
			not_constant_pattern = r'Not a constant: \(([^\)]+)\)'
			if (match := re.search(not_constant_pattern, line)):
				current_err["error_type"] = "not_a_constant"
				current_err["not_constant_term"] = match.group(1)
				count_type["not_a_constant"] += 1
				continue

			# Type unification failed
			type_unification_pattern = r'Type unification failed: Clash of types (?:.*)'
			if (match := re.search(type_unification_pattern, line)):
				current_err["error_type"] = "type_unification_failed"
				# current_err["term1"] = match.group(1)
				# current_err["term2"] = match.group(2)
				count_type["type_unification_failed"] += 1
				continue

			# ML error
			ML_error_pattern = r'ML error \(line (\d+) of \"([^\"]+)\"\)' # - 188
			ML_error_pattern2 = r'ML error \(file \"([^\"]+)\"\)'
			if (match := re.search(ML_error_pattern, line)):
				count_type["ML_error"] += 1
				if "error_type" not in current_err:
					current_err["error_type"] = "ML_error"
					current_ML_block["line"] = match.group(1)
					current_ML_block["file_path"] = match.group(2)
				else:
					current_ML_bundle.append(current_ML_block)
					current_ML_block = {}
					current_ML_block["line"] = match.group(1)
					current_ML_block["file_path"] = match.group(2)
				continue
			if (match := re.search(ML_error_pattern2, line)):
				count_type["ML_error"] += 1
				if "error_type" not in current_err:
					current_err["error_type"] = "ML_error"
					current_ML_block["file_path"] = match.group(1)
				else:
					current_ML_bundle.append(current_ML_block)
					current_ML_block = {}
					current_ML_block["file_path"] = match.group(1)
					continue
print(count_type)


