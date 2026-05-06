module HasTypeid
  extend ActiveSupport::Concern

  class_methods do
    def has_typeid(type_name)
      define_method :type_prefix do
        type_name.to_s.capitalize
      end
    end
  end
end
