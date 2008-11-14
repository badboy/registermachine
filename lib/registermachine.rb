class Registermachine
  OPS = {
   'END' => :endWhile,
   'DUMP' => :dump,
   'GOTO' => [:gotoline, true],
   'CLOAD' => [:cloadto, true],
   'LOAD' => [:loadto, true],
   'STORE' => [:storeto,  true],
   'CADD' => [:caddto, true],
   'ADD' => [:addto, true],
   'CSUB' => [:csubreg, true],
   'SUB' => [:subreg, true],
   'CMULT' => [:cmultreg, true],
   'MULT' => [:multreg, true],
   'CDIV' => [:cdivreg, true],
   'DIV' => [:divreg, true]
  }
  
  def initialize(regcount=5, regstart=[])
    raise(ArgumentError, "regcount must be > 0") if regcount <= 0
    @programcounter = 0
    @registercount = regcount
    @register = [0]*@registercount
	if regstart.size > 0
	  regstart.each_with_index do |e, i|
		raise(Exception, "only positive integers allowed (got #{e})") if e < 0
		break if i >= @registercount
	    @register[i] = e
	  end
	end
    @totalcount = 0
  end
  
  def execute(code, trace=false)
    code = code.split("\n")
    code.delete_if { |l| l =~ /^\s*#/ || l == "" }
    @codel = code.size
	
	endnow = false
    while @programcounter < @codel
      @totalcount += 1
      com = code[@programcounter].dup.strip
      puts "execute \"#{com}\"" if trace

      @programcounter += 1

      if com =~ /^\s?IF r(\d+)=0 GOTO (\d+)\s?$/
        reg = $1.to_i
        line = $2.to_i
        raise(Exception, "goto #{line} impossible, source has onlye #{@codel} lines") if line > @codel
        if @register[reg-1] == 0
          @programcounter = line-1
        end
        next
      end

      com = com.split(/\s/, 2)
      if OPS.keys.include? com[0]
        op = OPS[com[0]]
        case op
          when Array
            raise(ArgumentError, 'wrong number of arguments (0 for 1)') unless op.size == 2
            raise(ArgumentError, 'wrong type, must be an integer') unless com[1] =~ /^\d+$/
            self.send(op[0], com[1].to_i)
          when :endWhile
            endnow = true
            break
          when Symbol
            self.send(op)
        end
      else
        raise(Exception, "unknown command: \"#{com.join(' ')}\"")
      end
      break if endnow
    end
	
    puts "[#{@register.join(', ')}] in line #{@programcounter} after #{@totalcount} steps"
  end
  
  private
  def dump
    puts "  [DUMP] [#{@register.join(', ')}] in line #{@programcounter} after #{@totalcount} steps"
    STDOUT.flush
  end

  def cmultreg(r)
    @register[0] *= r
  end

  def multreg(r)
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[0] *= @register[r-1]
  end

  def cdivreg(r)
    @register[0] /= r
  end

  def divreg(r)
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[0] /= @register[r-1]
  end

  def addto(r)
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[0]+= @register[r-1]
  end

  def storeto(r)
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[r-1] = @register[0]
  end

  def caddto(r)
    raise(ArgumentError, 'integer must be positive') if r < 0
    @register[0]+= r
  end

  def csubreg(r)
    raise(ArgumentError, 'integer must be positive') if r < 0
    @register[0]-= r
    @register[0]=0 if @register[0]<0
  end

  def subreg(r)
    raise(ArgumentError, 'integer must be positive') if r < 0
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[0]-= @register[r-1]
    @register[0]=0 if @register[0]<0
  end

  def gotoline(line)
    raise(Exception, "goto #{line} impossible, source has onlye #{codel} lines") if line > @codel
    @programcounter = line-1
  end

  def cloadto(r)
    @register[0] = r
  end

  def loadto(r)
    raise(Exception, "only #{@registercount} registers available, loading from #{r} impossible") if r > @registercount
    @register[0] = @register[r-1]
  end
end
