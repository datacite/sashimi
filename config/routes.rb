Rails.application.routes.draw do
  root :to => 'index#index'
  resources :heartbeat, only: [:index]
  resources :index, path: '/', only: [:index]

  def add_swagger_route http_method, path, opts = {}
    full_path = path.gsub(/{(.*?)}/, ':\1')
    match full_path, to: "#{opts.fetch(:controller_name)}##{opts[:action_name]}", via: http_method
  end

  add_swagger_route 'DELETE', '//publishers/{id}', controller_name: 'publishers', action_name: 'destroy'
  add_swagger_route 'PUT', '//publishers/{id}', controller_name: 'publishers', action_name: 'update'
  add_swagger_route 'POST', '//publishers', controller_name: 'publishers', action_name: 'create'
  add_swagger_route 'GET', '//report-types', controller_name: 'report_types', action_name: 'index'
  add_swagger_route 'GET', '//report-types/{id}', controller_name: 'report_types', action_name: 'show'
  add_swagger_route 'POST', '//report-types', controller_name: 'report_types', action_name: 'create'
  add_swagger_route 'GET', '//reports', controller_name: 'reports', action_name: 'index'
  add_swagger_route 'DELETE', '//reports/{id}', controller_name: 'reports', action_name: 'destroy'
  add_swagger_route 'GET', '//reports/{id}', controller_name: 'reports', action_name: 'show'
  add_swagger_route 'GET', '//report-subsets/{id}', controller_name: 'report_subsets', action_name: 'show'
  add_swagger_route 'PUT', '//reports/{id}', controller_name: 'reports', action_name: 'update'
  add_swagger_route 'POST', '//reports', controller_name: 'reports', action_name: 'create'

  get 'repositories-usage-reports/:id', :to => 'publishers#show', constraints: { :id => /.+/ }

  resources :publishers, constraints: { :id => /.+/ }, format: false, defaults: { format: false }
  resources :repositories_usage_reports, constraints: { :id => /.+/ }, format: false, defaults: { format: false }

  get '/public/favicon.ico', to: redirect('/public/favicon.ico')
  get '/favicon.ico', to: redirect('/public/favicon.ico')
end
