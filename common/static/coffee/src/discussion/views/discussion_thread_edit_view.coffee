if Backbone?
  class @DiscussionThreadEditView extends Backbone.View

    events:
      "click .post-update": "update"
      "click .post-cancel": "cancel_edit"

    $: (selector) ->
      @$el.find(selector)

    initialize: (options) ->
      @form_id = options.form_id
      super()

    render: ->
      @template = _.template($("#thread-edit-template").html())
      @$el.html(@template(@model.toJSON()))
      @delegateEvents()
      @thread_type = new DiscussionThreadTypeView {
        form_id: @form_id
      }

      @addField(@thread_type.render())
      DiscussionUtil.makeWmdEditor @$el, $.proxy(@$, @), "edit-post-body"
      @

    addField: (fieldView) ->
      @$('.forum-edit-post-panel').append fieldView

    update: (event) ->
      @trigger "thread:update", event

    cancel_edit: (event) ->
      @trigger "thread:cancel_edit", event
