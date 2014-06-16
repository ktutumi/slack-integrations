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

post '/bitbucket/post/:channel' do |channel|
  puts '~~~~~ POST /'

  params = ::MultiJson.load(request.body.read)
  body = params['payload']

  repository = "#{body['repository']['owner']}/#{body['repository']['name']}"

  name = body['repository']['name']
  url = body['canon_url'] + body['repository']['absolute_url']

  text = '<%s|%s> pushed to <%s|%s>  ' % [
      "#{body['canon_url']}/#{body['user']}",
      body['user'],
      url,
      repository
  ]


  template = '[%s/%s] <%s/commits/%s|%s>: %s'
  text << "  \n"
  text << body['commits'].map { |commit|
    node = commit['node']
    message = commit['message']
    branch = commit['branch']

    template % [name, branch, url, node, node, message]
  }.join("  \n")

  Slack.chat_postMessage ({
    token: ENV['SLACK_API_TOKEN'],
    channel: "##{channel}",
    text: text,
    username: 'bitbucket',
    icon_url: 'https://slack.global.ssl.fastly.net/20653/img/services/bitbucket_48.png'
  })

  return 'ok'
end


