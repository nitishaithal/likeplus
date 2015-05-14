module ApplicationHelper
require 'net/http'
require 'net/https' if RUBY_VERSION < '1.9'
require 'uri'
  # Returns the full title on a per-page basis.       # Documentation comment
  def full_title(page_title)                          # Method definition
    base_title = "Express yourself"			 			  # Variable assignment
    if page_title.empty?                              # Boolean test
      base_title                                      # Implicit return
    else
      "#{base_title} | #{page_title}"                 # String interpolation
    end
  end

 def remote_ip
    if request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '117.192.176.246'
    else
      request.remote_ip
    end
 end


end
