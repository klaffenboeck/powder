json.array!(@frontend_explorations) do |frontend_exploration|
  json.extract! frontend_exploration, :id
  json.url frontend_exploration_url(frontend_exploration, format: :json)
end
