require 'sinatra'
require 'multi_json'
require 'slack'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN'];
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
    message = commit['message']

    template % [url, node, node, message]
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
get 'trello/post/:channel' do |channel|
  json ok: true
end

