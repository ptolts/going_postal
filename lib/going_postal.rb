# The GoingPostal mixin provides classes with postcode formatting and validation
# methods. If the class has a #country_code method, the country_code argument on
# the provided methods becomes optional. If the class also has one of #postcode,
# #post_code, #zipcode, #zip_code, or #zip, the string argument on the provided
# methods becomes optional.
# 
#   class Address
#     include GoingPostal
#     attr_accessor :number, :street, :city, :postcode, :country_code
#     
#     def initialize(number, street, :city, postcode, country_code="GB")
#       self.number = number
#       self.street = street
#       self.city = city
#       self.postcode = postcode
#       self.country_code = country_code
#     end
#     
#     def postcode=(value)
#       @postcode = format_postcode(value)
#     end
#     
#     def valid?
#       number && street && city && postcode_valid?
#     end
#   end
# 
# The methods can also be called directly on the GoingPostal module.
# 
#   GoingPostal.postcode?("sl41eg", "GB")      #=> "SL4 1EG"
#   GoingPostal.postcode?("200378001", "US")   #=> "20037-8001"
# 
# Currently supported countries are United Kingdom (GB, UK), United States (US),
# Canada (CA), Australia (AU), New Zeland (NZ), and South Africa (ZA).
# 
# Ireland (IE) is supported insomuch as, Ireland doesn't use postcodes, so "" or
# nil are considered valid.
# 
# Currently unsupported countries will be formatted by simply stripping leading
# and trailing whitespace, and any input will be considered valid.
# 
module GoingPostal
  extend self
  
  # :section: Validation
  
  # :call-seq: postcode?([string[, country_code]]) -> formatted_str or false
  # 
  # Returns a formatted postcode as a string if string is a valid postcode,
  # false otherwise.
  # 
  # If calling this method on the GoingPostal module the country_code argument
  # is required and should be a two letter country code.
  # 
  # If the GoingPostal module has been mixed in to a class, and the class has
  # a #country_code method, the country_code argument is optional, defaulting
  # to the value returned by #country_code. If the class also has a #postcode,
  # #post_code, #zipcode, #zip_code, or #zip method, the string argument becomes
  # optional.
  # 
  # Postcodes for unknown countries will always be considered valid, the return
  # value will consist of the input stripped of leading and trailing whitespace.
  # 
  # Ireland (IE) has no postcodes, "" will be returned from in input of "" or
  # nil, false otherwise.
  # 
  def postcode?(*args)
    string, country_code = get_args_for_format_postcode(args)
    if country_code.to_s.upcase == "IE"
      string.nil? || string.to_s.empty? ? "" : false
    else
      format_postcode(string, country_code) || false
    end
  end
  alias post_code? postcode?
  alias zip? postcode?
  alias zipcode? postcode?
  alias zip_code? postcode?
  alias valid_postcode? postcode?
  alias valid_post_code? postcode?
  alias valid_zip? postcode?
  alias valid_zipcode? postcode?
  alias valid_zip_code? postcode?
  alias postcode_valid? postcode?
  alias post_code_valid? postcode?
  alias zip_valid? postcode?
  alias zipcode_valid? postcode?
  alias zip_code_valid? postcode?
  
  # :call-seq: self.valid?([string[, country_code]]) -> formatted_string or false
  # 
  # Alias for #postcode?
  #--
  # this is just here to trick rdoc, the class alias below will overwrite this
  # empty method.
  #++
  def self.valid?; end
  
  class << self
    alias valid? postcode?
  end
  
  # :section: Formatting
  
  # :call-seq: format_postcode([string[, country_code]]) -> formatted_str or nil
  # 
  # Returns a formatted postcode as a string if string is a valid postcode, nil
  # otherwise.
  # 
  # If calling this method on the GoingPostal module the country_code argument
  # is required and should be a two letter country code.
  # 
  # If the GoingPostal module has been mixed in to a class, and the class has
  # a #country_code method, the country_code argument is optional, defaulting
  # to the value returned by #country_code. If the class also has a #postcode,
  # #post_code, #zipcode, #zip_code, or #zip method, the string argument becomes
  # optional.
  # 
  # Postcodes for unknown countries will simply be stripped of leading and
  # trailing whitespace.
  # 
  # Ireland (IE) has no postcodes, so nil will always be returned.
  #--
  # The magic is done calling a formatting method for each country. If no such
  # method exists a default method is called stripping the leading and trailing
  # whitespace.
  #++
  def format_postcode(*args)
    string, country_code = get_args_for_format_postcode(args)
    method = :"format_#{country_code.to_s.downcase}_postcode"
    respond_to?(method) ? __send__(method, string) : false
  end
  alias format_post_code format_postcode
  alias format_zip format_postcode
  alias format_zipcode format_postcode
  alias format_zip_code format_postcode
  
  # :stopdoc:
  
  def format_ie_postcode(string)
    nil
  end

  #Hungraian
  def format_hu_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{4}\b/).first
      return res
    end
  end

  #Czech
  def format_cz_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{3}\s?[0-9]{2}\b/).first
      return res
    end
  end

  #Denmark
  def format_dk_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b(DK(-| )?)?[0-9]{4}\b/).first
      return res
    end
  end  

  #Poland
  def format_pl_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{2}(\-|\s)[0-9]{3}\b/).first
      return res
    end
  end 

  #Portugal
  def format_pt_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{4}(\s|\-)[0-9]{3}\b/).first
      return res
    end
  end    

  #Azerbaijan
  def format_az_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[A-Z]{2}(\s|\-|)[0-9]{4}\b/).first
      return res
    end
  end 

  #Singapore
  def format_sg_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{6}\b/).first
      return res
    end
  end    
  #same as Romania
  alias format_ro_postcode format_sg_postcode

  #Lithuania
  def format_lt_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[A-Z]{2}(\s|\-|)[0-9]{5}\b/).first
      return res
    end
    if res = out_code.scan(/\b[0-9]{5}\b/).first
      return res
    end    
  end  

   
  #Brazil
  def format_br_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{5}\s?[0-9]{3}\b/).first
      return res
    end
  end   
   
  #Slovakia
  def format_sk_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[0-9]{3}\s?[0-9]{2}\b/).first
      return res
    end
  end 

  #Netherlands
  def format_nl_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[1-9][0-9]{3}\s?[a-zA-Z]{2}\b/).first
      return res
    end
  end    

  def format_fr_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b([0-9]{5})\b/).first
      return res
    end
  end
  #same as germany
  alias format_de_postcode format_fr_postcode
  #same as italian
  alias format_it_postcode format_fr_postcode
  #same as serbia
  alias format_rs_postcode format_fr_postcode
  #same as estonia
  alias format_ee_postcode format_fr_postcode  
  #same as croatia
  alias format_hr_postcode format_fr_postcode  
  #same as turkey
  alias format_tr_postcode format_fr_postcode  

  def format_in_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b([0-9]{6})\b/).first
      return res
    end
  end
  
  def format_gb_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]? {0,1}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)\b/).first
      return res
    end
  end
  alias format_uk_postcode format_gb_postcode
  
  def format_ca_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$/).first
      return res
    end    
  end
  
  #Australia
  def format_au_postcode(string)
    string = string.to_s.strip
    string if string =~ /\b[0-9]{4}\b/
  end
  #New Zealand
  alias format_nz_postcode format_au_postcode
  #South Africa
  alias format_za_postcode format_au_postcode
  #Norway
  alias format_no_postcode format_au_postcode 
  #Denmark
  alias format_dk_postcode format_au_postcode  
  
  def format_us_zipcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/^\d{5}(?:[-\s]\d{4})?$/).first
      return res
    end
  end
  alias format_mx_postcode format_us_zipcode
  
  def format_ch_postcode(string)
    out_code = string.to_s.upcase.strip
    if res = out_code.scan(/\b[1-9][0-9]{3}\b/).first
      return res
    end
  end
  
  private
  
  def get_args_for_format_postcode(args)
    case args.length
    when 2
      args
    when 0
      [postcode_for_format_postcode, country_code_for_format_postcode]
    when 1
      args << country_code_for_format_postcode
    else
      message = "wrong number of arguments (#{args.length} for 0..2)"
      raise ArgumentError, message, caller(2)
    end
  end
  
  def country_code_for_format_postcode
    if respond_to?(:country_code)
      country_code
    else
      raise ArgumentError, "wrong number of arguments (1 for 0..2)", caller(3)
    end
  end
  
  POSTCODE_ALIASES = [:postcode, :post_code, :zipcode, :zip_code, :zip]
  def postcode_for_format_postcode
    if ali = POSTCODE_ALIASES.find {|a| respond_to?(a)}
      send(ali)
    else
      raise ArgumentError, "wrong number of arguments (0 for 0..2)", caller(3)
    end
  end
  
end
