#!/usr/bin/env rspec

require_relative "test_helper"

require "yast"
require "network/edit_nic_name"

module Yast

  Yast.import "UI"

  CURRENT_NAME = "spec0"
  NEW_NAME = "new1"

  describe '#run' do

    # general mocking stuff is placed here
    before( :each) do
      # NetworkInterfaces are too low level. Everything needed should be mocked
      NetworkInterfaces.as_null_object

      # mock devices configuration
      LanItems.stub( :ReadHardware) { [ { "dev_name" => CURRENT_NAME } ] }
      LanItems.stub( :getNetworkInterfaces) { [ CURRENT_NAME ] }
      LanItems.stub( :GetItemUdev) { "" }
      LanItems.stub( :GetItemUdev).with("NAME") { CURRENT_NAME }

      # LanItems initialization
      Yast.import "LanItems"

      LanItems.Read
      LanItems.FindAndSelect( CURRENT_NAME)

      # create the dialog
      @edit_name_dlg = EditNicName.new

      allow(LanItems)
        .to receive(:GetNetcardNames)
        .and_return([CURRENT_NAME])
    end

    context 'when closed without any change' do
      before( :each) do
        # emulate UI work
        UI.stub( :QueryWidget).with( :dev_name, :Value) { CURRENT_NAME }
        UI.stub( :QueryWidget).with( :udev_type, :CurrentButton) { :mac }

      end

      it 'returns current name when used Ok button' do
        UI.stub( :UserInput) { :ok }

        expect( @edit_name_dlg.run).to be_equal CURRENT_NAME
      end

      it 'returns current name when used Cancel button' do
        UI.stub( :UserInput) { :cancel }

        expect( @edit_name_dlg.run).to be_equal CURRENT_NAME
      end
    end

    context 'when closed after name change' do
      before( :each) do
        # emulate UI work
        UI.stub( :QueryWidget).with( :dev_name, :Value) { NEW_NAME }
        UI.stub( :QueryWidget).with( :udev_type, :CurrentButton) { :mac }
      end

      it 'returns new name when used Ok button' do
        UI.stub( :UserInput) { :ok }

        expect( @edit_name_dlg.run).to be_equal NEW_NAME
      end

      it 'returns current name when used Cancel button' do
        UI.stub( :UserInput) { :cancel }

        expect( @edit_name_dlg.run).to be_equal CURRENT_NAME
      end
    end
  end
end
