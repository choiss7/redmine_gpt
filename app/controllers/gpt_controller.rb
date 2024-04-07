# app/controllers/gpt_controller.rb
require 'net/http'
require 'uri'
require 'json'

class GptController < ApplicationController

  def index
    # index 액션은 입력 폼을 렌더링합니다.
  end

  def generate_stream
    api_key = Setting.plugin_redmine_gpt['openai_api_key']
    gpt_model = params[:model]
    selected_model = gpt_model == 'gpt-4' ? 'ChatGPT-4' : 'ChatGPT-3.5'
    custom_instructions = Setting.plugin_redmine_gpt['custom_instructions']
    response_style = Setting.plugin_redmine_gpt['response_style']

    uri = URI.parse("https://api.openai.com/v1/chat/completions")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request.body = JSON.dump({
      model: selected_model,
      "messages" => [
        {
          "role" => "system",
          "content" => "You are a helpful assistant. #{custom_instructions} Respond in a #{response_style} style."
        },
        {
          "role" => "user",
          "content" => params[:prompt]
        }
      ]
    })

    req_options = { use_ssl: uri.scheme == "https", }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      # OpenAI API로부터 받은 응답을 파싱
      response_body = JSON.parse(response.body)
      response_text = response_body["choices"].first["message"]["content"] if response_body["choices"]

      # 응답 텍스트와 사용자 입력을 인스턴스 변수에 저장
      @response_text = response_text
      @user_prompt = params[:prompt]
      @selected_model = selected_model
    rescue => e
      Rails.logger.error "GPT Error: #{e.message}"
      @error_message = e.message
    ensure
      render :index
    end
  end
end
