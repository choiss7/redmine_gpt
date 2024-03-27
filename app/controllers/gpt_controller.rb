require 'net/http'
require 'uri'
require 'json'

 
class GptController < ApplicationController
#  unloadable

  def find_current_user
    @current_user = User.current
  end
 


  def index
    # index 액션은 입력 폼을 렌더링합니다.
  end

def generate
  api_key = Setting.plugin_redmine_gpt['openai_api_key'] # 설정에서 API 키 값을 불러옴
  gpt_model = params[:model] # 사용자가 선택한 모델
  @selected_model = gpt_model == 'gpt-4' ? 'ChatGPT-4' : 'ChatGPT-3.5' # 선택된 모델 이름 설정

  uri = URI.parse("https://api.openai.com/v1/chat/completions")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{api_key}"
  request.body = JSON.dump({
     model: gpt_model, # 사용자가 선택한 모델 사용
    "messages" => [
      {
        "role" => "system",
        "content" => "You are a helpful assistant."
      },
      {
        "role" => "user",
        "content" => params[:prompt]
      }
    ]
  })

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end


    @response_text = JSON.parse(response.body)["choices"].first["message"]["content"]
  rescue => e
    @error = e.message
  ensure
    render :index
  end
end

