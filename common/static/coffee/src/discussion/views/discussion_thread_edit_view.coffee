if Backbone?
  class @DiscussionThreadEditView extends Backbone.View

    events:
      "click .post-update": "update"
      "click .post-cancel": "cancel_edit"

    $: (selector) ->
      @$el.find(selector)

    initialize: (options) ->
      @mode = options.mode or "inline"
      @course_settings = options.course_settings
      @topicId = options.topicId
      super()

    render: ->
      @template = _.template($("#thread-edit-template").html())
      @$el.html(@template(@model.toJSON()))
      @delegateEvents()

      @topic = new DiscussionTopicView {
        topicId:  @topicId
        course_settings: @course_settings
        mode: @mode
      }

      @addField(@topic.render())
      DiscussionUtil.makeWmdEditor @$el, $.proxy(@$, @), "edit-post-body"
      @

    addField: (fieldView) ->
      @$('.forum-edit-post-panel').append fieldView

    update: (event) ->
      @trigger "thread:update", event

    save: (event) ->
      title = @$(".edit-post-title").val()
      body  = @$(".edit-post-body textarea").val()
      commentableId = @topic.getTopicId()
      url = DiscussionUtil.urlFor('update_thread', @model.id)

      return DiscussionUtil.safeAjax
          $elem: $(event.target)
          $loading: $(event.target) if event
          url: url
          type: "POST"
          dataType: 'json'
          async: false # TODO when the rest of the stuff below is made to work properly..
          data:
              title: title
              body: body
              commentable_id: commentableId

          error: DiscussionUtil.formErrorHandler(@$(".edit-post-form-errors"))
          success: (response, textStatus) =>
              # TODO: Move this out of the callback, this makes it feel sluggish
              @$(".edit-post-title").val("").attr("prev-text", "")
              @$(".edit-post-body textarea").val("").attr("prev-text", "")
              @$(".wmd-preview p").html("")

              @model.set
                title: title
                body: body
                commentable_id: commentableId,
                courseware_title: @topic.getFullTopicName()
              @model.unset("abbreviatedBody")

    cancel_edit: (event) ->
      @trigger "thread:cancel_edit", event
