require 'spec_helper'

describe Token do
  
  let(:single_token_text) { "### Cum sociis\n
## Etiam vel augue.\n
[Test](www.test.com)\n
@[youtube](jkas8sdh128)\n
Praesent id massa id nisl venenatis lacinia." }

  let(:multiple_token_text) { "### Cum sociis\n
@[youtube](jkas8sdh128)\n
## Etiam vel augue.\n
[Test](www.test.com)\n
@[vimeo]{date=8.26.11}(22002326)\n
Praesent id massa id nisl venenatis lacinia." }

  let(:single_token_render) { '<object style="height: 349px; width: 620px"><param name="movie" value="http://www.youtube.com/v/jkas8sdh128?version=4"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><embed src="http://www.youtube.com/v/jkas8sdh128?version=4" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="620" height="349"></object>' }
    
  it "should load the configuration file" do
    Token.reload!
    Token.options.should_not be nil
  end
  
  it "should automatically find tokens, replace them with their views, then insert markdown" do
    render = ::Token.render single_token_text
    render.should include(single_token_render)
    render.should include("<h3>Cum sociis</h3>")
    render.should include('<a href="www.test.com">Test</a>')
    render.should include("<h2>Etiam vel augue.</h2>")
    render.should include("<p>Praesent id massa id nisl venenatis lacinia.</p>")
  end
  
  it "should find tokens, provides a block with each token to modify" do
    ::Token.find_tokens multiple_token_text do |token|
      token.should be_a_kind_of(Hash)
    end
  end
  
  it "should find tokens, takes in a block to replace the current token in the given text " do
    replace = ::Token.find_tokens multiple_token_text do |token|
      token[:type].upcase
    end
    
    replace.should include("YOUTUBE", "VIMEO")
  end
  
  it "should replace tokens with rendered partials" do 
    render = Token::Render.new
    render.render_token({:type=>"youtube", :args=>{}, :value=>"jkas8sdh128"}).should include(single_token_render)
  end
end