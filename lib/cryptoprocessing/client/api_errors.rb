module Cryptoprocessing
  class APIError < RuntimeError
  end

  class BadRequestError < APIError
  end
end