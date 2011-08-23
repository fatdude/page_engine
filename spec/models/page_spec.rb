require 'spec_helper'

describe Page do  
  
  before(:each) do
    @attr = {
      :title => "A topic"
    }
    @page = Page.create!(@attr)
  end
  
  describe 'validations' do
    it 'should be valid with valid attributes' do
      @page.should be_valid
    end
    
    it 'requires a title' do
      @page.title = nil
      @page.should_not be_valid
    end
    
    it 'requires a unique permalink' do
      page = Page.new(@attr)
      page.should_not be_valid
    end
  end
  
  it 'returns correct no_publish_window_set?' do
    @page.no_publish_window_set?.should == true
    
    @page.publish_from = 1.day.ago
    @page.publish_to = 1.day.from_now
    
    @page.no_publish_window_set?.should == false
  end
  
  it 'returns correct controller_action' do
    @page.controller_action.should == nil
    @page.controller = 'welcome'
    @page.action = 'index'
    
    @page.controller_action.should == "welcome|index"
  end
  
  it 'should return the permalink when as param' do 
    @page.to_param.should == 'a-topic'
  end
end
