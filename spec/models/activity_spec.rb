require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before(:each) do
    @person = people(:quentin)
    @commenter = people(:aaron)
  end

  it "should delete a post activity along with its parent item" do
    @post = ForumPost.new(:body => "Hey there")
    @post.topic  = topics(:one)
    @post.person = @person
    @post.save!
    destroy_should_remove_activity(@post)
  end
  
  it "should delete a comment activity along with its parent item" do
    @comment = @person.comments.build(:body => "Hey there")
    @comment.commenter = @commenter
    @comment.save!
    destroy_should_remove_activity(@comment)
  end
  
  it "should delete topic & post activities along with the parent items" do
    @topic = forums(:one).topics.build(:name => "A topic")
    @topic.person = @person
    @topic.save!
    post = @topic.posts.build(:body => "body")
    post.person = @person
    post.save!
    @topic.posts.each do |post|
      destroy_should_remove_activity(post)
    end
    destroy_should_remove_activity(@topic)
  end
  
  it "should delete an associated connection" do
    @person = people(:quentin)
    @contact = people(:aaron)
    Connection.connect(@person, @contact)
    @connection = Connection.conn(@person, @contact)
    destroy_should_remove_activity(@connection, :breakup)
  end
  
  before(:each) do
    # Create an activity.
    @person.comments.create(:body => "Hey there",
                            :commenter => @commenter)    
  end
  
  it "should have a nonempty global feed" do
    Activity.global_feed.should_not be_empty
  end
  
  it "should not show activities for users who are inactive" do
    @commenter.toggle!(:deactivated)
    @commenter.should be_deactivated
    Activity.global_feed.should be_empty
  end
  
  it "should not show activities for users who are email unverified" do
    @commenter.email_verified = false; @commenter.save!
    Activity.global_feed.should be_empty
  end
  
  private
  
  # TODO: do this in a more RSpecky way.
  def destroy_should_remove_activity(obj, method = :destroy)
    Activity.find_by_item_id(obj).should_not be_nil
    obj.send(method)
    Activity.find_by_item_id(obj).should be_nil
  end
end
