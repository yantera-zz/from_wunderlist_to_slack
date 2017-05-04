#!/usr/bin/env ruby
require 'slack'
require 'json'

### confの内容
#※confは下記のように定義しています
######################################
# slack_token,slack_token
# wunderlist_token,wunderlist_token
# client_id,client_id
# channel,channel
# wunder_list_url,wunder_list_url
######################################

# - slack_token          # slackに通知するためのtoken
# - wunderlist_token     # wunderlistに通知するためのtoken
# - client_id            # wunderlistのclient_id
# - channel               # 通知したいslackのチャンネル
# - wunder_list_url      # wunderlistで叩きたいapiのURL


conf_file_path = '/home/[ユーザー名]/slack_bots/schedule_conf.txt' # cronを実行するユーザーがfile openするので絶対パスがおすすめ

### confの取得
datas = []
begin
  File.open(conf_file_path) do |file|
    file.each_line do |line|
      datas.push(line.chomp!)
    end
  end
end

### 取得したconfをhash化する
scheduler = {}
datas.each do |data|
  ary = data.split(',')
  scheduler[ary.first] = ary.last
end

### wunserlistからjson形式でパラメータを取得
result = `curl -H "X-Access-Token: #{scheduler["wunderlist_token"]}" -H "X-Client-ID: #{scheduler["client_id"]}" #{scheduler["wunderlist_url"]}`

result = JSON.parse(result)

### slackで表示するために整形
tasks = []
result.each do |r|
  tasks.push(r["title"])
end

task_list = tasks.join("\n")

Slack.configure do |config|
  config.token = scheduler["slack_token"]
end

line = "---------------------------\n"
text = case Time.now.hour
       when 11 then "#{line} today tasks confirm \n #{line} #{task_list}"
       else
         'Error!!'
       end

Slack.chat_postMessage(text: text, channel: scheduler["channel"], link_names: true, username: 'scheduler')
