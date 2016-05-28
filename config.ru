# coding: utf-8
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require './beni.rb'
require './const.rb'
#require './users.rb'

class App < Sinatra::Base
#add_friend
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
    }
    send_information = add_friend_send.to_json
    RestClient.post(Settings::ENDPOINT_URI,send_information,Settings::REQUEST_HEANDER)
  end

#start_server
  before do
    @add_friend_eventType = "138311609100106403"
    @add_friend_opType = 4
    @block_friend_opType = 8
    
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
        RestClient.post(Settings::ENDPOINT_URI,cjson1,Settings::REQUEST_HEANDER)
      else
        RestClient.post(Settings::ENDPOINT_URI,cjson1,Settings::REQUEST_HEANDER)
        RestClient.post(Settings::ENDPOINT_URI,cjson2,Settings::REQUEST_HEANDER)
      end
    end
  end

#post callback
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)


    if (params['result'][0]['eventType'] == @add_friend_eventType && params['result'][0]['content']['opType'] == @add_friend_opType)
      p "add_friend_event or cancel_block"
      add_friend_event(params['result'][0]['content']['params'][0])
      
    elsif(params['result'][0]['eventType'] == @add_friend_eventType && params['result'][0]['content']['opType'] == @block_friend_opType)
      p "block"
      
    else
      p "get request"
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
        RestClient.post(Settings::ENDPOINT_URI,content_json,Settings::REQUEST_HEANDER)
      end
    end
    "OK"
  end
end

run App
