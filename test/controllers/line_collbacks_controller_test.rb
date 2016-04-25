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

    stub_request(:get, 'https://stat.ink/u/matsumoto/stat/by-map')
      .to_return(body: '<div id="stat" data-screen-name="matsumoto" data-json="{&quot;shionome&quot;:{&quot;name&quot;:&quot;\u30b7\u30aa\u30ce\u30e1\u6cb9\u7530&quot;,&quot;win&quot;:6,&quot;lose&quot;:4},&quot;shottsuru&quot;:{&quot;name&quot;:&quot;\u30b7\u30e7\u30c3\u30c4\u30eb\u9271\u5c71&quot;,&quot;win&quot;:31,&quot;lose&quot;:17},&quot;arowana&quot;:{&quot;name&quot;:&quot;\u30a2\u30ed\u30ef\u30ca\u30e2\u30fc\u30eb&quot;,&quot;win&quot;:9,&quot;lose&quot;:8},&quot;bbass&quot;:{&quot;name&quot;:&quot;B\u30d0\u30b9\u30d1\u30fc\u30af&quot;,&quot;win&quot;:30,&quot;lose&quot;:26},&quot;mahimahi&quot;:{&quot;name&quot;:&quot;\u30de\u30d2\u30de\u30d2\u30ea\u30be\u30fc\u30c8&amp;\u30b9\u30d1&quot;,&quot;win&quot;:37,&quot;lose&quot;:46},&quot;hokke&quot;:{&quot;name&quot;:&quot;\u30db\u30c3\u30b1\u3075\u982d&quot;,&quot;win&quot;:23,&quot;lose&quot;:16},&quot;negitoro&quot;:{&quot;name&quot;:&quot;\u30cd\u30ae\u30c8\u30ed\u70ad\u9271&quot;,&quot;win&quot;:33,&quot;lose&quot;:20},&quot;masaba&quot;:{&quot;name&quot;:&quot;\u30de\u30b5\u30d0\u6d77\u5ce1\u5927\u6a4b&quot;,&quot;win&quot;:34,&quot;lose&quot;:21},&quot;mongara&quot;:{&quot;name&quot;:&quot;\u30e2\u30f3\u30ac\u30e9\u30ad\u30e3\u30f3\u30d7\u5834&quot;,&quot;win&quot;:49,&quot;lose&quot;:35},&quot;anchovy&quot;:{&quot;name&quot;:&quot;\u30a2\u30f3\u30c1\u30e7\u30d3\u30c3\u30c8\u30b2\u30fc\u30e0\u30ba&quot;,&quot;win&quot;:31,&quot;lose&quot;:26},&quot;mozuku&quot;:{&quot;name&quot;:&quot;\u30e2\u30ba\u30af\u8fb2\u5712&quot;,&quot;win&quot;:53,&quot;lose&quot;:40},&quot;dekaline&quot;:{&quot;name&quot;:&quot;\u30c7\u30ab\u30e9\u30a4\u30f3\u9ad8\u67b6\u4e0b&quot;,&quot;win&quot;:44,&quot;lose&quot;:35},&quot;tachiuo&quot;:{&quot;name&quot;:&quot;\u30bf\u30c1\u30a6\u30aa\u30d1\u30fc\u30ad\u30f3\u30b0&quot;,&quot;win&quot;:31,&quot;lose&quot;:14},&quot;hirame&quot;:{&quot;name&quot;:&quot;\u30d2\u30e9\u30e1\u304c\u4e18\u56e3\u5730&quot;,&quot;win&quot;:44,&quot;lose&quot;:35},&quot;hakofugu&quot;:{&quot;name&quot;:&quot;\u30cf\u30b3\u30d5\u30b0\u5009\u5eab&quot;,&quot;win&quot;:36,&quot;lose&quot;:20},&quot;kinmedai&quot;:{&quot;name&quot;:&quot;\u30ad\u30f3\u30e1\u30c0\u30a4\u7f8e\u8853\u9928&quot;,&quot;win&quot;:40,&quot;lose&quot;:25}}" data-no-data="データがありません"></div>')

    stub_request(:get, 'https://trialbot-api.line.me/v1/profiles?mids=u5f4dd90e8f044efe1bc21343391bab90')
      .to_return(body: "{\"contacts\":[{\"displayName\":\"\xE3\x83\x9E\xE3\x83\x84\xE3\x82\xAD\xE3\x83\xA8\",\"mid\":\"u5f4dd90e8f044efe1bc21343391bab90\",\"pictureUrl\":\"http://dl.profile.line-cdn.net/0m00fe68f672511a228855c22302eb1fd14f156a43bce2\",\"statusMessage\":\"\xE3\x81\x84\xE3\x81\x8B\xE3\x82\x88\xE3\x82\x8D\xE3\x81\x97\xE3\x81\x8F\xE3\x83\xBC\"}],\"count\":1,\"display\":1,\"pagingRequest\":{\"start\":1,\"display\":1,\"sortBy\":\"MID\"},\"start\":1,\"total\":1}")
    # WebMock.allow_net_connect!
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
    assert_no_difference('User.count') do
      post :callback, JSON.parse(example_data)
    end
    assert_response :success
    assert_requested(:post, 'https://trialbot-api.line.me/v1/events',
                     headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                     times: 1) do |req|
      req.body =~ /ヒラメが丘団地/ &&
        req.body =~ /ホッケふ頭/ &&
        req.body =~ /ナワバリバトル/ &&
        req.body =~ /ガチホコ/ &&
        req.body =~ /モズク農園/ &&
        req.body =~ /マサバ海峡大橋/ &&
        req.body =~ /57\.0\%/ &&
        req.body =~ /61\.8\%/ &&
        req.body =~ /59\.0\%/ &&
        req.body =~ /55\.7\%/ &&
        req.body =~ /サンプル/
    end
  end

  test 'should create new user on first request' do
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
        "from":"u5f4dd90e8f044efe1bc21343391bab90",
        "createdTime":1332394961610,
        "to":["u0a556cffd4da0dd89c94fb36e36e1cdc"],
        "toType":1,
        "contentMetadata":null,
        "text":"Hello, BOT API Server!"
      }
    }]}'

    assert_difference('User.count', 1) do
      post :callback, JSON.parse(example_data)
    end
    assert_response :success
    assert_requested(:post, 'https://trialbot-api.line.me/v1/events',
                     headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                     times: 1) do |req|
      req.body =~ /マツキヨ/ &&
        req.body =~ /stat\.ink/
    end

    example_data.gsub!(/Hello, BOT API Server\!/, 'matsumoto')

    assert_no_difference('User.count') do
      post :callback, JSON.parse(example_data)
    end
    assert_response :success
    assert_requested(:post, 'https://trialbot-api.line.me/v1/events',
                     headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                     times: 1) do |req|
      req.body =~ /matsumoto/
    end

    assert_no_difference('User.count') do
      post :callback, JSON.parse(example_data)
    end

    assert_response :success
    assert_requested(:post, 'https://trialbot-api.line.me/v1/events',
                     headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                     times: 1) do |req|
      req.body =~ /ヒラメが丘団地/ &&
        req.body =~ /ホッケふ頭/ &&
        req.body =~ /ナワバリバトル/ &&
        req.body =~ /ガチホコ/ &&
        req.body =~ /モズク農園/ &&
        req.body =~ /マサバ海峡大橋/ &&
        req.body =~ /57\.0\%/ &&
        req.body =~ /61\.8\%/ &&
        req.body =~ /59\.0\%/ &&
        req.body =~ /55\.7\%/ &&
        req.body =~ /マツキヨ/
    end
  end

  test 'new' do
    #
  end
end
# O0o 1lI
