module SmoothOperator
  module HttpMethods

    HTTP_VERBS = %w[get post put patch delete]

    HTTP_VERBS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(relative_path = '', params = {}, options = {})
          make_the_call(:#{method}, relative_path, params, options) do |remote_call|
            block_given? ? yield(remote_call) : remote_call
          end
        end
      RUBY
    end

  end
end
