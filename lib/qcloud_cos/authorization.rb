# encoding: utf-8

require 'base64'
require 'openssl'
require 'digest'
require 'uri'

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
      q_sign_time = current_time.to_s + ';' + (current_time + 10000).to_s
      q_key_time = q_sign_time
      q_header_list = headers.keys.sort.join(';').downcase
      q_url_param_list = params.keys.sort.join(';').downcase

      digest = OpenSSL::Digest.new('sha1')

      params_str = params.sort.to_h.map do |k, v|
        "#{k.downcase}=#{URI.escape(v, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
      end.join('&')
      headers_str = headers.sort.to_h.map do |k, v|
        "#{k.downcase}=#{URI.escape(v, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
      end.join('&')

      sign_key = OpenSSL::HMAC.hexdigest(digest, secret_key, q_key_time)
      puts "sign key:" + sign_key
      http_string = [options[:method].downcase, options[:uri], params_str, headers_str, ''].join("\n")
      string_to_sign = ['sha1', q_sign_time, Digest::SHA1.hexdigest(http_string), ''].join("\n")
      puts "http string:" + http_string
      puts "string to sign:" + string_to_sign
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
      puts "auth:" + auth
      return auth
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
