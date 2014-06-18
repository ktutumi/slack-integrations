require 'sinatra'
require 'multi_json'
require 'slack'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN'];
end

head '/' do
  return 'ok'
end

get '/' do
  return 'ok'
end

#
# BitBucket の コミットを通知する
#
post '/bitbucket/post/:channel' do |channel|
  body = ::MultiJson.load(params['payload'])

  repository = "#{body['repository']['owner']}/#{body['repository']['name']}"

  url = body['canon_url'] + body['repository']['absolute_url']

  text = "<%s|%s> pushed to <%s|%s>  \n" % [
      "#{body['canon_url']}/#{body['user']}",
      body['user'],
      url,
      repository
  ]

  template = '> <%s/commits/%s|%s>: %s'
  text << ''
  text << body['commits'].map { |commit|
    node = commit['node']
    message = commit['message'].lines.first
    puts '----------------'
    puts commit['message']
    puts message
    puts '----------------'

    template % [url.chop, node, node, message]
  }.join('')

  Slack.chat_postMessage ({
    token: ENV['SLACK_API_TOKEN'],
    channel: "##{channel}",
    text: text,
    username: 'bitbucket',
    icon_url: 'https://slack.global.ssl.fastly.net/20653/img/services/bitbucket_48.png'
  })

  return 'ok'
end

#
# Trello の更新を通知する
#
#head '/trello/post/:channel' do |channel|
#  return 'ok'
#end

post '/trello/post/:channel' do |channel|
  puts '~~~~~~~~~~~~~~~~~~~~'
  req = TrelloRequest.new(request)
  puts req.board_name
  puts '~~~~~~~~~~~~~~~~~~~~'

  return 'ok'
end

class TrelloRequest
  def initialize(request)
    request.body.rewind
    @body = ::MultiJson.load(request.body.read)
  end

  def board_name
    @body['action']['data']['board']['name'] rescue nil
  end

  def card_name
    @body['action']['data']['card']['name'] rescue nil
  end
end
