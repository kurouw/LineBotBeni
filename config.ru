# coding: utf-8
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require './beni.rb'
#require './users.rb'

def add_friend_event(toId)
  text = "友達追加してくれてありがとう！"
  add_friend_send = {
    to: [toId],
    toChannel: 1383378250, # Fixed  value
    eventType: "138311608800106203", # Fixed value
    content: {contentType: 1,
              toType: 1,
              text: text
             }
   send_information =  add_friend_send.to_json
    RestClient.post(@endpoint_uri,send_information,@request_header)
  }
  
end

class App < Sinatra::Base
  before do    
    @request_header = {
      'Content-Type' => 'application/json; charset=UTF-8',
      'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
      'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
      'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
    }
    @endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    @add_friend_eventType = "138311609100106403"
    @add_friend_opType = 4
    
    if(Time.now.hour == 8 && Time.now.min == 0)
      toMe = ENV["MY_ID"]
      
      img1, img2 = get_images("福島","一箕町")
      puts img1,img2
      f = false
      if img1 == "chirashi"
        conT = 1
        text  = "今日のチラシはないよ！"
        f = true
      else
        conT = 2
        oUrl1 = img1
        pIUrl1 = img1
        oUrl2 = img2
        pIUrl2 = img2
      end

      requestContent1 = {
        to: [toMe],
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
        to: [toMe],
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
        RestClient.post(@endpoint_uri,cjson1,@request_header)
      else
        RestClient.post(@endpoint_uri,cjson1,@request_header)
        RestClient.post(@endpoint_uri,cjson2,@request_header)
      end
    end
  end
  
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    #友達追加
#-----------------
    if (params['result'][0]['eventType'] == @add_friend_eventType && params['result']['opType'] == @add_friend_opType)
      puts params['result'][0]['content']['params'][0]
      add_friend_event(params['result'][0]['content']['params'][0])
    end
#-----------------
    
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
      
      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(@endpoint_uri, content_json,@request_header)
    end
    "OK"
  end
end

run App
