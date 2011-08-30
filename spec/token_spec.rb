require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

single_token_text = "### Cum sociis
## Etiam vel augue.
[Test](www.test.com) 
@[youtube](jkas8sdh128)
Praesent id massa id nisl venenatis lacinia."

single_output_text = "### Cum sociis @[youtube](jkas8sdh128)
## Etiam vel augue.
[Test](www.test.com) 
@[vimeo]{date=8.26.11}(22002326)
Praesent id massa id nisl venenatis lacinia."

multiple_token_text = "### Cum sociis @[youtube](jkas8sdh128)
## Etiam vel augue.
[Test](www.test.com) 
@[vimeo]{date=8.26.11}(22002326)
Praesent id massa id nisl venenatis lacinia."

rendered_vimeo = '<p><iframe src="http://player.vimeo.com/video/22002326?title=0&amp;byline=0&amp;portrait=0" width="620" height="349" frameborder="0"></iframe></p>'

describe Token do 
  #it "should replace text with a single token and markdown" do
  #  Token::Render.new(single_token_text).rendered
  #end
  before(:each) do
    
  end
  
  it "loads configuration" do
    
    p File.expand_path(".")
    Token::Config.load
  end
  
  it "parses tokens" do
    render = Token::Render.new
    render.parse_tokens single_token_text do |token|
      token.should be_a_kind_of(Hash)
      token.should_not be nil
      token.should == {:type=>"youtube", :args=>{}, :value=>"jkas8sdh128"}
    end
  end
  
  
  
  #it "renders partial" do
  #  token = Token::Render.new
  #  rendered = token.get_token_view "vimeo", "22002326"
  #  rendered.should == rendered_vimeo
  #end
  #
  #it "raises exception when token template isn't found" do
  #  token = Token::Render.new
  #  lambda {token.tokenize "missing", "22002326"}.should raise_error
  #end
  
  #it "should add the tokenize method to active record" do
  #  ActiveRecord::Base.method_defined?(:tokenize).should == true
  #end
  
  #it "should add the tokenize method to action views" do
  #  ActionView::Base.method_defined?(:tokenize).should == true
  #end
end
