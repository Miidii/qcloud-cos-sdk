require './lib/qcloud_cos'

QcloudCos.configure do |config|
  config.app_id = "1252845034"
  config.secret_id = "AKIDDzc1A469KFwPepwtmQq1zidPxGOHqMXU"
  config.secret_key = "sWw9C1bx5yc9SXO0NVNzLRHtGOHvKUQ7"
  config.bucket = "memriver-public-1252845034"
  config.region = "ap-guangzhou"
end

QcloudCos.list_buckets