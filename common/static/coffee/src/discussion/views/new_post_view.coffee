if Backbone?
  class @NewPostView extends Backbone.View

      initialize: (options) ->
          @mode = options.mode or "inline"  # allowed values are "tab" or "inline"
          if @mode not in ["tab", "inline"]
              throw new Error("invalid mode: " + @mode)
          @course_settings = options.course_settings
          @topicId = options.topicId

      render: () ->
          context = _.clone(@course_settings.attributes)
          _.extend(context, {
              cohort_options: @getCohortOptions(),
              mode: @mode,
              form_id: @mode + (if @topicId then "-" + @topicId else "")
          })
          @$el.html(_.template($("#new-post-template").html(), context))

          @topic = new DiscussionTopicView {
              topicId:  @topicId
              course_settings: @course_settings
              mode: @mode
              is_cohorted: context.cohort_options
          }

          @addField(@topic.render())
          DiscussionUtil.makeWmdEditor @$el, $.proxy(@$, @), "js-post-body"

      addField: (fieldView) ->
          @$('.forum-new-post-panel').append fieldView

      getCohortOptions: () ->
          if @course_settings.get("is_cohorted") and DiscussionUtil.isStaff()
              user_cohort_id = $("#discussion-container").data("user-cohort-id")
              _.map @course_settings.get("cohorts"), (cohort) ->
                  {value: cohort.id, text: cohort.name, selected: cohort.id==user_cohort_id}
          else
              null

      events:
          "submit .forum-new-post-form": "createPost"
          "change .post-option-input": "postOptionChange"

      postOptionChange: (event) ->
          $target = $(event.target)
          $optionElem = $target.closest(".post-option")
          if $target.is(":checked")
              $optionElem.addClass("is-enabled")
          else
              $optionElem.removeClass("is-enabled")

      createPost: (event) ->
          event.preventDefault()
          thread_type = @$(".post-type-input:checked").val()
          title   = @$(".js-post-title").val()
          body    = @$(".js-post-body").find(".wmd-input").val()
          group = @topic.getSelectedTopic()

          anonymous          = false || @$(".js-anon").is(":checked")
          anonymous_to_peers = false || @$(".js-anon-peers").is(":checked")
          follow             = false || @$(".js-follow").is(":checked")

          url = DiscussionUtil.urlFor('create_thread', @topicId)

          DiscussionUtil.safeAjax
              $elem: $(event.target)
              $loading: $(event.target) if event
              url: url
              type: "POST"
              dataType: 'json'
              async: false # TODO when the rest of the stuff below is made to work properly..
              data:
                  thread_type: thread_type
                  title: title
                  body: body
                  anonymous: anonymous
                  anonymous_to_peers: anonymous_to_peers
                  auto_subscribe: follow
                  group_id: group
              error: DiscussionUtil.formErrorHandler(@$(".post-errors"))
              success: (response, textStatus) =>
                  # TODO: Move this out of the callback, this makes it feel sluggish
                  thread = new Thread response['content']
                  DiscussionUtil.clearFormErrors(@$(".post-errors"))
                  @$el.hide()
                  @$(".js-post-title").val("").attr("prev-text", "")
                  @$(".js-post-body textarea").val("").attr("prev-text", "")
                  @$(".wmd-preview p").html("") # only line not duplicated in new post inline view
                  @collection.add thread
