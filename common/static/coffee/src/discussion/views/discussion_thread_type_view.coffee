if Backbone?
  class @DiscussionThreadTypeView extends Backbone.View

      initialize: (options) ->
          @form_id = options.form_id

      events:
          "click .post-option-input": "postOptionChange"

      render: () ->
          @template = _.template($("#thread-type-template").html())
          @$el.html(@template({form_id: @form_id}))
          return @$el

      postOptionChange: (event) ->
          $target = $(event.target)
          $optionElem = $target.closest(".post-option")
          if $target.is(":checked")
              $optionElem.addClass("is-enabled")
          else
              $optionElem.removeClass("is-enabled")

      val: () ->
          return @$(".post-type-input:checked").val()