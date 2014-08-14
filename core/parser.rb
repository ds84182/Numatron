# The command Parser
# Made by vifino
$commands ||= Hash.new()
$helpdata ||= Hash.new()
$variables ||= Hash.new()
def addCommand(nme,val,help="No help for this command available.")
	$commands[nme]=val
	$helpdata[nme]=help
end
def help(topicorig="",nick="",chan="",rawargs="",pipeargs="")
	if not topicorig.empty? then
		topic=topicorig.split(" ").first.downcase
		if $helpdata[topic.strip] then
			if $helpdata[topic.strip].is_a?(Method) then
				"#{topic}: "+$helpdata[topic.strip].call.to_s
			elsif $helpdata[topic.strip].class == Proc then
				"#{topic}: "+$helpdata[topic.strip].call.to_s
			elsif $helpdata[topic.strip].class == Symbol then
				"#{topic}: "+self.send($helpdata[topic.strip]).to_s
			elsif $helpdata[topic.strip].class == String then
				"#{topic}: "+$helpdata[topic.strip].to_s
			end
		else
			"#{topic}: No such topic."
		end
	else
		"To view help about a specific topic, do '#{@prefix}help <topic>'"
	end
end
def argParser(args="",nick,chan)
	$variables["nick"]=nick
	$variables["chan"]=chan
	$variables["channel"]=chan
	#args=args.gsub(/\$<(.*?)>/) {|var|
	args=args.gsub(/<(.*?)>/) {|var=""|
		if not var.empty? then
			nme=(var or "< >").strip.gsub(/^</,"").gsub(/>$/,"")#.split(" ")[0]
			"<>" if (nme or "").empty?
			if $variables[nme] then
				if not $variables[nme.downcase]=="" then
					$variables[nme.downcase]
				else
					var
				end
			else
				var
			end
		end
	}
	args=args.gsub(/\${(.*)}/) {|cmdN|
		if not cmdN.empty? then
			commandRunner((cmdN.strip.gsub("${","").gsub("}","") or cmdN), nick, chan)
		end
	}
end
def sanitizer(input)
	input.delete("\x06") # Bell char. Evil.
end
def outconv(input)
	if input.class==Array then
		# This is the main thing.
		#input.to_s.gsub("^[","").gsub("]$","")
		output=""
		input.each {|c|
			output+=c+"; "
		}
		output.strip.strip.chomp(";")
	else
		input.to_s
	end
end
def commandRunner(cmd,nick,chan)
	cmd=cmd.strip
	retFinal=""
	retLast=""
	rnd= ('a'..'z').to_a.shuffle[0,8].join
	#retLast=rnd
	cmdarray = cmd.scan(/(?:[^|\\]|\\.)+/) or [cmd]
	#func, args = cmd.lstrip().split(' ', 2)
	runtimes=0
	cmdarray.each {|cmd|
		cmd=cmd.lstrip
		if cmd then
			cmd = cmd.gsub("\\|","|")
			func, args = cmd.split(' ', 2)
			args = argParser((args.to_s or ""),nick,chan)
			func=func.downcase()
			nargs=""
			if retLast.class==Array then
				nargs=retLast
				if !args.empty? then
					nargs.push args
				end
			elsif retLast.class==String
				if (args.to_s or "").empty? then
					nargs=retLast
				else
					nargs=args.to_s+retLast
				end
			elsif retLast.class==Number
					if (args.to_s or "").empty? then
						nargs=retLast.to_s
					else
						nargs=args.to_s+retLast.to_s
					end
			else
				nargs=(args or "")+retLast.to_s
			end
			if $commands[func] then
				if runtimes==0 then # first command
					if $commands[func].is_a?(Method) then
						retLast = $commands[func].call(nargs, nick, chan, args, "")
					elsif $commands[func].class == Proc then
						retLast = $commands[func].call(nargs, nick, chan, args, "")
					elsif $commands[func].class == Symbol then
						retLast = self.send($commands[func], nargs, nick, chan, args, "")
					elsif
						retLast = $commands[func]
					end
				else
					if $commands[func].is_a?(Method) then
						retLast = $commands[func].call(nargs, chan, args, retLast)
					elsif $commands[func].class == Proc then
						retLast = $commands[func].call(nargs, chan, args, retLast)
					elsif $commands[func].class == Symbol then
						retLast = self.send($commands[func], nargs, nick, chan, args, retLast)
					elsif
						retLast = $commands[func]
					end
				#retLast=self.send(@commands[func],(args or "")+retLast,nick,chan) or ""
				end
			else
				if @cmdnotfound then
					retLast = "No such function: '#{func}'"
				end
				break
			end
			runtimes+=1
		end
	}
	return outconv(retLast) if not (retLast==rnd or (retLast.to_s or "").empty?)
end
def commandParser(cmd,nick,chan) # This is the entry point.
	#job_parser = fork do
	Thread.new do
		begin
			ret=commandRunner(cmd, nick, chan)
			if ret then
				if ret.to_s.length > 200 then
					@bot.msg(chan,"> Output: "+putHB(sanitizer(ret.to_s)))
				else
					@bot.msg(chan,"> "+sanitizer(ret.to_s))
				end
			end
		rescue Exception => detail
			@bot.msg(chan,detail.message())
		end
		#exit
	end
	#Process.detach(job_parser)
end
addCommand("let",->(args="",nick="",chan="",rawargs="",pipeargs=""){
	if not args.empty? then
		if data=args.match(/(.*?)=(.*)/) then
			p data
			$variables[data[1].strip.downcase] = data[2].strip
			return "Set Variable '#{data[1].downcase}' to '#{data[2]}'"
		else
			return "Missing input."
		end
	else
		return "Missing input."
	end
},"Assign Values to Variables.")
addCommand("help",:help,"Shows help on certain topics.")
