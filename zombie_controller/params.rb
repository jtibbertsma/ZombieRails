class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    sym_params = route_params.merge(parse_www_encoded_form(req.query_string || ''))
      .merge(parse_www_encoded_form(req.body || ''))

    @params = stringify(sym_params)
  end

  def [](key)
    @params[key.to_s]
  end

  # this will be useful if we want to `puts params` in the server log
  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  def require(attribute)
    result = {attribute => self[attribute]}
    raise AttributeNotFoundError unless result[attribute]

    Params.new(fake_request, result)
  end

  def permit(*args)
    result = args.each_with_object({}) do |attribute, hash|
      hash[attribute] = @params[attribute] if @params[attribute]
    end

    Params.new(fake_request, result)
  end

  def permitted?(attribute)
    @params.include?(attribute)
  end

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    URI::decode_www_form(www_encoded_form).each_with_object({}) do |(key, value), hash|
      key = parse_key(key)
      hash_to_add = hash

      key.take(key.length - 1).each do |key_item|
        hash_to_add[key_item] ||= {}
        hash_to_add = hash_to_add[key_item]
      end

      hash_to_add[key.last] = value
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|[\[\]]/)
  end

  def stringify(sym_hash)
    return sym_hash.to_s if sym_hash.is_a? Symbol
    return sym_hash unless sym_hash.is_a? Hash

    sym_hash.each_with_object({}) do |(key, value), hash|
      hash[key.to_s] = stringify(value)
    end
  end

  def fake_request
    WEBrick::HTTPRequest.new(Logger: nil)
  end
end