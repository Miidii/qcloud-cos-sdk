# encoding: utf-8

require 'base64'
require 'openssl'
require 'digest'
require 'addressable/uri'

module QcloudCos
  class Authorization
    attr_reader :config

    # 用于对请求进行签名
    # @param config [Configration] specify configuration for sign
    #
    def initialize(config)
      @config = config
    end

    def sign(params = {}, headers = {}, options = {method: 'get', uri: '/'})
      current_time = Time.now.to_i

      q_sign_algorithm = 'sha1'
      q_ak = secret_id
      q_sign_time = current_time.to_s + ';' + (current_time + 3600).to_s
      q_key_time = q_sign_time
      q_header_list = headers.keys.sort.join(';').downcase
      q_url_param_list = params.keys.sort.join(';').downcase

      digest = OpenSSL::Digest.new('sha1')

      uri = Addressable::URI.new
      uri.query_values = params

      header_uri = Addressable::URI.new
      header_uri.query_values = headers

      sign_key = OpenSSL::HMAC.hexdigest(digest, secret_key, q_key_time)
      http_string = [options[:method].downcase, options[:uri].downcase, uri.query.downcase, header_uri.query.downcase, ''].join("\n")
      string_to_sign = ['sha1', q_sign_time, Digest::SHA1.hexdigest(http_string), ''].join("\n")
      puts http_string
      puts string_to_sign
      signature = OpenSSL::HMAC.hexdigest(digest, sign_key, string_to_sign)
      auth = %W[
        q-sign-algorithm=#{q_sign_algorithm}
        q-ak=#{q_ak}
        q-sign-time=#{q_sign_time}
        q-key-time=#{q_key_time}
        q-header-list=#{q_header_list}
        q-url-param-list=#{q_url_param_list}
        q-signature=#{signature}
      ].join('&')
      puts auth
    end

    private

    def app_id
      config.app_id
    end

    def secret_id
      config.secret_id
    end

    def secret_key
      config.secret_key
    end

    def rdm
      rand(10**9)
    end
  end
end
