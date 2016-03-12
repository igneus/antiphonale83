%w(builder
document_loader
gly_patch
helpers
weekdays).each do |f|
  require_relative "antiphonal/#{f}"
end
