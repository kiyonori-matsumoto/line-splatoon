require 'json'
require 'rest-client'

class LineCollbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def callback
    params['result'].each do |msg|
      request_content = {
        to: [msg['content']['from']],
        to_Channel: 1383378250, #fixed valule
        eventType: '138311608800106203',
        content: msg['content']
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
        'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
        'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID']
      })
    end
    "OK"
  end
end
