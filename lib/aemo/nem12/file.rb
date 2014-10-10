module AEMO
  module NEM12
    class File
      attr_reader :csv, :file, :header, :footer, :nmis, :records

      def initialize(file)
        @file = file
        @csv = ::CSV.new(file)
        @enumerator = @csv.each

        @records = []

        parse_header
        parse_body
      end

      def parse_header
        @header = Header.new(
          version_identifier: enumerator.peek[1],
          created_at: Time.parse(enumerator.peek[2]),
          from_participant: enumerator.peek[3],
          to_participant: enumerator.peek[4]
        )
      end

      def parse_body
        while enumerator.peek[0] != "900"
          parse_row enumerator.next
        end
      rescue StopIteration
      end

      def parse_row(row)
        case row[0]
        when "200" then parse_data_detail(row)
        end
      end

      def parse_data_row(row, detail)
        case row[0]
        when "300" then parse_interval_data(row, detail)
        # when "400" then parse_interval_event(row, interval_length)
        # when "500" then parse_b2b_detail(row, interval_length)
        end
      end

      def where(options)
        records.select do |record|
          record.match?(options)
        end
      end

      def find(options)
        where(options).first
      end

      def parse_data_detail(row)
        detail = find(
          nmi: row[1],
          register_id: row[3],
          nmi_suffix: row[4],
          nmi_data_stream_identifier: row[5],
          meter_serial_number: row[6],
          uom: row[7]
        )

        unless detail
          detail = DataDetail.new(
            nmi: row[1],
            nmi_configuration: row[2],
            register_id: row[3],
            nmi_suffix: row[4],
            nmi_data_stream_identifier: row[5],
            meter_serial_number: row[6],
            uom: row[7],
            interval_length: row[8].to_i,
            next_scheduled_read_on: row[9],
            records: []
          )
          @records << detail
        end

        while enumerator.peek[0] != "200"
          parse_data_row(enumerator.next, detail)
        end
      end

      def parse_interval_data(row, detail)
        start_index = 2
        end_index = detail.interval_count + 1
        time = Time.parse(row[1])

        values = (start_index..end_index).to_a.map.with_index do |row_index, i|
          { read_at: time + (i * detail.interval_length).minutes, value: row[row_index].to_d }
        end

        detail.records << IntervalData.new(
          date: Date.parse(row[1]),
          values: values,
          quality_method: row[end_index + 1],
          reason_code: row[end_index + 2],
          reason_description: row[end_index + 3],
          updated_at: row[end_index + 4],
          msats_loaded_at: row[end_index + 5]
        )
      end

      def parse_interval_event(row)
        raise NotImplementedError.new("Not implemented yet")
      end

      def parse_b2b_detail(row)
        raise NotImplementedError.new("Not implemented yet")
      end

      private

      attr_reader :enumerator
    end
  end
end
