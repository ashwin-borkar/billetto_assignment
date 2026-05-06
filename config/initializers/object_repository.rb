Rails.configuration.to_prepare do
  # Register domain objects for ObjectRepository
  ObjectRepository.register(Guidelines::RequestForComment)
  ObjectRepository.register(Guidelines::Approval)
end
