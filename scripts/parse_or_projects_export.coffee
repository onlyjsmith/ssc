fs = require 'fs'
_ = require 'underscore'
_.str = require 'underscore.string'
async = require 'async'

Filter = require './filter'

class Start
  constructor: ->
    @countries = JSON.parse(fs.readFileSync('api/countries.json', encoding: 'utf8'))
    @projects  = JSON.parse(fs.readFileSync('api/or_projects_export.json', encoding: 'utf8'))
    @template  = fs.readFileSync('scripts/project_file_template._', encoding: 'utf8')

    processed = @processAll(@projects)
    @writeAll(processed)
    console.log("Processed #{@projects.length} projects - some of them even successfully")

  processAll: (projects) ->
    _.map projects, (project) =>
      @process(project)

  process: (project) ->
    {
      # IDs
      "project_id"        : project.project_id,
      "open_project_id"   : project.open_project_id,
      # Project description
      "project_title"     : project.project_title,
      "project_objective" : project.project_objective,
      "scale"             : @normalise_scale(project.scale),
      "host_location"     : @normalise_location(project.location),
      "region"            : @normalise('region', project.region),
      # SSC intervention
      "undp_role_type"    : @normalise_undp_role_type(project.undp_role_type),
      "thematic_focus"    : @normalise('thematic_focus', project.thematic_focus),
      "ssc_description"   : project.ssc_description,
      "territorial_focus" : project.territorial_focus,
      "partner_location"  : @normalise_partner_location(project.ssc_description),
      "partner_type"      : @normalise('partner_type', project.partner_type),
      # Links
      "project_link"      : project.project_link
    }

  writeAll: (data) ->
    _.each(data, (project) =>
      @writeEach(project)
    )

  writeEach: (project) ->
    compiled = _.template(@template)
    content = compiled(project)
    fs.writeFileSync "_ssc_data/#{project.project_id}.txt", content

  normalise: (type, text) ->
    return unless text
    new Filter(type, text).filter()

  normalise_scale: (scale) ->
    return unless scale
    scale.toLowerCase()

  normalise_location: (location) ->
    @host_location = _.map(@splitComma(location), (i) =>
      @match_country_name(i)
    )

  normalise_undp_role_type: (data) ->
    _.map(@splitComma(data), (i) ->
      _.str.underscored(i)
    )

  normalise_partner_location: (data) ->
    return unless data
    cleaned = data.split(" ").map( (i) ->
      i.replace(/\W/g, '')
    )
    partners = _.chain(cleaned)
    .map((i) => @match_exact_country_name(i))
    .compact().uniq().value()
    _.difference(partners, @host_location)

  splitComma: (data) ->
    return unless data
    data.split(',').map (i) ->
      i.replace(/^\s+|\s+$/g,"")

  justWords: (term) ->
    return unless term
    term.replace (/\(|\)/g), ""

  match_country_name: (term) ->
    re = new RegExp("^" + term,"i")
    matches = _.select(@countries, (i) ->
      i.name.match re
    )
    matches[0].iso3 if matches.length > 0

  match_exact_country_name: (term) ->
    matches = _.select(@countries, (i) ->
      re = new RegExp("^#{i.name}$","i")
      term.match re
    )
    matches[0].iso3 if matches.length > 0

s = new Start