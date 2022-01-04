require 'ipaddr'

module Turnout
  class Request
    def initialize(env)
      @rack_request = Rack::Request.new(env)
    end

    def allowed?(settings)
      path_allowed?(settings.allowed_paths) || ip_allowed?(settings.allowed_ips) || subdomain_allowed?(settings.allowed_subdomains)
    end

    private

    attr_reader :rack_request
    
    def subdomain_allowed?(allowed_subdomains)
      allowed_subdomains.any? do |allowed_subdomain|
        rack_request.host =~ Regexp.new(allowed_subdomain)
      end
    end

    def path_allowed?(allowed_paths)
      allowed_paths.any? do |allowed_path|
        rack_request.path =~ Regexp.new(allowed_path)
      end
    end

    def ip_allowed?(allowed_ips)
      begin
        ip = IPAddr.new(rack_request.ip.to_s)
      rescue ArgumentError
        return false
      end

      allowed_ips.any? do |allowed_ip|
        IPAddr.new(allowed_ip).include? ip
      end
    end
  end
end
