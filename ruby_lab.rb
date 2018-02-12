###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Bryan Plant
# bryanplant@gmail.com
#
###############################################################

$bigrams = Hash.new # The Bigram data structure
$name = "Bryan Plant"

# function to get song title, delete punctuation, and remove non-engish characters
def cleanup_title line
	song = line.gsub(/.*<SEP>/, '') # gget song title
	song.gsub!(/(\(|\[|\{|\\|\/|_|-|:|"|`|\+|=|\*|feat\.).*/, '') # delete superfluous text
	song.gsub!(/\?|!|¿|¡|\.|;|&|@|%|#|\|/, '') # delete punctuation
	song.downcase!() # convert to all lowercase letters
	song.gsub!(/\b(a|an|and|by|for|from|in|of|on|or|out|the|to|with)\b/, '') # remove common stop words
	song =~ /\A(\w|\s|\')+\z/? song : nil	# return the song if it is english or nil otherwise
end

# return the most common word to follow the given word
def mcw word
	max = 0
	maxWord = nil
	if $bigrams[word] != nil # check if there are any words that follow the given word
		$bigrams[word].each do |word2, count| # iterate through all following words
			if(count > max) # update most common word
				max = count
				maxWord = word2
			elsif(count == max) # randomly select word if it has the same count
				if(Random.rand(2) == 0)
					maxWord = word2
				end
			end
		end
	end
	maxWord # return max word
end

# create a title based on the most common words to follow each word
# in the title starting with the first given word
def create_title first
	title = [first]
	nextWord = first
	19.times do # add up to 19 words after the first
		nextWord = mcw(nextWord) # get the next word (most likely)
		if(nextWord == nil || title.include?(nextWord)) # end title if word is nil or repeating
			break
		else
			title.push(nextWord) # add word to title
		end
	end
	title * " " # return the list as a string separated with spaces
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		IO.foreach(file_name, encoding: "utf-8") do |line|
			title = cleanup_title(line) # get cleaned up song title
			if(title != nil)
				title = title.split(" ") # convert title into a list
				(title.length - 1).times do |i|
					if $bigrams[title[i]] == nil
						$bigrams[title[i]] = Hash.new # create a new hash as a value
					end
					if $bigrams[title[i]][title[i+1]] == nil
						$bigrams[title[i]][title[i+1]] = 1 # make the value of the hash 1 if this is the first occurence
					else
						$bigrams[title[i]][title[i+1]] += 1 # add one to the vlaue of the hash
					end
				end
			end
		end

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	while true
		puts "Enter a word [Enter 'q' to quit]:" # ask user for a starting word
		word = $stdin.gets.chomp # get user input
		if word == 'q' # end loop if user enters a 'q'
			break
		else
			puts create_title word # print out the title that is created
		end
	end
end

if __FILE__==$0
	main_loop()
end
