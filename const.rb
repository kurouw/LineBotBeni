class Settings
  REQUEST_HEANDER  = {
    'Content-Type' => 'application/json; charset=UTF-8',
    'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
    'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
    'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
  }
  ENDPOINT_URI = 'https://trialbot-api.line.me/v1/events'
end
