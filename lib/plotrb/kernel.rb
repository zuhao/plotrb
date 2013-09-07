module Plotrb

  # Kernel module includes most of the shortcuts used in Plotrb
  module Kernel

    # Don't use method_missing although it will shorten the code considerably.
    # Clarity is more important.

    # Initialize ::Plotrb::Visualization object

    def visualization(&block)
      ::Plotrb::Visualization.new(&block)
    end

    # Initialize ::Plotrb::Data objects

    def pdata(&block)
      ::Plotrb::Data.new(&block)
    end

    # Initialize ::Plotrb::Axis objects

    def x_axis(&block)
      ::Plotrb::Axis.new(:x, &block)
    end

    def y_axis(&block)
      ::Plotrb::Axis.new(:y, &block)
    end

    # Initialize ::Plotrb::Scale objects

    def linear_scale(&block)
      ::Plotrb::Scale.new(:linear, &block)
    end

    def log_scale(&block)
      ::Plotrb::Scale.new(:log, &block)
    end

    def pow_scale(&block)
      ::Plotrb::Scale.new(:pow, &block)
    end

    def sqrt_scale(&block)
      ::Plotrb::Scale.new(:sqrt, &block)
    end

    def quantile_scale(&block)
      ::Plotrb::Scale.new(:quantile, &block)
    end

    def quantize_scale(&block)
      ::Plotrb::Scale.new(:quantize, &block)
    end

    def threshold_scale(&block)
      ::Plotrb::Scale.new(:threshold, &block)
    end

    def ordinal_scale(&block)
      ::Plotrb::Scale.new(:ordinal, &block)
    end

    def time_scale(&block)
      ::Plotrb::Scale.new(:time, &block)
    end

    def utc_scale(&block)
      ::Plotrb::Scale.new(:utc, &block)
    end

    # Initialize ::Plotrb::Transform objects

    def array_transform(&block)
      ::Plotrb::Transform.new(:array, &block)
    end

    def copy_transform(&block)
      ::Plotrb::Transform.new(:copy, &block)
    end

    def cross_transform(&block)
      ::Plotrb::Transform.new(:cross, &block)
    end

    def facet_transform(&block)
      ::Plotrb::Transform.new(:facet, &block)
    end

    def filter_transform(&block)
      ::Plotrb::Transform.new(:filter, &block)
    end

    def flatten_transform(&block)
      ::Plotrb::Transform.new(:flatten, &block)
    end

    def fold_transform(&block)
      ::Plotrb::Transform.new(:fold, &block)
    end

    def formula_transform(&block)
      ::Plotrb::Transform.new(:formula, &block)
    end

    def slice_transform(&block)
      ::Plotrb::Transform.new(:slice, &block)
    end

    def sort_transform(&block)
      ::Plotrb::Transform.new(:sort, &block)
    end

    def stats_transform(&block)
      ::Plotrb::Transform.new(:stats, &block)
    end

    def truncate_transform(&block)
      ::Plotrb::Transform.new(:truncate, &block)
    end

    def unique_transform(&block)
      ::Plotrb::Transform.new(:unique, &block)
    end

    def window_transform(&block)
      ::Plotrb::Transform.new(:window, &block)
    end

    def zip_transform(&block)
      ::Plotrb::Transform.new(:zip, &block)
    end

    def force_transform(&block)
      ::Plotrb::Transform.new(:force, &block)
    end

    def geo_transform(&block)
      ::Plotrb::Transform.new(:geo, &block)
    end

    def geopath_transform(&block)
      ::Plotrb::Transform.new(:geopath, &block)
    end

    def link_transform(&block)
      ::Plotrb::Transform.new(:link, &block)
    end

    def pie_transform(&block)
      ::Plotrb::Transform.new(:pie, &block)
    end

    def stack_transform(&block)
      ::Plotrb::Transform.new(:stack, &block)
    end

    def treemap_transform(&block)
      ::Plotrb::Transform.new(:treemap, &block)
    end

    def wordcloud_transform(&block)
      ::Plotrb::Transform.new(:wordcloud, &block)
    end

    # Initialize ::Plotrb::Mark objects

    def rect_mark(&block)
      ::Plotrb::Mark.new(:rect, &block)
    end

    def symbol_mark(&block)
      ::Plotrb::Mark.new(:symbol, &block)
    end

    def path_mark(&block)
      ::Plotrb::Mark.new(:path, &block)
    end

    def arc_mark(&block)
      ::Plotrb::Mark.new(:arc, &block)
    end

    def area_mark(&block)
      ::Plotrb::Mark.new(:area, &block)
    end

    def line_mark(&block)
      ::Plotrb::Mark.new(:line, &block)
    end

    def image_mark(&block)
      ::Plotrb::Mark.new(:image, &block)
    end

    def text_mark(&block)
      ::Plotrb::Mark.new(:text, &block)
    end

  end

end
