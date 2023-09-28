# Judith Tonhauser, February 2019, prosody of stop/manner/again project

# This Praat assumes that the beginning and the end of the utterance is marked (point tier 1)
# What is marked in the stimuli files is the beginning and the end of the main clause
# The script will give the f0 values at the beginning and the end, and at 10ms intervals


form Get F0 Min-Max-Min
	sentence Directory /Users/tonhauser.1/Documents/current-research-topics/NSF-NAI/prop-att-experiments/8-stop-again-manner/results/f0-analyses-of-stimuli/main-clauses/stimuli/
	word Base_file_name 
	comment Output file
	text textfile /Users/tonhauser.1/Documents/current-research-topics/NSF-NAI/prop-att-experiments/8-stop-again-manner/results/f0-analyses-of-stimuli/main-clauses/f0values.csv
	comment How frequently should an f0 value be extracted?
	positive Time_step_(s) 0.01
endform

#Read all files in a folder
Create Strings as file list... wavlist 'directory$'/'base_file_name$'*.wav
Create Strings as file list... gridlist 'directory$'/'base_file_name$'*.TextGrid
n = Get number of strings
#writeInfoLine: n

fileappend 'textfile$' File,time,f0 'newline$'

for i to n
clearinfo

# Get the list of files in directory
	select Strings wavlist
	filename$ = Get string... i
	Read from file... 'directory$'/'filename$'
	soundname$ = selected$ ("Sound")

# Set appropriate f0 values for extraction
minimum_pitch = 50
maximum_pitch = 350

# Extract pitch tiers
	To Pitch... time_step minimum_pitch maximum_pitch
	output$ = "'soundname$'.Pitch"

# Read grid files and extract all points on tier 1 (points mark beginning and end of main clause)
	select Strings gridlist
	gridname$ = Get string... i
	Read from file... 'directory$'/'gridname$'
	int=Get number of points... 1
	writeInfoLine: gridname$

# Extract f0 values between the two points on tier 1
select TextGrid 'soundname$'
startTime = Get time of point... 1 1
endTime = Get time of point... 1 2
   
select Pitch 'soundname$'

first_frame = Get frame from time... 'startTime'
last_frame = Get frame from time... 'endTime'

		for j from 'first_frame' to 'last_frame'+1

			t_frame = Get time from frame... j
			#writeInfoLine: t_frame
			f0 = Get value at time... 't_frame' Hertz Linear
			if f0 <> undefined
				fileappend 'textfile$' 'soundname$','t_frame','f0' 'newline$'
			elsif f0 = undefined
				fileappend 'textfile$' 'soundname$','t_frame',NA'newline$'
			endif

		#writeInfoLine: numberOfFrames
	
		endfor

endfor

# clean up
select all
Remove