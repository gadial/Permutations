require 'net/http'
require 'uri'

def ask_the_oeis(s)
  s_string = s.collect{|i| i.to_s}.join("%2C")
  address = "http://www.research.att.com/~njas/sequences/index.html?q=#{s_string}&language=english&go=Search"
  begin
    res = Net::HTTP.get URI.parse(address)
    return "None" if res =~ /I am sorry, but the terms do not match anything in the table/
    res =~ /<a href="[^"]*" title="([^"]*)">/
    return $1 if nil != $1
    return "error"
  rescue Errno::ECONNREFUSED
    retry
  end
end