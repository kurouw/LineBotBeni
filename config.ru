# coding: utf-8
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require './main3.rb'

class App < Sinatra::Base

  before do
    img1, img2 = GetImages("福島","一箕町")
    puts img1,img2
    f = false
    if img1 == "chirashi"
      conT = 1
      text  = "今日のチラシはないよ！"
      f = true
    else
      conT = 2
      text = "ma"
      oUrl1 = img1
      pIUrl1 = img1
      oUrl2 = img2
      pIUrl2 = img2
    end

      push_header = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      }    
      ep_uri = 'https://trialbot-api.line.me/v1/events'
      requestContent1 = {
        to: ["udfcd43011e0c6fa0933012f10993560e"],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: {contentType: conT,
                  toType: 1,
                  text: text,
                  originalContentUrl: oUrl1,
                  previewImageUrl: pIUrl1
                 }
      }
       requestContent2 = {
        to: ["udfcd43011e0c6fa0933012f10993560e"],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: {contentType: conT,
                  toType: 1,
                  text: text,
                  originalContentUrl: oUrl2,
                  previewImageUrl: pIUrl2
                 }
      }
      cjson1 = requestContent1.to_json
      cjson2 = requestContent2.to_json
      
      RestClient.proxy = ENV["FIXIE_URL"]
      if(f)
        RestClient.post(ep_uri,cjson1,push_header)
      else
        RestClient.post(ep_uri,cjson1,push_header)
        RestClient.post(ep_uri,cjson2,push_header)
      end
end

  post '/linebot/callback' do
    params = JSON.parse(request.body.read)
    params['result'].each do |msg|
      
      if !msg['content']['location'].nil? 
        msg['content']['text'] = msg['content']['location']['address']
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

      p content_json
      
      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(endpoint_uri, content_json,request_header)
    end
    "OK"
  end
end

run App
