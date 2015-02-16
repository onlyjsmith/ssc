Router = Backbone.Router.extend
  initialize: ->
    @$appEl ||= $("#app")

  routes:
    ''                       : 'explorer'
    'project/:projectId'     : 'project'
    'admin'                  : 'admin'
    ':facetName/:facetValue' : 'explorer'
  
  # ROUTES
  explorer: (facetName, facetValue) ->
    params = app.utils.getUrlParams()

    console.log 'clearFilters here or not always?'
    # app.projects.clearFilters()

    if params.filterRef? # Try to find from stores (local and remote)
      options = 
        filterRef: params.filterRef
        facetName: facetName
        facetValue: facetValue

      app.projects.recreateFilterStateFromRef(options) 

    else if facetName and facetValue
      app.projects.clearFilters() # Better in here?
      app.projects.addFilter(name: facetName, value: facetValue)

    view = new ExplorerView(collection: app.projects)
    @switchView(view)

  project: (id) ->
    @view.remove() if @view
    project = app.projects.get(id)
    view = new ProjectView(model: project)
    @switchView(view)

  # View management
  switchView: (view) ->
    @view.remove() if @view
    @view = view
    @view.render()
    @$appEl.html(@view.$el)
