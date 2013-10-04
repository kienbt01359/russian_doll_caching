json.array!(@members) do |member|
  json.extract! member, :bio
  json.url member_url(member, format: :json)
end
