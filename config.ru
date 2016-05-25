# coding: utf-8
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require './main3.rb'

class App < Sinatra::Base
=begin
  before do
      push_header = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      }    
      ep_uri = 'https://trialbot-api.line.me/v1/events'
      content = {
        toType: 1,
        contentType: 1,
        from: "udfcd43011e0c6fa0933012f10993560e",
        location: nil,
        id: "4338702023774",
        to: ["u26b6b8a0feb3a295f46866ebeabd488a"],
        text: "おほよう",
        contentMetadata:
          {
            AT_RECV_MODE: "2",
            SKIP_BADGE_COUNT: true,
          },
        deloveredTime
      }
      requestContent = {
        to: ["u26b6b8a0feb3a295f46866ebeabd488a"],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: content
      }
      cjson = requestContent.to_json      
      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(ep_uri,cjson,push_header)
end
=end
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)
    params['result'].each do |msg|
      
      if !msg['content']['location'].nil? 
        msg['content']['text'] = msg['content']['location']['address']
      end
      
      if msg['content']['text'] == "shop"
        img1, img2 = GetImages("福島","一箕町")
        if img1 == "chirashi"
          msg['content']['text'] = "今日のチラシはないよ！"
        else
        msg['content']['originalContentUrl'] = img1 #"https://pv.orikomio.com/flyer/000011/000012/0037/4598/assets/PageImage_001.jpg"
          msg['content']['previewImageUrl'] = img2 #"https://pv.orikomio.com/flyer/000011/000012/0037/4598/assets/PageImage_001.jpg"
        end
      end
      
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: {contentType: msg['content']['contentType'],
                  toType: msg['content']['toType'],
                  text: msg['content']['text']
                 }
      }
     
      content_json = request_content.to_json
      request_header = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      }    
      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      
      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(endpoint_uri, content_json,request_header)
    end
    "OK"
  end
end

run App
