# frozen_string_literal: true

module AEMO
  # Namespace for classes and modules that handle AEMO Gem NEM12 interactions
  # @since 0.1.4
  class NEM12
    QUALITY_FLAGS = {
      'A' => 'Actual Data',
      'E' => 'Forward Estimated Data',
      'F' => 'Final Substituted Data',
      'N' => 'Null Data',
      'S' => 'Substituted Data',
      'V' => 'Variable Data'
    }.freeze

    METHOD_FLAGS = {
      11 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Check', description: '' },
      12 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Calculated', description: '' },
      13 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'SCADA', description: '' },
      14 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Retrospective Like Day', description: 'Updated v7.8' },
      15 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Retrospective Average Like Day', description: 'Updated v7.8' },
      16 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Agreed', description: '[OBSOLETE] v7.8' },
      17 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Linear', description: '' },
      18 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Alternate', description: '' },
      19 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Zero', description: '' },
      20 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Prospective Like Day',
              description: 'Updated v7.8' },
      21 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Five-minute No Historical Data',
              description: 'Added v7.8' },
      22 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Prospective Ave Like Day',
              description: 'Added v7.8' },
      23 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Previous Year',
              description: 'Added v7.8' },
      24 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'Data Scaling',
              description: 'Added v7.8' },
      25 => { type: %w[SUB], installation_type: [1, 2, 3, 4], short_descriptor: 'ADL',
              description: 'Added v7.8' },
      51 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Previous Year', description: '' },
      52 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Previous Read', description: '' },
      53 => { type: %w[SUB], installation_type: 5, short_descriptor: 'Revision', description: '' },
      54 => { type: %w[SUB], installation_type: 5, short_descriptor: 'Linear', description: '' },
      55 => { type: %w[SUB], installation_type: 5, short_descriptor: 'Agreed', description: '' },
      56 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Prior to First Read - Agreed',
              description: '' },
      57 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Customer Class', description: '' },
      58 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Zero', description: '' },
      59 => { type: %w[EST SUB], installation_type: 5, short_descriptor: 'Five-minute No Historical Data',
              description: '' },
      61 => { type: %w[EST SUB], installation_type: 6, short_descriptor: 'Previous Year', description: '' },
      62 => { type: %w[EST SUB], installation_type: 6, short_descriptor: 'Previous Read', description: '' },
      63 => { type: %w[EST SUB], installation_type: 6, short_descriptor: 'Customer Class', description: '' },
      64 => { type: %w[SUB], installation_type: 6, short_descriptor: 'Agreed', description: '' },
      65 => { type: %w[EST], installation_type: 6, short_descriptor: 'ADL', description: '' },
      66 => { type: %w[SUB], installation_type: 6, short_descriptor: 'Revision', description: '' },
      67 => { type: %w[SUB], installation_type: 6, short_descriptor: 'Customer Read', description: '' },
      68 => { type: %w[EST SUB], installation_type: 6, short_descriptor: 'Zero', description: '' },
      69 => { type: %w[SUB], installation_type: 6, short_descriptor: 'Linear extrapolation', description: '' },
      71 => { type: %w[SUB], installation_type: 7, short_descriptor: 'Recalculation', description: '' },
      72 => { type: %w[SUB], installation_type: 7, short_descriptor: 'Revised Table', description: '' },
      73 => { type: %w[SUB], installation_type: 7, short_descriptor: 'Revised Algorithm', description: '' },
      74 => { type: %w[SUB], installation_type: 7, short_descriptor: 'Agreed', description: '' },
      75 => { type: %w[EST], installation_type: 7, short_descriptor: 'Existing Table', description: '' }
    }.freeze
  end
end
