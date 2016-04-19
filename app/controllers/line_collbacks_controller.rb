require 'json'
require 'rest-client'
require 'open-uri'
require 'nokogiri'

class LineCollbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  LINE_PROFILE = 'https://trialbot-api.line.me/v1/profiles'.freeze
  AUTH_HASH = { 'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
                'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
                'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID'] }.freeze

  def callback
    mp = method(:map_func)
    @stage_json = nil
    open('http://splatapi.ovh/schedule_jp.json') do |fp|
      @stage_json = JSON.load(fp)
    end
    regular_stages = get_stages('regular')
    rank_stages = get_stages('ranked')
    rank_mode = @stage_json['schedule'][0]['ranked_mode']

    doc = Nokogiri::HTML(open('https://stat.ink/u/matsumoto/stat/by-map'))
    @stage_stat = JSON.parse doc.css('#stat').attribute('data-json').value

    regular_stages.map!(&mp)
    rank_stages.map!(&mp)

    string = "ナワバリバトル:\n #{regular_stages[0][0]}:勝率 #{'%0.1f' % regular_stages[0][1]}%\n #{regular_stages[1][0]}:勝率 #{'%0.1f' % regular_stages[1][1]}%\n" \
    "#{rank_mode}:\n #{rank_stages[0][0]}: 勝率 #{'%0.1f' % rank_stages[0][1]}%\n #{rank_stages[1][0]}: 勝率 #{'%0.1f' % rank_stages[1][1]}%"

    RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']

    params['result'].each do |msg|
      line_uid = msg['content']['from']
      if (user = User.find_by(line_uid: line_uid))
        uname = user.line_name
      else
        j = JSON.parse(RestClient.get(LINE_PROFILE + "?mids=#{line_uid}", AUTH_HASH.dup))
        uname = j['contacts'][0]['displayName']
        User.create(line_uid: line_uid,
                    line_name: uname)
      end

      string = "#{uname}さんのステータス\n" + string

      request_content = {
        to: [msg['content']['from']],
        toChannel: 1_383_378_250, # fixed valule
        eventType: '138311608800106203',
        content: msg['content']
      }

      request_content[:content][:text] = string

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.post(endpoint_uri, content_json,
                      'Content-Type' => 'application/json; charset=UTF-8',
                      'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
                      'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
                      'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID'])
    end
    render text: 'OK'
  end

  private

  def get_stages(mode)
    @stage_json['schedule'][0]['stages'][mode].map { |e| e['name'] }
  end

  def map_func(stg)
    s = @stage_stat.values.find { |e| e['name'][2..3] == stg[2..3] }
    [stg, s['win'].to_f / (s['win'].to_i + s['lose'].to_i) * 100]
  end
end
