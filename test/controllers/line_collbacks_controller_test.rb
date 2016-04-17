require 'test_helper'
require 'minitest/mock'
require 'json'
require 'webmock/minitest'

class LineCollbacksControllerTest < ActionController::TestCase
  def setup
    stub_request(:post, 'https://trialbot-api.line.me/v1/events').with(
      body: hash_including(toChannel: 1_383_378_250)
    ).to_return(status: 200)

    stub_request(:get, 'http://splatapi.ovh/schedule_jp.json')
      .to_return(body: '{"festival": false, "schedule": [{"stages": {"ranked": [{"nameEN": "Port Mackarel", "name": "ホッケふ頭"}, {"nameEN": "Flounder Heights", "name": "ヒラメが丘団地"}], "regular": [{"nameEN": "Kelp Dome", "name": "モズク農園"}, {"nameEN": "Hammerhead Bridge", "name": "マサバ海峡大橋"}]}, "begin": "2016-04-17T15:00:00.000+09:00", "end": "2016-04-17T19:00:00.000+09:00", "ranked_modeEN": "Rainmaker", "ranked_mode": "ガチホコ"}, {"stages": {"ranked": [{"nameEN": "Hammerhead Bridge", "name": "マサバ海峡大橋"}, {"nameEN": "Mahi-Mahi Resort", "name": "マヒマヒリゾート＆スパ"}], "regular": [{"nameEN": "Walleye Warehouse", "name": "ハコフグ倉庫"}, {"nameEN": "Piranha Pit", "name": "ショッツル鉱山"}]}, "begin": "2016-04-17T19:00:00.000+09:00", "end": "2016-04-17T23:00:00.000+09:00", "ranked_modeEN": "Splat Zones", "ranked_mode": "ガチエリア"}, {"stages": {"ranked": [{"nameEN": "Blackbelly Skatepark", "name": "Ｂバスパーク"}, {"nameEN": "Ancho-V Games", "name": "アンチョビットゲームズ"}], "regular": [{"nameEN": "Arowana Mall", "name": "アロワナモール"}, {"nameEN": "Mahi-Mahi Resort", "name": "マヒマヒリゾート＆スパ"}]}, "begin": "2016-04-17T23:00:00.000+09:00", "end": "2016-04-18T03:00:00.000+09:00", "ranked_modeEN": "Tower Control", "ranked_mode": "ガチヤグラ"}]}')
  end

  test 'should respond to callback' do
    text = 'Hello, BOT API Server!'
    example_data = '{"result":[
    {
      "from":"u2ddf2eb3c959e561f6c9fa2ea732e7eb8",
      "fromChannel":"1341301815",
      "to":["u0cc15697597f61dd8b01cea8b027050e"],
      "toChannel":1441301333,
      "eventType":"138311609000106303",
      "id":"ABCDEF-12345678901",
      "content": {
        "location":null,
        "id":"325708",
        "contentType":1,
        "from":"uff2aec188e58752ee1fb0f9507c6529a",
        "createdTime":1332394961610,
        "to":["u0a556cffd4da0dd89c94fb36e36e1cdc"],
        "toType":1,
        "contentMetadata":null,
        "text":"Hello, BOT API Server!"
      }
    }]}'

    post :callback, JSON.parse(example_data)
    assert_response :success
    assert_requested(:post, 'https://trialbot-api.line.me/v1/events',
                     headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                     times: 1) do |req|
      req.body =~ /ヒラメが丘団地/
      req.body =~ /ホッケふ頭/
      req.body =~ /ナワバリバトル/
      req.body =~ /ガチホコ/
      req.body =~ /モズク農園/
      req.body =~ /マサバ海峡大橋/
    end
  end

  test 'new' do
    #
  end
end
# O0o 1lI
