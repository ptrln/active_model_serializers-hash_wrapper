require 'spec_helper'

describe ActiveModelSerializers::HashWrapper do

  it "should have a version" do
    expect(::ActiveModelSerializers::HashWrapper::VERSION).to_not be_nil
  end

  describe "#wrapper_class" do

    it "should return a subclass of ActiveModelSerializers::Model" do
      expect(::ActiveModelSerializers::HashWrapper.wrapper_class("Item").superclass).to be ActiveModelSerializers::Model
    end

  end

  describe "#create" do

    let(:regular_item) do
      {
        id: 2,
        display_name: "Carrots",
        pricing: {
          full_price: "$9.99",
        },
        offers: [],
        retailer: {
          name: "Whole-Foods-Market",
        }
      }
    end

    let(:sale_item) do
      {
        id: 1,
        display_name: "Carrots",
        pricing: {
          full_price: "$9.99",
          sale_price: "$8.99",
        },
        offers: [
          {
            type: :bogo,
          },
          {
            type: :delivery_promotion,
          },
        ],
        retailer: {
          name: "Whole-Foods-Market",
        }
      }
    end

    def wrap(item)
      ::ActiveModelSerializers::HashWrapper.create("Item", item)
    end

    describe "[]" do

      it "allows attributes to be retrieve through []" do
        expect(wrap(sale_item)[:id]).to eq sale_item[:id]
        expect(wrap(sale_item)[:display_name]).to eq sale_item[:display_name]
        expect(wrap(sale_item)[:unknown]).to eq sale_item[:unknown]
      end

    end

    describe "hash wrapper" do

      def stub_item_serializer
        stub_const 'ItemSerializer', Class.new(ActiveModel::Serializer)
        ItemSerializer.class_eval { attribute   :id }
        ItemSerializer.class_eval { attribute   :display_name, key: :name }
      end

      def stub_pricing_serializer
        stub_const 'PricingSerializer', Class.new(ActiveModel::Serializer)
        PricingSerializer.class_eval { attribute :price do object[:sale_price] || object[:full_price] end }
        PricingSerializer.class_eval { attribute :on_sale do object[:sale_price].present? end }
      end

      def stub_retailer_serializer
        stub_const 'RetailerSerializer', Class.new(ActiveModel::Serializer)
        RetailerSerializer.class_eval { attribute :name }
      end

      def stub_offer_serializer
        stub_const 'OfferSerializer', Class.new(ActiveModel::Serializer)
        OfferSerializer.class_eval { attribute :type, key: :offer_type }
      end

      it "returns the source hash if no serializer can be found" do
        expect(ActiveModelSerializers::SerializableResource.new(wrap(sale_item)).as_json).to eq sale_item
      end

      describe "with no nested attributes" do

        before do
          stub_item_serializer
        end

        let(:expected_sale_json) do
          {id: sale_item[:id], name: sale_item[:display_name]}
        end

        it "is serialized correctly" do
          expect(ItemSerializer.new(wrap(sale_item)).as_json).to eq expected_sale_json
        end

        it "AMS can infer correct serializer class" do
          expect(ActiveModelSerializers::SerializableResource.new(wrap(sale_item)).as_json).to eq expected_sale_json
        end

      end

      describe "with nested attributes" do

        let(:serialized_json) do
          ItemSerializer.new(wrap(sale_item)).as_json
        end

        before do
          stub_item_serializer
        end

        describe "with has_one" do

          before do
            ItemSerializer.class_eval { has_one :pricing }
          end

          let(:wrapped_pricing) { wrap(sale_item).read_attribute_for_serialization(:pricing) }

          it "returns source hash if no serializer found" do
            expect(ActiveModelSerializers::SerializableResource.new(wrapped_pricing).as_json).to eq(sale_item[:pricing])
          end

          it "infers the right serializer if serializer is defined" do
            stub_pricing_serializer
            expect(ActiveModel::Serializer.serializer_for(wrapped_pricing)).to be(PricingSerializer)
          end

          it "serializes correctly with inferred serializer" do
            stub_pricing_serializer
            expected_json = {
              price: sale_item[:pricing][:sale_price],
              on_sale: true,
            }
            expect(serialized_json[:pricing]).to eq(expected_json)
          end

          it "allows a different serializer to be chosen if _hash_wrapper_model_name is passed in hash" do
            item = sale_item
            item[:pricing][:_hash_wrapper_model_name] = "OtherPricing"
            stub_const 'OtherPricingSerializer', Class.new(ActiveModel::Serializer)
            OtherPricingSerializer.class_eval { attribute :price do object[:sale_price] || object[:full_price] end }
            expect(ItemSerializer.new(wrap(item)).as_json[:pricing]).to eq({price: item[:pricing][:sale_price]})
          end

        end

        describe "with has_many" do

          before do
            ItemSerializer.class_eval { has_many :offers }
          end

          it "returns source hash if no serializer found" do
            expect(serialized_json[:offers]).to eq(sale_item[:offers])
          end

          it "infers the right serializer if serializer is defined" do
            stub_offer_serializer
            wrapped_offer = wrap(sale_item).read_attribute_for_serialization(:offers)[0]
            expect(ActiveModel::Serializer.serializer_for(wrapped_offer)).to be(OfferSerializer)
          end

          it "serializes correctly with inferred serializer" do
            stub_offer_serializer
            expected_json = [
              {
                offer_type: :bogo,
              },
              {
                offer_type: :delivery_promotion,
              },
            ]
            expect(serialized_json[:offers]).to eq(expected_json)
          end

          it "allows a different serializer to be chosen if _hash_wrapper_model_name is passed in hash" do
            item = sale_item
            item[:offers].map { |o| o[:_hash_wrapper_model_name] = "Item::Offer" }
            stub_const 'Item::OfferSerializer', Class.new(ActiveModel::Serializer)
            Item::OfferSerializer.class_eval { attribute :type, key: :item_offer_type }
            expected_json = [
              {
                item_offer_type: :bogo,
              },
              {
                item_offer_type: :delivery_promotion,
              },
            ]
            expect(ItemSerializer.new(wrap(item)).as_json[:offers]).to eq(expected_json)
          end

        end

        describe "with belongs_to" do

          before do
            ItemSerializer.class_eval { belongs_to :retailer }
          end

          let(:wrapped_retailer) { wrap(sale_item).read_attribute_for_serialization(:retailer) }

          it "returns source hash if no serializer found" do
            expect(ActiveModelSerializers::SerializableResource.new(wrapped_retailer).as_json).to eq(sale_item[:retailer])
          end

          it "infers the right serializer if serializer is defined" do
            stub_retailer_serializer
            expected_json = {
              name: sale_item[:retailer][:name],
            }
            expect(serialized_json[:retailer]).to eq(expected_json)
          end

          it "infers the right serializer if serializer is defined" do
            stub_retailer_serializer
            expect(ActiveModel::Serializer.serializer_for(wrapped_retailer)).to be(RetailerSerializer)
          end

          it "serializes correctly with inferred serializer" do
            stub_retailer_serializer
            expected_json = {
              name: sale_item[:retailer][:name],
            }
            expect(serialized_json[:retailer]).to eq(expected_json)
          end

          it "allows a different serializer to be chosen if _hash_wrapper_model_name is passed in hash" do
            item = sale_item
            item[:retailer][:_hash_wrapper_model_name] = "RetailerV3"
            stub_const 'RetailerV3Serializer', Class.new(ActiveModel::Serializer)
            RetailerV3Serializer.class_eval { attribute :name, key: :retailer_name }
            expected_json = {
              retailer_name: sale_item[:retailer][:name],
            }
            expect(ItemSerializer.new(wrap(item)).as_json[:retailer]).to eq(expected_json)
          end

        end

        describe "full items" do

          before do
            stub_pricing_serializer
            stub_retailer_serializer

            ItemSerializer.class_eval { has_one     :pricing }
            ItemSerializer.class_eval { has_many    :offers }
            ItemSerializer.class_eval { belongs_to  :retailer }          
          end

          describe "sale item" do

            let(:wrapper) { wrap(sale_item) }

            let(:expected_json) do
              {
                id: sale_item[:id],
                name: sale_item[:display_name],
                pricing: {
                  price: sale_item[:pricing][:sale_price],
                  on_sale: true,
                },
                offers: sale_item[:offers],
                retailer: {
                  name: sale_item[:retailer][:name],
                }
              }
            end

            let(:serialized_json) do
              ItemSerializer.new(wrapper).as_json
            end

            it "is serialized correctly" do
              expect(serialized_json).to eq(expected_json)
            end

            it "AMS can infer correct serializer class" do
              expect(ActiveModelSerializers::SerializableResource.new(wrapper).as_json).to eq serialized_json
            end

            describe "override model name in nest hashes" do

              before do
                stub_const 'Item::OfferSerializer', Class.new(ActiveModel::Serializer)
                Item::OfferSerializer.class_eval { attribute :type, key: :offer_type }
              end

              let(:item) do
                sale_item[:offers].each { |o| o[:_hash_wrapper_model_name] = "Item::Offer" }
                sale_item
              end

              let(:serialized_json) do
                wrapper = ::ActiveModelSerializers::HashWrapper.create("Item", item)
                ItemSerializer.new(wrapper).as_json
              end

              it "is serialized with the correct serializer" do
                expect(serialized_json[:offers]).to eq([{offer_type: :bogo}, {offer_type: :delivery_promotion}])
              end

            end

          end

          describe "regular item" do

            let(:wrapper) { wrap(regular_item) }

            let(:expected_json) do
              {
                id: regular_item[:id],
                name: regular_item[:display_name],
                pricing: {
                  price: regular_item[:pricing][:full_price],
                  on_sale: false,
                },
                offers: [],
                retailer: {
                  name: regular_item[:retailer][:name],
                },
              }
            end

            let(:serialized_json) do
              ItemSerializer.new(wrapper).as_json
            end

            it "is serialized correctly" do
              expect(serialized_json).to eq(expected_json)
            end

            it "AMS can infer correct serializer class" do
              expect(ActiveModelSerializers::SerializableResource.new(wrapper).as_json).to eq serialized_json
            end

          end

        end

      end

    end

  end

end
