module Rack
  # Provides the option of serving SSL only for selected portion of subdomains (e.g. paid users only).
  # Other requests will be redirected to use standard HTTP.
  # Initialize with an array of privileged subdomains.  
  
  class PrivilegedSsl 

    def initialize(app, enabled_subdomains)
      @app = app
      @enabled_subdomains = enabled_subdomains
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.scheme == "https" 
       # check the given subdomain is in SSL enabled list
       unless ssl_enabled?(subdomains(request.host).first)
         modified_url = "http://#{request.host}#{request.fullpath}"
         return [302, {'Location' => modified_url }, []]
       end
      end

      @app.call(env)
    end

    def ssl_enabled?(account)
      @enabled_subdomains.include? account
    end

    def subdomains(host, tld_length = 1)
      return [] unless named_host?(host)

      parts = host.split('.')
      parts[0..-(tld_length+2)]
    end

    def named_host?(host)
      !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
    end

  end
end
