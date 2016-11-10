class ExternalApi
  def self.api_request(url, options = {})
    options.reverse_merge!(:tries => 3, :raise_errors => false)
    tries ||= options[:tries]    
    req_options = options.except(:tries, :raise_errors)
    result = HTTParty.get(url, req_options)
  rescue => e
    sleep 3
    if (tries -= 1) > 0
      retry
    else
      return nil unless options[:raise_errors]
      raise "can't connect to API, #{e}"
    end
  else
    unless result.code == 200
      if (tries -= 1) > 0
        #code was not 200, lets try again
        sleep 3
        api_request(url, :tries => tries, :query => options[:query])
      else
        return nil unless options[:raise_errors]
        raise "API responded with non 200. #{result.code}"
      end
    else
      result
    end
  end
end
