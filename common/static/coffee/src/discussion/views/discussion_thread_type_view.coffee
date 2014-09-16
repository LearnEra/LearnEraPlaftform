if Backbone?
  class @DiscussionThreadTypeView extends Backbone.View

      initialize: (options) ->
          @form_id = options.form_id

      render: () ->
          @template = _.template($("#thread-type-template").html())
          @$el.html(@template({form_id: @form_id}))
          return @$el

      val: () ->
          return @$(".post-type-input:checked").val()