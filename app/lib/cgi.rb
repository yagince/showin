# -*- coding: utf-8 -*-
class CGI
  def self.parse(query)
    params = {}
    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split('=',2)#.collect{|v| CGI::unescape(v) } # unescapeはそのうち持ってくる
      if key && value
        params.has_key?(key) ? params[key].push(value) : params[key] = [value]
      elsif key
        params[key]=[]
      end
    end
    params.default=[].freeze
    params    
  end
end
