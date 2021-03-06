class HeadlinesView extends Backbone.View
  template: ->  _.template($('#headlinesView').html())

  events: 
    'click .reset': '_resetFilters'

  initialize: ->
    @listenTo @collection, 'reset', @render
    @listenTo app.state, 'filters:changed', @render

    @render()

  render: ->
    compiled = @template()(
      collection: @collection
      stats: @_calculateStats()
    )
    @$el.html(compiled)
    @

  _calculateStats: ->
    filterState = app.state.get('filterState')
    primaryFilter = filterState

    activeCountriesCount: 
      @collection.prepareFilterGroupForType('country').length
    primaryFilterTitle:
      if filterState?[0]?
        app.filters.nameFromShort(filterState[0].value)
      else
        'All projects'
    hasSecondaryFilters:
      filterState?.length > 1
    secondaryFilterCount:
      filterState?.length - 1 || 0

  _resetFilters: =>
    @collection.clearFilters()