require 'sinatra'
require 'multi_json'
require 'slack'

#ENV['SLACK_API_TOKEN'] = 'xoxp-2381348639-2381348641-2387116848-200f20'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN'];
end


get '/' do
  response = MultiJson::dump({foo: 'bar', hoge: 'fuga'})
  puts response
  response
end

#Slack.chat_postMessage ({
#  token: ENV['SLACK_API_TOKEN'],
#  channel: '#gfc',
#  text: '> Hello world',
#  username: 'Ruby',
#  icon_url: 'https://slack.global.ssl.fastly.net/10562/img/services/trello_48.png'
#})

