# Judith Tonhauser, Oct 2018, stop-manner-again project

# This Praat script extracts the labels and f0 values of the marks on point tier 2. 

form Get F0 Min-Max-Min
	sentence Directory /Users/tonhauser.1/Documents/current-research-topics/NSF-NAI/prop-att-experiments/8-stop-again-manner/results/f0-analyses-of-stimuli/adjunct-clauses/stimuli/
	word Base_file_name 
	comment Output file
	text textfile /Users/tonhauser.1/Documents/current-research-topics/NSF-NAI/prop-att-experiments/8-stop-again-manner/results/f0-analyses-of-stimuli/adjunct-clauses/f0-values.csv
endform

#Read all files in a folder
Create Strings as file list... wavlist 'directory$'/'base_file_name$'*.wav
Create Strings as file list... gridlist 'directory$'/'base_file_name$'*.TextGrid
n = Get number of strings

fileappend 'textfile$' File,label,time,f0 'newline$'

for i to n
clearinfo
#We first extract pitch tiers
	select Strings wavlist
	filename$ = Get string... i
	Read from file... 'directory$'/'filename$'
	soundname$ = selected$ ("Sound")
	To Pitch... 0.01 75 400
	output$ = "'soundname$'.Pitch"
	# Write to binary file... 'output$'

# We now read grid files and extract all intervals in them
	select Strings gridlist
	gridname$ = Get string... i
	Read from file... 'directory$'/'gridname$'
	int=Get number of points... 2

# Get beginning of utterance (2nd interval) and end of utterance (n-1 interval)
#	uttStart = Get starting point... 1	2
#	lastWord = 'int'-1
#	uttEnd = Get end point... 1 lastWord

# Get f0min and f0max of utterance
#	select Pitch 'soundname$'
#	uttf0min = Get minimum... uttStart uttEnd Hertz Parabolic
#	uttf0max = Get maximum... uttStart uttEnd Hertz Parabolic
	
# extract label, time and f0 value of points on tier 2
for k from 1 to 'int'
	select TextGrid 'soundname$'
	label$ = Get label of point... 2 'k'
	timePoint = Get time of point... 2 'k'
	select Pitch 'soundname$'
	f0 = Get value at time... timePoint Hertz Linear
	fileappend 'textfile$' 'soundname$','label$','timePoint','f0' 'newline$'
endfor
	
endfor

# clean up
select all
Remove