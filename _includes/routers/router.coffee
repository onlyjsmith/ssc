Router = Backbone.Router.extend
  routes:
    "": "root"
    "theme/:theme": "byTheme"
    "location/:iso3": "byLocation"
    "partner/:partner_type": "byPartner"
    "role/:undp_role": "byRole"
    "project/:id": "project"
  
  root: ->
    @view.remove() if @view
    @view = new ExplorerView(collection: app.projects)

  byTheme: (theme) ->
    filtered = app.projects.filterByTheme(theme)
    @renderFilteredTable(filtered)

  byLocation: (iso3) ->
    filtered = app.projects.filterByLocation(iso3)
    @renderFilteredTable(filtered)

  byPartner: (partner_type) ->
    filtered = app.projects.filterByPartner(partner_type)
    @renderFilteredTable(filtered)

  byRole: (partner_type) ->
    filtered = app.projects.filterByRole(partner_type)
    @renderFilteredTable(filtered)

  renderFilteredTable: (filtered) ->
    @view.remove() if @view
    collection = new Projects(filtered)
    @view = new AppLayout(collection: collection)

  project: (id) ->
    @view.remove() if @view
    project = projects.get(id)
    @view = new ProjectView(model: project)
