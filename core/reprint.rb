# Reprint lines :D
# Made by vifino
def reprintinit
	print "\r"
	@lastline||=""
	def putsbelow(t)
		t=t.to_s.chomp||""
		if @written==nil then
				print "#{t.to_s}"
		else
			print "\n#{t.to_s}"
		end
		@written=true
		@lastline=t.to_s
	end
	def p(t)
		t=t.chomp||""
		if @written==nil then
			print "#{t.inspect}"
		else
			print "\n#{t.inspect}"
		end
		@written=true
		@lastline=t.inspect
	end
	def reprint(t)
		if t!=nil then
			str=""
			rel=(@lastline or "").length - t.length
			if rel>0 then
				str=" "*rel
			end
			print "\r#{t}"+str
		end
	end
	def puts(t)
			reprint(t)
			putsbelow @lastline
	end
end
reprintinit
