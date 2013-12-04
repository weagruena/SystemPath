# SystemPath
#!/usr/bin/env ruby
#
require 'yaml'

# Exit while compiling
exit if Object.const_defined?(:Ocra)

@cfile = 'SystemPath.ini'
@setx = 'c:/Windows/System32/setx'

def append(folder)
	config()
	puts "[APPEND]"
	path = "#{@path};#{folder};"
	regwrite(path)	
end

def backup()
	config()
	xpath = ENV["Path"].split(";").sort
	if xpath.size > 0
		puts "[BACKUP] #{xpath.size.to_s}"
		File.rename(@cfile, "#{@cfile}.old") if File.exists?(@cfile)
		data = {"paths" => xpath, "settings" => @set}
		File.open(@cfile, "w") { |f| f.write(data.to_yaml) }
		puts "Backup file: '" + @cfile + "'"
	end
end

def config()
	if File.exists?(@cfile)
		@cfg = YAML.load_file(@cfile)
		@set = @cfg['settings']
		@sys = @cfg['system']		
	else
		puts 'Error loading file ' + @cfile
		exit
	end	
end

def regwrite(path)
	if @set['64bit']
		regexe = @set['reg64']
	else
		regexe = @set['reg32']
	end
	if @set['system']
		regp = '"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
	else
		regp = '"HKCU\Environment"'
	end
	cmd = "#{regexe} add #{regp} /v Path /t REG_EXPAND_SZ /d " + '"' + path + '" /f'
	system(cmd)
	puts "PATH update finished."
end

def restore()
	config()
	paths = @cfg['paths']
	if paths.size > 0
		path = ""
		paths.sort.each do |p|
			path = "#{path}#{p};"
		end
		puts "[RESTORE] #{paths.size.to_s}"
		regwrite(path)
	end	
end

###################################################

@path = ENV["Path"]
puts "SystemPath (2013) ruby.gruena.net"
puts "*" * 40

if ARGV.length < 1
	
	puts "Command is missing (only listing)."
	puts "Please run:\t'SystemPath.exe <command>'"
	puts "Commands:\t(b)ackup / (r)estore\n\t\t(a)ppend <folder>"
	puts "*" * 40
	paths = @path.split(";")
	if paths.size > 0
		puts "[LIST] #{paths.size.to_s}"
		paths.sort.each { |p| puts p } 
		system("pause")
	end	
else	
	comm = ARGV[0]
	if comm[0..1] == "b"
		backup()
	elsif comm[0..1] == "r"
		restore()
	elsif comm[0..1] == "a"
		if ARGV[1]
			append(ARGV[1].strip)
		end	
	end	
end
