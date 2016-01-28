require 'socket'  
#message = ARGV[1]
#port = ARGV[0]

cdir = Dir.getwd
h = Hash.new{0}
arr = Array.new(0){Hash.new}
while(true)
	#establish connections with file and directory servers
	fser = TCPSocket.new( "localhost", 2000)
	s = TCPSocket.new( "localhost", 8000)
	puts "Enter Command: " 
	command = gets.chomp
	#parse user command into
	#list directory communicates with directory server
	if command == "ls"
		s.write(command)
		str = s.recv( 1024 )  
		puts str
		#Change directory communicates with directory server
	elsif command.start_with?("cd") && command != "cd"
		s.write(command)
		str = s.recv( 1024 )
		if(!str.start_with?("File"))
			cdir = str
			Dir.chdir(cdir)
			command = "cd " + cdir
			fser.write(command)
		else
			puts "\nInvalid Entry\n"	
		end
	#Read and write both communicate with file server
	elsif command.start_with?("fnew") || command.start_with?("read")
		fname = command[5, command.length]
		fser.write(command)
		str = fser.recv( 1024 )
		fname = cdir + "/" + fname
		puts str
		if(h[fname] == 0)
			h[fname] = str
			#when cache is full, pop the oldest value
			if(arr.length >= 10)
				arr.pop()
			end
			#insert file path as key and data as value
			arr.insert(0, h[fname])
		end
	#Delete communicates with file server
	elsif command.start_with?("del")
		fser.write(command)
		str = fser.recv( 1024 )
		puts str
	end
end

s.close
