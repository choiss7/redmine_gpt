# plugins/redmine_gpt/config/routes.rb
Rails.application.routes.draw do
  get 'gpt', to: 'gpt#index'
  get 'gpt/generate', to: 'gpt#generate'
  post 'gpt/generate', to: 'gpt#generate', as: 'generate_gpt'
end

