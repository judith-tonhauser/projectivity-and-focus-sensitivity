#################################################################
## create-grids.praat
## 
## For all .wav files in a directory, 
##	- if no TextGrids exist: creates TextGrids with f0 point tier
##	- if TextGrids exist: allows for modification of that tier
##
## Adapted by Judith Tonhauser Oct 2018 for stop-manner-again project
##
## Adapted by Robert Daland
## Dept. of Linguistics @ Northwestern University
## 10/18/2004
##
## Original code by 
## Pauline Welby
## welby@ling.ohio-state.edu
## September 12, 2002
##
#################################################################

form Input 
	#check box if TextGrids already exist, otherwise uncheck box
	boolean TextGrids_exist 0 
	#check box if TextGrids already exist and you want to add more tiers
	boolean I_want_to_add_tiers 0
	sentence DirName /Users/tonhauser.1/Documents/current-research-topics/NSF-NAI/prop-att-experiments/8-stop-again-manner/results/f0-analyses-of-stimuli/main-clauses/problems/
endform

Create Strings as file list... fileList 'dirName$'*.wav
nFiles = Get number of strings
for i to nFiles
	# get sound filename
	select Strings fileList
	fileName$ = Get string... i
	Read from file... 'dirName$''fileName$'
	name$ = selected$("Sound")

			
	#if TextGrids already exist
	if (textGrids_exist) 
		#checks if TextGrids really exists
		if fileReadable("'dirName$''name$'.TextGrid") 
			#if TextGrids you want to add tiers
			if (i_want_to_add_tiers)
				Read from file... 'dirName$''name$'.TextGrid
				Insert point tier... 2 f0
				#Insert interval tier... 3 phonology
				plus Sound 'name$'
				Edit
				pause Modify TextGrid as desired
				select TextGrid 'name$'
				Write to text file... 'dirName$''name$'.TextGrid
				plus Sound 'name$'
				Remove
			#if you just want to update your analyses in fully specified TextGrids
			else  
				Read from file... 'dirName$''name$'.TextGrid
				plus Sound 'name$'
				Edit
				pause Modify TextGrid as desired
				select TextGrid 'name$'
				Write to text file... 'dirName$''name$'.TextGrid
				plus Sound 'name$'
				Remove
			endif
		#if no TextGrids exist yet, script complains
		else 
			exit NO TEXTGRID EXISTS YET
		endif
	#if user specified that no TextGrid exists yet, script checks that that is the case
	else 
		if fileReadable("'dirName$''name$'.TextGrid") 
		   exit TEXTGRID EXISTS ALREADY
		# if really no TextGrid exists, create a TextGrid with a "f0" point tier
		else 
			select Sound 'name$'
			To TextGrid: "f0", "f0"
			plus Sound 'name$'
			Edit
			pause Label f0 as intervals
			select TextGrid 'name$'
			Write to text file... 'dirName$''name$'.TextGrid
			plus Sound 'name$'
			Remove
		endif
	endif
endfor

# clean up
select Strings fileList
Remove

