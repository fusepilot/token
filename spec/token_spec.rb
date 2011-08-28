require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

token_1 = {:type => "youtube", :id => "jkas8sdh128", :pattern => "@[youtube](jkas8sdh128)"}
token_2 = {:type => "vimeo", :id => "22002326", :pattern => "@[vimeo](22002326)"}

single_token_text = "### Cum sociis
## Etiam vel augue.
[Test](www.test.com) 
#{token_1[:pattern]}
Praesent id massa id nisl venenatis lacinia."

multiple_token_text = "### Cum sociis #{token_1[:pattern]}
## Etiam vel augue.
[Test](www.test.com) 
#{token_2[:pattern]}
Praesent id massa id nisl venenatis lacinia."

rendered_vimeo = '<p><iframe src="http://player.vimeo.com/video/22002326?title=0&amp;byline=0&amp;portrait=0" width="620" height="349" frameborder="0"></iframe></p>'

describe Token do 
  it "finds single token in text." do
    token = Token::Render.new
    tokens = token.find_tokens(single_token_text)
    tokens.length.should == 1
    tokens.should == [token_1]
  end
  
  it "finds multiple tokens in text." do
    token = Token::Render.new
    tokens = token.find_tokens(multiple_token_text)
    tokens.length.should == 2
    tokens.include?(token_1).should == true
    tokens.include?(token_2).should == true  
  end
  
  it "renders partial" do
    token = Token::Render.new
    rendered = token.get_token_view "vimeo", "22002326"
    rendered.should == rendered_vimeo
  end
  
  it "raises exception when token template isn't found" do
    token = Token::Render.new
    lambda {token.tokenize "missing", "22002326"}.should raise_error
  end
  
  it "should replace text with tokens and markdown" do
    Token::Render.new multiple_token_text
  end
  
  #it "should add the tokenize method to active record" do
  #  ActiveRecord::Base.method_defined?(:tokenize).should == true
  #end
  
  it "should add the tokenize method to action views" do
    ActionView::Base.method_defined?(:tokenize).should == true
  end
end
