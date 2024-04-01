Redmine::Plugin.register :redmine_gpt do
  name 'Redmine GPT Plugin'
  author 'Medialog Messaging Platform Development Team'
  description 'This is a plugin for Redmine to interact with OpenAI GPT-4 API'
  version '0.0.2'
  url 'https://github.com/choiss7/redmine_gpt'
  author_url 'https://github.com/choiss7/redmine_gpt'

  # 여기에 플러그인 설정을 추가하세요.
  # 예를 들어, 메뉴 항목 추가나 권한 설정 등을 할 수 있습니다.

  menu :project_menu, :gpt, { controller: 'gpt', action: 'index' }, caption: 'GPT-4', after: :activity, param: :project_id

 # settings default: {'empty' => true}, partial: 'settings/gpt_settings'

  settings default: {'openai_api_key' => '', 'gpt_model' => ''}, partial: 'settings/gpt_settings'

  project_module :gpt do
    permission :view_gpt, { gpt: [:index] } # gpt 컨트롤러의 index 액션을 볼 수 있는 권한을 추가합니다.
    permission :use_gpt, { gpt: [:query] } # gpt 컨트롤러의 query 액션을 사용할 수 있는 권한을 추가합니다.
  end

end

