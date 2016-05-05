require 'json'
require 'rest-client'
require 'open-uri'
require 'nokogiri'

class LineCollbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  include LineCollbacksHelper

  def callback
    @stage_json = nil
    open(SCHEDULE_URI) do |fp|
      @stage_json = JSON.load(fp)
    end
    @regular_stages = get_stages('regular')
    @rank_stages = get_stages('ranked')
    @rank_mode = @stage_json['schedule'][0]['ranked_mode']

    RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']

    params['result'].each do |msg|
      line_uid = msg['content']['from']
      if (@user = User.find_by(line_uid: line_uid))
        uname = @user.line_name
      else
        j = JSON.parse(RestClient.get(LINE_PROFILE + "?mids=#{line_uid}", AUTH_HASH.dup))
        uname = j['contacts'][0]['displayName']
        @user = User.create(line_uid: line_uid,
                            line_name: uname,
                            line_message_state: :initial)
      end

      parse_message(msg['content']['text'])
      string = create_message
      msg = Message.new
      msg.to = line_uid
      msg.text = string
      send_message(msg)
    end
    render text: 'OK'
  end

  private

  def create_message
    if @user.normal?
      get_status(@user.line_uid)
      mp = method(:map_func)
      regular_stages = @regular_stages.map(&mp)
      rank_stages    = @rank_stages.map(&mp)

      string = "#{@user.line_name}さんのステータス\n"

      string << "ナワバリバトル:\n #{regular_stages[0][0]}:勝率 #{'%0.1f' % regular_stages[0][1]}%\n #{regular_stages[1][0]}:勝率 #{'%0.1f' % regular_stages[1][1]}%\n" \
      "#{@rank_mode}:\n #{rank_stages[0][0]}: 勝率 #{'%0.1f' % rank_stages[0][1]}%\n #{rank_stages[1][0]}: 勝率 #{'%0.1f' % rank_stages[1][1]}%"
      return string
    elsif @user.initial?
      @user.update_attribute(:line_message_state, :recieving_statink_id)
      return "はじめまして！#{@user.line_name}さん!\nstat.inkのユーザIDを教えてほしいな！"
    elsif @user.recieving_statink_id?
      @user.normal!
      return "#{@user.stat_ink_id}で登録したよ!"
    else
      'Error'
    end
  end

  def parse_message(content)
    if @user.recieving_statink_id?
      @user.update_attribute(:stat_ink_id, content)
      @user.reload
    end
  end

  def get_stages(mode)
    @stage_json['schedule'][0]['stages'][mode].map { |e| e['name'] }
  end

  def map_func(stg)
    s = @stage_stat.values.find { |e| e['name'][2..3] == stg[2..3] }
    [stg, s['win'].to_f / (s['win'].to_i + s['lose'].to_i) * 100]
  end

  def get_status(line_uid)
    if (user = User.find_by(line_uid: line_uid))
      uri = STAT_INK_URI + user.stat_ink_id + STAT_INK_BYMAP
      doc = Nokogiri::HTML(open(uri))
      @stage_stat = JSON.parse doc.css('#stat').attribute('data-json').value
      user.update_attribute(:stat_ink_result, @stage_stat)
    end
  end
end
