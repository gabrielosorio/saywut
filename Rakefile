require_relative 'main'

desc 'Create API token'
task :generate_api_token_for, :domain do |t, args|
  token = Array.new(32){rand(36).to_s(36)}.join
  if ApiToken.create(domain: args[:domain], token: token)
    true
  end
  false
end

desc 'List API tokens'
task :list_api_tokens do
  ApiToken.each do |api|
    p api.domain
    p api.token
  end
end
