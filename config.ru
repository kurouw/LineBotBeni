# coding: utf-8
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require './main3.rb'

class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

=begin
    params['result'][0]['content'].each do |key|
      p key
    end
=end
    
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
        content: msg['content']
      }

      request_header = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      }
      
      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json
      
      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(endpoint_uri, content_json,request_header)
      RestClient.post(endpoint_uri, content_json,request_header)
    end
    
=begin    
       params['result'][0]['content'].each do |key|
         p key
       end
=end
    
    "OK"
  end
end

run App
