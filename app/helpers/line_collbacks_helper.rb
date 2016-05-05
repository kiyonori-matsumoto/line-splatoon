require 'json'

module LineCollbacksHelper
  LINE_EVENT = 'https://trialbot-api.line.me/v1/events'.freeze
  LINE_PROFILE = 'https://trialbot-api.line.me/v1/profiles'.freeze
  AUTH_HASH = { 'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
                'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
                'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID'] }.freeze
  SCHEDULE_URI = 'http://splatapi.ovh/schedule_jp.json'.freeze
  STAT_INK_URI = 'https://stat.ink/u/'.freeze
  STAT_INK_BYMAP = '/stat/by-map'.freeze
  USERS_URI = 'https://line-splatoon.herokuapp.com/users'.freeze

  Message = Struct.new(:to, :text)

  MessageTemplate = {
    to: [],
    toChannel: 1_383_378_250,
    eventType: '138311608800106203',
    content: {
      content_type: 1,
      toType: 1,
      text: ''
    }
  }.freeze

  def send_message(message)
    msg = MessageTemplate.dup
    msg[:to][0] = message.to
    msg[:content][:text] = message.text
    content_json = msg.to_json
    hash = AUTH_HASH.dup
    hash['Content-Type'] = 'application/json; charset=UTF-8'
    RestClient.post(LINE_EVENT, content_json, hash)
  end
end
