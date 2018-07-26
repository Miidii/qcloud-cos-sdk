# encoding: utf-8
require 'qcloud_cos/utils'
require 'qcloud_cos/multipart'
require 'qcloud_cos/model/list'
require 'httparty'
require 'addressable'
require 'nori'

module QcloudCos
  module Api
    include HTTParty


    # 列出 Buckets
    #
    # @param options [Hash] options
    #
    # @return [Hash]
    def list_buckets(options = {})

      uri = Addressable::URI.parse('https://service.cos.myqcloud.com/')

      headers = {
          'Host' => uri.host,
          'User-Agent' => user_agent
      }

      hash = parser.parse(
          HTTParty.get(uri.display_uri, headers: {
              'Authorization' => authorization.sign({}, headers, method: 'get', uri: uri.path)
          }.merge(headers), debug_output: $stdout).body
      )

      hash['ListAllMyBucketsResult']['Bucket']
    end

    # 上传文件
    #
    # @param path [String] 指定上传文件的路径
    # @param file_or_bin [File||String] 指定文件或者文件内容
    # @param options [Hash] options
    # @option options [String] :bucket (config.bucket_name) 指定当前 bucket, 默认是配置里面的 bucket
    # @option options [Integer] :biz_attr 指定文件的 biz_attr 由业务端维护, 会在文件信息中返回
    #
    # @return [Hash]
    def upload(path, file_or_bin, options = {})
      path = fixed_path(path)
      bucket = validates(path, options)

      url = generate_rest_url(bucket, path)

      uri = Addressable::URI.parse(url)

      headers = {
          'Host' => uri.host
      }

      response = HTTParty.put(url, headers: {
          'User-Agent' => user_agent,
          'x-cos-security-token' => '',
          'x-cos-storage-class' => 'STANDARD',
          'Content-Type' => 'text/txt; charset=utf-8',
          'Authorization' => authorization.sign({}, headers, method: 'put', uri: uri.path)
      }.merge(headers), body: file_or_bin.read)

      if response.code == 200
        return url
      else
        return ''
      end
    end

    alias create upload

    private
    def generate_tempfile(file_or_bin)
      tempfile = Tempfile.new("temp-#{Time.now.to_i}")
      tempfile.write(file_or_bin)
      tempfile.rewind
      tempfile
    end

    def parser
      Nori.new
    end

    def user_agent
      "qcloud-cos-sdk-ruby/#{QcloudCos::VERSION} #{RbConfig::CONFIG['host_os']} ruby-#{RbConfig::CONFIG['ruby_version']}"
    end

  end
end
