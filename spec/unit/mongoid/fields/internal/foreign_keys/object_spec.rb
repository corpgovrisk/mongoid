require "spec_helper"

describe Mongoid::Fields::Internal::ForeignKeys::Object do

  describe "#serialize" do

    context "when the array is object ids" do

      let(:metadata) do
        Mongoid::Relations::Metadata.new(
          :inverse_class_name => "Game",
          :name => :person,
          :relation => Mongoid::Relations::Referenced::In
        )
      end

      let(:field) do
        described_class.instantiate(
          :vals,
          :type => Object,
          :default => nil,
          :identity => true,
          :metadata => metadata
        )
      end

      context "when using object ids" do

        let(:object_id) do
          BSON::ObjectId.new
        end

        it "performs conversion on the ids if strings" do
          field.serialize(object_id.to_s).should == object_id
        end
      end

      context "when not using object ids" do

        context "when using strings" do

          context "when provided a string" do

            let(:object_id) do
              BSON::ObjectId.new
            end

            before do
              Person.identity :type => String
            end

            after do
              Person.identity :type => BSON::ObjectId
            end

            it "does not convert" do
              field.serialize(object_id.to_s).should == object_id.to_s
            end
          end

          context "when provided a hash" do

            let(:object_id) do
              BSON::ObjectId.new
            end

            before do
              Person.identity :type => String
            end

            after do
              Person.identity :type => BSON::ObjectId
            end

            let(:criterion) do
              { "$in" => [ object_id.to_s ] }
            end

            it "does not convert" do
              field.serialize(criterion).should eq(
                criterion
              )
            end
          end
        end

        context "when using integers" do

          context "when provided a string" do

            before do
              Person.identity :type => Integer
            end

            after do
              Person.identity :type => BSON::ObjectId
            end

            it "does not convert" do
              field.serialize("1").should eq(1)
            end
          end

          context "when provided a hash with a string value" do

            before do
              Person.identity :type => Integer
            end

            after do
              Person.identity :type => BSON::ObjectId
            end

            let(:criterion) do
              { "$eq" => "1" }
            end

            it "does not convert" do
              field.serialize(criterion).should eq(
                { "$eq" => 1 }
              )
            end
          end

          context "when provided a hash with an array of string values" do

            before do
              Person.identity :type => Integer
            end

            after do
              Person.identity :type => BSON::ObjectId
            end

            let(:criterion) do
              { "$in" => [ "1" ] }
            end

            it "does not convert" do
              field.serialize(criterion).should eq(
                { "$in" => [ 1 ] }
              )
            end
          end
        end
      end
    end
  end
end
