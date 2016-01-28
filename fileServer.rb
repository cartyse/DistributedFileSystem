require "socket"  

arr = Array.new

#Lock and unlock push and pop paths onto a list 
def lock(fileName, arr)
	if !arr.include?(fileName)
		arr.insert(0,fileName)
		puts "value pushed"
	end
end

def unlock(fileName, arr)
	if arr.include?(fileName)
		index = arr.count(fileName)
		arr.pop(index)
		puts "Value popped"
	end
end

#checklocked checks to see if filename is in the list
def checkLocked(fileName, arr)
	return arr.include?(fileName)
end

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
				puts input
				if input.start_with?("fnew") && input.length > 4
					fname = input[5, input.length] 
					data = ""
					if !checkLocked(fname, arr)
						lock(fname, arr)
						File.open(fname, 'w') do |f|
							f.puts "Created by Sean Carty\nWooohooo!!"
							data = "Created by Sean Carty\nWooohooo!!" 
						end
						client.write(data)
						unlock(fname, arr)
					else
						client.write("\nFile is Locked\n")
					end 
				#read file
				elsif input.start_with?("read")
					fname = input[5, input.length] 
					if(!checkLocked(fname, arr))
						lock(fname, arr)
						puts "File Locked"
						File.open(fname, 'r') do |f1|
							while line = f1.gets
								client.write(line)
							end
						end	
						unlock(fname, arr)
						client.write("\nFile Read")
					else
						client.write("\nFile Locked\n")
					end
				#Change directory
				elsif input.start_with?("cd")
      				str = input[3, input.length]
      				puts "here"
      				puts str
      				Dir.chdir(str)
      				Dir.pwd
      			#Delete file
      			elsif input.start_with?("del") && input.length > 4
					name = input[4, input.length]
					if(!checkLocked(name,arr))
						lock(name, arr)
						fp = false
						Dir.entries('.').each do|f|
	      					if(name == f)
	      						fp = true
	      						str = Dir.getwd + "/" + f
	      						File.delete(str)
	      						client.write(str + " is deleted")
	      						Dir.pwd
	      					end
	      				end
	      				unlock(name, arr)
	      			else
	      				client.write("\nFile is locked")
	      			end
      				if(!fp)
      					client.write("File doesn't exist\n")
      				end
				end
			end
		rescue ThreadError
		end
	end
end
workers.map(&:join)
dts.close
