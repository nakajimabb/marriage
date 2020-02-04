require 'aws/ses'

ActionMailer::Base.add_delivery_method(:ses, AWS::SES::Base,
                                       access_key_id: Rails.application.credentials.dig(:aws_ses, :access_key_id),
                                       secret_access_key: Rails.application.credentials.dig(:aws_ses, :secret_access_key))
