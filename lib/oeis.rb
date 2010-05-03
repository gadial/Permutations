require 'net/http'
require 'uri'

def get_from_the_oeis(s)
  s_string = s.collect{|i| i.to_s}.join("%2C")
  address = "http://www.research.att.com/~njas/sequences/index.html?q=#{s_string}&language=english&go=Search"
  begin
    return Net::HTTP.get URI.parse(address)
  rescue Errno::ECONNREFUSED
    retry
  end
end

def ask_the_oeis(s)
  res = get_from_the_oeis(s)
  return "None" if res =~ /I am sorry, but the terms do not match anything in the table/
  res =~ /<a href="[^"]*" title="([^"]*)">/
  return $1 if nil != $1
  return "error"
end

def advanced_ask_the_oeis(s)
  res = get_from_the_oeis(s)
  return "None" if res =~ /I am sorry, but the terms do not match anything in the table/
  return res.scan(/<tr bgcolor="#EEEEFF">.*?<\/table>/m).collect{|s| s =~ /<td valign=top align=left>\n[ ]*(.*?)<\/td>/m; $1}
end
