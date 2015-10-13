define (require) ->

  $        = require 'jquery'
  _        = require 'underscore'
  Backbone = require 'backbone'

  template = require '../../jade/grid.jade'

  require '../../css/grid.less'

  class extends Backbone.View
    className: 'grid-view'

    initialize: (@boardModel) ->
      @render()
      @boardModel.on 'change', _.bind @render, @

    render: ->
      @$el.html template(board: @boardModel.get('board'))
      @bindEvents()

      # Render last moved cell shading
      lastMove = @boardModel.get('last_move')
      if lastMove
        @$cells.filter("[data-x='#{lastMove.from.x}'][data-y='#{lastMove.from.y}']")
          .addClass 'last-move-from'

        @$cells.filter("[data-x='#{lastMove.to.x}'][data-y='#{lastMove.to.y}']")
          .addClass 'last-move-to'

    bindEvents: ->
      @$cells  = @$el.find '.cell'
      @$pieces = @$el.find '.piece'

      @$cells.on 'click', _.bind @_clickCell, @
      @$cells.on 'mouseover', _.bind @_hoverInCell, @
      @$cells.on 'mouseleave', _.bind @_hoverOutCell, @
      @$cells.on 'dragover', _.bind @_dragOverCell, @
      @$cells.on 'dragleave', _.bind @_dragLeaveCell, @
      @$cells.on 'drop', _.bind @_dropCell, @

      @$pieces.on 'dragstart', _.bind @_dragStart, @
      @$pieces.on 'dragend', _.bind @_dragEnd, @

    _dragStart: (e) ->
      @$cells.removeClass 'selected'

      $cell = $(e.target).parent()

      $cell.addClass 'selected'

      data =
        from:
          x: $cell.data 'x'
          y: $cell.data 'y'

      e.originalEvent.dataTransfer.setData 'text/plain', JSON.stringify(data)

    _dragEnd: (e) ->
      $(e.target).parent().removeClass 'selected'

    _dragOverCell: (e) ->
      e.preventDefault()

      $cell = @_getCellFromTarget e
      $cell.addClass 'hover'

    _dropCell: (e) ->
      $toCell = @_getCellFromTarget e
      $toCell.removeClass 'hover'

      @$cells.removeClass 'selected'

      data = JSON.parse e.originalEvent.dataTransfer.getData 'text'

      to =
        x: $toCell.data 'x'
        y: $toCell.data 'y'

      @trigger 'move', data.from, to

    _dragLeaveCell: (e) ->
      @_getCellFromTarget(e).removeClass 'hover'

    _clickCell: (e) ->
      $currentTarget = $ e.currentTarget

      $fromCell = @$cells.filter '.selected'

      @$cells.removeClass 'selected'
      @$cells.removeClass 'hover'

      if $fromCell.length
        # Enable drag
        @$pieces.filter((i, e) =>
          return @canSelect($(e).parent())
        ).attr 'draggable', true

        to =
          x: $currentTarget.data 'x'
          y: $currentTarget.data 'y'

        from =
          x: $fromCell.data 'x'
          y: $fromCell.data 'y'

        @trigger 'move', from, to

      # If nothing is selected, is there a piece in this cell we can select?
      else if $(e.target).hasClass('piece') and @canSelect($currentTarget)
        # Disable drag
        @$pieces.removeAttr 'draggable'

        $currentTarget.addClass 'selected'

    _hoverInCell: (e) ->
      $cell = @_getCellFromTarget e

      if $cell.find('.piece').length and @canSelect($cell)
        $cell.addClass 'hover'
      else if @$cells.filter('.selected').length
        $cell.addClass 'hover'

    _hoverOutCell: (e) ->
      @_getCellFromTarget(e).removeClass 'hover'

    _getCellFromTarget: (e) ->
      $cell = $(e.target)
      if $cell.hasClass 'piece'
        $cell = $cell.parent()

      $cell

    canSelect: (cell) ->
      if cell.find('.piece').data('rank') is '?' then false else true
