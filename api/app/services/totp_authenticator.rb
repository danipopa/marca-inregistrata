class TotpAuthenticator
  ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  DIGITS = 6
  INTERVAL = 30
  WINDOW = 1

  class << self
    def generate_secret(length = 32)
      Array.new(length) { ALPHABET[SecureRandom.random_number(ALPHABET.length)] }.join
    end

    def provisioning_uri(email:, secret:, issuer: "Inregistrare Marca")
      label = "#{issuer}:#{email}"
      query = URI.encode_www_form(secret: secret, issuer: issuer, algorithm: "SHA1", digits: DIGITS, period: INTERVAL)

      "otpauth://totp/#{ERB::Util.url_encode(label)}?#{query}"
    end

    def verify?(secret, code, at: Time.current)
      normalized_code = code.to_s.gsub(/\s+/, "")
      return false unless normalized_code.match?(/\A\d{#{DIGITS}}\z/)

      counter = (at.to_i / INTERVAL).floor
      (-WINDOW..WINDOW).any? do |offset|
        ActiveSupport::SecurityUtils.secure_compare(generate_code(secret, counter + offset), normalized_code)
      end
    end

    private

    def generate_code(secret, counter)
      digest = OpenSSL::HMAC.digest("sha1", decode_base32(secret), [counter].pack("Q>"))
      offset = digest.bytes.last & 0x0f
      truncated_hash = digest.byteslice(offset, 4).unpack1("N") & 0x7fffffff

      (truncated_hash % (10**DIGITS)).to_s.rjust(DIGITS, "0")
    end

    def decode_base32(secret)
      bits = secret.to_s.upcase.each_char.filter_map do |character|
        next if character.match?(/\s/)

        value = ALPHABET.index(character)
        raise ArgumentError, "invalid base32 secret" unless value

        value.to_s(2).rjust(5, "0")
      end.join

      bits.scan(/.{8}/).map { |byte| byte.to_i(2).chr }.join
    end
  end
end
