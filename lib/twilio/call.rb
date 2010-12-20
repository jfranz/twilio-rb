module Twilio
  class Call
    include Twilio::Resource
    include Twilio::Persistable
    extend Twilio::Finder

    class << self
      alias old_create create
      def create(attrs={})
        attrs = attrs.with_indifferent_access
        attrs.each { |k,v| v.upcase! if k.to_s =~ /method$/ }
        attrs[:send_digits] = CGI.escape(attrs[:send_digits]) if attrs[:send_digits]
        attrs['if_machine'].try :capitalize
        old_create attrs
      end
    end

    # Cancels a call if its state is 'queued' or 'ringing'    
    def cancel!
      modify_call 'Status' => 'cancelled'
    end
    
    def complete!
      modify_call 'Status' => 'completed'
    end
    
    # Update Handler URL
    def url=(url)
      # If this attribute exists it is assumed the API call to create a call has been made, so we need to tell Twilio.
      modify_call "url" => url if self[:status]
      self[:url] = url
    end

    private

    def modify_call(params)
      handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/Calls/#{self[:sid]}.json", :body => params
    end
  end
end
