require 'net/http'
require 'uri'
require 'json'

class GptController < ApplicationController
  # unloadable

  def index
    # index 액션은 입력 폼을 렌더링합니다.
  end

  def generate
    api_key = Setting.plugin_redmine_gpt['openai_api_key'] # 설정에서 API 키 값을 불러옴
    model_info = params[:model] # 사용자가 선택한 모델 정보 ("모델명 (API 주소)")

    # 모델 이름과 API 주소를 분리
    begin
      model_name, api_address = model_info.match(/^(.*?)\s*\((.*?)\)$/).captures
    rescue
      @error = "모델명 형식이 올바르지 않습니다. '모델명 (API 주소)' 형식으로 입력해주세요."
      Rails.logger.error @error
      render :index and return
    end

    @selected_model = model_name # 선택된 모델 이름 설정

    custom_instructions = Setting.plugin_redmine_gpt['custom_instructions'] # 사용자 정의 지침 불러옴
    response_style = Setting.plugin_redmine_gpt['response_style'] # 응답 스타일 설정값 불러옴

    uri = URI.parse(api_address) # 분리된 API 주소를 사용하여 URI 객체 생성
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request.body = JSON.dump({
       model: model_name, # 분리된 모델 이름 사용
      "messages" => [
        {
          "role" => "system",
          "content" => "You are a helpful assistant. #{custom_instructions} Respond in a #{response_style} style." # 응답 스타일을 시스템 메시지에 추가
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

    # API 응답을 로그에 기록
    @response_text = JSON.parse(response.body)["choices"].first["message"]["content"]
    Rails.logger.info "User Prompt: #{params[:prompt]}, Model: #{model_name}, GPT Response: #{@response_text}"


  rescue => e
  @error = e.message
  # 오류 메시지를 로그에 기록
  Rails.logger.error "GPT Error: #{@error}"
ensure
  # 에러가 있을 경우에만 index를 렌더링
  render :index if @error.present?
end
end
