# app/controllers/gpt_controller.rb
require 'net/http'
require 'uri'
require 'json'

class GptController < ApplicationController
  include ActionController::Live

  def index
    # index 액션은 입력 폼을 렌더링합니다.
  end

  def generate_stream
    response.headers['Content-Type'] = 'text/event-stream'

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
      stream: true,
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
      Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request) do |response|
          response_body = JSON.parse(response.body)
          response_text = response_body["choices"].first["message"]["content"]
          # 스트리밍 응답 시작
          response.stream.write "User Prompt: #{params[:prompt]}, GPT Response: #{response_text}\n"
        end
      end
    rescue => e
      Rails.logger.error "GPT Error: #{e.message}"
      response.stream.write "Error: #{e.message}\n"
    ensure
      response.stream.close
    end
  end
end
