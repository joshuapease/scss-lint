require 'spec_helper'

describe SCSSLint::Linter::PropertySortOrder do
  context 'when rule is empty' do
    let(:scss) { <<-SCSS }
      p {
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in sorted order' do
    let(:scss) { <<-SCSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule contains nested properties in unsorted order' do
    let(:scss) { <<-SCSS }
      p {
        font: {
          family: Arial;
          weight: bold;
          size: 1.2em;
        }
      }
    SCSS

    it { should report_lint line: 4 }
  end

  context 'when rule contains mixins followed by properties in sorted order' do
    let(:scss) { <<-SCSS }
      p {
        @include border-radius(5px);
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule contains nested rules after sorted properties' do
    let(:scss) { <<-SCSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
          color: #555;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in random order' do
    let(:scss) { <<-SCSS }
      p {
        padding: 5px;
        display: block;
        margin: 10px;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when there are multiple rules with out of order properties' do
    let(:scss) { <<-SCSS }
      p {
        display: block;
        background: #fff;
      }
      a {
        margin: 5px;
        color: #444;
      }
    SCSS

    it { should report_lint line: 2 }
    it { should report_lint line: 6 }
  end

  context 'when there are nested rules with out of order properties' do
    let(:scss) { <<-SCSS }
      p {
        display: block;
        background: #fff;
        a {
          margin: 5px;
          color: #444;
        }
      }
    SCSS

    it { should report_lint line: 2 }
    it { should report_lint line: 5 }
  end

  context 'when out-of-order property is the second last in the list of sorted properties' do
    let(:scss) { <<-SCSS }
      p {
        border: 0;
        border-radius: 3px;
        float: left;
        display: block;
      }
    SCSS

    it { should report_lint line: 4 }
  end

  context 'when vendor-prefixed properties are ordered after the non-prefixed property' do
    let(:scss) { <<-SCSS }
      p {
        border-radius: 3px;
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when vendor-prefixed properties are ordered before the non-prefixed property' do
    let(:scss) { <<-SCSS }
      p {
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
        border-radius: 3px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when using -moz-osx vendor-prefixed property' do
    let(:scss) { <<-SCSS }
      p {
        -moz-osx-font-smoothing: grayscale;
        -webkit-font-smoothing: antialiased;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when vendor properties are ordered out-of-order before the non-prefixed property' do
    let(:scss) { <<-SCSS }
      p {
        -moz-border-radius: 3px;
        -webkit-border-radius: 3px;
        -o-border-radius: 3px;
        border-radius: 3px;
      }
    SCSS

    it { should report_lint line: 3 }
  end

  context 'when include block contains properties in sorted order' do
    let(:scss) { <<-SCSS }
      @include some-mixin {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when include block contains properties not in sorted order' do
    let(:scss) { <<-SCSS }
      @include some-mixin {
        background: #000;
        margin: 5px;
        display: none;
      }
    SCSS

    it { should report_lint line: 3 }
  end

  context 'when @media block contains properties not in sorted order' do
    let(:scss) { <<-SCSS }
      @media screen and (min-width: 500px) {
        margin: 5px;
        display: none;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when if block contains properties in sorted order' do
    let(:scss) { <<-SCSS }
      @if $var {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when if block contains properties not in sorted order' do
    let(:scss) { <<-SCSS }
      @if $var {
        background: #000;
        margin: 5px;
        display: none;
      }
    SCSS

    it { should report_lint line: 3 }
  end

  context 'when if block contains properties in sorted order' do
    let(:scss) { <<-SCSS }
      @if $var {
        // Content
      } @else {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when else block contains properties not in sorted order' do
    let(:scss) { <<-SCSS }
      @if $var {
        // Content
      } @else {
        background: #000;
        margin: 5px;
        display: none;
      }
    SCSS

    it { should report_lint line: 5 }
  end

  context 'when the order has been explicitly set' do
    let(:linter_config) { { 'order' => %w[position display padding margin width] } }

    context 'and the properties match the specified order' do
      let(:scss) { <<-SCSS }
        p {
          display: block;
          padding: 5px;
          margin: 10px;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'and the properties do not match the specified order' do
      let(:scss) { <<-SCSS }
        p {
          padding: 5px;
          display: block;
          margin: 10px;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'and there are properties that are not specified in the explicit ordering' do
      let(:scss) { <<-SCSS }
        p {
          display: block;
          padding: 5px;
          font-weight: bold; // Unspecified
          margin: 10px;
          border: 0;         // Unspecified
          background: red;   // Unspecified
          width: 100%;
        }
      SCSS

      context 'and the ignore_unspecified option is enabled' do
        let(:linter_config) { super().merge('ignore_unspecified' => true) }

        it { should_not report_lint }
      end

      context 'and the ignore_unspecified option is disabled' do
        let(:linter_config) { super().merge('ignore_unspecified' => false) }

        it { should report_lint }
      end
    end
  end

  context 'when sort order is set to a preset order' do
    let(:linter_config) { { 'order' => 'concentric' } }

    context 'and the properties match the order' do
      let(:scss) { <<-SCSS }
        p {
          display: block;
          position: absolute;
          float: left;
          clear: both;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'and the properties do not match the order' do
      let(:scss) { <<-SCSS }
        p {
          clear: both;
          display: block;
          float: left;
          position: absolute;
        }
      SCSS

      it { should report_lint }
    end
  end

  context 'when separation between groups of properties is enforced' do
    let(:order) do
      %w[display position top right bottom left] + [nil] +
      %w[width height margin padding] + [nil] +
      %w[float clear]
    end

    let(:linter_config) { { 'separate_groups' => true, 'order' => order } }

    context 'and the groups are separated correctly' do
      let(:scss) { <<-SCSS }
        p {
          display: none;
          position: absolute;

          margin: 0;
          padding: 0;

          float: left;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'and the groups are separated incorrectly' do
      let(:scss) { <<-SCSS }
        p {
          display: none;
          position: absolute;
          margin: 0;

          padding: 0;

          float: left;
        }
      SCSS

      it { should report_lint line: 4 }
    end

    context 'and the groups are separated by a comment' do
      let(:scss) { <<-SCSS }
        p {
          display: none;
          position: absolute;
          //
          margin: 0;
          padding: 0;
          //
          float: left;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the sort order has multiple gaps separating two groups' do
      let(:order) { %w[display position] + [nil, nil] + %w[margin padding] }

      context 'and the groups are separated correctly' do
        let(:scss) { <<-SCSS }
          p {
            display: none;
            position: absolute;

            margin: 0;
            padding: 0;
          }
        SCSS

        it { should_not report_lint }
      end

      context 'and the groups are separated incorrectly' do
        let(:scss) { <<-SCSS }
          p {
            display: none;
            position: absolute;
            margin: 0;

            padding: 0;
          }
        SCSS

        it { should report_lint line: 4 }
      end
    end
  end

  context 'when a minimum number of properties is required' do
    let(:linter_config) { { 'min_properties' => 3 } }

    context 'when fewer than the minimum number of properties are out of order' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
          display: none;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when at least the minimum number of properties are out of order' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
          position: absolute;
          display: none;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the minimum number of properties are out of order in a nested property' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
          font: {
            size: 16px;
            weight: bold;
            family: Arial;
          }
        }
      SCSS

      it { should report_lint line: 4 }
    end
  end
end
