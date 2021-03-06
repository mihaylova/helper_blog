require 'spec_helper'

describe Post do
	it { should validate_presence_of(:title) }
	it { should validate_presence_of(:user_id) }
	it { should validate_uniqueness_of(:title) }

	it { should validate_presence_of(:text) }
	it { should belong_to(:user) }
	it { should belong_to(:last_editor).class_name('User') }
	it { should have_many(:comments).dependent(:destroy) }

	it { should have_many(:pictures).dependent(:destroy) }
	it { should have_and_belong_to_many(:tags) }

	it { should accept_nested_attributes_for(:pictures).
              allow_destroy(true)}

	describe "searchALL" do
		let!(:post) { FactoryGirl.create(:post, title: "Some title")}
		let(:tag) { FactoryGirl.create(:tag, name: "Tag_name")}
		
		it "can search posts by keyword" do
			expect(Post.searchAll("Some")).to eq [post]
		end

		it "can search posts by tag keyword" do
			post.tags << tag
			post.save
			expect(Post.searchAll("Tag_n")).to eq [post]
		end
	end

	describe "Count posts" do 
		context "by tag" do
			let(:post_1) { FactoryGirl.create(:post)}
			let(:tag) {FactoryGirl.create(:tag)}
			let!(:post_2) { FactoryGirl.create(:post)}

			before do
				post_1.tags << tag
				post_2.tags << tag
				post_1.save
				post_2.save
				@hash = {[tag.name, tag.id]=>2, [post_1.tags.first.name, post_1.tags.first.id]=>1, [post_2.tags.first.name, post_2.tags.first.id]=>1}
			end

			it "count post by tag" do 
				expect(Post.count_posts_by_tags(Post.all)).to eq @hash
			end 
		end

		context "by author" do
			let(:user_1) { FactoryGirl.create(:user)}
			let(:user_2) { FactoryGirl.create(:user)}
			let(:post_2) { FactoryGirl.create(:post, user: user_2)}
			let(:post_1) { FactoryGirl.create(:post, user: user_1)}

			before { @hash = {[post_2.user.name, post_2.user.id]=>1, [post_1.user.name, post_1.user.id]=>1} }

			it "count post by author" do 
				expect(Post.count_posts_by_authors(Post.all)).to eq @hash
			end 
		end

		context "by private" do 
			let!(:post_2) { FactoryGirl.create(:post, private: true)}
			let!(:post_1) { FactoryGirl.create(:post, private: true)}

			it "count private posts" do 
				expect(Post.count_private_posts(Post.all)).to eq 2
			end 
		end
	end

	describe "filter" do
		context "by tags" do 
			let(:post_1) { FactoryGirl.create(:post)}
			let(:tag) {FactoryGirl.create(:tag)}
			let!(:post_2) { FactoryGirl.create(:post)}

			before do
				post_1.tags << tag
				post_1.save
			end

			it "filter post by tag" do 
				expect(Post.filter({tags: [tag.id.to_s]})).to eq [post_1]
			end 
		end

		context "by authors" do 
			let(:user_1) { FactoryGirl.create(:user)}
			let(:user_2) { FactoryGirl.create(:user)}
			let!(:post_2) { FactoryGirl.create(:post, user: user_2)}
			let(:post_1) { FactoryGirl.create(:post, user: user_1)}

			it "filter post by authors" do 
				expect(Post.filter({authors: [user_1.id.to_s]})).to eq [post_1]
			end
		end

		context "by private" do 
			let!(:post) { FactoryGirl.create(:post)}
			let(:private_post) { FactoryGirl.create(:post, private: true)}

			it "filter by private" do
				expect(Post.filter({private: "1"})).to eq [private_post]
			end
		end
	end

	describe "Sort_by" do
		context "title" do 
			let(:post_last) { FactoryGirl.create(:post, title: "B")}
			let(:post_first) { FactoryGirl.create(:post, title: "A")}

			it "sort by title" do
				expect(Post.sort_by('title')).to eq [post_first, post_last]
			end
		end

		context "comments count" do 
			let(:post_last) { FactoryGirl.create(:post)}
			let(:comment) { FactoryGirl.create(:comment)}

			it "sort by comments count" do
				expect(Post.sort_by('comments')).to eq [comment.post, post_last]
			end
		end

		context "rating" do 
			let(:comment_last) { FactoryGirl.create(:comment, rating: 2)}
			let(:comment_first) { FactoryGirl.create(:comment, rating: 5)}

			it "sort by avg rating" do
				expect(Post.sort_by('rating')).to eq [comment_first.post, comment_last.post]
			end
		end

		context "author" do 
			let(:user_first) { FactoryGirl.create(:user, name: "A")}
			let(:user_last) { FactoryGirl.create(:user, name: "B")}
			let(:post_last) { FactoryGirl.create(:post, user: user_last)}
			let(:post_first) { FactoryGirl.create(:post, user: user_first)}

			it "sort by author's name" do
				expect(Post.sort_by('author')).to eq [post_first, post_last]
			end
		end
	end
end
