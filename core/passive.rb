# Passive data collection, WIP
# Made by vifino
@passivedata = Hash.new
def passive_newacc(acc)
	if not @passivedata[acc].class == "Hash" then
		@passivedata[acc] = Hash.new
		@passivedata[acc]["addr"] = ""
		@passivedata[acc]["acc"] = ""
		@passivedata[acc]["user"] = ""
		@passivedata[acc]["real"] = ""
		@passivedata[acc]["host"] = ""
		@passivedata[acc]["chan"] = {}
	end
end
def passive_process(raw)
	data= @bot.msgtype(raw)
	#p data
	type = data[0]
	nick = data[1]
	chan = data[2]
	msg = data[3]
	username = data[4]
	hostname = data[5]
	if type=="msg" or type=="notice" or type=="join" then
		#if nick then
			puts type
			if not @passivedata.include? nick then @passivedata[nick] = {} end
			@passivedata[nick]["user"] = username
			@passivedata[nick]["host"] = hostname
			if not @passivedata[nick]["chan"] then @passivedata[nick]["chan"] = [] end
			if not @passivedata[nick]["chan"].include? chan then @passivedata[nick]["chan"].push chan end
		#end
	elsif type=="nick" then
		# Move table to new pos
		puts "Nick Change"
		@passivedata[chan] = @passivedata[nick]
	end
end
def passive_start
	@fifoPassive = open("pipes/passive","r+")
	#if not job_passive then
		job_passive = fork do
			until false do
				passive_process(@fifoPassive.gets)
			end
		end
	#end
end
