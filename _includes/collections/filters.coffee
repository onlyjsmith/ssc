class Filters extends Backbone.Collection
  model: Filter

  initialize: ->
    # preloadData is bootstrapped into index.html
    @_addIndices(preloadData.indices)
    @_addCountries(preloadData.countries)

  validFilter: (filterName, filterValue) ->
    return false unless filterName? and filterValue?
    
    @any (indice) ->
      indice.get('type') == filterName and
      indice.get('short') == filterValue

  # FIND/SEARCH
  nameFromShort: (short) ->
    got = @get(short)
    if got?
      got.get('name')
    else
      console.info "Can't find valid Filter for '#{short}'"
      false

  search: (term) ->
    @filter (indice) ->
      re = new RegExp(term, 'i')
      re.test(i.get('name'))

  _addIndices: (indices) ->
    _.each indices, (indice) =>
      _.each indice.values, (indiceEntry) =>
        @add
          name: indiceEntry.name
          short: indiceEntry.short
          type: indice.type
          filterTitle: indice.filterTitle

  _addCountries: (countries) ->
    _.each countries, (country) =>
      @add
        name: country.name
        short: country.iso3.toLowerCase()
        type: 'country'
        filterTitle: 'Country'
