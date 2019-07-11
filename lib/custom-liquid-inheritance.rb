require "liquid"

# Author: Dylan Mao<maverickpuss@gmail.com>
# Required Liquid version: 4.0.3
# p.s if you are using version 3.0.6 (or earlier, haven't tested yet), go to
# line #78 and add `nil` as the second parameter of the method
# `read_template_file`
module CustomLiquidInheritance
  class BlockDrop < Liquid::Drop
    def initialize(block)
      @block = block
    end

    def super
      @block.call_super(@context)
    end
  end

  class BlockTag < Liquid::Block
    Syntax = /(#{Liquid::QuotedFragment})/

    attr_accessor :parent
    attr_reader :name

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @name = $1
      else
        raise Liquid::SyntaxError.new(
          "Syntax Error in 'block' - Valid syntax: block [name]"
        )
      end

      super
    end

    def call_super(context)
      if @parent
        @parent.render(context)
      else
        raise Liquid::SyntaxError.new(
          "Syntax Error in 'block.super' - super '#{name}' block not defined"
        )
      end
    end

    def render(context)
      context.stack do
        context['block'] = BlockDrop.new(self)

        super(context)
      end
    end
  end

  class ExtendsTag < Liquid::Tag
    Syntax = /(#{Liquid::QuotedFragment})/

    attr_reader :layout

    def initialize(tag_name, markup, tokens)

      if markup =~ Syntax
        layout_expr = $1

        # unwrap quoted string: 'layout' -> layout
        @layout = Liquid::Expression.parse(layout_expr)
      else
        raise Liquid::SyntaxError.new(
          "Syntax Error in 'extends' - Valid syntax: extends [template]"
        )
      end

      super
    end

    def render(ctx)
      ''
    end
  end

  Liquid::Template.register_tag(:extends, ExtendsTag)
  Liquid::Template.register_tag(:block, BlockTag)
  # break rendering on errors
  Liquid::Template.error_mode = :strict

  class << self
    def load_template(tpl_name)
      source = Liquid::Template.file_system.read_template_file(tpl_name)
      Liquid::Template.parse(source)
    end

    def find_blocks(parent, blocks=[])
      parent.nodelist.each do |node|
        if node.is_a?(BlockTag)
          # block cant' be defined twice in the same layout
          if (blocks.index { |x| x.name == node.name })
            raise Liquid::SyntaxError.new(
              "Syntax Error in 'block #{node.name}' - block can't be defined twice in the same layout"
            )
          end

          blocks.push(node)
        end

        # find nested blocks(note: only blocks contain blocks)
        # do not use respond_to?(:nodelist), otherwise it will throw a
        # "nil Class" error, no ideas what happened since I'm not quite
        # experienced.
        if node.is_a?(Liquid::Block)
          find_blocks(node, blocks)
        end
      end

      blocks
    end

    def replace_nodes(parent, blocks)
      parent.nodelist.each_with_index do |node, idx|
        if node.is_a?(BlockTag)
          foundIdx = blocks.index { |x| x.name == node.name }

          if foundIdx
            # set a reference pointing to it's parent block
            blocks[foundIdx].parent = node

            parent.nodelist.insert(idx, blocks[foundIdx])
            parent.nodelist.delete_at(idx + 1)
          end
        end

        if node.is_a?(Liquid::Block)
          replace_nodes(node, blocks)
        end
      end
    end

    # the most important method, used to build the final nodetree to be rendered
    def parse_template(tpl_name)
      layout = load_template(tpl_name)

      # extract all defined blocks in child layouts, except the master layout,
      # which doesn't extend any parent layout, since it will be used as the
      # base nodetree to deal with the extracted child blocks.
      # from left to right: second-to-last layout blocks, ... child layout blocks,
      # grandchild layout blocks
      extended_blocks_chain = []

      while layout.root.nodelist[0].is_a?(ExtendsTag) do
        extended_blocks_chain.unshift(find_blocks(layout.root))
        layout = load_template(layout.root.nodelist[0].layout)
      end

      # recursively use child layout's blocks to override same name blocks in
      # master layout till there isn't any block left behind
      # NOTE: those stand-alone blocks which neither been defined in master
      # layout nor been used(as child block) in any child layout's blocks will
      # never be rendered.
      extended_blocks_chain.each do |blocks|
        replace_nodes(layout.root, blocks)
      end

      layout
    end
  end

  # to use render_liquid in your Sinatra/Padrino Controllers, please include
  # this helper.
  # e.g.: in Padrino App: helpers CustomLiquidInheritance::RenderHelper
  module RenderHelper
    def render_liquid(tpl_name, options={})
      tpl = ::CustomLiquidInheritance.parse_template(tpl_name)
      # use `render!` to break rendering on errors
      tpl.render!(options, :strict_variables => true, :strict_filters => true)
    end
  end
end
