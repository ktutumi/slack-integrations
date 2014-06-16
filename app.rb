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

post '/bitbucket/post' do
  puts '~~~~~ POST /'
  body = params[:payload]
  repository = "#{body[:owner]}/#{body[:name]}"
  url = body[:canon_url] + body[:absolute_url]

  str = '<%s|%s> pushed to <%s|%s>' % [
      "#{body[:canon_url]}/#{body[:user]}",
      body[:user],
      repository,
      url
  ]

#  body[:commits].each do |commit|
#    author = commit[:author]
#    node = commit[:node]
#    message = commit[:message]
#  end

  Slack.chat_postMessage ({
    token: ENV['SLACK_API_TOKEN'],
    channel: '#gfc',
    text: str,
    username: 'BitBucket',
    icon_url: 'https://slack.global.ssl.fastly.net/20653/img/services/bitbucket_48.png'
  })
end


