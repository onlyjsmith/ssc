class FilterView extends Backbone.View
  template: ->  _.template($('#filterView').html())

  events:
    'click #filters': '_showHideAllFilters'
    'click .filter-group': '_showHideFilterGroup'
    'click .group-item[data-active-filter="false"]': '_addFilter'
    'click .group-item[data-active-filter="true"]': '_removeFilter'
    'click .active-filter': '_removeFilter'
    'click .reset-filters': '_resetFilters'


  initialize:  () ->
    @state = app.state

    @listenTo @state, 'search:foundFilters', @_showFilterSearchResults
    @listenTo @state, 'search:stopped', @_hideFilterSearchResults

    @listenTo @collection, 'reset', @render

    @render()

  render: (options) =>
    filterGroups = options?.filterGroups || @_prepareFilterGroups()
    compiled = @template()(
      activeFilters: @_prepareActiveFilters()
      collection: @collection
      filterGroups: filterGroups
      hasSearchResults: options?.hasSearchResults
    )
    @$el.html(compiled)

  _prepareActiveFilters: =>
    _.map @state.get('filterState'), (filter) ->
      filter.long = app.filters.nameFromShort(filter.value)
      filter

  _prepareFilterGroups: =>
    @collection.prepareFilterGroups()

  _showHideAllFilters: (ev) ->
    ev.preventDefault()
    @$el.find('.filters').toggle()
    @$el.find('img.filters-disclose').toggleClass('displayed')

  _showHideFilterGroup: (ev) ->
    ev.preventDefault()
    $(ev.target).siblings().toggle()

  _addFilter: (ev) =>
    ev.preventDefault()
    data = ev.currentTarget.dataset
    @state.addFilter(facetName: data.filterName, facetValue: data.filterValue)

  _removeFilter: (ev) =>
    ev.preventDefault()
    data = ev.currentTarget.dataset
    @state.removeFilter(facetName: data.filterName, facetValue: data.filterValue)

  _resetFilters: (ev) =>
    ev.preventDefault()
    @state.clearFilters()

  _showFilterSearchResults: (results) =>
    @_receivedSearchResults = true
    @render(hasSearchResults: true, filterGroups: results) 

  _hideFilterSearchResults: =>
    @render() if @_receivedSearchResults? # Render original filterGroups
