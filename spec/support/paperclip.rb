class Test::Unit::TestCase
  def self.should_have_attached_file(attachment)
    klass = self.name.gsub(/Test$/, '').constantize

    should "have a paperclip attachment named ##{attachment}" do
      assert klass.new.respond_to?(attachment.to_sym), "@#{klass.name.underscore} doesn't have a paperclip field named #{attachment}"
      assert_equal Paperclip::Attachment, klass.new.send(attachment.to_sym).class
    end
    
  end
end
