# The command Parser
# Made by vifino
$commands ||= Hash.new()
$variables ||= Hash.new()
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
			args = argParser((args or ""),nick,chan)
			func=func.downcase()
			if $commands[func] then
				if runtimes==0 then # first command
					if $commands[func].is_a?(Method) then
						retLast = $commands[func].call(args.to_s, nick, chan, args, "")
					elsif $commands[func].class == Proc then
						retLast = $commands[func].call(args.to_s, nick, chan, args, "")
					elsif $commands[func].class == Symbol then
						retLast = self.send($commands[func], args.to_s, nick, chan, args, "")
					else
						retLast = $commands[func]
					end
				else
					if $commands[func].is_a?(Method) then
						retLast = $commands[func].call((args.to_s or "")+retLast, chan, args, retLast)
					elsif $commands[func].class == Proc then
						retLast = $commands[func].call((args.to_s or "")+retLast, chan, args, retLast)
					elsif $commands[func].class == Symbol then
						retLast = self.send($commands[func], (args.to_s or "")+retLast, nick, chan, args, retLast)
					else
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
	return retLast if not (retLast==rnd or (retLast.to_s or "").empty?)
end
def commandParser(cmd,nick,chan) # This is the entry point.
	#job_parser = fork do
	Thread.new do
		begin
			ret=commandRunner(cmd, nick, chan)
			if ret then
				if ret.to_s.length > 200 then
					@bot.msg(chan,"> Output: "+putHB(ret.to_s))
				else
					@bot.msg(chan,"> "+ret.to_s)
				end
			end
		rescue Exception => detail
			@bot.msg(chan,detail.message())
		end
		#exit
	end
	#Process.detach(job_parser)
end
$commands["let"]=->(args="",nick="",chan="",rawargs="",pipeargs=""){
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
}
