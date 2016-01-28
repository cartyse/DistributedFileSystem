require "socket"  
port = ARGV[0]
dts = TCPServer.new('localhost', port)  

puts "Server now open on port: #{port}"

POOL_SIZE = 2
#jobs = Queue.new

workers = (POOL_SIZE).times.map do
	Thread.new do 
		begin 
			while (client = dts.accept)
				#puts Thread.current 
				input = client.recv(1024)
				#list contents of directory
				if input == "ls"
					puts "Listing Directory"
					dirContent = Dir.pwd
					content = Dir.entries(dirContent)
					client.write(content)
					puts "Message sent to Client\n"
				#change directory
				elsif input.start_with?("cd")
      				str = input[3, input.length]
      				#directory present boolean
      				fp = false
      				Dir.entries('.').each do|f|
      					if(str == f)
      						fp = true
      						directory = Dir.getwd + "/" + input[3, input.length]
      						puts "Changing directory to: " + directory
      						Dir.chdir(directory)
      						client.write(directory)
      						Dir.pwd
      					end
      				end
      				if(!fp)
      					client.write("File or Directory doesn't exist\n")
      				end
				end
			end
		rescue ThreadError
		end
	end
end
workers.map(&:join)
dts.close
