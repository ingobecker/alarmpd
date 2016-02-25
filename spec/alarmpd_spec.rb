require 'alarmpd'

RSpec.describe AlarMPD do
  
  describe 'given a invalid playlist entry' do
    it{ expect(AlarMPD.parse_entry 'Gangsterrap').to be_nil}
  end

  describe 'given a valid playlist entry' do
    before(:example) do
      allow(Date).to receive(:today).and_return(Date.new(2016,2,24))
      allow(Time).to receive(:now).and_return(Time.mktime(2016,2,24,12,2))
    end

    describe 'refreshed' do
      subject(:ampd) {AlarMPD.new 'localhost', 6600}

      before(:example) do
        @first_alarm = ampd.latest_alarm
        allow(ampd).to receive(:next_alarm).and_return(Alarm.new('Wednesday 13:00', Time.new(2016,2,24,13,0)))
        ampd.refresh
      end

      it 'replaces latest_alarm' do
        expect(ampd.latest_alarm).not_to be(@first_alarm)
      end

      describe 'refreshed without changes' do
        it 'doesn\'t replace  latest_alarm' do
          previous_alarm = ampd.latest_alarm
          ampd.refresh
          expect(ampd.latest_alarm).to be(previous_alarm)
        end
      end

      describe 'refreshed with new alarm' do
        it 'replaces alarm' do
          allow(ampd).to receive(:next_alarm).and_return(Alarm.new('Wednesday 12:00', Time.new(2016,2,24,12,0)))
          previous_alarm = ampd.latest_alarm
          ampd.refresh
          expect(ampd.latest_alarm).not_to be(previous_alarm)
        end
      end

      describe 'refreshed with no alarm' do
        it 'have no alarm' do
          allow(ampd).to receive(:next_alarm).and_return(nil)
          ampd.refresh
          expect(ampd.next_alarm).to be_nil
        end
      end
    end

    it 'parses to correct time' do
      expect(AlarMPD.parse_entry 'Wednesday 13:00').to eq(Time.new(2016,2,24,13,0))
    end

    describe 'that wraps around' do
      it 'parses to correct time' do
        expect(AlarMPD.parse_entry 'Wednesday 1:00').to eq(Time.new(2016,2,31,1,0))
      end
    end

  end
end
