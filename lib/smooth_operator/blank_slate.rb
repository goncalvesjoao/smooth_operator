# THANKS tdantas! https://github.com/tdantas

module SmoothOperator
  class BlankSlate
    instance_methods.each { |m| undef_method m unless m =~ /^__|object_id/ }
  end
end
