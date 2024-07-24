with open("different_files", 'r') as f:
	with open("different_sessions", 'w') as g:
		started = False
		for line in f:
			if started == False:
				if line.startswith("="):
					started = True
			else:
				g.write(line)
				started = False
